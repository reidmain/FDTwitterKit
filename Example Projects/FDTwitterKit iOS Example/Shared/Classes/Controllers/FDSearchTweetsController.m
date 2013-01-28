#import "FDSearchTweetsController.h"
#import <FDTwitterKit/FDTwitterManager.h>


#pragma mark Class Definition

@implementation FDSearchTweetsController


#pragma mark - Constructors

- (id)initWithDefaultNibName
{
	// Abort if base initializer fails.
	if ((self = [self initWithNibName: @"FDSearchTweetsView" 
		bundle: nil]) == nil)
	{
		return nil;
	}
	
	// Set controller's title.
	self.title = @"Search";

	// Return initialized instance.
	return self;
}

#pragma mark - UISearchBarDelegate Methods

- (void)searchBarSearchButtonClicked: (UISearchBar *)searchBar
{
	[searchBar resignFirstResponder];
	
	FDTwitterManager *twitterManager = [FDTwitterManager sharedInstance];
	[twitterManager tweetsForSearchQuery: searchBar.text 
		count: 100 
		maxTweetId: nil 
		completionBlock: ^(NSArray *tweets, NSString *maxTweetId)
			{
				self.tweets = tweets;
			}];
}


@end