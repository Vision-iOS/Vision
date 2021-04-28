#import "TGClusterAnnotation.h"
#import "TGMapCluster.h"

BOOL TGClusterCoordinate2DIsOffscreen(CLLocationCoordinate2D coord) {
    return (coord.latitude == kTGCoordinate2DOffscreen.latitude && coord.longitude == kTGCoordinate2DOffscreen.longitude);
}

@implementation TGClusterAnnotation
@synthesize cluster = _cluster;
-(id)init {
    self = [super init];
    if (self) {
        _cluster = nil;
        self.coordinate = kTGCoordinate2DOffscreen;
        _type = TGClusterAnnotationTypeUnknown;
        _shouldBeRemovedAfterAnimation = NO;
    }
    return self;
}
-(void)setCluster:(TGMapCluster*)cluster {
    [self willChangeValueForKey:@"title"];
    [self willChangeValueForKey:@"subtitle"];
    _cluster = cluster;
    [self didChangeValueForKey:@"subtitle"];
    [self didChangeValueForKey:@"title"];
}
-(TGMapCluster*)cluster {
    return _cluster;
}

-(NSString*)title {
    return self.cluster.title;
}
-(NSString *)subtitle {
    return self.cluster.subtitle;
}
-(void)reset {
    self.cluster = nil;
    self.coordinate = kTGCoordinate2DOffscreen;
}
-(NSArray<id<MKAnnotation>> *)originalAnnotations {
    NSAssert(self.cluster != nil, @"This annotation should have a cluster assigned!"); // Ritorna nil se non c'è il cluster che contiene le annotazioni.
    return self.cluster.originalAnnotations;
}
@end