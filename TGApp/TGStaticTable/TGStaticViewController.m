#import "UIKit/UIKit.h"
#import "TGStaticViewController.h"
#import "TGSwitch.h"
#import "TGCircleButton.h"
#import "TGColor.h"

@implementation TGStaticViewController
-(void)setUpTableView {
	NSInteger numberOfSections = [self numberOfSectionsInTableView:_tableView];
	for (NSInteger section = 0; section < numberOfSections; section++) {
		NSInteger rows = [self tableView:_tableView numberOfRowsInSection:section];
		for (NSInteger row = 0; row < rows; row++) {
			[self tableView:_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:section]];
		}
	}
}
-(void)showAlertForButton:(TGCircleButton*)sender {
	[super showAlertWithTitle:sender.name message:sender.message];
}
+(TGStaticViewController*)withSections:(TGTableSections*)sections {
	return [[TGStaticViewController alloc] initWithSections:sections];
}
-(instancetype)initWithSections:(TGTableSections*)sections {
	if (self = [super init]) {
		self.sections = sections;
	}
	return self;
}
-(void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
	if ([self isMovingFromParentViewController]) {
		[self.sections destruct];
		self.sections = nil;
		_tableView = nil;
	}
}
-(void)viewDidLoad {
	[super viewDidLoad];
	[self setTitle:self.sections.title];
	_tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
	_tableView.delegate = self;
	_tableView.dataSource = self;
	_tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
	[self.view addSubview:_tableView];
	[self setUpTableView];
}
#pragma mark - UITableViewDataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return self.sections.count;
}
-(NSInteger)tableView:(UITableView *)theTableView numberOfRowsInSection:(NSInteger)section {
	return [self.sections sectionAtIndex:section].count;
}
-(NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
	return [self.sections sectionAtIndex:section].footer;
}
-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	return [self.sections sectionAtIndex:section].header;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return [[self.sections sectionAtIndex:indexPath.section] rowAtIndex:indexPath.row].height;
}
-(TGTableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	int section = [indexPath section];
	int row = [indexPath row];
	TGTableRow *tableRow = [[self.sections sectionAtIndex:section] rowAtIndex:row];
	if (tableRow.cell)
		return tableRow.cell;
/*
	NSString *identifier = [NSString stringWithFormat:@"TGStaticCell-%@-%d-%d", self.title, section, row];
	TGTableViewCell *cell = (TGTableViewCell*)[tableView dequeueReusableCellWithIdentifier:identifier];
	if (cell == nil)
		cell = [[TGTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier];
*/
	TGTableViewCell *cell = [[TGTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil]; // No reuse identifier because we've already a reference of the cell.
	cell.row = tableRow;
	tableRow.cell = cell;
	if (tableRow.gestureHandler) {
		UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:tableRow action:@selector(execGesture)];
		[longPressGesture setMinimumPressDuration:1.5];
		[cell addGestureRecognizer:longPressGesture];
		tableRow.gesture = longPressGesture;
	}
	cell.textLabel.text = tableRow.title;
	cell.detailTextLabel.text = tableRow.detailTitle;
	if (tableRow.image) {
		cell.imageView.image = tableRow.image;
		cell.imageView.layer.cornerRadius = 5.0f;
		cell.imageView.clipsToBounds = YES;
	}
	BOOL hasSwitch = FALSE;
	if (tableRow.key) {
		hasSwitch = TRUE;
		TGSwitch *switchView = [TGSwitch switchWithName:tableRow.title key:tableRow.key target:self];
		switchView.restartRequired = tableRow.restartRequired;
		cell.accessoryView = switchView;
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		if (tableRow.message)
			[TGViewController addButtonInCell:cell delegate:self message:tableRow.message atIndexPath:indexPath];
		if (tableRow.isNotSelectable)
			switchView.enabled = FALSE;
	}
	else if (tableRow.isController)
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	else {
		cell.detailTextLabel.text = tableRow.detailTitle;
		cell.textLabel.textColor = tableRow.isDestructive ? [TGColor dynamicRedColor] : [TGColor dynamicTintColor];
	}
	if ((tableRow.isNotSelectable) && (!hasSwitch)) {
		[cell setUserInteractionEnabled:NO];
		cell.contentView.alpha = 0.2;
	}
	return cell;
}
-(void)switchChanged:(TGSwitch*)sender {
	[[NSUserDefaults standardUserDefaults] setBool:sender.on forKey:sender.key];
	[[NSUserDefaults standardUserDefaults] synchronize];
	TGTableViewCell *cell = (TGTableViewCell*)[sender superview];
	TGTableRow *row = cell.row;
	if (row.handler != nil)
		[row execHandler];
	else if (sender.restartRequired) {
		sender.restartRequired = FALSE;
		[super showAlertWithTitle:@"Restart to apply changes." message:nil];
	}
}
#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	TGTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
	TGTableRow *row = cell.row;
	if ([row isSelectable])
		[row execHandler];
}
@end
