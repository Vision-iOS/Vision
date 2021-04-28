#import "TGMapPointAnnotation.h"

@implementation TGMapPointAnnotation

-(instancetype)initWithAnnotation:(id<MKAnnotation>)annotation {
    if (self = [super init]) {
        _mapPoint = MKMapPointForCoordinate(annotation.coordinate);
        _annotation = annotation;
    }
    return self;
}

@end
