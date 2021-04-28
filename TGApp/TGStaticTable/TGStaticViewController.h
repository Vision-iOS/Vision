#import "UIKit/UIKit.h"
#import "TGTableSections.h"
#import "TGTableSection.h"
#import "TGTableRow.h"
#import "TGTableViewCell.h"
#import "TGViewController.h"

@interface TGStaticViewController : TGViewController <UITableViewDelegate, UITableViewDataSource> {

}
@property (nonatomic, retain) TGTableSections *sections;
-(instancetype)initWithSections:(TGTableSections*)sections;
+(TGStaticViewController*)withSections:(TGTableSections*)sections;
-(TGTableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
-(void)showAlertForButton:(id)sender;
-(void)switchChanged:(id)sender;
@end
