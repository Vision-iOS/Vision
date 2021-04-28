#import "TGImages.h"
#import "TGConfettiView.h"
#import "TGViewController.h"

@interface TGImagesViewController : TGViewController <UITableViewDelegate, UITableViewDataSource> {
    UIImage *_originalImage;
    NSString *_metadata;
}
@property (nonatomic, retain) NSString *path;
@property (nonatomic, retain) TGImages *images;
@property (nonatomic, retain) TGConfettiView *confettiView;
@property (nonatomic, assign) int mode;
@property (nonatomic, retain) id delegate;
-(instancetype)initWithImage:(UIImage*)image originalImage:(UIImage*)originalImage;
-(instancetype)initWithEditedImage:(UIImage*)image path:(NSString *)path metadata:(NSString *)metadata;
@end
