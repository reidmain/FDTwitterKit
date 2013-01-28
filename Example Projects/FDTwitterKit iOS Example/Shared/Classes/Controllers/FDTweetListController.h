#pragma mark Class Interface

@interface FDTweetListController : UIViewController<
	UICollectionViewDataSource, 
	UICollectionViewDelegateFlowLayout>


#pragma mark - Properties

@property (nonatomic, strong) NSArray *tweets;


#pragma mark - Constructors

- (id)initWithDefaultNibName;


@end