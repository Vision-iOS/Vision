#import "UIKit/UIKit.h"
#import "UIScrollableLabel.h"

@interface TGHeaderView : UIView {
	UITapGestureRecognizer *_gestureRecognizer;
	BOOL _isHighlighted;
}
@property (nonatomic, copy) void (^handler)(void);
-(instancetype)initWithTitle:(NSString*)title subtitle:(NSString*)subtitle;
-(void)addHandler:(void(^)(void))handler;
-(void)destruct;
@end
