@interface TGButton : UIButton
-(instancetype)initWithCoder:(NSCoder*)coder;
+(TGButton*)buttonNamed:(NSString*)name frame:(CGRect)frame view:(UIView*)view;
+(UIImage*)rectedImageWithSize:(CGSize)size color:(id)color;
@end
