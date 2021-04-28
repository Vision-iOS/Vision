@interface TGDotView : UIView {
	int _activeDot;
}
-(void)changeDot;
-(void)updatePosition;
-(void)buildDots;
-(instancetype)initWithFrame:(CGRect)frame;
@end
