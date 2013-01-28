#import "FDTwitterListTimelineController.h"


#pragma mark Class Definition

@implementation FDTwitterListTimelineController
{
	@private __strong FDTwitterList *_twitterList;
}


#pragma mark - Constructors

- (id)initWithTwitterList: (FDTwitterList *)twitterList
{
	// Abort if base initializer fails.
	if ((self = [super initWithDefaultNibName]) == nil)
	{
		return nil;
	}
	
	// Initialize instance variables.
	_twitterList = twitterList;
	
	// Set controller's title.
	self.title = [NSString stringWithFormat: @"@%@/%@", _twitterList.creator.screenName, _twitterList.name];
	
	// Return initialized instance.
	return self;
}


#pragma mark - Overridden Methods

- (void)viewDidAppear: (BOOL)animated
{
	// Call base implementation.
	[super viewDidAppear: animated];
	
	// Load tweets for list.
	FDTwitterManager *twitterManager = [FDTwitterManager sharedInstance];
	[twitterManager tweetsForListId: _twitterList.listId 
		count: 100 
		maxTweetId: nil 
		completionBlock: ^(NSArray *tweets, NSString *maxTweetId)
			{
				self.tweets = tweets;
			}];
}


@end