#pragma mark Class Interface

@interface FDTwitterListListController : UIViewController<
	UICollectionViewDataSource, 
	UICollectionViewDelegateFlowLayout>


#pragma mark - Properties


@property (nonatomic, strong) NSArray *twitterLists;


#pragma mark - Constructors

- (id)initWithDefaultNibName;


@end