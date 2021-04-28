
#import <UIKit/UIKit.h>
#import "TOCropViewConstants.h"

NS_ASSUME_NONNULL_BEGIN

@interface TOCropToolbar : UIView
@property (nonatomic, assign) CGFloat statusBarHeightInset;
@property (nonatomic, assign) UIEdgeInsets backgroundViewOutsets;
@property (nonatomic, strong, readonly) UIButton *doneTextButton;
@property (nonatomic, strong, readonly) UIButton *doneIconButton;
@property (nonatomic, copy) NSString *doneTextButtonTitle;
@property (nonatomic, strong, readonly) UIButton *cancelTextButton;
@property (nonatomic, strong, readonly) UIButton *cancelIconButton;
@property (nonatomic, readonly) UIView *visibleCancelButton;
@property (nonatomic, copy) NSString *cancelTextButtonTitle;
@property (nonatomic, strong, readonly)  UIButton *rotateCounterclockwiseButton;
@property (nonatomic, strong, readonly)  UIButton *resetButton;
@property (nonatomic, strong, readonly)  UIButton *clampButton;
@property (nullable, nonatomic, strong, readonly) UIButton *rotateClockwiseButton;
@property (nonatomic, readonly) UIButton *rotateButton;
@property (nullable, nonatomic, copy) void (^cancelButtonTapped)(void);
@property (nullable, nonatomic, copy) void (^doneButtonTapped)(void);
@property (nullable, nonatomic, copy) void (^rotateCounterclockwiseButtonTapped)(void);
@property (nullable, nonatomic, copy) void (^rotateClockwiseButtonTapped)(void);
@property (nullable, nonatomic, copy) void (^clampButtonTapped)(void);
@property (nullable, nonatomic, copy) void (^resetButtonTapped)(void);
@property (nonatomic, assign) BOOL clampButtonGlowing;
@property (nonatomic, readonly) CGRect clampButtonFrame;
@property (nonatomic, assign) BOOL clampButtonHidden;
@property (nonatomic, assign) BOOL rotateCounterclockwiseButtonHidden;
@property (nonatomic, assign) BOOL rotateClockwiseButtonHidden;
@property (nonatomic, assign) BOOL resetButtonHidden;
@property (nonatomic, assign) BOOL doneButtonHidden;
@property (nonatomic, assign) BOOL cancelButtonHidden;
@property (nonatomic, assign) BOOL resetButtonEnabled;
@property (nonatomic, readonly) CGRect doneButtonFrame;
@end

NS_ASSUME_NONNULL_END
