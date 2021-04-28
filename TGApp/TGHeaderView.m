#import "TGHeaderView.h"
#import "TGColor.h"

@implementation TGHeaderView
/*
-(instancetype)initWithTitle:(NSString*)title subtitle:(NSString*)subtitle {
	UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
	titleLabel.backgroundColor = [UIColor clearColor];
	titleLabel.textColor = [TGColor dynamicTextColor];
	titleLabel.font = [UIFont boldSystemFontOfSize:16];
	titleLabel.text = title;
	[titleLabel sizeToFit];
	UILabel *subtitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 21, 0, 0)];
	subtitleLabel.backgroundColor = [UIColor clearColor];
	subtitleLabel.textColor = [TGColor dynamicSubTextColor];
	subtitleLabel.font = [UIFont systemFontOfSize:10];
	subtitleLabel.text = subtitle;
	[subtitleLabel sizeToFit];
	CGFloat width = MAX(subtitleLabel.frame.size.width, titleLabel.frame.size.width);
	self = [[TGHeaderView alloc] initWithFrame:CGRectMake(0, 0, width, 30)];
	_titleLabel = titleLabel;
	_subtitleLabel = subtitleLabel;
	[self addSubview:_titleLabel];
	[self addSubview:_subtitleLabel];
	_titleLabel.frame = CGRectMake(0, 0, self.frame.size.width, _titleLabel.frame.size.height);
	_subtitleLabel.frame = CGRectMake(0, 21, self.frame.size.width, _subtitleLabel.frame.size.height);
	[_titleLabel setTextAlignment:NSTextAlignmentCenter];
	[_subtitleLabel setTextAlignment:NSTextAlignmentCenter];
	return self;
}*/
-(instancetype)initWithTitle:(NSString*)title subtitle:(NSString*)subtitle {
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 25)];
    titleLabel.text = title;
    [titleLabel sizeToFit];
    UIScrollableLabel *scrollableLabel;
    if(titleLabel.frame.size.width > 200){
        scrollableLabel = [[UIScrollableLabel alloc] initWithFrame:CGRectMake(0, 0, 200, 25)];
        [scrollableLabel setLabelText:title];
        [scrollableLabel setLabelFont:[UIFont boldSystemFontOfSize:16]];
        [scrollableLabel setLabelTextColor:[TGColor dynamicTextColor]];
        UILabel *textLabel = [scrollableLabel textLabel];
        [textLabel sizeToFit];
    }
    //UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = [TGColor dynamicTextColor];
    titleLabel.font = [UIFont boldSystemFontOfSize:16];
    titleLabel.text = title;
    [titleLabel sizeToFit];
    UILabel *subtitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 21, 0, 0)];
    subtitleLabel.backgroundColor = [UIColor clearColor];
    subtitleLabel.textColor = [TGColor dynamicSubTextColor];
    subtitleLabel.font = [UIFont systemFontOfSize:10];
    subtitleLabel.text = subtitle;
    [subtitleLabel sizeToFit];
    CGFloat width = scrollableLabel ? MAX(subtitleLabel.frame.size.width, scrollableLabel.frame.size.width) : MAX(subtitleLabel.frame.size.width, titleLabel.frame.size.width);
    self = [[TGHeaderView alloc] initWithFrame:CGRectMake(0, 0, width, 30)];
    if(scrollableLabel)
        [self addSubview:scrollableLabel];
    else
        [self addSubview:titleLabel];
    [self addSubview:subtitleLabel];
    titleLabel.frame = CGRectMake(0, 0, self.frame.size.width, titleLabel.frame.size.height);
    subtitleLabel.frame = CGRectMake(0, 21, self.frame.size.width, subtitleLabel.frame.size.height);
    [titleLabel setTextAlignment:NSTextAlignmentCenter];
    [subtitleLabel setTextAlignment:NSTextAlignmentCenter];
    return self;
}
-(void)destruct {
	_gestureRecognizer = nil;
	self.handler = nil;
	[self removeFromSuperview];
}
-(void)addHandler:(void(^)(void))handler {
	_gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(execHandler)];
	_gestureRecognizer.numberOfTapsRequired = 1;
	[self addGestureRecognizer:_gestureRecognizer];
	self.handler = handler;
}
-(void)execHandler {
	self.handler();
}
-(void)touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event {
	if (self.handler) {
		_isHighlighted = TRUE;
		[UIView transitionWithView:self duration:0.3f options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
			self.alpha = 0.4;
		} completion:nil];
	}
}
-(void)touchesEnded:(NSSet*)touches withEvent:(UIEvent*)event {
	if (self.handler) {
		_isHighlighted = FALSE;
		[UIView transitionWithView:self duration:0.3f options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
       	self.alpha = 1.0;
		} completion:nil];
	}
}
-(void)touchesCancelled:(NSSet*)touches withEvent:(UIEvent*)event {
	if (self.handler) {
		_isHighlighted = FALSE;
		[UIView transitionWithView:self duration:0.3f options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
			self.alpha = 1.0;
		} completion:nil];
	}
}
-(UIView*)touchedViewWithTouches:(NSSet*)touches andEvent:(UIEvent*)event {
	UITouch *touch = [[event allTouches] anyObject];
	CGPoint touchLocation = [touch locationInView:touch.view];
	UIView *touchedView;
	for (UIView *view in self.subviews) {
		if ((CGRectContainsPoint(view.frame, touchLocation)) || (CGRectContainsPoint([view superview].frame, touchLocation))) {
			touchedView = view;
			break;
		}
	}
	return touchedView;
}
-(void)touchesMoved:(NSSet*)touches withEvent:(UIEvent*)event {
	if (self.handler) {
		UIView *view = [self touchedViewWithTouches:touches andEvent:event];
		if (!view && _isHighlighted) {
			_isHighlighted = FALSE;
			[UIView transitionWithView:self duration:0.3f options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
				self.alpha = 1.0;
			} completion:nil];
		}
		else if (view && !_isHighlighted) {
			_isHighlighted = TRUE;
			[UIView transitionWithView:self duration:0.3f options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
				self.alpha = 0.4;
			} completion:nil];
		}
	}
}
@end
