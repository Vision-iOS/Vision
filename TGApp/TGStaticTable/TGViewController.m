#import "UIKit/UIKit.h"
#import "TGViewController.h"
#import "TGCircleButton.h"
#import "TGColor.h"

@implementation TGViewController
+(TGCircleButton*)addButtonInCell:(UITableViewCell*)cell delegate:(id)delegate message:(NSString*)message atIndexPath:(NSIndexPath*)indexPath {
    TGCircleButton *button = [TGCircleButton buttonWithType:UIButtonTypeDetailDisclosure];
	button.name = cell.textLabel.text;
	button.row = indexPath.row;
	button.section = indexPath.section;
	button.message = message;
	[button setHidden:FALSE];
	button.tintColor = [TGColor dynamicTintColor];
	[button setTranslatesAutoresizingMaskIntoConstraints:FALSE];
	[button addTarget:delegate action:@selector(showAlertForButton:) forControlEvents:UIControlEventTouchUpInside];
	[cell.contentView addSubview:button];
	[button.trailingAnchor constraintEqualToAnchor:cell.contentView.trailingAnchor constant:-15.0f].active = TRUE;
	[button.centerYAnchor constraintEqualToAnchor:cell.contentView.centerYAnchor].active = TRUE;
	return button;
}
-(void)showAlertWithTitle:(NSString*)title message:(NSString*)message {
	UIAlertController *controller = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
	controller.view.frame = [[UIScreen mainScreen] applicationFrame];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
	[action setValue:[TGColor dynamicTintColor] forKey:@"titleTextColor"];
	[controller addAction:action];
	[self presentViewController:controller animated:YES completion:nil];
}
-(void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
	if ([self isMovingFromParentViewController])
		[self.navigationItem setRightBarButtonItem:nil animated:NO];
}
-(void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	SEL selector = @selector(unhighlightRowAtIndexPath:animated:);
	if ((_tableView) && ([_tableView respondsToSelector:selector])) {
		NSArray *indexPaths = [_tableView valueForKey:@"_highlightedIndexPaths"];
		if ((indexPaths) && (indexPaths.count)) {
			for (NSIndexPath *indexPath in indexPaths)
				[_tableView performSelector:selector withObject:indexPath withObject:nil];
		}
	}
}
@end
