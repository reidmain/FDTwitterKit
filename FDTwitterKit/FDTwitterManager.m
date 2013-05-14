#import "FDTwitterManager.h"
#import "FDTwitterAPIClient.h"
#import <Social/Social.h>
#import "FDNullOrEmpty.h"
#import "NSObject+PerformBlock.h"
#import "NSUserDefaults+Accessing.h"


#pragma mark Constants

static NSString * const UserDefaultsKey_TwitterAccountIdentifier = @"twitter_account_identifier";
static NSString * const UserDefaultsKey_TwitterUser	= @"twitter_user";


#pragma mark - Class Extension

@interface FDTwitterManager ()

- (void)_setTwitterAccountIdentifier: (NSString *)twitterAccountIdentifier;
- (void)_setTwitterUser: (FDTwitterUser *)twitterUser;

@end


#pragma mark - Class Variables

static FDTwitterManager *_sharedInstance;


#pragma mark - Class Definition

@implementation FDTwitterManager
{
	@private __strong ACAccountStore *_twitterAccountStore;
	@private __strong ACAccountType *_twitterAccountType;
	@private __strong NSString *_twitterAccountIdentifier;
	@private __strong FDTwitterAPIClient *_twitterAPIClient;
}


#pragma mark - Properties

- (BOOL)loggedIn
{
	BOOL loggedIn = NO;
	
	if ([_twitterAccountType accessGranted] == YES 
		&& self.account != nil)
	{
		loggedIn = YES;
	}
	
	return loggedIn;
}

- (ACAccount *)account
{
	ACAccount *twitterAccount = [_twitterAccountStore accountWithIdentifier: _twitterAccountIdentifier];
	
	return twitterAccount;
}


#pragma mark - Constructors

+ (void)initialize
{
	// NOTE: initialize is called in a thead-safe manner so we don't need to worry about two shared instances possibly being created.
	
	// Create a flag to keep track of whether or not this class has been initialized because this method could be called a second time if a subclass does not override it.
	static BOOL classInitialized = NO;
	
	// If this class has not been initialized then create the shared instance.
	if (classInitialized == NO)
	{
		_sharedInstance = [[FDTwitterManager alloc] 
			init];
		
		classInitialized = YES;
	}
}

+ (id)allocWithZone: (NSZone *)zone
{
	// Because we are creating the shared instance in the +initialize method we can check if it exists here to know if we should alloc an instance of the class.
	if (_sharedInstance == nil)
	{
		return [super allocWithZone: zone];
	}
	else
	{
	    return [self sharedInstance];
	}
}

- (id)init
{
	// Abort if base initializer fails.
	if ((self = [super init]) == nil)
	{
		return nil;
	}
	
	// Initialize instance variables.
	_twitterAccountStore = [[ACAccountStore alloc] init];
	_twitterAccountType = [_twitterAccountStore accountTypeWithAccountTypeIdentifier: ACAccountTypeIdentifierTwitter];
	
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	_twitterAccountIdentifier = [userDefaults stringForKey: UserDefaultsKey_TwitterAccountIdentifier];
	
	_user = [userDefaults unarchivedObjectForKey: UserDefaultsKey_TwitterUser];
	
	_twitterAPIClient = [[FDTwitterAPIClient alloc] 
		init];
	
	// Return initialized instance.
	return self;
}


#pragma mark - Public Methods

+ (FDTwitterManager *)sharedInstance
{
	return _sharedInstance;
}

- (void)loginWithCompletionBlock: (FDTwitterManagerLoginCompletionBlock)completionBlock
{
	// If a tweet is not able to be sent display an alert to the user.
	if ([SLComposeViewController isAvailableForServiceType: SLServiceTypeTwitter] == NO)
	{
		// If a SLComposeViewController is presented with all of its subviews removed when the user cannot tweet a alert view will be displayed with a button that will take users directly to Settings so they can setup a Twitter account.
        SLComposeViewController *composeTweetController = [SLComposeViewController composeViewControllerForServiceType: SLServiceTypeTwitter];
		
		composeTweetController.completionHandler = ^(SLComposeViewControllerResult result)
			{
				completionBlock(NO, nil);
			};
		
		[composeTweetController.view.subviews makeObjectsPerformSelector: @selector(removeFromSuperview)];
        
        [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController: composeTweetController 
			animated: NO 
			completion: nil];
	}
	// If the user is already logged in succeed automatically.
	else if (self.loggedIn == YES)
	{
		completionBlock(YES, nil);
	}
	// Otherwise, request access to the user's Twitter accounts.
	else
	{
		[_twitterAccountStore requestAccessToAccountsWithType: _twitterAccountType 
			options: nil 
			completion: ^(BOOL granted, NSError *error)
				{
					NSArray *twitterAccounts = [_twitterAccountStore accountsWithAccountType: _twitterAccountType];
					
					// NOTE: The completion handler is called on an arbitrary queue. Unsure the completion
					[self performBlockOnMainThread:^
						{
							// If the user has granted permission to access the Twitter accounts automatically log the user in if there is only a single account.
							if (granted == YES && [twitterAccounts count] == 1)
							{
								ACAccount *twitterAccount = [twitterAccounts lastObject];
								
								[self loginWithAccount: twitterAccount 
									completionBlock: completionBlock];
							}
							else
							{
								completionBlock(NO, twitterAccounts);
							}
						}];
				}];
	}
}

- (void)loginWithAccount: (ACAccount *)account 
	completionBlock: (FDTwitterManagerLoginCompletionBlock)completionBlock;
{
	// Save the account identifier so the account can be retrieved in the future.
	[self _setTwitterAccountIdentifier: account.identifier];
	
	// Load information for the Twitter user that was logged in.
	[self userForScreenName: account.username 
		completionBlock: ^(NSError *error, FDTwitterUser *user)
		{
			if (error == nil 
				&& [_twitterAccountIdentifier isEqualToString: account.identifier] == YES)
			{
				[self _setTwitterUser: user];
			}
			
			if (completionBlock != nil)
				completionBlock(error == nil, nil);
		}];
}

- (void)logout
{
	[self _setTwitterAccountIdentifier: nil];
}

- (void)userForScreenName: (NSString *)screenName 
	completionBlock:(void (^)(NSError *error, FDTwitterUser *user))completionBlock
{
	[_twitterAPIClient userForScreenName: screenName 
		account: self.account 
		completionBlock:^(FDURLResponseStatus status, NSError *error, FDTwitterUser *user)
		{
			completionBlock(error, user);
		}];
}

- (void)twitterUsersForUserIds: (NSArray *)userIds 
	account: (ACAccount *)account 
	completionBlock: (FDTwitterManagerTwitterUsersCompletionBlock)completionBlock;
{
	[_twitterAPIClient twitterUsersForIds: userIds 
		account: self.account 
		completionBlock:^(FDURLResponseStatus status, NSError *error, NSArray *twitterUsers)
			{
				completionBlock(twitterUsers);
			}];
}

- (void)homeTimelineWithCompletionBlock: (FDTwitterManagerHomeTimelineCompletionBlock)completionBlock
{
	[_twitterAPIClient homeTimelineForAccount: self.account 
		completionBlock: ^(FDURLResponseStatus status, NSError *error, NSArray *tweets)
			{
				completionBlock(tweets);
			}];
}

- (void)mentionsTimelineWithCompletionBlock: (FDTwitterManagerMentionsTimelineCompletionBlock)completionBlock
{
	[_twitterAPIClient mentionsTimelineForAccount: self.account 
		completionBlock: ^(FDURLResponseStatus status, NSError *error, NSArray *tweets)
			{
				completionBlock(tweets);
			}];
}

- (void)favouritesTimelineWithCompletionBlock: (FDTwitterManagerFavouritesTimelineCompletionBlock)completionBlock
{
	[_twitterAPIClient favouriteTweetsForAccount: self.account 
		completionBlock: ^(FDURLResponseStatus status, NSError *error, NSArray *tweets)
			{
				completionBlock(tweets);
			}];
}

- (void)retweetsTimelineWithCompletionBlock: (FDTwitterManagerRetweetsTimelineCompletionBlock)completionBlock
{
	[_twitterAPIClient retweetsForAccount: self.account 
		completionBlock: ^(FDURLResponseStatus status, NSError *error, NSArray *tweets)
			{
				completionBlock(tweets);
			}];
}

- (void)friendsForUserId: (NSString *)userId 
	cursor: (NSString *)cursor 
	completionBlock: (FDTwitterManagerFriendsCompletionBlock)completionBlock
{
	[_twitterAPIClient friendsForUserId: userId 
		cursor: cursor 
		count: 100 
		account: self.account 
		completionBlock: ^(FDURLResponseStatus status, NSError *error, NSArray *userIds, NSString *nextCursor)
			{
				// If there are no user ids then there is nothing to do so just call the completion block.
				if (FDIsEmpty(userIds) == YES)
				{
					completionBlock(nil, nil);
				}
				// Otherwise load the fully-hydrated Twitter user objects
				else
				{
					[self twitterUsersForUserIds: userIds 
						account: self.account 
						completionBlock:^(NSArray *twitterUsers)
						{
							// Create a dictionary where the key is the user's id so it is quick to find a user by their id.
							NSMutableDictionary *twitterUsersById = [NSMutableDictionary dictionaryWithCapacity: [twitterUsers count]];
							[twitterUsers enumerateObjectsUsingBlock: ^(FDTwitterUser *twitterUser, NSUInteger index, BOOL *stop)
								{
									[twitterUsersById setObject: twitterUser 
										forKey: twitterUser.userId];
								}];
							
							// Create a sorted array of Twitter users based on the order of the ids.
							NSMutableArray *sortedTwitterUsers = [NSMutableArray arrayWithCapacity: [twitterUsers count]];
							[userIds enumerateObjectsUsingBlock: ^(id userId, NSUInteger index, BOOL *stop)
								{
									FDTwitterUser *twitterUser = [twitterUsersById objectForKey: userId];
									if (FDIsEmpty(twitterUser) == NO)
									{
										[sortedTwitterUsers addObject: twitterUser];
									}
								}];
							
							completionBlock(sortedTwitterUsers, nextCursor);
						}];
				}
			}];
}

- (void)followersForUserId: (NSString *)userId 
	cursor: (NSString *)cursor 
	completionBlock: (FDTwitterManagerFollowersCompletionBlock)completionBlock
{
	[_twitterAPIClient followersForUserId: userId 
		cursor: cursor 
		count: 100 
		account: self.account 
		completionBlock: ^(FDURLResponseStatus status, NSError *error, NSArray *userIds, NSString *nextCursor)
			{
				// If there are no userIds then there is nothing to do so just call the completion block.
				if (FDIsEmpty(userIds) == YES)
				{
					completionBlock(nil, nil);
				}
				// Otherwise load the fully-hydrated Twitter user objects
				else
				{
					[self twitterUsersForUserIds: userIds 
						account: self.account 
						completionBlock:^(NSArray *twitterUsers)
						{
							completionBlock(twitterUsers, nextCursor);	
						}];
				}
			}];
}

- (void)ownedListsForUserId: (NSString *)userId 
	cursor: (NSString *)cursor 
	completionBlock: (FDTwitterManagerOwnedListsCompletionBlock)completionBlock
{
	[_twitterAPIClient ownedListsForUserId: userId 
		cursor: cursor 
		count: 1000 
		account: self.account 
		completionBlock: ^(FDURLResponseStatus status, NSError *error, NSArray *lists, NSString *nextCursor)
			{
				completionBlock(lists, nextCursor);
			}];
}

- (void)subscribedListsForUserId: (NSString *)userId 
	cursor: (NSString *)cursor 
	completionBlock: (FDTwitterManagerSubscribedListsCompletionBlock)completionBlock
{
	[_twitterAPIClient subscribedListsForUserId: userId 
		cursor: cursor 
		count: 1000 
		account: self.account 
		completionBlock: ^(FDURLResponseStatus status, NSError *error, NSArray *lists, NSString *nextCursor)
			{
				completionBlock(lists, nextCursor);
			}];
}

- (void)tweetsForListId: (NSString *)listId 
	count: (unsigned int)count 
	maxTweetId: (NSString *)maxTweetId 
	completionBlock: (FDTwitterManagerListTimelineCompletionBlock)completionBlock
{
	[_twitterAPIClient tweetsForListId: listId 
		count: count 
		maxTweetId: maxTweetId 
		account: self.account 
		completionBlock: ^(FDURLResponseStatus status, NSError *error, NSArray *tweets)
			{
				completionBlock(tweets, maxTweetId);
			}];
}

- (void)tweetsForSearchQuery: (NSString *)query 
	count: (unsigned int)count 
	maxTweetId: (NSString *)maxTweetId 
	completionBlock: (FDTwitterManagerSearchCompletionBlock)completionBlock
{
	[_twitterAPIClient tweetsForSearchQuery: query 
		count: count 
		maxTweetId: maxTweetId 
		account: self.account 
		completionBlock:^(FDURLResponseStatus status, NSError *error, NSArray *tweets, NSString *maxTweetId)
		{
			completionBlock(tweets, maxTweetId);
		}];
}


#pragma mark - Overridden Methods

- (id)copyWithZone: (NSZone *)zone
{
	return self;
}


#pragma mark - Private Methods

- (void)_setTwitterAccountIdentifier: (NSString *)twitterAccountIdentifier
{
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	
	if (FDIsEmpty(twitterAccountIdentifier) == YES)
	{
		_twitterAccountIdentifier = nil;
		
		[userDefaults removeObjectForKey: UserDefaultsKey_TwitterAccountIdentifier];
	}
	else
	{
		_twitterAccountIdentifier = twitterAccountIdentifier;
		
		[userDefaults setObject: _twitterAccountIdentifier 
			forKey: UserDefaultsKey_TwitterAccountIdentifier];
	}
	
	[userDefaults synchronize];
}

- (void)_setTwitterUser: (FDTwitterUser *)twitterUser
{
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	
	if (twitterUser == nil)
	{
		_user = nil;
		
		[userDefaults removeObjectForKey: UserDefaultsKey_TwitterUser];
	}
	else
	{
		_user = twitterUser;
		
		[userDefaults archiveAndSetObject: twitterUser 
			forKey: UserDefaultsKey_TwitterUser];
	}
	
	[userDefaults synchronize];
}


@end