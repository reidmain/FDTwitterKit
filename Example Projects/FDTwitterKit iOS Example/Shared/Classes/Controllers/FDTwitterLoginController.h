#import <FDTwitterKit/FDTwitterUser.h>


#pragma mark Type Definitions

typedef void (^FDTwitterLoginControllerCompletionBlock)(FDTwitterUser *twitterUser);


#pragma mark - Class Interface

@interface FDTwitterLoginController : UIViewController<
	UICollectionViewDataSource, 
	UICollectionViewDelegateFlowLayout>


#pragma mark - Constructors

- (id)initWithCompletionBlock: (FDTwitterLoginControllerCompletionBlock)completionBlock;


@end