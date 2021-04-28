#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TOCropViewControllerTransitioning : NSObject <UIViewControllerAnimatedTransitioning>
@property (nonatomic, assign) BOOL isDismissing;
@property (nullable, nonatomic, strong) UIImage *image;
@property (nullable, nonatomic, strong) UIView *fromView;
@property (nullable, nonatomic, strong) UIView *toView;

@property (nonatomic, assign) CGRect fromFrame;
@property (nonatomic, assign) CGRect toFrame;
@property (nullable, nonatomic, copy) void (^prepareForTransitionHandler)(void);
- (void)reset;

@end

NS_ASSUME_NONNULL_END
