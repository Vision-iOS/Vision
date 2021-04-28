#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TOCropScrollView : UIScrollView

@property (nullable, nonatomic, copy) void (^touchesBegan)(void);
@property (nullable, nonatomic, copy) void (^touchesCancelled)(void);
@property (nullable, nonatomic, copy) void (^touchesEnded)(void);

@end

NS_ASSUME_NONNULL_END
