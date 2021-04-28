#import "TOActivityCroppedImageProvider.h"
#import "UIImage+CropRotate.h"

@interface TOActivityCroppedImageProvider ()
@property (nonatomic, strong, readwrite) UIImage *image;
@property (nonatomic, assign, readwrite) CGRect cropFrame;
@property (nonatomic, assign, readwrite) NSInteger angle;
@property (nonatomic, assign, readwrite) BOOL circular;
@property (atomic, strong) UIImage *croppedImage;
@end

@implementation TOActivityCroppedImageProvider

-(instancetype)initWithImage:(UIImage *)image cropFrame:(CGRect)cropFrame angle:(NSInteger)angle circular:(BOOL)circular {
    if (self = [super initWithPlaceholderItem:[UIImage new]]) {
        _image = image;
        _cropFrame = cropFrame;
        _angle = angle;
        _circular = circular;
    }
    return self;
}

#pragma mark - UIActivity Protocols -
- (id)activityViewControllerPlaceholderItem:(UIActivityViewController *)activityViewController {
    return [[UIImage alloc] init];
}
- (id)activityViewController:(UIActivityViewController *)activityViewController itemForActivityType:(NSString *)activityType {
    return self.croppedImage;
}
#pragma mark - Image Generation -
- (id)item {
    if (self.angle == 0 && CGRectEqualToRect(self.cropFrame, (CGRect){CGPointZero, self.image.size})) { // Ritorna l'immagine originale se l'utente non ha interagito con essa.
        self.croppedImage = self.image;
        return self.croppedImage;
    }
    UIImage *image = [self.image croppedImageWithFrame:self.cropFrame angle:self.angle circularClip:self.circular];
    self.croppedImage = image;
    return self.croppedImage;
}
@end
