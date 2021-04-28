@interface TGBarButtonItem : UIBarButtonItem
@property (nonatomic, copy) void (^handler)(void);
+(TGBarButtonItem*)withTitle:(id)title handler:(void(^)(void))handler;
+(TGBarButtonItem*)buttonInController:(UIViewController*)controller withTitle:(id)title handler:(void(^)(void))handler;
-(TGBarButtonItem*)initWithTitle:(id)title handler:(void(^)(void))handler;
-(void)addToRight:(UIViewController*)controller;
-(void)addToLeft:(UIViewController*)controller;
@end

