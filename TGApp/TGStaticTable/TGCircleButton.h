#import "UIKit/UIKit.h"

@interface TGCircleButton : UIButton {
	int _row;
	int _section;
}
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *message;
@property (nonatomic, assign) int row;
@property (nonatomic, assign) int section;
+(TGCircleButton*)buttonAtIndexPath:(NSIndexPath*)indexPath delegate:(id)delegate name:(NSString*)name message:(NSString*)message;
@end
