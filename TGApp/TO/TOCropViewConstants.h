
#import <Foundation/Foundation.h>
typedef NS_ENUM(NSInteger, TOCropViewCroppingStyle) {
    TOCropViewCroppingStyleDefault,
    TOCropViewCroppingStyleCircular
};

typedef NS_ENUM(NSInteger, TOCropViewControllerAspectRatioPreset) {
    TOCropViewControllerAspectRatioPresetOriginal,
    TOCropViewControllerAspectRatioPresetSquare,
    TOCropViewControllerAspectRatioPreset3x2,
    TOCropViewControllerAspectRatioPreset5x3,
    TOCropViewControllerAspectRatioPreset4x3,
    TOCropViewControllerAspectRatioPreset5x4,
    TOCropViewControllerAspectRatioPreset7x5,
    TOCropViewControllerAspectRatioPreset16x9,
    TOCropViewControllerAspectRatioPresetCustom
};

typedef NS_ENUM(NSInteger, TOCropViewControllerToolbarPosition) {
    TOCropViewControllerToolbarPositionBottom,
    TOCropViewControllerToolbarPositionTop
};

static inline NSBundle *TO_CROP_VIEW_RESOURCE_BUNDLE_FOR_OBJECT(NSObject *object) {
#if SWIFT_PACKAGE
   	NSString *bundleName = @"TOCropViewController_TOCropViewController";
#else
	NSString *bundleName = @"TOCropViewControllerBundle";
#endif
    NSBundle *resourceBundle = nil;
    NSBundle *classBundle = [NSBundle bundleForClass:object.class];
    NSURL *resourceBundleURL = [classBundle URLForResource:bundleName withExtension:@"bundle"];
    if (resourceBundleURL) {
        resourceBundle = [[NSBundle alloc] initWithURL:resourceBundleURL];
		#ifndef NDEBUG
		if (resourceBundle == nil) {
		    @throw [[NSException alloc] initWithName:@"BundleAccessor" reason:[NSString stringWithFormat:@"unable to find bundle named %@", bundleName] userInfo:nil];
		}
		#endif
    } else {
        resourceBundle = classBundle;
    }
    return resourceBundle;
}
