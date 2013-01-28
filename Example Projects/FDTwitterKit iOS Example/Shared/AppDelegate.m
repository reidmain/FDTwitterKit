#import "AppDelegate.h"
#import "FDTwitterActionListController.h"
#import "FDTwitterLoginController.h"
#import <FDTwitterKit/FDTwitterManager.h>


#pragma mark Class Definition

@implementation AppDelegate
{
	@private __strong UIWindow *_mainWindow;
}


#pragma mark - UIApplicationDelegate Methods

- (BOOL)application: (UIApplication *)application 
	didFinishLaunchingWithOptions: (NSDictionary *)launchOptions
{
	// Create the main window.
	UIScreen *mainScreen = [UIScreen mainScreen];
	
	_mainWindow = [[UIWindow alloc] 
		initWithFrame: mainScreen.bounds];
	
	_mainWindow.backgroundColor = [UIColor blackColor];
	
	// Create a navigation controller with the twitter action list as the root controller.
	FDTwitterActionListController *twitterActionListController = [[FDTwitterActionListController alloc] 
		initWithDefaultNibName];
	
	UINavigationController *rootNavigationController = [[UINavigationController alloc] initWithRootViewController:twitterActionListController];
	
	_mainWindow.rootViewController = rootNavigationController;
	
	// Show the main window.
	[_mainWindow makeKeyAndVisible];
	
	// If the user is not logged in present the twitter login controller modally.
	FDTwitterManager *twitterManager = [FDTwitterManager sharedInstance];
	if ([twitterManager loggedIn] == NO)
	{
		FDTwitterLoginController *twitterLoginController = [[FDTwitterLoginController alloc] 
			initWithCompletionBlock: ^(FDTwitterUser *twitterUser)
			{
				[_mainWindow.rootViewController dismissViewControllerAnimated: YES 
					completion: nil];
			}];
		
		UINavigationController *loginNavigationController = [[UINavigationController alloc] 
			initWithRootViewController: twitterLoginController];
		
		[_mainWindow.rootViewController presentViewController: loginNavigationController 
			animated: NO 
			completion: nil];
	}
	
	// Indicate success.
	return YES;
}


@end // @implementation AppDelegate