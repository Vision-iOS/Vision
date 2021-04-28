#import "TO/TOCropViewController.h"

@interface TGMainViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate, TOCropViewControllerDelegate>{
	int _page;
	UIImage *_lastOriginalImage;
}
+(void)closeAlertIndicator;
@end
