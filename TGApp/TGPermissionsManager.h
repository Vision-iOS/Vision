@import CoreLocation;
@interface TGPermissionsManager : NSObject <CLLocationManagerDelegate> {
	NSInteger _cameraPermissionStatus;
    CLLocationManager *_locationManager;
}
@property (nonatomic, readwrite) BOOL hasCameraPermission;
@property (nonatomic, readwrite) BOOL hasLocation;
@property (nonatomic, readwrite) BOOL hasCameraRestriction;
@property (nonatomic, assign) CGFloat latitude;
@property (nonatomic, assign) CGFloat longitude;
+(instancetype)sharedInstance;
-(void)askCameraPermissionWithCompletionHandler:(void (^)(BOOL))completionHandler;
-(void)askPhotoPermissionWithCompletionHandler:(void (^)(BOOL))completionHandler;
-(void)askLocationPermission;
-(void)updateLocation;
@end
