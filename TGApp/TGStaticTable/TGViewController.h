#import "UIKit/UIKit.h"

@interface TGViewController : UIViewController {
	UITableView *_tableView;
}
-(void)showAlertWithTitle:(NSString*)title message:(NSString*)message;
+(id)addButtonInCell:(UITableViewCell*)cell delegate:(id)delegate message:(NSString*)message atIndexPath:(NSIndexPath*)indexPath;
@end
