#import "FDTwitterUserListController.h"
#import "FDCollectionViewCell.h"
#import <FDTwitterKit/FDTwitterManager.h>


#pragma mark Constants

static NSString * const CellReuseIdentifier = @"CellIdentifier";


#pragma mark - Class Extension

@interface FDTwitterUserListController ()

@property (nonatomic, retain) IBOutlet UICollectionView *collectionView;

- (void)_initializeTwitterUserListController;


@end


#pragma mark - Class Definition

@implementation FDTwitterUserListController
{
	@private __strong FDCollectionViewCell *_templateCell;
}


#pragma mark - Properties

- (void)setTwitterUsers:(NSArray *)twitterUsers
{
	if (_twitterUsers != twitterUsers)
	{
		_twitterUsers = twitterUsers;
		
		[_collectionView reloadData];
	}
}


#pragma mark - Constructors

- (id)initWithDefaultNibName
{
	// Abort if base initializer fails.
	if ((self = [self initWithNibName: @"FDTwitterUserListView" 
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
	[self _initializeTwitterUserListController];
	
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
	[self _initializeTwitterUserListController];
	
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

- (void)_initializeTwitterUserListController
{
	// Initialize instance variables.
	_templateCell = [[FDCollectionViewCell alloc] 
		initWithFrame: CGRectZero];
}


#pragma mark - UICollectionViewDataSource Methods

- (NSInteger)collectionView: (UICollectionView *)collectionView 
	numberOfItemsInSection: (NSInteger)section
{
	NSInteger numberOfItems = 0;
	
	if (collectionView == _collectionView)
	{
		numberOfItems = [_twitterUsers count];
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
		
		FDTwitterUser *twitterUser = [_twitterUsers objectAtIndex:indexPath.row];
		
		cell.textLabel.text = twitterUser.screenName;
		cell.detailTextLabel.text = twitterUser.bio;
	}
	
	return cell;
}


#pragma mark - UICollectionViewDelegate Methods

- (BOOL)collectionView: (UICollectionView *)collectionView 
	shouldHighlightItemAtIndexPath: (NSIndexPath *)indexPath
{
	BOOL shouldHighlightItem = YES;
	
	if (collectionView == _collectionView)
	{
		shouldHighlightItem = NO;
	}
	
	return shouldHighlightItem;
}

#pragma mark - UICollectionViewDelegateFlowLayout Methods

- (CGSize)collectionView: (UICollectionView *)collectionView 
	layout: (UICollectionViewLayout *)collectionViewLayout 
	sizeForItemAtIndexPath: (NSIndexPath *)indexPath
{
	CGSize itemSize = CGSizeMake(collectionView.bounds.size.width, 44.0f);
	
	if (collectionView == _collectionView)
	{
		FDTwitterUser *twitterUser = [_twitterUsers objectAtIndex:indexPath.row];
		
		_templateCell.textLabel.text = twitterUser.screenName;
		_templateCell.detailTextLabel.text = twitterUser.bio;
		
		itemSize = [_templateCell sizeThatFits: CGSizeMake(collectionView.bounds.size.width, CGFLOAT_MAX)];
	}
	
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