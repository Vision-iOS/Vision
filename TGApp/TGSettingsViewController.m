#import "UIKit/UIKit.h"
#import "TGSettingsViewController.h"
#import "TGStaticTable/TGSwitch.h"
#import "TGStaticTable/TGStaticTable.h"
#import "TGStaticTable/TGTableViewCell.h"
#import "TGConfidenceSettingsViewController.h"
#import "UIView+Toast.h"
#import "TGColor.h"
#import "TGImages.h"
#import "TGPermissionsManager.h"


@import UIKit;
@import Firebase;
@implementation TGSettingsViewController

-(void)openLink:(NSURL *)link{
    [[UIApplication sharedApplication] openURL:link options: @{UIApplicationOpenURLOptionUniversalLinksOnly: @YES} completionHandler:^(BOOL success){
        if (!success) {
            SFSafariViewController *safariVC = [[SFSafariViewController alloc] initWithURL:link entersReaderIfAvailable:NO];
            safariVC.delegate = self;
            [self.navigationController presentViewController:safariVC animated:YES completion:nil];
        }
       }];
}

-(NSString*)imagePath __attribute__ ((objc_direct)) {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0]; // Get documents folder
    NSArray *components = [documentsDirectory componentsSeparatedByString:@"/Documents"];
    if (components.count > 0) {
        NSString *path = [components objectAtIndex:0];
        if (path)
            return [[NSString alloc] initWithFormat:@"%@/Library/Images/", path];
    }
    return NULL;
}
-(void)deleteAllData{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Do you really want to delete all data?" message:@"This action will remove all scanned images and it cannot be undone." preferredStyle:UIAlertControllerStyleActionSheet];
    alertController.view.frame = [[UIScreen mainScreen] applicationFrame];
    UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:@"Delete" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        NSString *imagePath = [self imagePath];
        NSFileManager *fm = [NSFileManager defaultManager];
        NSInteger count = 0, errors = 0;
        for (NSString *file in [fm contentsOfDirectoryAtPath:imagePath error:nil]) {
            NSError *error = nil;
            if([fm removeItemAtPath:[NSString stringWithFormat:@"%@%@", imagePath, file] error:&error])
                count++;
            if(error)
                errors++;
        }
        [[TGImages sharedInstance] destruct];
        if(errors)
            [super showAlertWithTitle:[NSString stringWithFormat:@"Found %ld errors", errors] message:nil];
        else
            [super showAlertWithTitle:count == 1 ? @"Deleted 1 item." : [NSString stringWithFormat:@"Deleted %ld items.", count] message:nil];
    }];
    UIAlertAction *closeAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
    
    }];
    [deleteAction setValue:[TGColor dynamicRedColor] forKey:@"titleTextColor"];
    [alertController addAction:deleteAction];
    [alertController addAction:closeAction];
    [self.navigationController presentViewController:alertController animated:TRUE completion:nil];
}
-(void)openConfidenceController {
    TGConfidenceSettingsViewController *controller = [[TGConfidenceSettingsViewController alloc] init];
    [self.navigationController pushViewController:controller animated:YES];
}
-(void)openStaticAboutController {
    TGTableRow *secondRow = [TGTableRow rowWithTitle:@"Simone Margio" key:@"NULL"];
    [secondRow setImageNamed:@"MarcoSimone"];
    TGTableRow *firstRow = [TGTableRow rowWithTitle:@"Marco Granieri" key:@"NULL"];
    [firstRow setImageNamed:@"MarcoSimone"];
    
    [firstRow addHandler:^{
        NSString *scheme = @"https://github.com/Ram4096";
        NSString *url = [scheme stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        [self openLink:[NSURL URLWithString:url]];
    }];
    [secondRow addHandler:^{
        NSString *scheme = @"https://github.com/simonemargio";
        NSString *url = [scheme stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        [self openLink:[NSURL URLWithString:url]];
    }];
    TGTableSection *firstSection = [TGTableSection sectionWithTableRows:@[firstRow, secondRow] header:@"AUTHOR"];
    
    TGTableRow *firstRowAppInfo = [TGTableRow rowWithTitle:@"What's new?" key:@"NULL"];
    [firstRowAppInfo setImageNamed:@"WhatsNew"];
    TGTableRow *secondRowAppInfo = [TGTableRow rowWithTitle:@"Terms & Privacy Policy" key:@"NULL"];
    [secondRowAppInfo setImageNamed:@"PrivacyPolicy"];
    TGTableRow *thirdRowAppInfo = [TGTableRow rowWithTitle:@"Shop" key:@"NULL"];
    [thirdRowAppInfo setImageNamed:@"Shop"];
    TGTableSection *secondSection = [TGTableSection sectionWithTableRows:@[firstRowAppInfo, secondRowAppInfo, thirdRowAppInfo] header:@"APP INFORMATION"];
    [firstRowAppInfo addHandler:^{
        NSString *url = @"https://github.com/Vision-iOS/Updates";
        [self openLink:[NSURL URLWithString:url]];
    }];
    [secondRowAppInfo addHandler:^{
        NSString *url = @"https://github.com/Vision-iOS/Terms-Policy";
        [self openLink:[NSURL URLWithString:url]];
    }];
    [thirdRowAppInfo addHandler:^{
        NSString *url = @"https://www.spreadshirt.it/shop/design/vision+app+adesivo-D5fdcc437ce0ae7780edb8ebf?sellable=jwRn4xNQpmh37qgzYL9r-1459-215";
        [self openLink:[NSURL URLWithString:url]];
    }];
    secondSection.footer = [NSString stringWithFormat:@"Version: %@", [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]];
    TGTableSections *sections = [TGTableSections withSections:@[firstSection,secondSection] title:@"About"];
    TGStaticViewController *controller = [[TGStaticViewController alloc] initWithSections:sections];
    controller.navigationItem.largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeNever;
    [self.navigationController pushViewController:controller animated:TRUE];
}
-(instancetype)init {
    TGTableRow *firebaseRow = [TGTableRow rowWithTitle:@"Disable Analytics" key:@"disableFirebase" message:@"Enabling this switch will disable analytics collection."];
    [firebaseRow setImageNamed:@"DisableAnalytics"];
    [firebaseRow addHandler:^{
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [FIRAnalytics setAnalyticsCollectionEnabled:![defaults boolForKey:@"disableFirebase"]];
    }];
	TGTableRow *tutorialRow = [TGTableRow rowWithTitle:@"Show Tutorial" key:@"forceTutorial" message:@"Show again the tutorial enabling this switch."];
    [tutorialRow setImageNamed:@"ShowTutorial"];
	tutorialRow.restartRequired = TRUE;
	TGTableRow *feedbackRow = [TGTableRow rowWithTitle:@"Send Feedback" key:@"NULL"];
    [feedbackRow setImageNamed:@"SendFeedback"];
	[feedbackRow addHandler:^{
        NSString *scheme = @"mailto:vision@ium.com?subject=Feedback";
		NSString *url = [scheme stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
	}];
	TGTableRow *cacheRow = [TGTableRow rowWithTitle:@"Clear Cache" key:@"NULL"];
    [cacheRow setImageNamed:@"ClearCache"];
	[cacheRow addHandler:^{
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults removeObjectForKey:@"_lastOriginalImage"];
        [defaults removePersistentDomainForName:[[NSBundle mainBundle] bundleIdentifier]];
        [defaults setBool:TRUE forKey:@"welcomeShown"];
        [defaults synchronize];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"CacheCleared" object:nil];
        [self.view makeToast:@"All cached data successfully removed" duration:2.0 position:CSToastPositionBottom];
	}];
    TGTableRow *deleteDataRow = [TGTableRow rowWithTitle:@"Delete all data" key:@"NULL"];
    [deleteDataRow setImageNamed:@"DeleteAllData"];
    [deleteDataRow addHandler:^{
        [self deleteAllData];
    }];
	TGTableRow *aboutRow = [TGTableRow rowWithTitle:@"About" key:@"CONTROLLER"];
    [aboutRow setImageNamed:@"About"];
    [aboutRow addHandler:^{
		[self openStaticAboutController];
	}];
	TGTableRow *confidenceRow = [TGTableRow rowWithTitle:@"Confidence Level" key:@"CONTROLLER"];
    [confidenceRow setImageNamed:@"ConfidenceLevel"];
	[confidenceRow addHandler:^{
		[self openConfidenceController];
	}];
	TGTableSection *firstSection = [TGTableSection sectionWithTableRows:@[confidenceRow] header:nil];
    TGTableSection *firstSecondSection = [TGTableSection sectionWithTableRows:@[cacheRow, deleteDataRow] header:@"DATA STORAGE"];
	TGTableSection *secondSection = [TGTableSection sectionWithTableRows:@[firebaseRow, tutorialRow] header:nil];
	TGTableSection *thirdSection = [TGTableSection sectionWithTableRows:@[feedbackRow, aboutRow] header:@"INFORMATION AND HELP"];
	TGTableSections *sections = [TGTableSections withSections:@[firstSection, secondSection, firstSecondSection, thirdSection] title:@"Settings"];
	self = [super initWithSections:sections];
	return self;
}
-(void)viewDidLoad {
	[super viewDidLoad];
    [self.navigationController setNavigationBarHidden:NO];
    self.navigationItem.largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeAlways;
    self.navigationController.navigationBar.prefersLargeTitles = true;
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
   
}
-(void)switchChanged:(TGSwitch*)sender {
	[super switchChanged:sender];
}
#pragma mark - UITableViewDataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return [super numberOfSectionsInTableView:tableView];
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [super tableView:tableView numberOfRowsInSection:section];
}
-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	return [super tableView:tableView titleForHeaderInSection:section];
}
-(NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
	return [super tableView:tableView titleForFooterInSection:section];
}
-(TGTableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	return [super tableView:tableView cellForRowAtIndexPath:indexPath];
}
#pragma mark - UITableViewDelegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[super tableView:tableView didSelectRowAtIndexPath:indexPath];
}
@end
