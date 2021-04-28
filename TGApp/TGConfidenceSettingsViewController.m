#import "TGSwitch.h"
#import "TGColor.h"
#import "TGConfidenceSettingsViewController.h"

@implementation TGConfidenceSettingsViewController
-(void)viewDidLoad {
    [super viewDidLoad];
	super.title = @"Confidence Level";
	_tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
	_tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
	_tableView.delegate = self;
	_tableView.dataSource = self;
	[self.view addSubview:_tableView];
}
#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return 3;
}
-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	return NULL;
}
-(NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	int row = [defaults integerForKey:@"confidenceLevel"];
	if (row == 0)
		return @"More results will be shown when analyzing images, but some of them might be inaccurate.";
	if (row == 1)
		return @"Results with low reliability will be discarded when analyzing images.";
	return @"Only the most reliable results will be shown when analyzing images.";
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	int row = [indexPath row];
	NSString *identifier = [NSString stringWithFormat:@"TGConfidenceCell%d", row];
	UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
        
	if (cell == nil)
		cell = [[UITableViewCell alloc] initWithStyle: UITableViewCellStyleValue1 reuseIdentifier:identifier];
	switch (row) {
		case 0:
			cell.textLabel.text = @"Low";
			break;
		case 1:
			cell.textLabel.text = @"Medium";
			break;
		case 2:
			cell.textLabel.text = @"High";
	}
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	int selectedRow = [defaults integerForKey:@"confidenceLevel"];
	if (row == selectedRow)
		cell.accessoryType = UITableViewCellAccessoryCheckmark;
	else
		cell.accessoryType = UITableViewCellAccessoryNone;
    return cell;
}
#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	int row = indexPath.row;
	int oldRow = [defaults integerForKey:@"confidenceLevel"];
	if (row != oldRow) {
		[defaults setInteger:row forKey:@"confidenceLevel"];
		[defaults synchronize];
		NSIndexPath *oldIndexPath = [NSIndexPath indexPathForRow:oldRow inSection:indexPath.section];
		UITableViewCell *oldCell = [tableView cellForRowAtIndexPath:oldIndexPath];
		oldCell.accessoryType = UITableViewCellAccessoryNone;
		UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
		cell.accessoryType = UITableViewCellAccessoryCheckmark;
		[_tableView footerViewForSection:0].textLabel.text = [self tableView:_tableView titleForFooterInSection:0];
	}
}
@end
