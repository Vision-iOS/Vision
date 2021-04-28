#import "UIKit/UIKit.h"
#include "TGLabel.h"

@implementation TGLabel // Sottoclasse di UILabel per permettere di creare un label con i margini laterali 10-10.
- (void)drawTextInRect:(CGRect)rect {
    UIEdgeInsets insets = {0, 10, 0, 10};
    [super drawTextInRect:UIEdgeInsetsInsetRect(rect, insets)];
}
@end
