@interface UIScrollableLabel : UIView {
    UILabel *textLabel;
    NSTimer *timer;
}
- (void) setLabelText:(NSString*) text;
- (void) setLabelFont:(UIFont*)font;
- (void) setLabelTextColor:(UIColor*)color;
- (void) setLabelTextAlignment:(UITextAlignment)alignment;
-(UILabel*)textLabel;
@end
