#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, SpriteType) {
    Confetti = 0,
    Star,
    Diamond,
    Triangle
};

@interface TGConfettiView : UIView
@property (nonatomic, assign) SpriteType spriteType;
@property (nonatomic, assign) CGFloat intensity;


- (void)starConfetti;
- (void)stopConfetti;
@end
