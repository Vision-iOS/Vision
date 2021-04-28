#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN
@interface TOActivityCroppedImageProvider : UIActivityItemProvider
@property (nonnull, nonatomic, readonly) UIImage *image;
@property (nonatomic, readonly) CGRect cropFrame;
@property (nonatomic, readonly) NSInteger angle;
@property (nonatomic, readonly) BOOL circular;
- (nonnull instancetype)initWithImage:(nonnull UIImage *)image cropFrame:(CGRect)cropFrame angle:(NSInteger)angle circular:(BOOL)circular;
@end
NS_ASSUME_NONNULL_END
