#import <QuartzCore/CoreAnimation.h>
#import "TGClusterMapView.h"
#import "TGClusterAnnotation.h"
#import "TGMapCluster.h"
#import "TGMapPointAnnotation.h"


const static CGFloat kDefaultGamma = 1.0f;

@interface TGClusterMapView () {
@private
    __weak id <TGClusterMapViewDelegate> _secondaryDelegate;
    TGMapCluster *_rootMapCluster;
    BOOL _isAnimatingClusters;
    BOOL _shouldComputeClusters;
}
@property (strong, nonatomic) NSMutableArray *clusterAnnotations;
@property (strong, nonatomic) NSMutableArray *clusterAnnotationsToAddAfterAnimation;
-(void)_initElements;
-(TGClusterAnnotation *)_newAnnotationWithCluster:(TGMapCluster *)cluster ancestorAnnotation:(TGClusterAnnotation*)ancestor;
-(NSInteger)_numberOfClusters;
-(NSMutableArray<TGClusterAnnotation *> *)_leafAnnotationsFromAnnotations:(NSArray<id<MKAnnotation>>*)annotations;
-(void)_clusterDisplayedClusterAnnotationsInMapRect:(MKMapRect)rect;
-(void)_clusterAnnotations:(NSArray<id<MKAnnotation>> *)annotations inMapRect:(MKMapRect)rect;
-(BOOL)_annotation:(TGClusterAnnotation *)annotation belongsToClusters:(NSArray *)clusters;
-(void)_handleClusterAnimationEnded;
-(void)_addClusterAnnotation:(id <MKAnnotation>)annotation;
-(void)_addClusterAnnotations:(NSArray <id <MKAnnotation>> *)annotations;
@end

@implementation TGClusterMapView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame]; // Crea il frame.
    if (self) {
        [self _initElements]; // Inizializza gli elementi.
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self _initElements];
    }
    return self;
}

#pragma mark - MKMapView
-(void)addAnnotation:(id<MKAnnotation>)annotation {
    NSAssert(NO, @"Cannot be used for now"); // Se non appare il pin, riscrivi la funzione.
}

-(void)addAnnotations:(NSArray<id<MKAnnotation>> *)annotations {
    NSAssert(NO, @"Cannot be used for now"); // Se non appare il pin, riscrivi la funzione.
}

-(void)removeAnnotation:(id<MKAnnotation>)annotation {
    [self.clusterAnnotations removeObject:annotation]; // Rimuovi l'annotazione dall'array che contiene tutte le annotazioni.
    [super removeAnnotation:annotation]; // Rimuovila anche dalla superclasse.
}

-(void)removeAnnotations:(NSArray<id<MKAnnotation>> *)annotations {
    [self.clusterAnnotations removeObjectsInArray:annotations]; // Rimuovi le annotazioni dall'array che contiene tutte le annotazioni.
    [super removeAnnotations:annotations];// Rimuovile anche dalla superclasse.
}

-(void)selectAnnotation:(id<MKAnnotation>)annotation animated:(BOOL)animated {
    TGClusterAnnotation * clusterAnnotation = [self clusterAnnotationForOriginalAnnotation:annotation];
    id<MKAnnotation> annotationToSelect = clusterAnnotation ?: annotation;
    [super selectAnnotation:annotationToSelect animated:animated];
}

#pragma mark - Getters
-(NSArray<id<MKAnnotation>> *)displayedAnnotations {
    return [self annotationsInMapRect:self.visibleMapRect].allObjects;
}

-(NSArray<TGClusterAnnotation *> *)displayedClusterAnnotations {
    return [self.displayedAnnotations filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self isKindOfClass: %@", [TGClusterAnnotation class]]];
}

#pragma mark - Methods
-(TGClusterAnnotation *)clusterAnnotationForOriginalAnnotation:(id<MKAnnotation>)annotation {
    NSAssert(![annotation isKindOfClass:[TGClusterAnnotation class]], @"Unexpected annotation!");
    for (TGClusterAnnotation * clusterAnnotation in self.displayedClusterAnnotations) {
        if ([clusterAnnotation.cluster isRootClusterForAnnotation:annotation]) {
            return clusterAnnotation;
        }
    }
    return nil;
}

-(void)selectClusterAnnotation:(TGClusterAnnotation *)annotation animated:(BOOL)animated {
    [super selectAnnotation:annotation animated:animated];
}
-(void)setAnnotations:(NSArray<id<MKAnnotation>> *)annotations {
    [self removeAnnotations:self.annotations];
    NSMutableArray<id<MKAnnotation>> * leafClusterAnnotations = [self _leafAnnotationsFromAnnotations:annotations];
    [self.clusterAnnotations addObjectsFromArray:leafClusterAnnotations];
    double gamma = kDefaultGamma;
    if ([_secondaryDelegate respondsToSelector:@selector(clusterDiscriminationPowerForMapView:)]) {
        gamma = [_secondaryDelegate clusterDiscriminationPowerForMapView:self];
    }
    NSString * clusterTitle = @"%d elements";
    if ([_secondaryDelegate respondsToSelector:@selector(clusterTitleForMapView:)]) {
        clusterTitle = [_secondaryDelegate clusterTitleForMapView:self];
    }
    BOOL shouldShowSubtitle = YES;
    if ([_secondaryDelegate respondsToSelector:@selector(shouldShowSubtitleForClusterAnnotationsInMapView:)]) {
        shouldShowSubtitle = [_secondaryDelegate shouldShowSubtitleForClusterAnnotationsInMapView:self];
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        NSMutableArray<TGMapPointAnnotation *> * mapPointAnnotations = [[NSMutableArray alloc] initWithCapacity:annotations.count];;
        for (id<MKAnnotation> annotation in annotations) {
            TGMapPointAnnotation * mapPointAnnotation = [[TGMapPointAnnotation alloc] initWithAnnotation:annotation];
            [mapPointAnnotations addObject:mapPointAnnotation];
        }
        _rootMapCluster = [TGMapCluster rootClusterForAnnotations:mapPointAnnotations gamma:gamma clusterTitle:clusterTitle showSubtitle:shouldShowSubtitle];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self _clusterAnnotations:leafClusterAnnotations inMapRect:self.visibleMapRect];
            NSPredicate * predicate = [NSPredicate predicateWithFormat:@"%K = nil", NSStringFromSelector(@selector(cluster))];
            NSArray * annotationNotDisplayedAfterClustering = [self.clusterAnnotations filteredArrayUsingPredicate:predicate];
            [self removeAnnotations:annotationNotDisplayedAfterClustering];
            if ([_secondaryDelegate respondsToSelector:@selector(mapViewDidFinishClustering:)]) {
                [_secondaryDelegate mapViewDidFinishClustering:self];
            }
        });
    });
}

-(void)addNonClusteredAnnotation:(nonnull id<MKAnnotation>)annotation {
    [super addAnnotation:annotation];
}

-(void)addNonClusteredAnnotations:(nonnull NSArray<id<MKAnnotation>> *)annotations {
    [super addAnnotations:annotations];
}

-(void)removeNonClusteredAnnotation:(nonnull id<MKAnnotation>)annotation {
    [super removeAnnotation:annotation];
}

-(void)removeNonClusteredAnnotations:(nonnull NSArray<id<MKAnnotation>> *)annotations {
    [super removeAnnotations:annotations];
}
- (void)setDelegate:(id<TGClusterMapViewDelegate>)delegate {
	// Imposta prima il delegato a nil, poi salvalo come secondo delegato e imposta l'istanza attuale come delegato principale.
    [super setDelegate:nil];
    _secondaryDelegate = delegate;
    [super setDelegate:self];
}

-(BOOL)respondsToSelector:(SEL)aSelector {
    BOOL respondsToSelector = [super respondsToSelector:aSelector] || [_secondaryDelegate respondsToSelector:aSelector];
    return respondsToSelector;
}

-(id)forwardingTargetForSelector:(SEL)aSelector {
    if ([_secondaryDelegate respondsToSelector:aSelector]) {
        return _secondaryDelegate;
    }
    return [super forwardingTargetForSelector:aSelector];
}

-(void)forwardInvocation:(NSInvocation *)anInvocation {
    if ([_secondaryDelegate respondsToSelector:[anInvocation selector]]) {
        [anInvocation invokeWithTarget:_secondaryDelegate];
    } else {
        [super forwardInvocation:anInvocation];
    }
}

#pragma mark - MKMapViewDelegate
-(MKAnnotationView *)mapView:(nonnull MKMapView *)mapView viewForAnnotation:(nonnull id<MKAnnotation>)annotation {
    if (![annotation isKindOfClass:[TGClusterAnnotation class]]) {
        if ([_secondaryDelegate respondsToSelector:@selector(mapView:viewForAnnotation:)]) {
            return [_secondaryDelegate mapView:self viewForAnnotation:annotation];
        }
        return nil;
	}
    if (((TGClusterAnnotation *)annotation).type == TGClusterAnnotationTypeLeaf || ![_secondaryDelegate respondsToSelector:@selector(mapView:viewForClusterAnnotation:)]) {
        if ([_secondaryDelegate respondsToSelector:@selector(mapView:viewForAnnotation:)]) {
            return [_secondaryDelegate mapView:self viewForAnnotation:annotation];
        }
        return nil;
    }
    return [_secondaryDelegate mapView:self viewForClusterAnnotation:annotation];
}
- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    if (_isAnimatingClusters) {
        _shouldComputeClusters = YES;
    } else {
        _isAnimatingClusters = YES;
        [self _clusterDisplayedClusterAnnotationsInMapRect:self.visibleMapRect];
    }
    for (id<MKAnnotation> annotation in [self selectedAnnotations]) {
        [self deselectAnnotation:annotation animated:YES];
    }
    if ([_secondaryDelegate respondsToSelector:@selector(mapView:regionDidChangeAnimated:)]) {
        [_secondaryDelegate mapView:self regionDidChangeAnimated:animated];
    }
}
- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
    if ([_secondaryDelegate respondsToSelector:@selector(mapView:didSelectAnnotationView:)]) {
        [_secondaryDelegate mapView:mapView didSelectAnnotationView:view];
    }
}
- (void)_initElements {
    _clusterAnnotations = [[NSMutableArray alloc] init];
    _clusterAnnotationsToAddAfterAnimation = [[NSMutableArray alloc] init];
}

- (TGClusterAnnotation *)_newAnnotationWithCluster:(TGMapCluster *)cluster ancestorAnnotation:(TGClusterAnnotation *)ancestor {
    TGClusterAnnotation * annotation = [[TGClusterAnnotation alloc] init];
    annotation.type = (cluster.numberOfChildren == 1) ? TGClusterAnnotationTypeLeaf : TGClusterAnnotationTypeCluster;
    annotation.cluster = cluster;
    annotation.coordinate = (ancestor) ? ancestor.coordinate : cluster.clusterCoordinate;
    return annotation;
}

- (NSInteger)_numberOfClusters {
    NSInteger numberOfClusters = 32; // default value
    if ([_secondaryDelegate respondsToSelector:@selector(numberOfClustersInMapView:)]) {
        numberOfClusters = [_secondaryDelegate numberOfClustersInMapView:self];
    }
    return numberOfClusters;
}

- (NSMutableArray<TGClusterAnnotation *> *)_leafAnnotationsFromAnnotations:(NSArray<id<MKAnnotation>> *)annotations {
    NSMutableArray<id<MKAnnotation>> * leafClusterAnnotations = [[NSMutableArray alloc] initWithCapacity:annotations.count];
    for (id<MKAnnotation> originalAnotation in annotations) {
        TGClusterAnnotation * annotation = [[TGClusterAnnotation alloc] init];
        annotation.type = TGClusterAnnotationTypeLeaf;
        annotation.coordinate = [originalAnotation coordinate];
        [leafClusterAnnotations addObject:annotation];
    }
    return leafClusterAnnotations;
}

- (void)_clusterAnnotations:(NSArray<id<MKAnnotation>> *)annotations inMapRect:(MKMapRect)rect {
    NSArray * clustersToShowOnMap = [_rootMapCluster find:[self _numberOfClusters] childrenInMapRect:rect];

    NSMutableArray<TGClusterAnnotation *> * annotationToRemoveFromMap = [[NSMutableArray alloc] init];
    NSMutableArray<TGClusterAnnotation *> * annotationToAddToMap = [[NSMutableArray alloc] init];
    NSMutableArray<TGClusterAnnotation *> * selfDividingAnnotations = [[NSMutableArray alloc] init];
    NSMutableArray * displayedAnnotation = [NSMutableArray arrayWithArray:annotations];

    for (TGClusterAnnotation * annotation in displayedAnnotation) {
        if ([annotation isKindOfClass:[MKUserLocation class]] || !annotation.cluster) {
            continue;
        }

        for (TGMapCluster * cluster in clustersToShowOnMap) {
            if (![annotation.cluster isAncestorOf:cluster])
                continue;
            [selfDividingAnnotations addObject:annotation];
            break;
        }
    }
    for (TGClusterAnnotation * annotation in selfDividingAnnotations) {
        TGMapCluster * originalAnnotationCluster = annotation.cluster;
        for (TGMapCluster * cluster in clustersToShowOnMap) {
            if (![originalAnnotationCluster isAncestorOf:cluster])
                continue;
            TGClusterAnnotation * newAnnotation = [self _newAnnotationWithCluster:cluster ancestorAnnotation:annotation];
            [annotationToRemoveFromMap addObject:annotation];
            [annotationToAddToMap addObject:newAnnotation];
        }
    }
    for (TGMapCluster * cluster in clustersToShowOnMap) {
        BOOL didAlreadyFindAChild = NO;
        for (__strong TGClusterAnnotation * annotation in displayedAnnotation) {
            if ([annotation isKindOfClass:[MKUserLocation class]] || !annotation.cluster || ![cluster isAncestorOf:annotation.cluster])
                continue;
            if (!didAlreadyFindAChild) {
                TGClusterAnnotation * newAnnotation = [[TGClusterAnnotation alloc] init];
                newAnnotation.type = TGClusterAnnotationTypeCluster;
                newAnnotation.cluster = cluster;
                newAnnotation.coordinate = cluster.clusterCoordinate;
                [self.clusterAnnotationsToAddAfterAnimation addObject:newAnnotation];
            }
            annotation.cluster = cluster;
            annotation.shouldBeRemovedAfterAnimation = YES;
            didAlreadyFindAChild = YES;
        }
    }

    [self _addClusterAnnotations:annotationToAddToMap];
    [self removeAnnotations:annotationToRemoveFromMap];
    [displayedAnnotation addObjectsFromArray:annotationToAddToMap];
    [displayedAnnotation removeObjectsInArray:annotationToRemoveFromMap];

    [UIView animateWithDuration:0.5f animations:^{
        for (TGClusterAnnotation * annotation in displayedAnnotation) {
            if ([annotation isKindOfClass:[MKUserLocation class]]) {
                continue;
            }
            if (![annotation isKindOfClass:[MKUserLocation class]] && annotation.cluster) {
                NSAssert(!TGClusterCoordinate2DIsOffscreen(annotation.coordinate), @"annotation.coordinate not valid! Can't animate from an invalid coordinate (inconsistent result)!");
                annotation.coordinate = annotation.cluster.clusterCoordinate;
            }
        }
    } completion:^(BOOL finished) {
        [self _handleClusterAnimationEnded];;
    }];


    // Add not-yet-annotated clusters
    annotationToAddToMap = [[NSMutableArray alloc] init];

    for (TGMapCluster * cluster in clustersToShowOnMap) {
        BOOL isAlreadyAnnotated = NO;
        for (TGClusterAnnotation * annotation in displayedAnnotation) {
            if (![annotation isKindOfClass:[MKUserLocation class]]) {
                if ([cluster isEqual:annotation.cluster]) {
                    isAlreadyAnnotated = YES;
                    break;
                }
            }
        }
        if (!isAlreadyAnnotated) {
            TGClusterAnnotation * newAnnotation = [self _newAnnotationWithCluster:cluster ancestorAnnotation:nil];
            [annotationToAddToMap addObject:newAnnotation];
        }
    }
    [self _addClusterAnnotations:annotationToAddToMap];
}

- (void)_clusterDisplayedClusterAnnotationsInMapRect:(MKMapRect)rect {
    [self _clusterAnnotations:self.displayedClusterAnnotations inMapRect:rect];
}

- (BOOL)_annotation:(nonnull TGClusterAnnotation *)annotation belongsToClusters:(NSArray<TGMapCluster *> *)clusters {
    if (!annotation.cluster) {
        return NO;
    }
    for (TGMapCluster * cluster in clusters) {
        if ([cluster isAncestorOf:annotation.cluster] || [cluster isEqual:annotation.cluster]) {
            return YES;
        }
    }
    return NO;
}

- (void)_handleClusterAnimationEnded {
    NSMutableArray * annotationToRemove = [[NSMutableArray alloc] init];;
    for (TGClusterAnnotation * annotation in self.annotations) {
        if ([annotation isKindOfClass:[MKUserLocation class]]) {
            continue;
        }
        if ([annotation isKindOfClass:[TGClusterAnnotation class]]) {
            if (annotation.shouldBeRemovedAfterAnimation) {
                [annotationToRemove addObject:annotation];
            }
        }
    }
    [self removeAnnotations:annotationToRemove];
    [self _addClusterAnnotations:self.clusterAnnotationsToAddAfterAnimation];
    [self.clusterAnnotationsToAddAfterAnimation removeAllObjects];
    _isAnimatingClusters = NO;
    if (_shouldComputeClusters) { // do one more computation if the user moved the map while animating
        _shouldComputeClusters = NO;
        [self _clusterDisplayedClusterAnnotationsInMapRect:self.visibleMapRect];
    }
    if ([_secondaryDelegate respondsToSelector:@selector(clusterAnimationDidStopForMapView:)]) {
        [_secondaryDelegate clusterAnimationDidStopForMapView:self];
    }
}

- (void)_addClusterAnnotation:(id<MKAnnotation>)annotation {
    [self.clusterAnnotations addObject:annotation];
    [super addAnnotation:annotation];
}

- (void)_addClusterAnnotations:(NSArray<id<MKAnnotation>> *)annotations {
    [self.clusterAnnotations addObjectsFromArray:annotations];
    [super addAnnotations:annotations];
}

@end
