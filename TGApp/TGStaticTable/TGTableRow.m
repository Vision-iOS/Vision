#import "UIKit/UIKit.h"
#include "TGTableRow.h"

@implementation TGTableRow
-(instancetype)init {
	self = [super init];
	self.height = UITableViewAutomaticDimension;
	return self;
}
+(TGTableRow*)rowControllerWithTitle:(NSString*)title icon:(NSString*)name 
handler:(void(^)(void))handler {
	TGTableRow *row = [self rowControllerWithTitle:title icon:name];
	[row addHandler:handler];
	return row;
}
+(TGTableRow*)rowControllerWithTitle:(NSString*)title icon:(NSString*)name {
	TGTableRow *row = [self rowWithTitle:title key:@"CONTROLLER"];
	[row setImageNamed:name];
	return row;
}
+(TGTableRow*)rowWithTitle:(NSString*)title key:(NSString*)key icon:(NSString*)icon {
	TGTableRow *row = [self rowWithTitle:title key:key];
	[row setImageNamed:icon];
	return row;
}
+(TGTableRow*)rowWithTitle:(NSString*)title key:(NSString*)key {
	TGTableRow *row = [[TGTableRow alloc] init];
	row.title = title;
	if ([key isEqualToString:@"CONTROLLER"])
		row.isController = TRUE;
	else
	if (![key isEqualToString:@"NULL"])
		row.key = key;
	//row.message = message;
	return row;
}
+(TGTableRow*)rowWithTitle:(NSString*)title key:(NSString*)key message:(NSString*)message {
	TGTableRow *row = [[TGTableRow alloc] init];
	row.title = title;
	if ([key isEqualToString:@"CONTROLLER"])
		row.isController = TRUE;
	else
	if (![key isEqualToString:@"NULL"])
		row.key = key;
	row.message = message;
	return row;
}
-(void)setImageNamed:(NSString*)name {
    self.image = [UIImage imageNamed:name];
}
-(BOOL)isSelectable {
	return ((self.handler != nil) && (!self.key));
}
-(void)addGesture:(void(^)(void))gesture {
	self.gestureHandler = gesture;
}
-(void)addHandler:(void(^)(void))handler {
	self.handler = handler;
}
-(void)addHandler:(void(^)(void))handler isDestructive:(BOOL)destructive {
	self.handler = handler;
	self.isDestructive = destructive;
}
-(void)execGesture {
	self.gestureHandler();
}
-(void)execHandler {
	self.handler();
}
@end
