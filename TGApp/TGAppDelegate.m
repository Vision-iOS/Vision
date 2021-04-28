#import "UIKit/UIKit.h"
#import "TGAppDelegate.h"
#import "TGMainViewController.h"
#import "TGSettingsViewController.h"
#import "TGImagesController.h"

@import UIKit;
@import Firebase;

@implementation TGAppDelegate
- (void)applicationDidFinishLaunching:(UIApplication *)application {
    self.modelURLs = [NSMutableDictionary dictionary]; // Dizionario che contiene gli URL dei modelli compilati a runtime, nel caso non fossero già stati pre-compilati durante la compilazione dell'app.
	_window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds]; // Crea la finestra principale con le dimensioni dello schermo.
	//_rootViewController = [[UINavigationController alloc] initWithRootViewController:[[TGMainViewController alloc] init]]; // La root sarà la prima schermata da mostrare all'avvio dell'app.
	//_window.rootViewController = _rootViewController; // La finestra principale deve contenere la root.
    TGMainViewController *vc1 = [[TGMainViewController alloc] init];
    vc1.tabBarItem.image = [UIImage imageNamed:@"Home"];
    vc1.tabBarItem.title = @"Home";
    // Set up the second View Controller
    TGSettingsViewController *vc2 = [[TGSettingsViewController alloc] init];
    vc2.tabBarItem.image = [UIImage imageNamed:@"Settings"];
    vc2.tabBarItem.title = @"Settings";
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:vc2];
    navigationController.tabBarItem.title = @"Settings";
    
    UINavigationController *navigationHomeController = [[UINavigationController alloc] initWithRootViewController:vc1];
    navigationHomeController.tabBarItem.title = @"Home";
    
   // TGImagesController *vc3 = [[TGImagesController alloc] init];
    TGImagesController *vc3 = [[TGImagesController alloc] initWithMode:0 withMetadata:nil];
    vc3.tabBarItem.image = [UIImage imageNamed:@"Search"];
    vc3.tabBarItem.title = @"Search";
    UINavigationController *navigationSearchController = [[UINavigationController alloc] initWithRootViewController:vc3];
   // navigationSearchController.navigationBar.translucent = FALSE;
    navigationSearchController.tabBarItem.title = @"Search";
    
    
    // Set up the Tab Bar Controller to have two tabs
    UITabBarController *tabBarController = [[UITabBarController alloc] init];
    [tabBarController setViewControllers:@[navigationHomeController, navigationSearchController, navigationController]];
   
    // Make the Tab Bar Controller the root view controller
    self.window.rootViewController = tabBarController;
    [FIRApp configure]; // Configura firebase.
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if([defaults boolForKey:@"disableFirebase"])
    [FIRAnalytics setAnalyticsCollectionEnabled:NO];
    else [FIRAnalytics setAnalyticsCollectionEnabled:YES];
  
	[_window makeKeyAndVisible]; // Rendi visibile la finestra.
}
-(void)applicationWillTerminate:(UIApplication *)application {
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSArray *keys = self.modelURLs.allKeys; // Ottieni tutti i nomi dei modelli compilati a runtime.
	for (NSString *key in keys) { // Itera le chiavi
		NSURL *url = [self.modelURLs objectForKey:key]; // Ottieni l'URL del modello compilato.
		[fileManager removeItemAtPath:[url path]  error:NULL]; // Rimuovi il modello compilato.
	}
}

@end


