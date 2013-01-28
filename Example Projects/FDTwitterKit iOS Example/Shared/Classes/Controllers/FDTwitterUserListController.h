#pragma mark Class Interface

@interface FDTwitterUserListController : UIViewController<
	UICollectionViewDataSource, 
	UICollectionViewDelegateFlowLayout>


#pragma mark - Properties

@property (nonatomic, strong) NSArray *twitterUsers;


#pragma mark - Constructors

- (id)initWithDefaultNibName;


@end