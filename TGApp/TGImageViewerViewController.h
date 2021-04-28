#import <UIKit/UIKit.h>
#import "TGImagesController.h"

@interface TGImageViewerViewController : UIViewController <UIScrollViewDelegate, CAAnimationDelegate>
@property (nonatomic, retain) TGImagesController *collectionController;
@property (nonatomic, readwrite) BOOL isSingle;
@property (nonatomic, readwrite) BOOL canEdit;
@property (nonatomic, readwrite) BOOL isPreviewing;
@property (nonatomic) UIImage *image;
@property (nonatomic) UIScrollView *scrollView;
@property (nonatomic) UIImageView *imageView;
@property (nonatomic, retain) NSArray *images;
@property (nonatomic, retain) NSArray *paths;
@property (nonatomic, retain) NSArray *metadata;
@property (nonatomic, retain) NSArray *realMetadata;
@property (nonatomic, assign) int index;
+(instancetype)forImage:(UIImage*)image;
-(id)initWithImage:(UIImage*)image;
@end
