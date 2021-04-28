#import "UIKit/UIKit.h"
#include "TGPermissionsManager.h"
#import <AVFoundation/AVFoundation.h>
@import Photos;

static TGPermissionsManager *manager = nil;


@implementation TGPermissionsManager
+(instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
		manager = [[TGPermissionsManager alloc] init];
	});
	return manager;
}
-(instancetype)init {
	if (self = [super init]) {
		_cameraPermissionStatus = 0;
        _locationManager = [[CLLocationManager alloc] init];
		AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
		self.hasCameraPermission = authStatus == AVAuthorizationStatusAuthorized;
		self.hasCameraRestriction = authStatus == AVAuthorizationStatusRestricted;
	}
	return self;
}
-(void)didPermissionChanged {
	// Implementare receiver.
}
-(void)validateCameraPermission {
	self.hasCameraPermission = TRUE;
	self.hasCameraRestriction = FALSE;
	[[NSNotificationCenter defaultCenter] postNotificationName:@"tg_openCamera" object:nil];
}
-(void)invalidateCameraPermissionOfType:(NSInteger)type {
	_cameraPermissionStatus = type;
}
-(void)forceCameraPermission {
	[AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL success) {
		if (success)
			[self validateCameraPermission];
		else
			[self invalidateCameraPermissionOfType:1]; // DECLINED
	}];
}
-(void)askLocationPermission{
    // [[NSOperationQueue mainQueue] addOperationWithBlock:^{
    _locationManager.delegate = self;
    _locationManager.distanceFilter = kCLDistanceFilterNone;
    _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [_locationManager requestWhenInUseAuthorization];
    if(CLLocationManager.authorizationStatus == kCLAuthorizationStatusAuthorizedWhenInUse || CLLocationManager.authorizationStatus == kCLAuthorizationStatusAuthorizedAlways){
        [_locationManager startUpdatingLocation];
    }
    // }];
}
-(void)updateLocation {
    [_locationManager startUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    CLLocation *location = [locations lastObject];
    //NSLog(@"TELEFONO: [POSIZIONE] lat(%f) - lon(%f)", location.coordinate.latitude, location.coordinate.longitude);
    self.latitude = location.coordinate.latitude;
    self.longitude = location.coordinate.longitude;
    self.hasLocation = true;
   // NSLog(@"CLASSE: [POSIZIONE] lat(%f) - lon(%f)", self.latitude, self.longitude);
}
-(void)askCameraPermissionWithCompletionHandler:(void (^)(BOOL))completionHandler {
	AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (authStatus == AVAuthorizationStatusAuthorized){
        self.hasCameraPermission = TRUE;
        self.hasCameraRestriction = FALSE;
        completionHandler(YES);
    } else if (authStatus == AVAuthorizationStatusNotDetermined) {
		[AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL success) {
            if (success){
                self.hasCameraPermission = TRUE;
                self.hasCameraRestriction = FALSE;
                completionHandler(YES);
            }else{
                [self invalidateCameraPermissionOfType:1]; // DECLINED
                completionHandler(FALSE);
            }
		}];
	}
    else if (authStatus == AVAuthorizationStatusRestricted){
        [self invalidateCameraPermissionOfType:2]; // RESTRICTED
        completionHandler(FALSE);
    }
    else{
         [self invalidateCameraPermissionOfType:0]; // UNKNOWN
         completionHandler(FALSE);
    }
}
-(void)askPhotoPermissionWithCompletionHandler:(void (^)(BOOL))completionHandler {
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];

    if (status == PHAuthorizationStatusAuthorized) {
         completionHandler(TRUE);
    }

    else if (status == PHAuthorizationStatusDenied) {
         completionHandler(FALSE);
    }

    else if (status == PHAuthorizationStatusNotDetermined) {

         [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {

             if (status == PHAuthorizationStatusAuthorized) {
                completionHandler(TRUE);
             }

             else {
                completionHandler(FALSE);
             }
         }];
    }

    else if (status == PHAuthorizationStatusRestricted) {
         completionHandler(FALSE);
    }else{
        completionHandler(FALSE);
    }
}
@end
