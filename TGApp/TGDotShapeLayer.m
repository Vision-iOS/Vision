#import "UIKit/UIKit.h"
#include "TGDotShapeLayer.h"

@implementation TGDotShapeLayer
+(TGDotShapeLayer*)dotShapeLayerFromSublayers:(NSArray*)array {
	if (array) {
		for (id obj in array)
			if ([obj isMemberOfClass:[self class]])
				return obj;
	}
	return NULL;
}
+(TGDotShapeLayer*)dotShapeLayerLocated:(int)location tag:(int)tag {
	TGDotShapeLayer *shapeLayer = [TGDotShapeLayer layer]; // Crea un nuovo layer.
	shapeLayer.path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(location, 7, 7, 7)].CGPath; // Specifica il path del layer (di tipo circolare).
	shapeLayer.strokeColor = [UIColor colorWithWhite:0.2f alpha:1.0f].CGColor; // Specifica il colore del contorno del layer.
	shapeLayer.fillColor = [UIColor colorWithWhite:0.8f alpha:1.0f].CGColor; // Specifica il colore del colore del layer.
	shapeLayer.tag = tag; // Diamo un tag al layer, per trovarlo più facilmente in seguito.
	return shapeLayer;
}
-(void)fillLayer {
	self.fillColor = [UIColor colorWithWhite:0.3f alpha:1.0f].CGColor; // Imposta il colore.
}
-(void)unfillLayer {
	self.fillColor = [UIColor colorWithWhite:0.8f alpha:1.0f].CGColor; // Imposta il colore.
}
@end
