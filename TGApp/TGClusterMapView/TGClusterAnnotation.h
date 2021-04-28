#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@class TGMapCluster;

#define kTGCoordinate2DOffscreen CLLocationCoordinate2DMake(85.0, 179.0)

BOOL TGClusterCoordinate2DIsOffscreen(CLLocationCoordinate2D coord);

typedef NS_ENUM(NSInteger, TGClusterAnnotationType) {
    TGClusterAnnotationTypeUnknown = 0,
    TGClusterAnnotationTypeLeaf = 1,
    TGClusterAnnotationTypeCluster = 2
};

@interface TGClusterAnnotation : NSObject <MKAnnotation>
@property (nonatomic) TGClusterAnnotationType type;
@property (nonatomic) CLLocationCoordinate2D coordinate;
@property (nonatomic, weak, nullable) TGMapCluster *cluster;
@property (nonatomic) BOOL shouldBeRemovedAfterAnimation;
@property (weak, nonatomic, readonly, nullable) NSArray<id<MKAnnotation>> *originalAnnotations;
-(void)reset;
@end

