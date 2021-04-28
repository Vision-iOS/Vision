#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@class TGClusterAnnotation;
@class TGClusterMapView;

@protocol TGClusterMapViewDelegate <MKMapViewDelegate>
@optional
-(NSInteger)numberOfClustersInMapView:(nonnull TGClusterMapView *)mapView;
-(nonnull MKAnnotationView*)mapView:(nonnull TGClusterMapView *)mapView viewForClusterAnnotation:(nonnull id <MKAnnotation>)annotation;
-(BOOL)shouldShowSubtitleForClusterAnnotationsInMapView:(nonnull TGClusterMapView *)mapView;
-(double)clusterDiscriminationPowerForMapView:(nonnull TGClusterMapView *)mapView;
-(nullable NSString*)clusterTitleForMapView:(nonnull TGClusterMapView *)mapView;
-(void)clusterAnimationDidStopForMapView:(nonnull TGClusterMapView *)mapView;
-(void)mapViewDidFinishClustering:(nonnull TGClusterMapView *)mapView;
@end

@interface TGClusterMapView : MKMapView <MKMapViewDelegate>
@property (nonatomic, readonly, nonnull) NSArray<id<MKAnnotation>> *displayedAnnotations;
@property (nonatomic, readonly, nonnull) NSArray<TGClusterAnnotation *> *displayedClusterAnnotations;

-(void)addAnnotation:(nonnull id<MKAnnotation>)annotation NS_UNAVAILABLE;
-(void)addAnnotations:(nonnull NSArray<id<MKAnnotation>> *)annotations NS_UNAVAILABLE;
-(nullable TGClusterAnnotation *)clusterAnnotationForOriginalAnnotation:(nonnull id<MKAnnotation>)annotation;
-(void)selectClusterAnnotation:(nonnull TGClusterAnnotation *)annotation animated:(BOOL)animated;
-(void)setAnnotations:(nullable NSArray<id<MKAnnotation>> *)annotations;
-(void)addNonClusteredAnnotation:(nonnull id<MKAnnotation>)annotation;
-(void)addNonClusteredAnnotations:(nonnull NSArray<id<MKAnnotation>> *)annotations;
-(void)removeNonClusteredAnnotation:(nonnull id<MKAnnotation>)annotation;
-(void)removeNonClusteredAnnotations:(nonnull NSArray<id<MKAnnotation>> *)annotations;
@end
