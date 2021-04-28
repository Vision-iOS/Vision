#import "UIKit/UIKit.h"
#include "TGCircleButton.h"
#import "TGColor.h"

@implementation TGCircleButton
@synthesize row = _row;
@synthesize section = _section;
+(TGCircleButton*)buttonAtIndexPath:(NSIndexPath*)indexPath delegate:(id)delegate name:(NSString*)name message:(NSString*)message {
    TGCircleButton *button = [TGCircleButton buttonWithType:UIButtonTypeDetailDisclosure];
	button.name = name;
	button.row = indexPath.row;
	button.section = indexPath.section;
	button.tintColor = [TGColor dynamicTintColor];
	[button addTarget:delegate action:@selector(showAlertForButton:) forControlEvents:UIControlEventTouchUpInside];
	return button;
}
@end
