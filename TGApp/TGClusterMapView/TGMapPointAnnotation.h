#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface TGMapPointAnnotation : NSObject
@property (nonatomic, readonly) MKMapPoint mapPoint;
@property (nonatomic, readonly, nonnull) id<MKAnnotation> annotation;
-(nonnull instancetype)initWithAnnotation:(nonnull id<MKAnnotation>)annotation;
@end

