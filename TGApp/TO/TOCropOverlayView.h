#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TOCropOverlayView : UIView
@property (nonatomic, assign) BOOL gridHidden;
@property (nonatomic, assign) BOOL displayHorizontalGridLines;
@property (nonatomic, assign) BOOL displayVerticalGridLines;
- (void)setGridHidden:(BOOL)hidden animated:(BOOL)animated;
@end

NS_ASSUME_NONNULL_END
