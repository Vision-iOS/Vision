@interface TGImage : NSObject
@property (nonatomic, retain) UIImage *image;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, assign) CGFloat confidence;
@property (nonatomic, assign) CGFloat latitude;
@property (nonatomic, assign) CGFloat longitude;
-(instancetype)initWithName:(NSString*)name image:(UIImage*)image confidence:(CGFloat)confidence latitude:(CGFloat)latitude longitude:(CGFloat)longitude;
+(UIImage *)fixrotation:(UIImage *)image;
+(UIImage *)imageWithImage:(UIImage *)image convertToSize:(CGSize)size;
@end
