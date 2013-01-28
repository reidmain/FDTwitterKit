#import <Accounts/Accounts.h>
#import "FDTwitterUser.h"
#import "FDTweet.h"
#import "FDTwitterList.h"


#pragma mark Type Definitions

typedef void (^FDTwitterManagerLoginCompletionBlock)(BOOL successful, NSArray *accounts);
typedef void (^FDTwitterManagerTwitterUsersCompletionBlock)(NSArray *twitterUsers);
typedef void (^FDTwitterManagerHomeTimelineCompletionBlock)(NSArray *tweets);
typedef void (^FDTwitterManagerMentionsTimelineCompletionBlock)(NSArray *tweets);
typedef void (^FDTwitterManagerFavouritesTimelineCompletionBlock)(NSArray *tweets);
typedef void (^FDTwitterManagerRetweetsTimelineCompletionBlock)(NSArray *tweets);
typedef void (^FDTwitterManagerFriendsCompletionBlock)(NSArray *twitterUsers, NSString *nextCursor);
typedef void (^FDTwitterManagerFollowersCompletionBlock)(NSArray *twitterUsers, NSString *nextCursor);
typedef void (^FDTwitterManagerOwnedListsCompletionBlock)(NSArray *lists, NSString *nextCursor);
typedef void (^FDTwitterManagerSubscribedListsCompletionBlock)(NSArray *lists, NSString *nextCursor);
typedef void (^FDTwitterManagerListTimelineCompletionBlock)(NSArray *tweets, NSString *maxTweetId);
typedef void (^FDTwitterManagerSearchCompletionBlock)(NSArray *tweets, NSString *maxTweetId);


#pragma mark - Class Interface

@interface FDTwitterManager : NSObject


#pragma mark - Properties

@property (nonatomic, readonly) BOOL loggedIn;
@property (nonatomic, readonly) ACAccount *account;
@property (nonatomic, readonly) FDTwitterUser *user;


#pragma mark - Constructors


#pragma mark - Static Methods

+ (FDTwitterManager *)sharedInstance;


#pragma mark - Instance Methods

- (void)loginWithCompletionBlock: (FDTwitterManagerLoginCompletionBlock)completionBlock;
- (void)loginWithAccount: (ACAccount *)account 
	completionBlock: (FDTwitterManagerLoginCompletionBlock)completionBlock;
- (void)logout;

- (void)userForScreenName: (NSString *)screenName 
	completionBlock:(void (^)(NSError *error, FDTwitterUser *user))completionBlock;

- (void)twitterUsersForUserIds: (NSArray *)userIds 
	account: (ACAccount *)account 
	completionBlock: (FDTwitterManagerTwitterUsersCompletionBlock)completionBlock;

- (void)homeTimelineWithCompletionBlock: (FDTwitterManagerHomeTimelineCompletionBlock)completionBlock;

- (void)mentionsTimelineWithCompletionBlock: (FDTwitterManagerMentionsTimelineCompletionBlock)completionBlock;

- (void)favouritesTimelineWithCompletionBlock: (FDTwitterManagerFavouritesTimelineCompletionBlock)completionBlock;

- (void)retweetsTimelineWithCompletionBlock: (FDTwitterManagerRetweetsTimelineCompletionBlock)completionBlock;

- (void)friendsForUserId: (NSString *)userId 
	cursor: (NSString *)cursor 
	completionBlock: (FDTwitterManagerFriendsCompletionBlock)completionBlock;

- (void)followersForUserId: (NSString *)userId 
	cursor: (NSString *)cursor 
	completionBlock: (FDTwitterManagerFollowersCompletionBlock)completionBlock;

- (void)ownedListsForUserId: (NSString *)userId 
	cursor: (NSString *)cursor 
	completionBlock: (FDTwitterManagerOwnedListsCompletionBlock)completionBlock;

- (void)tweetsForListId: (NSString *)listId 
	count: (unsigned int)count 
	maxTweetId: (NSString *)maxTweetId 
	completionBlock: (FDTwitterManagerListTimelineCompletionBlock)completionBlock;

- (void)subscribedListsForUserId: (NSString *)userId 
	cursor: (NSString *)cursor 
	completionBlock: (FDTwitterManagerSubscribedListsCompletionBlock)completionBlock;

- (void)tweetsForSearchQuery: (NSString *)query 
	count: (unsigned int)count 
	maxTweetId: (NSString *)maxTweetId 
	completionBlock: (FDTwitterManagerSearchCompletionBlock)completionBlock;


@end