#import "FDRequestClient.h"
#import <Accounts/Accounts.h>
#import "FDTwitterUser.h"
#import "FDTweet.h"
#import "FDTwitterList.h"


#pragma mak Type Definitions

typedef void (^FDTwitterAPIClientTwitterUsersCompletionBlock)(FDURLResponseStatus status, NSError *error, NSArray *twitterUsers);
typedef void (^FDTwitterAPIClientHomeTimelineCompletionBlock)(FDURLResponseStatus status, NSError *error, NSArray *tweets);
typedef void (^FDTwitterAPIClientMentionsTimelineCompletionBlock)(FDURLResponseStatus status, NSError *error, NSArray *tweets);
typedef void (^FDTwitterAPIClientFavouriteTweetsCompletionBlock)(FDURLResponseStatus status, NSError *error, NSArray *tweets);
typedef void (^FDTwitterAPIClientRetweetsCompletionBlock)(FDURLResponseStatus status, NSError *error, NSArray *tweets);
typedef void (^FDTwitterAPIClientFriendsCompletionBlock)(FDURLResponseStatus status, NSError *error, NSArray *userIds, NSString *nextCursor);
typedef void (^FDTwitterAPIClientFollowersCompletionBlock)(FDURLResponseStatus status, NSError *error, NSArray *userIds, NSString *nextCursor);
typedef void (^FDTwitterAPIClientOwnedListsCompletionBlock)(FDURLResponseStatus status, NSError *error, NSArray *lists, NSString *nextCursor);
typedef void (^FDTwitterAPIClientSubscribedListsCompletionBlock)(FDURLResponseStatus status, NSError *error, NSArray *lists, NSString *nextCursor);
typedef void (^FDTwitterAPIClientListTimelineCompletionBlock)(FDURLResponseStatus status, NSError *error, NSArray *tweets);
typedef void (^FDTwitterAPIClientSearchCompletionBlock)(FDURLResponseStatus status, NSError *error, NSArray *lists, NSString *maxTweetId);


#pragma mark - Class Interface

@interface FDTwitterAPIClient : FDRequestClient


#pragma mark - Instance Methods

- (void)userForScreenName: (NSString *)screenName 
	account: (ACAccount *)account 
	completionBlock:(void (^)(FDURLResponseStatus status, NSError *error, FDTwitterUser *user))completionBlock;

- (void)twitterUsersForIds: (NSArray *)userIds 
	account: (ACAccount *)account 
	completionBlock: (FDTwitterAPIClientTwitterUsersCompletionBlock)completionBlock;

- (void)profileImageForScreenName: (NSString *)screenName 
	account: (ACAccount *)account 
	completion: (void (^)(FDURLResponseStatus status, NSError *error, UIImage *profileImage, NSURL *profileImageURL))completion;

- (void)homeTimelineForAccount: (ACAccount *)account 
	completionBlock: (FDTwitterAPIClientHomeTimelineCompletionBlock)completionBlock;

- (void)mentionsTimelineForAccount: (ACAccount *)account 
	completionBlock: (FDTwitterAPIClientMentionsTimelineCompletionBlock)completionBlock;

- (void)favouriteTweetsForAccount: (ACAccount *)account 
	completionBlock: (FDTwitterAPIClientFavouriteTweetsCompletionBlock)completionBlock;

- (void)retweetsForAccount: (ACAccount *)account 
	completionBlock: (FDTwitterAPIClientRetweetsCompletionBlock)completionBlock;

- (void)friendsForUserId: (NSString *)userId 
	cursor: (NSString *)cursor 
	count: (unsigned int)count 
	account: (ACAccount *)account 
	completionBlock: (FDTwitterAPIClientFriendsCompletionBlock)completionBlock;

- (void)followersForUserId: (NSString *)userId 
	cursor: (NSString *)cursor 
	count: (unsigned int)count 
	account: (ACAccount *)account 
	completionBlock: (FDTwitterAPIClientFollowersCompletionBlock)completionBlock;

- (void)ownedListsForUserId: (NSString *)userId 
	cursor: (NSString *)cursor 
	count: (unsigned int)count 
	account: (ACAccount *)account 
	completionBlock: (FDTwitterAPIClientOwnedListsCompletionBlock)completionBlock;

- (void)subscribedListsForUserId: (NSString *)userId 
	cursor: (NSString *)cursor 
	count: (unsigned int)count 
	account: (ACAccount *)account 
	completionBlock: (FDTwitterAPIClientSubscribedListsCompletionBlock)completionBlock;

- (void)tweetsForListId: (NSString *)listId 
	count: (unsigned int)count 
	maxTweetId: (NSString *)maxTweetId 
	account: (ACAccount *)account 
	completionBlock: (FDTwitterAPIClientListTimelineCompletionBlock)completionBlock;

- (void)tweetsForSearchQuery: (NSString *)query 
	count: (unsigned int)count 
	maxTweetId: (NSString *)maxTweetId 
	account: (ACAccount *)account 
	completionBlock: (FDTwitterAPIClientSearchCompletionBlock)completionBlock;


@end