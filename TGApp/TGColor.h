@interface TGColor : NSObject
@property (nonatomic, retain) id tintColor;
@property (nonatomic, retain) id redColor;
@property (nonatomic, retain) id yellowColor;
@property (nonatomic, retain) id subTextColor;
+(BOOL)isDarkInterface;
+(UIImage*)tintImage:(UIImage*)image withColor:(UIColor*)color;
+(id)dynamicColorWithLight:(UIColor*)light dark:(UIColor*)dark;
+(id)dynamicTintColor;
+(id)dynamicRedColor;
+(id)dynamicYellowColor;
+(id)dynamicTextColor;
+(id)dynamicBackgroundColor;
+(id)defaultBlueColor;
+(id)dynamicNavigationBarColor;
+(id)dynamicToastBackgroundColor;
+(id)dynamicToastTextColor;
+(id)dynamicSubTextColor;
@end
