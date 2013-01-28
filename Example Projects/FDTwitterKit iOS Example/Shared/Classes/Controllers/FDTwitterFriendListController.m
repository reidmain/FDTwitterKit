#import "FDTwitterFriendListController.h"
#import <FDTwitterKit/FDTwitterManager.h>


#pragma mark Class Definition

@implementation FDTwitterFriendListController


#pragma mark - Constructors

- (id)initWithDefaultNibName
{
	// Abort if base initializer fails.
	if ((self = [super initWithDefaultNibName]) == nil)
	{
		return nil;
	}
	
	// Set controller's title.
	self.title = @"Following";

	// Return initialized instance.
	return self;
}


#pragma mark - Overridden Methods

- (void)viewDidAppear: (BOOL)animated
{
	// Call base implementation.
	[super viewDidAppear: animated];
	
	// Load authenticated Twitter user's first 100 followed users.
	FDTwitterManager *twitterManager = [FDTwitterManager sharedInstance];
	[twitterManager friendsForUserId: twitterManager.user.userId 
		cursor: nil 
		completionBlock:^(NSArray *twitterUsers, NSString *nextCursor)
		{
			self.twitterUsers = twitterUsers;
		}];
}

@end