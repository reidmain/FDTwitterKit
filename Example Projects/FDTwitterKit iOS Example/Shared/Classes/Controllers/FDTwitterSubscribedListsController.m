#import "FDTwitterSubscribedListsController.h"
#import <FDTwitterKit/FDTwitterManager.h>


#pragma mark Class Definition

@implementation FDTwitterSubscribedListsController


#pragma mark - Constructors

- (id)initWithDefaultNibName
{
	// Abort if base initializer fails.
	if ((self = [super initWithDefaultNibName]) == nil)
	{
		return nil;
	}
	
	// Set controller's title.
	self.title = @"Subscribed Lists";

	// Return initialized instance.
	return self;
}


#pragma mark - Overridden Methods

- (void)viewDidAppear: (BOOL)animated
{
	// Call base implementation.
	[super viewDidAppear: animated];
	
	// Load authenticated Twitter user's owned lists.
	FDTwitterManager *twitterManager = [FDTwitterManager sharedInstance];
	[twitterManager subscribedListsForUserId: twitterManager.user.userId 
		cursor: nil 
		completionBlock: ^(NSArray *lists, NSString *nextCursor)
			{
				self.twitterLists = lists;
			}];
}


@end