#import "UIKit/UIKit.h"
#include "TGImage.h"

@implementation TGImage
-(instancetype)initWithName:(NSString*)name image:(UIImage*)image confidence:(CGFloat)confidence latitude:(CGFloat)latitude longitude:(CGFloat)longitude{
	self = [super init];
	self.name = name;
	self.image = image;
	self.confidence = confidence;
    self.latitude = latitude;
    self.longitude = longitude;
	return self;
}

+(UIImage *)fixrotation:(UIImage *)image{
if (image.imageOrientation == UIImageOrientationUp) return image;
CGAffineTransform transform = CGAffineTransformIdentity;

switch (image.imageOrientation) {
    case UIImageOrientationDown:
    case UIImageOrientationDownMirrored:
        transform = CGAffineTransformTranslate(transform, image.size.width, image.size.height);
        transform = CGAffineTransformRotate(transform, M_PI);
        break;

    case UIImageOrientationLeft:
    case UIImageOrientationLeftMirrored:
        transform = CGAffineTransformTranslate(transform, image.size.width, 0);
        transform = CGAffineTransformRotate(transform, M_PI_2);
        break;

    case UIImageOrientationRight:
    case UIImageOrientationRightMirrored:
        transform = CGAffineTransformTranslate(transform, 0, image.size.height);
        transform = CGAffineTransformRotate(transform, -M_PI_2);
        break;
    case UIImageOrientationUp:
    case UIImageOrientationUpMirrored:
        break;
}

switch (image.imageOrientation) {
    case UIImageOrientationUpMirrored:
    case UIImageOrientationDownMirrored:
        transform = CGAffineTransformTranslate(transform, image.size.width, 0);
        transform = CGAffineTransformScale(transform, -1, 1);
        break;

    case UIImageOrientationLeftMirrored:
    case UIImageOrientationRightMirrored:
        transform = CGAffineTransformTranslate(transform, image.size.height, 0);
        transform = CGAffineTransformScale(transform, -1, 1);
        break;
    case UIImageOrientationUp:
    case UIImageOrientationDown:
    case UIImageOrientationLeft:
    case UIImageOrientationRight:
        break;
}

// Now we draw the underlying CGImage into a new context, applying the transform
// calculated above.
CGContextRef ctx = CGBitmapContextCreate(NULL, image.size.width, image.size.height,
                                         CGImageGetBitsPerComponent(image.CGImage), 0,
                                         CGImageGetColorSpace(image.CGImage),
                                         CGImageGetBitmapInfo(image.CGImage));
CGContextConcatCTM(ctx, transform);
switch (image.imageOrientation) {
    case UIImageOrientationLeft:
    case UIImageOrientationLeftMirrored:
    case UIImageOrientationRight:
    case UIImageOrientationRightMirrored:
        // Grr...
        CGContextDrawImage(ctx, CGRectMake(0,0,image.size.height,image.size.width), image.CGImage);
        break;

    default:
        CGContextDrawImage(ctx, CGRectMake(0,0,image.size.width,image.size.height), image.CGImage);
        break;
}

// And now we just create a new UIImage from the drawing context
CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
UIImage *img = [UIImage imageWithCGImage:cgimg];
CGContextRelease(ctx);
CGImageRelease(cgimg);
return img;
}

+(UIImage *)imageWithImage:(UIImage *)image convertToSize:(CGSize)size {
    if(image){
        UIGraphicsBeginImageContext(size);
        [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
        UIImage *destImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return destImage;
    }
    return NULL;
}

@end


