#import <UIKit/UIKit.h>

#import "TOCropViewConstants.h"
#import "TOCropView.h"
#import "TOCropToolbar.h"

@class TOCropViewController;

@protocol TOCropViewControllerDelegate <NSObject>
@optional
- (void)cropViewController:(nonnull TOCropViewController *)cropViewController
        didCropImageToRect:(CGRect)cropRect
                     angle:(NSInteger)angle;
- (void)cropViewController:(nonnull TOCropViewController *)cropViewController
            didCropToImage:(nonnull UIImage *)image withRect:(CGRect)cropRect
                     angle:(NSInteger)angle;
- (void)cropViewController:(nonnull TOCropViewController *)cropViewController
    didCropToCircularImage:(nonnull UIImage *)image withRect:(CGRect)cropRect
                     angle:(NSInteger)angle;
- (void)cropViewController:(nonnull TOCropViewController *)cropViewController
        didFinishCancelled:(BOOL)cancelled;
@end

@interface TOCropViewController : UIViewController
@property (nonnull, nonatomic, readonly) UIImage *image;
@property (nonatomic, assign) CGFloat minimumAspectRatio;
@property (nullable, nonatomic, weak) id<TOCropViewControllerDelegate> delegate;
@property (nonatomic, assign) BOOL showActivitySheetOnDone;
@property (nonnull, nonatomic, strong, readonly) TOCropView *cropView;
@property (nonatomic, assign) CGRect imageCropFrame;
@property (nonatomic, assign) NSInteger angle;
@property (nonnull, nonatomic, strong, readonly) TOCropToolbar *toolbar;
@property (nonatomic, readonly) TOCropViewCroppingStyle croppingStyle;
@property (nonatomic, assign) TOCropViewControllerAspectRatioPreset aspectRatioPreset;
@property (nonatomic, assign) CGSize customAspectRatio;
@property (nullable, nonatomic, copy) NSString *customAspectRatioName;
@property (nullable, nonatomic, readonly) UILabel *titleLabel;
@property (nullable, nonatomic, copy) NSString *doneButtonTitle;
@property (nullable, nonatomic, copy) NSString *cancelButtonTitle;
@property (nonatomic, assign) BOOL showCancelConfirmationDialog;
@property (nonatomic, assign) BOOL aspectRatioLockDimensionSwapEnabled;
@property (nonatomic, assign) BOOL aspectRatioLockEnabled;
@property (nonatomic, assign) BOOL resetAspectRatioEnabled;
@property (nonatomic, assign) TOCropViewControllerToolbarPosition toolbarPosition;
@property (nonatomic, assign) BOOL rotateClockwiseButtonHidden;
@property (nonatomic, assign) BOOL hidesNavigationBar;
@property (nonatomic, assign) BOOL rotateButtonsHidden;
@property (nonatomic, assign) BOOL resetButtonHidden;
@property (nonatomic, assign) BOOL aspectRatioPickerButtonHidden;
@property (nonatomic, assign) BOOL doneButtonHidden;
@property (nonatomic, assign) BOOL cancelButtonHidden;
@property (nullable, nonatomic, strong) NSArray *activityItems;
@property (nullable, nonatomic, strong) NSArray<UIActivity *> *applicationActivities;
@property (nullable, nonatomic, strong) NSArray<UIActivityType> *excludedActivityTypes;
@property (nullable, nonatomic, strong) NSArray<NSNumber *> *allowedAspectRatios;
@property (nullable, nonatomic, strong) void (^onDidFinishCancelled)(BOOL isFinished);
@property (nullable, nonatomic, strong) void (^onDidCropImageToRect)(CGRect cropRect, NSInteger angle);
@property (nullable, nonatomic, strong) void (^onDidCropToRect)(UIImage* _Nonnull image, CGRect cropRect, NSInteger angle);
@property (nullable, nonatomic, strong) void (^onDidCropToCircleImage)(UIImage* _Nonnull image, CGRect cropRect, NSInteger angle);
- (nonnull instancetype)initWithImage:(nonnull UIImage *)image NS_SWIFT_NAME(init(image:));
- (nonnull instancetype)initWithCroppingStyle:(TOCropViewCroppingStyle)style image:(nonnull UIImage *)image NS_SWIFT_NAME(init(croppingStyle:image:));
- (void)resetCropViewLayout;
- (void)setAspectRatioPreset:(TOCropViewControllerAspectRatioPreset)aspectRatioPreset animated:(BOOL)animated NS_SWIFT_NAME(setAspectRatioPresent(_:animated:));
- (void)presentAnimatedFromParentViewController:(nonnull UIViewController *)viewController
                                       fromView:(nullable UIView *)fromView
                                      fromFrame:(CGRect)fromFrame
                                          setup:(nullable void (^)(void))setup
                                     completion:(nullable void (^)(void))completion NS_SWIFT_NAME(presentAnimatedFrom(_:view:frame:setup:completion:));
- (void)presentAnimatedFromParentViewController:(nonnull UIViewController *)viewController
                                      fromImage:(nullable UIImage *)image
                                       fromView:(nullable UIView *)fromView
                                      fromFrame:(CGRect)fromFrame
                                          angle:(NSInteger)angle
                                   toImageFrame:(CGRect)toFrame
                                          setup:(nullable void (^)(void))setup
                                     completion:(nullable void (^)(void))completion NS_SWIFT_NAME(presentAnimatedFrom(_:fromImage:fromView:fromFrame:angle:toFrame:setup:completion:));
- (void)dismissAnimatedFromParentViewController:(nonnull UIViewController *)viewController
                                         toView:(nullable UIView *)toView
                                        toFrame:(CGRect)frame
                                          setup:(nullable void (^)(void))setup
                                     completion:(nullable void (^)(void))completion NS_SWIFT_NAME(dismissAnimatedFrom(_:toView:toFrame:setup:completion:));

- (void)dismissAnimatedFromParentViewController:(nonnull UIViewController *)viewController
                               withCroppedImage:(nullable UIImage *)image
                                         toView:(nullable UIView *)toView
                                        toFrame:(CGRect)frame
                                          setup:(nullable void (^)(void))setup
                                     completion:(nullable void (^)(void))completion NS_SWIFT_NAME(dismissAnimatedFrom(_:croppedImage:toView:toFrame:setup:completion:));

- (void)dismissCropViewControllerWithCompletion:(void (^_Nullable)(void))handler;
@end

