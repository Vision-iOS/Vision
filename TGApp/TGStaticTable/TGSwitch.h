#import "UIKit/UIKit.h"

@interface TGSwitch : UISwitch {
	NSString *_name;
	NSString *_key;
}
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *key;
@property (nonatomic, readwrite) BOOL restartRequired;
+(TGSwitch*)switchWithName:(NSString*)name key:(NSString*)key target:(id)target isOn:(BOOL)on;
+(TGSwitch*)switchWithName:(NSString*)name key:(NSString*)key target:(id)target;
+(TGSwitch*)switchWithName:(NSString*)name key:(NSString*)key target:(id)target isOn:(BOOL)on generalKey:(NSString*)generalKey;
+(TGSwitch*)switchView;
@end
