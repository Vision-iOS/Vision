#import <UIKit/UIKit.h>
#import "TOCropViewConstants.h"

@class TOCropOverlayView;
@class TOCropView;

NS_ASSUME_NONNULL_BEGIN

@protocol TOCropViewDelegate<NSObject>
- (void)cropViewDidBecomeResettable:(nonnull TOCropView *)cropView;
- (void)cropViewDidBecomeNonResettable:(nonnull TOCropView *)cropView;
@end

@interface TOCropView : UIView
@property (nonnull, nonatomic, strong, readonly) UIImage *image;
@property (nonatomic, assign, readonly) TOCropViewCroppingStyle croppingStyle;
@property (nonnull, nonatomic, strong, readonly) TOCropOverlayView *gridOverlayView;
@property (nonnull, nonatomic, readonly) UIView *foregroundContainerView;
@property (nullable, nonatomic, weak) id<TOCropViewDelegate> delegate;
@property (nonatomic, assign) BOOL cropBoxResizeEnabled;
@property (nonatomic, readonly) BOOL canBeReset;
@property (nonatomic, readonly) CGRect cropBoxFrame;
@property (nonatomic, readonly) CGRect imageViewFrame;
@property (nonatomic, assign) UIEdgeInsets cropRegionInsets;
@property (nonatomic, assign) BOOL simpleRenderMode;
@property (nonatomic, assign) BOOL internalLayoutDisabled;
@property (nonatomic, assign) CGSize aspectRatio;
@property (nonatomic, assign) BOOL aspectRatioLockEnabled;
@property (nonatomic, assign) BOOL aspectRatioLockDimensionSwapEnabled;
@property (nonatomic, assign) BOOL resetAspectRatioEnabled;
@property (nonatomic, readonly) BOOL cropBoxAspectRatioIsPortrait;
@property (nonatomic, assign) NSInteger angle;
@property (nonatomic, assign) BOOL croppingViewsHidden;
@property (nonatomic, assign) CGRect imageCropFrame;
@property (nonatomic, assign) BOOL gridOverlayHidden;
@property (nonatomic) CGFloat cropViewPadding;
@property (nonatomic) NSTimeInterval cropAdjustingDelay;
@property (nonatomic, assign) CGFloat minimumAspectRatio;
@property (nonatomic, assign) CGFloat maximumZoomScale;
@property (nonatomic, assign) BOOL alwaysShowCroppingGrid;
@property (nonatomic, assign) BOOL translucencyAlwaysHidden;
- (nonnull instancetype)initWithImage:(nonnull UIImage *)image;
- (nonnull instancetype)initWithCroppingStyle:(TOCropViewCroppingStyle)style image:(nonnull UIImage *)image;
- (void)performInitialSetup;
- (void)setSimpleRenderMode:(BOOL)simpleMode animated:(BOOL)animated;
- (void)prepareforRotation;
- (void)performRelayoutForRotation;
- (void)resetLayoutToDefaultAnimated:(BOOL)animated;
- (void)setAspectRatio:(CGSize)aspectRatio animated:(BOOL)animated;
- (void)rotateImageNinetyDegreesAnimated:(BOOL)animated;
- (void)rotateImageNinetyDegreesAnimated:(BOOL)animated clockwise:(BOOL)clockwise;
- (void)setGridOverlayHidden:(BOOL)gridOverlayHidden animated:(BOOL)animated;
- (void)setCroppingViewsHidden:(BOOL)hidden animated:(BOOL)animated;
- (void)setBackgroundImageViewHidden:(BOOL)hidden animated:(BOOL)animated;
- (void)moveCroppedContentToCenterAnimated:(BOOL)animated;
@end

NS_ASSUME_NONNULL_END
