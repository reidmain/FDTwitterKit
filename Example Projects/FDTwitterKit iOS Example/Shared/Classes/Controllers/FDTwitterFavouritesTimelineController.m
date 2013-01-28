#import "FDTwitterFavouritesTimelineController.h"
#import <FDTwitterKit/FDTwitterManager.h>


#pragma mark Class Definition

@implementation FDTwitterFavouritesTimelineController


#pragma mark - Constructors

- (id)initWithDefaultNibName
{
	// Abort if base initializer fails.
	if ((self = [super initWithDefaultNibName]) == nil)
	{
		return nil;
	}
	
	// Set controller's title.
	self.title = @"Favourites";

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
	[twitterManager favouritesTimelineWithCompletionBlock: ^(NSArray *tweets)
		{
			self.tweets = tweets;
		}];
}


@end