#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "UIScrollableLabel.h"
#import "TGColor.h"

@implementation UIScrollableLabel

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
       // Initialization code
        self.clipsToBounds = YES;
        self.autoresizesSubviews = YES;

        textLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, frame.size.width,   frame.size.height)];
        textLabel.backgroundColor = [UIColor clearColor];
        textLabel.textColor = [TGColor dynamicTextColor];
        textLabel.textAlignment = UITextAlignmentRight;
        [self addSubview:textLabel];
    }
    return self;
}
-(UILabel*)textLabel{
    return textLabel;
}
-(void) setLabelText:(NSString*) text {

    textLabel.text  = text;
    CGSize textSize = [text sizeWithFont:textLabel.font];

    if(textSize.width > self.frame.size.width) {
        textLabel.frame = CGRectMake(0, 0, textSize.width, self.frame.size.height);
    }
    else {
        textLabel.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    }

    if(textLabel.frame.size.width > self.frame.size.width) {

      [timer invalidate];
      timer = nil;
      CGRect frame = textLabel.frame;
      frame.origin.x = self.frame.size.width-50;
      textLabel.frame = frame;
      timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(moveText) userInfo:nil repeats:YES];
    }
    else {
        [timer invalidate];
        timer = nil;
    }
  }

-(void) moveText {

    if(textLabel.frame.origin.x < textLabel.frame.size.width-2*textLabel.frame.size.width) {
        CGRect frame = textLabel.frame;
        frame.origin.x = self.frame.size.width;
        textLabel.frame = frame;
    }
    [UIView beginAnimations:nil context:nil];
    CGRect frame = textLabel.frame;
    frame.origin.x -= 5;
    textLabel.frame = frame;
    [UIView commitAnimations];

}

- (void) setLabelFont:(UIFont*)font {
    textLabel.font = font;
}

- (void) setLabelTextColor:(UIColor*)color {
    textLabel.textColor = color;
}

- (void) setLabelTextAlignment:(UITextAlignment)alignment {
    textLabel.textAlignment = alignment;
}
@end
