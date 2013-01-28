#import "FDTwitterActionListController.h"
#import <FDTwitterKit/FDTwitterManager.h>
#import "FDTwitterLoginController.h"
#import "FDCollectionViewCell.h"
#import "FDTwitterHomeTimelineController.h"
#import "FDTwitterMentionsTimelineController.h"
#import "FDTwitterFriendListController.h"
#import "FDTwitterFollowerListController.h"
#import "FDTwitterFavouritesTimelineController.h"
#import "FDTwitterRetweetsTimelineController.h"
#import "FDTwitterOwnedListsController.h"
#import "FDTwitterSubscribedListsController.h"
#import "FDSearchTweetsController.h"


#pragma mark Constants

static NSString * const CellReuseIdentifier = @"CellIdentifier";
static NSString * const Row_Timeline = @"Timeline";
static NSString * const Row_Mentions = @"Mentions";
static NSString * const Row_Following = @"Following";
static NSString * const Row_Followers = @"Followers";
static NSString * const Row_Favourites = @"Favourites";
static NSString * const Row_Retweets = @"Retweets";
static NSString * const Row_OwnedLists = @"Owned Lists";
static NSString * const Row_SubscribedLists = @"Subscribed Lists";
static NSString * const Row_Search = @"Search";


#pragma mark - Class Extension

@interface FDTwitterActionListController ()

@property (nonatomic, retain) IBOutlet UICollectionView *collectionView;

- (void)_initializeTwitterActionListController;
- (void)_signOutOfTwitter;

@end


#pragma mark - Class Definition

@implementation FDTwitterActionListController
{
	@private __strong NSMutableArray *_actions;
}


#pragma mark - Constructors

- (id)initWithDefaultNibName
{
	// Abort if base initializer fails.
	if ((self = [self initWithNibName: @"FDTwitterActionListView" 
		bundle: nil]) == nil)
	{
		return nil;
	}

	// Return initialized instance.
	return self;
}

- (id)initWithNibName: (NSString *)nibName 
    bundle: (NSBundle *)bundle
{
	// Abort if base initializer fails.
	if ((self = [super initWithNibName: nibName 
        bundle: bundle]) == nil)
	{
		return nil;
	}
	
	// Initialize view.
	[self _initializeTwitterActionListController];
	
	// Return initialized instance.
	return self;
}

- (id)initWithCoder: (NSCoder *)coder
{
	// Abort if base initializer fails.
	if ((self = [super initWithCoder: coder]) == nil)
	{
		return nil;
	}
	
	// Initialize view.
	[self _initializeTwitterActionListController];
	
	// Return initialized instance.
	return self;
}


#pragma mark - Destructor

- (void)dealloc 
{
	// nil out delegates of any instance variables.
	_collectionView.delegate = nil;
	_collectionView.dataSource = nil;
}


#pragma mark - Overridden Methods

- (NSUInteger)supportedInterfaceOrientations
{
	return UIInterfaceOrientationMaskAll;
}

- (void)viewDidLoad
{
	// Call base implementation.
	[super viewDidLoad];
	
	// Register cell classes with the collection view.
	[_collectionView registerClass: [FDCollectionViewCell class] forCellWithReuseIdentifier: CellReuseIdentifier];
}

- (void)viewWillAppear: (BOOL)animated
{
	// Call base implementation.
	[super viewWillAppear: animated];
	
	// Set controller's title.
	FDTwitterManager *twitterManager = [FDTwitterManager sharedInstance];
	self.title = [NSString stringWithFormat: @"@%@", twitterManager.user.screenName];
	
	// Reload the data in the collection view to ensure the cells widths are resized to be the same width as the collection view.
	[_collectionView reloadData];
}

- (void)willRotateToInterfaceOrientation: (UIInterfaceOrientation)toInterfaceOrientation 
	duration: (NSTimeInterval)duration
{
	// Call base implementation.
	[super willRotateToInterfaceOrientation: toInterfaceOrientation 
		duration: duration];
	
	// Reload the data in the collection view to ensure the cells widths are resized to be the same width as the collection view.
	[_collectionView reloadData];
}


#pragma mark - Private Methods

- (void)_initializeTwitterActionListController
{
	// Initialize instance variables.
	_actions = [[NSMutableArray alloc] initWithObjects: 
		Row_Timeline, 
		Row_Mentions, 
		Row_Following, 
		Row_Followers, 
		Row_Favourites, 
		Row_Retweets, 
		Row_OwnedLists, 
		Row_SubscribedLists, 
		Row_Search, 
		nil];
	
	// Add 'Sign Out' button to the navigation bar.
	UIBarButtonItem *signOutBarButtonItem = [[UIBarButtonItem alloc] 
		initWithTitle: @"Sign Out" 
			style: UIBarButtonItemStyleBordered 
			target: self 
			action: @selector(_signOutOfTwitter)];
	
	self.navigationItem.rightBarButtonItem = signOutBarButtonItem;
}

- (void)_signOutOfTwitter
{
	FDTwitterManager *twitterManager = [FDTwitterManager sharedInstance];
	[twitterManager logout];
	
	FDTwitterLoginController *twitterLoginController = [[FDTwitterLoginController alloc] 
		initWithCompletionBlock: ^(FDTwitterUser *twitterUser)
		{
			[self dismissViewControllerAnimated: YES 
				completion: nil];
		}];
	
	UINavigationController *navigationController = [[UINavigationController alloc] 
		initWithRootViewController: twitterLoginController];
	
	[self presentViewController: navigationController 
		animated: YES 
		completion: nil];
}


#pragma mark - UICollectionViewDataSource Methods

- (NSInteger)collectionView: (UICollectionView *)collectionView 
	numberOfItemsInSection: (NSInteger)section
{
	NSInteger numberOfItems = 0;
	
	if (collectionView == _collectionView)
	{
		numberOfItems = [_actions count];
	}
	
	return numberOfItems;
}

- (UICollectionViewCell *)collectionView: (UICollectionView *)collectionView 
	cellForItemAtIndexPath: (NSIndexPath *)indexPath
{
	FDCollectionViewCell *cell = nil;
	
	if (collectionView == _collectionView)
	{
		cell = [collectionView dequeueReusableCellWithReuseIdentifier: CellReuseIdentifier 
			forIndexPath: indexPath];
		
		NSString *action = [_actions objectAtIndex: indexPath.row];
		
		cell.textLabel.text = action;
	}
	
	return cell;
}


#pragma mark - UICollectionViewDelegate Methods

- (void)collectionView: (UICollectionView *)collectionView 
	didSelectItemAtIndexPath: (NSIndexPath *)indexPath
{
	[collectionView deselectItemAtIndexPath: indexPath 
		animated: YES];
	
	if (collectionView == _collectionView)
	{
		NSString *action = [_actions objectAtIndex: indexPath.row];
		
		if ([action isEqualToString: Row_Timeline] == YES)
		{
			FDTwitterHomeTimelineController *homeTimelineController = [[FDTwitterHomeTimelineController alloc] 
				initWithDefaultNibName];
			
			[self.navigationController pushViewController: homeTimelineController 
				animated: YES];
		}
		else if ([action isEqualToString: Row_Mentions] == YES)
		{
			FDTwitterMentionsTimelineController *mentionsTimelineController = [[FDTwitterMentionsTimelineController alloc] 
				initWithDefaultNibName];
			
			[self.navigationController pushViewController: mentionsTimelineController 
				animated: YES];
		}
		else if ([action isEqualToString: Row_Following] == YES)
		{
			FDTwitterFriendListController *friendListController = [[FDTwitterFriendListController alloc] 
				initWithDefaultNibName];
			
			[self.navigationController pushViewController: friendListController 
				animated: YES];
		}
		else if ([action isEqualToString: Row_Followers] == YES)
		{
			FDTwitterFollowerListController *followerListController = [[FDTwitterFollowerListController alloc] 
				initWithDefaultNibName];
			
			[self.navigationController pushViewController: followerListController 
				animated: YES];
		}
		else if ([action isEqualToString: Row_Favourites] == YES)
		{
			FDTwitterFavouritesTimelineController *favouritesTimelineController = [[FDTwitterFavouritesTimelineController alloc] 
				initWithDefaultNibName];
			
			[self.navigationController pushViewController: favouritesTimelineController 
				animated: YES];
		}
		else if ([action isEqualToString: Row_Retweets] == YES)
		{
			FDTwitterRetweetsTimelineController *retweetsTimelineController = [[FDTwitterRetweetsTimelineController alloc] 
				initWithDefaultNibName];
			
			[self.navigationController pushViewController: retweetsTimelineController 
				animated: YES];
		}
		else if ([action isEqualToString: Row_OwnedLists] == YES)
		{
			FDTwitterOwnedListsController *ownedListsController = [[FDTwitterOwnedListsController alloc] 
				initWithDefaultNibName];
			
			[self.navigationController pushViewController: ownedListsController 
				animated: YES];
		}
		else if ([action isEqualToString: Row_SubscribedLists] == YES)
		{
			FDTwitterSubscribedListsController *subscribedListsController = [[FDTwitterSubscribedListsController alloc] 
				initWithDefaultNibName];
				
			[self.navigationController pushViewController: subscribedListsController 
				animated: YES];
		}
		else if ([action isEqualToString: Row_Search] == YES)
		{
			FDSearchTweetsController *searchTweetsController = [[FDSearchTweetsController alloc] 
				initWithDefaultNibName];
			
			[self.navigationController pushViewController: searchTweetsController 
				animated: YES];
		}
	}
}

#pragma mark - UICollectionViewDelegateFlowLayout Methods

- (CGSize)collectionView: (UICollectionView *)collectionView 
	layout: (UICollectionViewLayout *)collectionViewLayout 
	sizeForItemAtIndexPath: (NSIndexPath *)indexPath
{
	CGSize itemSize = CGSizeMake(collectionView.bounds.size.width, 44.0f);
	
	return itemSize;
}

- (CGFloat)collectionView: (UICollectionView *)collectionView 
	layout: (UICollectionViewLayout*)collectionViewLayout 
	minimumLineSpacingForSectionAtIndex: (NSInteger)section
{
	CGFloat minimumLineSpacing = 0.0f;
	
	return minimumLineSpacing;
}

- (CGFloat)collectionView: (UICollectionView *)collectionView 
	layout: (UICollectionViewLayout *)collectionViewLayout 
	minimumInteritemSpacingForSectionAtIndex: (NSInteger)section
{
	CGFloat minimumInteritemSpacing = 0.0f;
	
	return minimumInteritemSpacing;
}


@end