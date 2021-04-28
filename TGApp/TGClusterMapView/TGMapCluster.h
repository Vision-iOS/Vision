#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@class TGMapPointAnnotation;

@interface TGMapCluster : NSObject
@property (nonatomic) CLLocationCoordinate2D clusterCoordinate;
@property (weak, nonatomic, readonly, nullable) NSString * title;
@property (weak, nonatomic, readonly, nullable) NSString * subtitle;
@property (nonatomic, strong, nullable) TGMapPointAnnotation * annotation;
@property (nonatomic, readonly, nonnull) NSMutableArray<id<MKAnnotation>> * originalAnnotations;
@property (nonatomic, readonly) NSInteger depth;
@property (nonatomic, assign) BOOL showSubtitle;
- (nonnull instancetype)initWithAnnotations:(nullable NSArray<TGMapPointAnnotation *> *)annotations
                                    atDepth:(NSInteger)depth
                                  inMapRect:(MKMapRect)mapRect
                                      gamma:(double)gamma
                               clusterTitle:(nullable NSString *)clusterTitle
                               showSubtitle:(BOOL)showSubtitle;
+ (nonnull TGMapCluster *)rootClusterForAnnotations:(nonnull NSArray<TGMapPointAnnotation *> *)annotations
                                              gamma:(double)gamma
                                       clusterTitle:(nullable NSString *)clusterTitle
                                       showSubtitle:(BOOL)showSubtitle;
- (nonnull NSArray<TGMapCluster *> *)find:(NSInteger)N
                        childrenInMapRect:(MKMapRect)mapRect;
- (nonnull NSArray<TGMapCluster *> *)children;
- (BOOL)isAncestorOf:(nonnull TGMapCluster *)mapCluster;
- (BOOL)isRootClusterForAnnotation:(nonnull id<MKAnnotation>)annotation;
- (NSInteger)numberOfChildren;
- (nonnull NSArray<NSString *> *)namesOfChildren;
@end

