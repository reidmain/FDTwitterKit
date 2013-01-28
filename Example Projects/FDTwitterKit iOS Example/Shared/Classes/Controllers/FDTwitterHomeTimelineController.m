#import "FDTwitterHomeTimelineController.h"
#import <FDTwitterKit/FDTwitterManager.h>


#pragma mark Class Definition

@implementation FDTwitterHomeTimelineController


#pragma mark - Constructors

- (id)initWithDefaultNibName
{
	// Abort if base initializer fails.
	if ((self = [super initWithDefaultNibName]) == nil)
	{
		return nil;
	}
	
	// Set controller's title.
	self.title = @"Timeline";

	// Return initialized instance.
	return self;
}


#pragma mark - Overridden Methods

- (void)viewDidAppear: (BOOL)animated
{
	// Call base implementation.
	[super viewDidAppear: animated];
	
	// Load authenticated Twitter user's timeline.
	FDTwitterManager *twitterManager = [FDTwitterManager sharedInstance];
	[twitterManager homeTimelineWithCompletionBlock: ^(NSArray *tweets)
		{
			self.tweets = tweets;
		}];
}


@end