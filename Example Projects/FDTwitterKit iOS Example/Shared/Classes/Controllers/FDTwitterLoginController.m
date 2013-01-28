#import "FDTwitterLoginController.h"
#import <FDTwitterKit/FDTwitterManager.h>
#import "FDCollectionViewCell.h"


#pragma mark Constants

static NSString * const CellReuseIdentifier = @"CellIdentifier";


#pragma mark - Class Extension

@interface FDTwitterLoginController ()

@property (nonatomic, retain) IBOutlet UICollectionView *collectionView;

- (void)_initializeTwitterLoginController;


@end


#pragma mark - Class Definition

@implementation FDTwitterLoginController
{
	@private __strong NSArray *_twitterAccounts;
	
	@private __strong FDTwitterLoginControllerCompletionBlock _completionBlock;
}


#pragma mark - Constructors

- (id)initWithCompletionBlock: (FDTwitterLoginControllerCompletionBlock)completionBlock
{
	// Abort if base initializer fails.
	if ((self = [self initWithNibName: @"FDTwitterLoginView" 
		bundle: nil]) == nil)
	{
		return nil;
	}
	
	// Initialize instance variable
	_completionBlock = completionBlock;

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
	[self _initializeTwitterLoginController];
	
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
	[self _initializeTwitterLoginController];
	
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
	
	// Perform additional initialization after nib outlets are bound.
}

- (void)viewDidAppear: (BOOL)animated
{
	// Call base implementation.
	[super viewDidAppear: animated];
	
	// Attempt to log the user into Twitter.
	FDTwitterManager *twitterManager = [FDTwitterManager sharedInstance];
	
	[twitterManager loginWithCompletionBlock: ^(BOOL successful, NSArray *accounts)
		{
			if(successful == YES)
			{
				_completionBlock(twitterManager.user);
			}
			else
			{
				_twitterAccounts = accounts;
				
				[_collectionView reloadData];
			}
		}];
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

- (void)_initializeTwitterLoginController
{
	// Set the controller's title.
	self.title = @"Login to Twitter";
}


#pragma mark - UICollectionViewDataSource Methods

- (NSInteger)collectionView: (UICollectionView *)collectionView 
	numberOfItemsInSection: (NSInteger)section
{
	NSInteger numberOfItems = 0;
	
	if (collectionView == _collectionView)
	{
		numberOfItems = [_twitterAccounts count];
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
		
		// Populate the cell with the name of the Twitter account.
		ACAccount *twitterAccount = [_twitterAccounts objectAtIndex: indexPath.row];
		cell.textLabel.text = [twitterAccount accountDescription];
	}
	
	return cell;
}


#pragma mark - UICollectionViewDelegate Methods

- (void)collectionView: (UICollectionView *)collectionView 
	didSelectItemAtIndexPath: (NSIndexPath *)indexPath
{
	if (collectionView == _collectionView)
	{
		[collectionView deselectItemAtIndexPath: indexPath animated: YES];
		
		// Log into the selected Twitter account.
		ACAccount *twitterAccount = [_twitterAccounts objectAtIndex: indexPath.row];
		
		FDTwitterManager *twitterManager = [FDTwitterManager sharedInstance];
		[twitterManager loginWithAccount: twitterAccount 
			completionBlock: ^(BOOL successful, NSArray *accounts)
				{
					_completionBlock(successful == YES ? twitterManager.user  : nil);
				}];
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