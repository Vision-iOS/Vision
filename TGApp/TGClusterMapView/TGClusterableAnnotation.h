#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "TGMapCluster.h"

@interface TGClusterableAnnotation : NSObject <MKAnnotation>
@property (nonatomic) CLLocationCoordinate2D coordinate;
@property (nonatomic, readwrite) BOOL isMyLocation;
-(instancetype)initWithDictionary:(NSDictionary *)dictionary;
-(UIImage*)image;
@end
