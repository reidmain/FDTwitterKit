#import "FDTwitterFollowerListController.h"
#import <FDTwitterKit/FDTwitterManager.h>


#pragma mark Class Definition

@implementation FDTwitterFollowerListController


#pragma mark - Constructors

- (id)initWithDefaultNibName
{
	// Abort if base initializer fails.
	if ((self = [super initWithDefaultNibName]) == nil)
	{
		return nil;
	}
	
	// Set controller's title.
	self.title = @"Followers";

	// Return initialized instance.
	return self;
}


#pragma mark - Overridden Methods

- (void)viewDidAppear: (BOOL)animated
{
	// Call base implementation.
	[super viewDidAppear: animated];
	
	// Load authenticated Twitter user's first 100 followers.
	FDTwitterManager *twitterManager = [FDTwitterManager sharedInstance];
	[twitterManager followersForUserId: twitterManager.user.userId 
		cursor: nil 
		completionBlock:^(NSArray *twitterUsers, NSString *nextCursor)
		{
			self.twitterUsers = twitterUsers;
		}];
}

@end