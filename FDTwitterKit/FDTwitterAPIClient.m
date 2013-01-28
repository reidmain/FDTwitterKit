#import "FDTwitterAPIClient.h"
#import <Social/Social.h>
#import "NSDictionary+Accessing.h"


#pragma mark Class Extension

@interface FDTwitterAPIClient ()

- (NSURL *)_resourceURLForMethodName: (NSString *)methodName;

- (void)_setMaxTweetId: (NSString *)maxTweetId 
	forParameters: (NSMutableDictionary *)parameters;

- (void)_loadRequest: (SLRequest *)request 
	transformBlock: (FDURLConnectionTransformBlock)transformBlock 
	completionBlock: (FDURLConnectionOperationCompletionBlock)completionBlock;

- (FDTwitterUser *)_twitterUserFromJSONObject: (NSDictionary *)jsonObject;
- (FDTweet *)_tweetFromJSONObject: (NSDictionary *)jsonObject;
- (FDTwitterList *)_twitterListFromJSONObject: (NSDictionary *)jsonObject;

- (NSArray *)_twitterUsersFromJSONObject: (NSArray *)jsonObject;
- (NSArray *)_tweetsFromJSONObject: (NSArray *)jsonObject;
- (NSArray *)_twitterListsFromJSONObject: (NSArray *)jsonObject;

@end


#pragma mark - Class Variables

static NSDateFormatter *_apiDateFormatter;


#pragma mark - Class Definition

@implementation FDTwitterAPIClient


#pragma mark - Constructors

+ (void)initialize
{
	// NOTE: initialize is called in a thead-safe manner so we don't need to worry about two shared instances possibly being created.
	
	// Create a flag to keep track of whether or not this class has been initialized because this method could be called a second time if a subclass does not override it.
	static BOOL classInitialized = NO;
	
	// If this class has not been initialized then create the shared instance.
	if (classInitialized == NO)
	{
		_apiDateFormatter = [[NSDateFormatter alloc] 
			init];
		[_apiDateFormatter setDateFormat: @"EEE MMM dd HH:mm:ss Z yyyy"];
		
		classInitialized = YES;
	}
}


#pragma mark - Public Methods

- (void)userForScreenName: (NSString *)screenName 
	account: (ACAccount *)account 
	completionBlock:(void (^)(FDURLResponseStatus status, NSError *error, FDTwitterUser *user))completionBlock
{
	// Create resource URL for user show request.
	NSURL *resourceURL = [self _resourceURLForMethodName: @"users/show"];
	
	// Create paramters for user show request.
	NSDictionary *parameters = @{ @"screen_name" : screenName };
	
	// Create user show request.
	SLRequest *request = [SLRequest requestForServiceType: SLServiceTypeTwitter 
		requestMethod: SLRequestMethodGET 
		URL: resourceURL 
		parameters: parameters];
	
	request.account = account;
	
	// Load user show request.
	[self _loadRequest: request 
		transformBlock: ^id(id jsonObject)
			{
				// Transform user into local entity.
				FDTwitterUser *twitterUser = [self _twitterUserFromJSONObject: jsonObject];
				
				return twitterUser;
			} 
		completionBlock: ^(FDURLResponse *response)
			{
				completionBlock(response.status, response.error, response.content);
			}];
}

- (void)twitterUsersForIds: (NSArray *)userIds 
	account: (ACAccount *)account 
	completionBlock: (FDTwitterAPIClientTwitterUsersCompletionBlock)completionBlock
{
	// Create resource URL for user lookup request.
	NSURL *resourceURL = [self _resourceURLForMethodName: @"users/lookup"];
	
	// Create parameters for user lookup request.
	NSDictionary *parameters = @{ @"user_id" : [userIds componentsJoinedByString:@","] };
	
	// Create user lookup request.
	SLRequest *request = [SLRequest requestForServiceType: SLServiceTypeTwitter 
		requestMethod: SLRequestMethodGET 
		URL: resourceURL 
		parameters: parameters];
	
	request.account = account;
	
	// Load user lookup request.
	[self _loadRequest: request 
		transformBlock: ^id(id jsonObject)
			{
				// Transform users into local entities.
				NSArray *users = [self _twitterUsersFromJSONObject: jsonObject];
				
				return users;
			} 
		completionBlock: ^(FDURLResponse *response)
			{
				completionBlock(response.status, response.error, response.content);
			}];
}

- (void)profileImageForScreenName: (NSString *)screenName 
	account: (ACAccount *)account 
	completion: (void (^)(FDURLResponseStatus status, NSError *error, UIImage *profileImage, NSURL *profileImageURL))completion
{
	// Create resource URL for profile image request.
	NSString *methodName = [NSString stringWithFormat: @"users/profile_image/%@", 
		screenName];
	
	NSURL *resourceURL = [self _resourceURLForMethodName: methodName];
	
	// Create parameters for profile image request.
	NSDictionary *parameters = [[NSDictionary alloc] 
		initWithObjectsAndKeys: 
			@"original", 
			@"size", 
			nil];
	
	// Create profile image request.
	SLRequest *request = [SLRequest requestForServiceType: SLServiceTypeTwitter 
		requestMethod: SLRequestMethodGET 
		URL: resourceURL 
		parameters: parameters];
	
	request.account = account;
	
	// Load profile image request.
	[self loadURLRequest: [request preparedURLRequest] 
		urlRequestType: FDURLRequestTypeImage 
		authorizationBlock: nil 
		progressBlock: nil 
		dataParserBlock: nil 
		transformBlock: nil 
		completionBlock: ^(FDURLResponse *response)
		{
			if (response.status == FDURLResponseStatusSucceed)
			{
				completion(response.status, nil, response.content, [response.rawURLResponse URL]);
			}
			else
			{
				completion(response.status, response.error, nil, nil);
			}
		}];
}

- (void)homeTimelineForAccount: (ACAccount *)account 
	completionBlock: (FDTwitterAPIClientHomeTimelineCompletionBlock)completionBlock
{
	// Create resource URL for home timeline request.
	NSURL *resourceURL = [self _resourceURLForMethodName: @"statuses/home_timeline"];
	
	// Create parameters for home timeline request.
	NSDictionary *parameters = @{ @"count" : @"200" };
	
	// Create home timeline request.
	SLRequest *request = [SLRequest requestForServiceType: SLServiceTypeTwitter 
		requestMethod: SLRequestMethodGET 
		URL: resourceURL 
		parameters: parameters];
	
	request.account = account;
	
	// Load home timeline request.
	[self _loadRequest: request 
		transformBlock: ^id(id jsonObject)
			{
				// Transform tweets into local entities.
				NSArray *tweets = [self _tweetsFromJSONObject: jsonObject];
				
				return tweets;
			} 
		completionBlock: ^(FDURLResponse *response)
			{
				completionBlock(response.status, response.error, response.content);
			}];
}

- (void)mentionsTimelineForAccount: (ACAccount *)account 
	completionBlock: (FDTwitterAPIClientMentionsTimelineCompletionBlock)completionBlock
{
	// Create resource URL for mentions timeline request.
	NSURL *resourceURL = [self _resourceURLForMethodName: @"statuses/mentions_timeline"];
	
	// Create parameters for mentions timeline request.
	NSDictionary *parameters = @{ @"count" : @"200" };
	
	// Create mentions timeline request.
	SLRequest *request = [SLRequest requestForServiceType: SLServiceTypeTwitter 
		requestMethod: SLRequestMethodGET 
		URL: resourceURL 
		parameters: parameters];
	
	request.account = account;
	
	// Load mentions timeline request.
	[self _loadRequest: request 
		transformBlock: ^id(id jsonObject)
			{
				// Transform tweets into local entities.
				NSArray *tweets = [self _tweetsFromJSONObject: jsonObject];
				
				return tweets;
			} 
		completionBlock: ^(FDURLResponse *response)
			{
				completionBlock(response.status, response.error, response.content);
			}];
}

- (void)favouriteTweetsForAccount: (ACAccount *)account 
	completionBlock: (FDTwitterAPIClientFavouriteTweetsCompletionBlock)completionBlock
{
	// Create resource URL for favourites timeline request.
	NSURL *resourceURL = [self _resourceURLForMethodName: @"favorites/list"];
	
	// Create parameters for favourites timeline request.
	NSDictionary *parameters = @{ @"count" : @"200" };
	
	// Create favourites timeline request.
	SLRequest *request = [SLRequest requestForServiceType: SLServiceTypeTwitter 
		requestMethod: SLRequestMethodGET 
		URL: resourceURL 
		parameters: parameters];
	
	request.account = account;
	
	// Load favourites timeline request.
	[self _loadRequest: request 
		transformBlock: ^id(id jsonObject)
			{
				// Transform tweets into local entities.
				NSArray *tweets = [self _tweetsFromJSONObject: jsonObject];
				
				return tweets;
			} 
		completionBlock: ^(FDURLResponse *response)
			{
				completionBlock(response.status, response.error, response.content);
			}];
}

- (void)retweetsForAccount: (ACAccount *)account 
	completionBlock: (FDTwitterAPIClientRetweetsCompletionBlock)completionBlock
{
	// Create resource URL for retweets timeline request.
	NSURL *resourceURL = [self _resourceURLForMethodName: @"statuses/retweets_of_me"];
	
	// Create parameters for retweets timeline request.
	NSDictionary *parameters = @{ @"count" : @"100" };
	
	// Create retweets timeline request.
	SLRequest *request = [SLRequest requestForServiceType: SLServiceTypeTwitter 
		requestMethod: SLRequestMethodGET 
		URL: resourceURL 
		parameters: parameters];
	
	request.account = account;
	
	// Load retweets timeline request.
	[self _loadRequest: request 
		transformBlock: ^id(id jsonObject)
			{
				// Transform tweets into local entities.
				NSArray *tweets = [self _tweetsFromJSONObject: jsonObject];
				
				return tweets;
			} 
		completionBlock: ^(FDURLResponse *response)
			{
				completionBlock(response.status, response.error, response.content);
			}];
}

- (void)friendsForUserId: (NSString *)userId 
	cursor: (NSString *)cursor 
	count: (unsigned int)count 
	account: (ACAccount *)account 
	completionBlock: (FDTwitterAPIClientFriendsCompletionBlock)completionBlock
{
	// Create resource URL for friends request.
	NSURL *resourceURL =  [self _resourceURLForMethodName: @"friends/ids"];
	
	// Create parameters for friends request.
	NSDictionary *parameters = @{ 
		@"stringify_ids" : @"true", 
		@"user_id" : userId, 
		@"cursor" : (FDIsEmpty(cursor) == YES) ? @"-1" : cursor, 
		@"count" : [NSString stringWithFormat: @"%u", count] };
	
	// Create friends request.
	SLRequest *request = [SLRequest requestForServiceType: SLServiceTypeTwitter 
		requestMethod: SLRequestMethodGET 
		URL: resourceURL 
		parameters: parameters];
	
	request.account = account;
	
	// Load friends request.
	[self _loadRequest: request 
		transformBlock: ^id(id jsonObject)
		{
			NSArray *userIds = [jsonObject objectForKey: @"ids"];
			NSNumber *nextCursor = [jsonObject objectForKey: @"next_cursor"];
			
			NSDictionary *transformResult = @{ 
				@"userIds" : userIds, 
				@"nextCursor" : [nextCursor stringValue] };
			
			return transformResult;
		} 
		completionBlock: ^(FDURLResponse *urlResponse)
		{
			if (urlResponse.status == FDURLResponseStatusSucceed)
			{
				NSArray *userIds = [urlResponse.content objectForKey: @"userIds"];
				NSString *nextCursor = [urlResponse.content objectForKey: @"nextCursor"];
				
				completionBlock(urlResponse.status, nil, userIds, nextCursor);
			}
			else
			{
				completionBlock(urlResponse.status, urlResponse.error, nil, nil);
			}
		}];
}

- (void)followersForUserId: (NSString *)userId 
	cursor: (NSString *)cursor 
	count: (unsigned int)count 
	account: (ACAccount *)account 
	completionBlock: (FDTwitterAPIClientFollowersCompletionBlock)completionBlock
{
	// Create resource URL for followers request.
	NSURL *resouceURL = [self _resourceURLForMethodName: @"followers/ids"];
	
	// Create parameters for followers request.
	NSDictionary *parameters = @{ 
		@"stringify_ids" : @"true", 
		@"user_id" : userId, 
		@"cursor" : (FDIsEmpty(cursor) == YES) ? @"-1" : cursor, 
		@"count" : [NSString stringWithFormat:@"%u", count] };
	
	// Create followers request.
	SLRequest *request = [SLRequest requestForServiceType: SLServiceTypeTwitter 
		requestMethod: SLRequestMethodGET 
		URL: resouceURL 
		parameters: parameters];
	
	request.account = account;
	
	// Load followers request.
	[self _loadRequest: request 
		transformBlock: ^id(id jsonObject)
		{
			NSArray *userIds = [jsonObject objectForKey: @"ids"];
			NSNumber *nextCursor = [jsonObject objectForKey: @"next_cursor"];
			
			NSDictionary *transformResult = @{ 
				@"userIds" : userIds, 
				@"nextCursor" : [nextCursor stringValue] };
			
			return transformResult;
		} 
		completionBlock: ^(FDURLResponse *urlResponse)
		{
			if (urlResponse.status == FDURLResponseStatusSucceed)
			{
				NSArray *userIds = [urlResponse.content objectForKey: @"userIds"];
				NSString *nextCursor = [urlResponse.content objectForKey: @"nextCursor"];
				
				completionBlock(urlResponse.status, nil, userIds, nextCursor);
			}
			else
			{
				completionBlock(urlResponse.status, urlResponse.error, nil, nil);
			}
		}];
}

- (void)ownedListsForUserId: (NSString *)userId 
	cursor: (NSString *)cursor 
	count: (unsigned int)count 
	account: (ACAccount *)account 
	completionBlock: (FDTwitterAPIClientOwnedListsCompletionBlock)completionBlock
{
	// Create resource URL for owned lists request.
	NSURL *resourceURL = [self _resourceURLForMethodName: @"lists/ownerships"];
	
	// Create parameters for owned lists request.
	NSDictionary *parameters = @{ 
		@"user_id" : userId, 
		@"cursor" : (FDIsEmpty(cursor) == YES) ? @"-1" : cursor, 
		@"count" : [NSString stringWithFormat:@"%u", count] };
	
	// Create owned lists request.
	SLRequest *request = [SLRequest requestForServiceType: SLServiceTypeTwitter 
		requestMethod: SLRequestMethodGET 
		URL: resourceURL 
		parameters: parameters];
	
	request.account = account;
	
	// Load owned list request.
	[self _loadRequest: request 
		transformBlock: ^id(id jsonObject)
		{
			// Transform lists into local entities.
			NSArray *jsonLists = [jsonObject objectForKey: @"lists"];
			NSArray *lists = [self _twitterListsFromJSONObject: jsonLists];
			
			NSNumber *nextCursor = [jsonObject objectForKey: @"next_cursor"];
			
			NSDictionary *transformResult = @{ 
				@"lists" : lists, 
				@"nextCursor" : [nextCursor stringValue] };
			
			return transformResult;
		} 
		completionBlock: ^(FDURLResponse *response)
		{
			if (response.status == FDURLResponseStatusSucceed)
			{
				NSArray *lists = [response.content objectForKey: @"lists"];
				NSString *nextCursor = [response.content objectForKey: @"nextCursor"];
				
				completionBlock(response.status, nil, lists, nextCursor);
			}
			else
			{
				completionBlock(response.status, response.error, nil, nil);
			}
		}];
}

- (void)subscribedListsForUserId: (NSString *)userId 
	cursor: (NSString *)cursor 
	count: (unsigned int)count 
	account: (ACAccount *)account 
	completionBlock: (FDTwitterAPIClientSubscribedListsCompletionBlock)completionBlock
{
	// Create resource URL for subscribed lists request.
	NSURL *resourceURL = [self _resourceURLForMethodName: @"lists/subscriptions"];
	
	// Create parameters for subscribed lists request.
	NSDictionary *parameters = @{ 
		@"user_id" : userId, 
		@"cursor" : (FDIsEmpty(cursor) == YES) ? @"-1" : cursor, 
		@"count" : [NSString stringWithFormat:@"%u", count] };
	
	// Create subscribed lists request.
	SLRequest *request = [SLRequest requestForServiceType: SLServiceTypeTwitter 
		requestMethod: SLRequestMethodGET 
		URL: resourceURL 
		parameters: parameters];
	
	request.account = account;
	
	// Load subscribed list request.
	[self _loadRequest: request 
		transformBlock: ^id(id jsonObject)
		{
			// Transform lists into local entities.
			NSArray *jsonLists = [jsonObject objectForKey: @"lists"];
			NSArray *lists = [self _twitterListsFromJSONObject: jsonLists];
			
			NSNumber *nextCursor = [jsonObject objectForKey: @"next_cursor"];
			
			NSDictionary *transformResult = @{ 
				@"lists" : lists, 
				@"nextCursor" : [nextCursor stringValue] };
			
			return transformResult;
		} 
		completionBlock: ^(FDURLResponse *response)
		{
			if (response.status == FDURLResponseStatusSucceed)
			{
				NSArray *lists = [response.content objectForKey: @"lists"];
				NSString *nextCursor = [response.content objectForKey: @"nextCursor"];
				
				completionBlock(response.status, nil, lists, nextCursor);
			}
			else
			{
				completionBlock(response.status, response.error, nil, nil);
			}
		}];
}

- (void)tweetsForListId: (NSString *)listId 
	count: (unsigned int)count 
	maxTweetId: (NSString *)maxTweetId 
	account: (ACAccount *)account 
	completionBlock: (FDTwitterAPIClientListTimelineCompletionBlock)completionBlock
{
	// Create resource URL for list's statuses request.
	NSURL *resourceURL = [self _resourceURLForMethodName: @"lists/statuses"];
	
	// Create parameters for list's statuses request.
	NSMutableDictionary *parameters = [[NSMutableDictionary alloc] 
		initWithObjectsAndKeys: 
			listId, @"list_id", 
			[NSString stringWithFormat:@"%u", count], @"count", 
			nil];
	
	[self _setMaxTweetId: maxTweetId 
		forParameters: parameters];
	
	// Create list's statuses request.
	SLRequest *request = [SLRequest requestForServiceType: SLServiceTypeTwitter 
		requestMethod: SLRequestMethodGET 
		URL: resourceURL 
		parameters: parameters];
	
	request.account = account;
	
	// Load list's statuses request
	[self _loadRequest: request 
		transformBlock: ^id(id jsonObject)
		{
			// Transform tweets into local entities.
			NSArray *tweets = [self _tweetsFromJSONObject: jsonObject];
			
			return tweets;
		} 
		completionBlock: ^(FDURLResponse *response)
		{
			if (response.status == FDURLResponseStatusSucceed)
			{
				completionBlock(response.status, nil, response.content);
			}
			else
			{
				completionBlock(response.status, response.error, nil);
			}
		}];
}

- (void)tweetsForSearchQuery: (NSString *)query 
	count: (unsigned int)count 
	maxTweetId: (NSString *)maxTweetId 
	account: (ACAccount *)account 
	completionBlock: (FDTwitterAPIClientSearchCompletionBlock)completionBlock
{
	// Create resource URL for search request.
	NSURL *resourceURL = [self _resourceURLForMethodName: @"search/tweets"];
	
	// Create paramters for search request.
	NSMutableDictionary *parameters = [[NSMutableDictionary alloc] 
		initWithObjectsAndKeys: 
			query, @"q", 
			[NSString stringWithFormat:@"%u", count], @"count", 
			nil];
	
	[self _setMaxTweetId: maxTweetId 
		forParameters: parameters];
	
	// Create search request.
	SLRequest *request = [SLRequest requestForServiceType: SLServiceTypeTwitter 
		requestMethod: SLRequestMethodGET 
		URL: resourceURL 
		parameters: parameters];
	
	request.account = account;
	
	// Load search request.
	[self _loadRequest: request 
		transformBlock: ^id(id jsonObject)
		{
			// Transform tweets into local entities.
			NSArray *jsonTweets = [jsonObject objectForKey: @"statuses"];
			NSArray *tweets = [self _tweetsFromJSONObject: jsonTweets];
			
			NSDictionary *searchMetadata = [jsonObject objectForKey: @"search_metadata"];
			NSString *maxTweetId = [searchMetadata objectForKey: @"max_id_str"];
			
			NSDictionary *transformResult = @{ 
				@"tweets" : tweets, 
				@"maxTweetId" : maxTweetId };
			
			return transformResult;
		} 
		completionBlock: ^(FDURLResponse *response)
		{
			if (response.status == FDURLResponseStatusSucceed)
			{
				NSArray *tweets = [response.content objectForKey: @"tweets"];
				NSString *maxTweetId = [response.content objectForKey: @"maxTweetId"];
				
				completionBlock(response.status, nil, tweets, maxTweetId);
			}
			else
			{
				completionBlock(response.status, response.error, nil, nil);
			}
		}];
}


#pragma mark -
#pragma mark Overridden Methods


#pragma mark - Private Methods

- (NSURL *)_resourceURLForMethodName: (NSString *)methodName
{
	NSString *resourceURLAsString = [NSString stringWithFormat: @"https://api.twitter.com/1.1/%@.json", 
		methodName];
	
	NSURL *resourceURL = [NSURL URLWithString: resourceURLAsString];
	
	return resourceURL;
}

- (void)_setMaxTweetId: (NSString *)maxTweetId 
	forParameters: (NSMutableDictionary *)parameters
{
	if (FDIsEmpty(maxTweetId) == NO)
	{
		// Subtract one from the tweet id so that it cannot be included in the results of the request.
		long long lowerMaxTweetId = [maxTweetId longLongValue] - 1;
		
		[parameters setObject: [NSString stringWithFormat: @"%lld", lowerMaxTweetId]  
			forKey: @"max_id"];
	}
}

- (void)_loadRequest: (SLRequest *)request 
	transformBlock: (FDURLConnectionTransformBlock)transformBlock 
	completionBlock: (FDURLConnectionOperationCompletionBlock)completionBlock
{
	[self loadURLRequest: [request preparedURLRequest] 
		urlRequestType: FDURLRequestTypeJSON 
		authorizationBlock: nil 
		progressBlock: nil 
		dataParserBlock: nil 
		transformBlock: transformBlock 
		completionBlock: completionBlock];
}

- (FDTwitterUser *)_twitterUserFromJSONObject: (NSDictionary *)jsonObject
{
	NSString *userId = [jsonObject objectForKey: @"id_str"];
	NSString *screenName = [jsonObject objectForKey: @"screen_name"];
	NSString *name = [jsonObject objectForKey: @"name"];
	NSString *location = [jsonObject objectForKey: @"location"];
	NSString *urlAsString = [jsonObject objectForKey: @"url"];
	NSString *bio = [jsonObject objectForKey: @"description"];
	NSString *profileImageURLAsString = [jsonObject objectForKey: @"profile_image_url"];
	NSNumber *followingCount = [jsonObject objectForKey: @"friends_count"];
	NSNumber *followerCount = [jsonObject objectForKey: @"followers_count"];
	NSNumber *listedCount = [jsonObject objectForKey: @"listed_count"];
	NSString *followedByAuthenticatedUserAsString = [jsonObject objectForKey: @"following"];
	
	FDTwitterUser *twitterUser = [[FDTwitterUser alloc] 
		init];
	
	twitterUser.userId = userId;
	twitterUser.screenName = screenName;
	twitterUser.name = name;
	
	if (FDIsEmpty(location) == NO)
	{
		twitterUser.location = location;
	}
	
	if (FDIsEmpty(urlAsString) == NO)
	{
		twitterUser.url = [NSURL URLWithString: urlAsString];
	}
	
	if (FDIsEmpty(bio) == NO)
	{
		twitterUser.bio = bio;
	}
	
	twitterUser.profileImageURL = [NSURL URLWithString: profileImageURLAsString];
	twitterUser.followingCount = [followingCount unsignedIntValue];
	twitterUser.followerCount = [followerCount unsignedIntValue];
	twitterUser.listedCount = [listedCount unsignedIntValue];
	
	if (FDIsEmpty(followedByAuthenticatedUserAsString) == NO)
	{
		twitterUser.followedByAuthenticatedUser = [followedByAuthenticatedUserAsString boolValue];
	}
	
	return twitterUser;
}

- (FDTweet *)_tweetFromJSONObject: (NSDictionary *)jsonObject
{
	NSString *tweetId = [jsonObject objectForKey: @"id_str"];
	NSString *text = [jsonObject objectForKey: @"text"];
	NSString *creationDateAsString = [jsonObject objectForKey: @"created_at"];
	NSDate *creationDate = [_apiDateFormatter dateFromString: creationDateAsString];
	BOOL favourited = [[jsonObject objectForKey: @"favorited"] 
		boolValue];
	BOOL retweeted = [[jsonObject objectForKey: @"retweeted"] 
		boolValue];
	NSNumber *retweetCount = [jsonObject objectForKey: @"retweet_count"];
	NSDictionary *jsonUser = [jsonObject objectForKey: @"user"];
	FDTwitterUser *user = [self _twitterUserFromJSONObject: jsonUser];
	
	FDTweet *tweet = [[FDTweet alloc] 
		init];
	
	tweet.tweetId = tweetId;
	tweet.text = text;
	tweet.creationDate = creationDate;
	tweet.favourited = favourited;
	tweet.retweeted = retweeted;
	tweet.retweetCount = [retweetCount unsignedIntValue];
	tweet.user = user;
	
	NSDictionary *entities = [jsonObject objectForKey: @"entities"];
	
	NSArray *jsonURLs = [entities objectForKey: @"urls"];
	
	for (NSDictionary *jsonURL in jsonURLs)
	{
		NSString *rawURLAsString = [jsonURL nonNullObjectForKey: @"url"];
		NSString *displayURLAsString = [jsonURL nonNullObjectForKey: @"display_url"];
		NSString *expandedURLAsString = [jsonURL nonNullObjectForKey: @"expanded_url"];
		
		FDTwitterURL *url = [[FDTwitterURL alloc] 
			init];
		
		url.rawURL = [NSURL URLWithString: rawURLAsString];
		url.displayURL = [NSURL URLWithString: displayURLAsString];
		url.expandedURL = [NSURL URLWithString: expandedURLAsString];
		
		[tweet.urls addObject: url];
	}
	
	return tweet;
}

- (FDTwitterList *)_twitterListFromJSONObject: (NSDictionary *)jsonObject
{
	NSString *listId = [jsonObject objectForKey: @"id_str"];
	NSString *name = [jsonObject objectForKey: @"name"];
	NSString *description = [jsonObject objectForKey: @"description"];
	NSNumber *memberCount = [jsonObject objectForKey: @"member_count"];
	NSNumber *subscriberCount = [jsonObject objectForKey: @"subscriber_count"];
	NSDictionary *jsonUser = [jsonObject objectForKey: @"user"];
	FDTwitterUser *user = [self _twitterUserFromJSONObject: jsonUser];
	
	FDTwitterList *list = [[FDTwitterList alloc] 
		init];
	
	list.listId = listId;
	list.name = name;
	list.listDescription = description;
	list.memberCount = [memberCount unsignedIntValue];
	list.subscriberCount = [subscriberCount unsignedIntValue];
	list.creator = user;
	
	return list;
}

- (NSArray *)_twitterUsersFromJSONObject: (NSArray *)jsonObject
{
	NSMutableArray *twitterUsers = [[NSMutableArray alloc] 
		initWithCapacity: [jsonObject count]];
	
	for (NSDictionary *jsonUser in jsonObject)
	{
		FDTwitterUser *twitterUser = [self _twitterUserFromJSONObject: jsonUser];
		
		[twitterUsers addObject: twitterUser];
	}
	
	return twitterUsers;
}

- (NSArray *)_tweetsFromJSONObject: (NSArray *)jsonObject
{
	NSMutableArray *tweets = [[NSMutableArray alloc] 
		initWithCapacity: [jsonObject count]];
	
	for (NSDictionary *jsonTweet in jsonObject)
	{
		FDTweet *tweet = [self _tweetFromJSONObject: jsonTweet];
		
		[tweets addObject: tweet];
	}
	
	return tweets;
}

- (NSArray *)_twitterListsFromJSONObject: (NSArray *)jsonObject
{
	NSMutableArray *twitterLists = [[NSMutableArray alloc] 
		initWithCapacity: [jsonObject count]];
	
	for (NSDictionary *jsonList in jsonObject)
	{
		FDTwitterList *twitterList = [self _twitterListFromJSONObject: jsonList];
		
		[twitterLists addObject: twitterList];
	}
	
	return twitterLists;
}


@end