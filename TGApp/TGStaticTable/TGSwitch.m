#import "UIKit/UIKit.h"
#include "TGSwitch.h"
#import "TGColor.h"

@implementation TGSwitch
@synthesize name = _name;
@synthesize key = _key;
+(TGSwitch*)switchWithName:(NSString*)name key:(NSString*)key target:(id)target isOn:(BOOL)on generalKey:(NSString*)generalKey {
	TGSwitch *switchView = [TGSwitch switchView];
	switchView.name = name;
	switchView.key = key;
	[switchView setOn:on animated:NO];
	if (generalKey) {
		switchView.enabled = [[NSUserDefaults standardUserDefaults] boolForKey:generalKey];
		if (!switchView.enabled)
			[switchView setOn:FALSE animated:NO];
	}
	[switchView addTarget:target action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
	return switchView;
}
+(TGSwitch*)switchWithName:(NSString*)name key:(NSString*)key target:(id)target isOn:(BOOL)on {
	TGSwitch *switchView = [TGSwitch switchView];
	switchView.name = name;
	switchView.key = key;
	[switchView setOn:on animated:NO];
	[switchView addTarget:target action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
	return switchView;
}
+(TGSwitch*)switchWithName:(NSString*)name key:(NSString*)key target:(id)target {
	BOOL on = [[NSUserDefaults standardUserDefaults] boolForKey:key];
	TGSwitch *switchView = [TGSwitch switchView];
	switchView.name = name;
	switchView.key = key;
	[switchView setOn:on animated:NO];
	[switchView addTarget:target action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
	return switchView;
}
+(TGSwitch*)switchView {
	TGSwitch *switchView = [[TGSwitch alloc] initWithFrame:CGRectMake(0,0,0,0)];
	[switchView setOnTintColor:[TGColor dynamicTintColor]];
	return switchView;
}
@end
