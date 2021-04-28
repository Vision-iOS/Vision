#import "UIKit/UIKit.h"

@interface TGTableRow : NSObject {
}
@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *detailTitle;
@property (nonatomic, retain) NSString *key;
@property (nonatomic, retain) NSString *message;
@property (nonatomic, assign) CGFloat height;
@property (nonatomic, retain) UIImage *image;
@property (nonatomic, retain) NSString *badgeKey;
@property (nonatomic, readwrite) BOOL isDestructive;
@property (nonatomic, readwrite) BOOL restartRequired;
@property (nonatomic, readwrite) BOOL isController;
@property (nonatomic, readwrite) BOOL isNotSelectable;
@property (nonatomic, retain) UILongPressGestureRecognizer *gesture;
@property (nonatomic, copy) void (^handler)(void);
@property (nonatomic, copy) void (^gestureHandler)(void);
@property (nonatomic, retain) id cell;
+(TGTableRow*)rowWithTitle:(NSString*)title key:(NSString*)key icon:(NSString*)icon;
+(TGTableRow*)rowControllerWithTitle:(NSString*)title icon:(NSString*)name 
handler:(void(^)(void))handler;
+(TGTableRow*)rowControllerWithTitle:(NSString*)title icon:(NSString*)name;
+(TGTableRow*)rowWithTitle:(NSString*)title key:(NSString*)key;
+(TGTableRow*)rowWithTitle:(NSString*)title key:(NSString*)key message:(NSString*)message;
-(void)setImageNamed:(NSString*)name;
-(BOOL)isSelectable;
-(void)addGesture:(void(^)(void))handler;
-(void)addHandler:(void(^)(void))handler;
-(void)addHandler:(void(^)(void))handler isDestructive:(BOOL)destructive;
-(void)execGesture;
-(void)execHandler;
@end
