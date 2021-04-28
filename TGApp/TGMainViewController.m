#import "UIKit/UIKit.h"
#import "TGMainViewController.h"
#import "TGBarButtonItem.h"
#import "TGButton.h"
#import "TGImagesViewController.h"
#import "TGDotView.h"
#import "TGPermissionsManager.h"
#import "TGLabel.h"
#import "TGColor.h"
#import "UIView+Toast.h"
#import <Foundation/Foundation.h>

static CGPoint (^CGRectGetCenter)(CGRect) = ^(CGRect rect) {
    return CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect));
};
static bool isTutorial = FALSE;
static UIAlertController *pending = nil;
@implementation TGMainViewController
-(void)showAlertIndicator {
    pending = [UIAlertController alertControllerWithTitle:nil message:@"Scanning image..." preferredStyle:UIAlertControllerStyleAlert];
    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    indicator.color = [TGColor dynamicTextColor];
    indicator.translatesAutoresizingMaskIntoConstraints=NO;
    [pending.view addSubview:indicator];
    NSDictionary *views = @{@"pending" : pending.view, @"indicator" : indicator};
    NSArray *constraintsVertical = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[indicator]-(20)-|" options:0 metrics:nil views:views];
    NSArray *constraintsHorizontal = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[indicator]|" options:0 metrics:nil views:views];
    NSArray *constraints = [constraintsVertical arrayByAddingObjectsFromArray:constraintsHorizontal];
    [pending.view addConstraints:constraints];
    [indicator setUserInteractionEnabled:NO];
    [indicator startAnimating];
    [self presentViewController:pending animated:YES completion:nil];
}
+(void)closeAlertIndicator {
   /* UIApplication *sharedApplication = [UIApplication sharedApplication];
    UIWindow *window = sharedApplication.windows.firstObject;
    UITabBarController *tabBarController = (UITabBarController*)window.rootViewController;
    UINavigationController *navigationController = tabBarController.childViewControllers.firstObject;
    TGMainViewController *controller = (TGMainViewController*)navigationController.childViewControllers.firstObject;*/
    [pending dismissViewControllerAnimated:YES completion:nil];
}
-(BOOL)shouldShowHomePage {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if([defaults boolForKey:@"forceTutorial"])
        return false;
    return [defaults boolForKey:@"welcomeShown"];
}
-(void)configureImage:(id)object {
	UIImage *image;
	if (object) {
		if ([object isKindOfClass:[NSData class]]) {
			_lastOriginalImage = [UIImage imageWithData:object];
			image = _lastOriginalImage;
		}
	else
		image = object;
	}
	if (image) {
		UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
        imageView.tag = 51;
        imageView.frame = CGRectMake(0, 0, 150, 150);
        imageView.center = self.view.center;
        TGButton *button = [self.view viewWithTag:42];
		CGRect primaryFrame = CGRectMake(0, 22, self.view.frame.size.width, button.frame.origin.y);
        imageView.frame = CGRectMake(0, 0, 150, 150);
		imageView.center = CGRectGetCenter(primaryFrame);
        imageView.clipsToBounds = YES;
        imageView.layer.cornerRadius = 75;
		if ([TGColor isDarkInterface])
        	[imageView.layer setBorderColor: [[UIColor whiteColor] CGColor]];
		else
			[imageView.layer setBorderColor: [[UIColor blackColor] CGColor]];
        [imageView.layer setBorderWidth: 2.0];
        [imageView setUserInteractionEnabled:YES];
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(retry)];
        singleTap.numberOfTapsRequired = 1;
        [imageView addGestureRecognizer:singleTap];
        UIImageView * colorView = [[UIImageView alloc] initWithFrame:imageView.frame];
        colorView.backgroundColor = [TGColor dynamicColorWithLight:[UIColor colorWithWhite:0.2 alpha:0.4] dark:[UIColor colorWithWhite:0.8 alpha:0.3]];
        imageView.alpha = 0.5;
        UILabel *description = [[UILabel alloc] initWithFrame:colorView.frame];
        description.tag = 52;
        description.textAlignment = NSTextAlignmentCenter;
        description.numberOfLines = 0;
        description.text = [object isKindOfClass:NSData.class] ? @"Use again" : @"Try again";
        [imageView addSubview:colorView];
        [self.view addSubview:imageView];
        [self.view addSubview:description];
	}
}
-(void)saveImage {
	NSData *imageData = UIImagePNGRepresentation(_lastOriginalImage);
	[[NSUserDefaults standardUserDefaults] setObject:imageData forKey:@"_lastOriginalImage"];
	[[NSUserDefaults standardUserDefaults] synchronize];
}
-(void)openCamera {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [[TGPermissionsManager sharedInstance] updateLocation];
    });
	[[TGPermissionsManager sharedInstance] askCameraPermissionWithCompletionHandler:^(BOOL success) {
		if (success) {
			[[NSOperationQueue mainQueue] addOperationWithBlock:^{
                [[TGImages sharedInstance] destruct];
				UIImagePickerController *picker = [[UIImagePickerController alloc] init];
				picker.sourceType = UIImagePickerControllerSourceTypeCamera;
				picker.delegate = self;
				[self presentViewController:picker animated:YES completion:nil];
			}];
		}
	}];
}
-(void)openLibrary {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [[TGPermissionsManager sharedInstance] updateLocation];
    });
	[[TGPermissionsManager sharedInstance] askPhotoPermissionWithCompletionHandler:^(BOOL success){
		if (success) {
			[[NSOperationQueue mainQueue] addOperationWithBlock:^{
                [[TGImages sharedInstance] destruct];
				UIImagePickerController *picker = [[UIImagePickerController alloc] init];
				picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
				picker.delegate = self;
				[self presentViewController:picker animated:YES completion:nil];
			}];
		}
	}];
}
-(void)showSheet:(id)sender {
	BOOL isSimulator = ![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
	if (!isSimulator) {
		static dispatch_once_t onceToken;
		dispatch_once(&onceToken, ^{
			[TGImages compileModels];
		});
	}
	NSString *title = isSimulator ? @"You are under development environment. You can import an image from the library." : @"Choose the image source";
	UIAlertController *controller = [UIAlertController alertControllerWithTitle:title message:nil preferredStyle:UIAlertControllerStyleActionSheet];
	controller.view.frame = [[UIScreen mainScreen] applicationFrame];
	if (!isSimulator) {
		UIAlertAction *cameraAction = [UIAlertAction actionWithTitle:@"Camera" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
			[self openCamera];
		}];
		[cameraAction setValue:[TGColor dynamicTintColor] forKey:@"titleTextColor"];
		[controller addAction:cameraAction];
	}
	UIAlertAction *libraryAction = [UIAlertAction actionWithTitle:@"Photo library" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
		[self openLibrary];
	}];
	UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
	[libraryAction setValue:[TGColor dynamicTintColor] forKey:@"titleTextColor"];
	[cancelAction setValue:[TGColor dynamicRedColor] forKey:@"titleTextColor"];
	[controller addAction:libraryAction];
	[controller addAction:cancelAction];
	[self presentViewController:controller animated:YES completion:nil];
}

- (void)hideTabBar:(UITabBarController *) tabbarcontroller {
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0];
    for (UIView *view in tabbarcontroller.view.subviews) {
        if([view isKindOfClass:[UITabBar class]])
            [view setFrame:CGRectMake(view.frame.origin.x, 480, view.frame.size.width, view.frame.size.height)];
        else
            [view setFrame:CGRectMake(view.frame.origin.x, view.frame.origin.y, view.frame.size.width, 480)];
    }
    [UIView commitAnimations];
}

-(void)showTabBar:(UITabBarController *) tabbarcontroller {
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.5];
    for (UIView *view in tabbarcontroller.view.subviews) {
        if([view isKindOfClass:[UITabBar class]])
            [view setFrame:CGRectMake(view.frame.origin.x, 431, view.frame.size.width, view.frame.size.height)];

        else
            [view setFrame:CGRectMake(view.frame.origin.x, view.frame.origin.y, view.frame.size.width, 431)];
    }
    [UIView commitAnimations];
}
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    //[self hideTabBar:self.tabBarController];
	UIImageView *oldImageView = [self.view viewWithTag:51];
	if (oldImageView)
		[oldImageView removeFromSuperview];
	UILabel *oldLabel = [self.view viewWithTag:52];
	if (oldLabel)
		[oldLabel removeFromSuperview];
	[[picker presentingViewController] dismissViewControllerAnimated:YES completion:nil]; 
	UIImage *picture = [info objectForKey:UIImagePickerControllerEditedImage];
	if (!picture) {
		_lastOriginalImage = nil;
		picture = [info objectForKey:UIImagePickerControllerOriginalImage];
	}
    _lastOriginalImage = [info objectForKey:UIImagePickerControllerOriginalImage];
	if (_lastOriginalImage){
		[self saveImage];
		[self configureImage:_lastOriginalImage];
	}
	[[TGImages sharedInstance] destruct];
	TOCropViewController *cropController = [[TOCropViewController alloc] initWithImage:picture];
	[cropController setCancelButtonTitle:@"Cancel"];
	[cropController setDoneButtonTitle:@"Analyze"];
	cropController.delegate = self;
  
	//[self.navigationController pushViewController:cropController animated:YES];
    //self.navigationController = [[UINavigationController alloc] initWithRootViewController:cropController];
 
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
    [self presentViewController: cropController animated:YES completion:nil];
    }];
}
-(void)retry {
    [[TGImages sharedInstance] destruct];
    TOCropViewController *cropController = [[TOCropViewController alloc] initWithImage:_lastOriginalImage];
    [cropController setCancelButtonTitle:@"Cancel"];
    [cropController setDoneButtonTitle:@"Analyze"];
    cropController.delegate = self;
    [self.tabBarController.tabBar setHidden:YES];
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [self presentViewController: cropController animated:YES completion:nil];
    }];
}
/*
-(void)retry {
    [[TGImages sharedInstance] destruct];
    TOCropViewController *cropController = [[TOCropViewController alloc] initWithImage:_lastOriginalImage];
    [cropController setCancelButtonTitle:@"Cancel"];
    [cropController setDoneButtonTitle:@"Analyze"];
    cropController.delegate = self;
    [self.tabBarController.tabBar setHidden:YES];
    [self.navigationController pushViewController:cropController animated:YES];
}*/
-(void)cropViewController:(TOCropViewController *)cropViewController didCropToImage:(UIImage *)image withRect:(CGRect)cropRect angle:(NSInteger)angle{
    [cropViewController performSelector:@selector(dismissCropViewControllerWithCompletion:) withObject:^{
        pending = [UIAlertController alertControllerWithTitle:@"Scanning image...\n\n\n" message:nil preferredStyle:UIAlertControllerStyleAlert];
        UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        indicator.color = [TGColor dynamicTextColor];
        indicator.translatesAutoresizingMaskIntoConstraints=NO;
        [pending.view addSubview:indicator];
        NSDictionary *views = @{@"pending" : pending.view, @"indicator" : indicator};
        NSArray *constraintsVertical = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[indicator]-(20)-|" options:0 metrics:nil views:views];
        NSArray *constraintsHorizontal = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[indicator]|" options:0 metrics:nil views:views];
        NSArray *constraints = [constraintsVertical arrayByAddingObjectsFromArray:constraintsHorizontal];
        [pending.view addConstraints:constraints];
        [indicator setUserInteractionEnabled:NO];
        [indicator startAnimating];
        [self presentViewController:pending animated:YES completion:^{
            TGImagesViewController *controller = [[TGImagesViewController alloc] initWithImage:image originalImage:image];
            [self.tabBarController.tabBar setHidden:YES];
            [pending dismissViewControllerAnimated:YES completion:^{
                pending = nil;
            [self.navigationController pushViewController:controller animated:YES];
            }];
        }];
    }];
    //  [self.navigationController pushViewController:controller animated:YES];
}
/*
-(void)cropViewController:(TOCropViewController *)cropViewController didCropToImage:(UIImage *)image withRect:(CGRect)cropRect angle:(NSInteger)angle{
	[cropViewController performSelector:@selector(dismissCropViewController)];
    [self showAlertIndicator];
    __weak TGImagesViewController *controller = [[TGImagesViewController alloc] initWithImage:image originalImage:image];
    [self.tabBarController.tabBar setHidden:YES];
    [pending dismissViewControllerAnimated:YES completion:^{
        pending = nil;
        [self.navigationController pushViewController:controller animated:YES];
    }];
 //   [self.navigationController pushViewController:controller animated:YES];
}*/
-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
	[[picker presentingViewController] dismissViewControllerAnimated:YES completion:nil];
}
-(void)addStartButtonWithAnimation:(BOOL)animate {
	TGButton *button = [TGButton buttonNamed:@"Import" frame:CGRectMake(self.view.center.x, self.view.center.y + (self.view.center.y / 2), 200, 50) view:self.view];
	button.center = self.view.center;
	button.tag = 42;
	[button addTarget:self action:@selector(showSheet:)forControlEvents:UIControlEventTouchUpInside];
	if (animate)
		button.alpha = 0;
	[self.view addSubview:button];
	if (animate)
		[UIView animateWithDuration:0.5 animations:^{
			button.alpha = 1.0;
        }completion:^(BOOL finished) {
            [[TGPermissionsManager sharedInstance] askLocationPermission];
        }];
    else{
        [self configureImage:[[NSUserDefaults standardUserDefaults] objectForKey:@"_lastOriginalImage"]];
        [[TGPermissionsManager sharedInstance] askLocationPermission];
    }
}
-(void)showHomePage {
	if (_page == 5) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setBool:TRUE forKey:@"welcomeShown"];
        [defaults setBool:FALSE forKey:@"forceTutorial"];
        [defaults synchronize];
		TGButton *button = [self.view viewWithTag:42];
		UIView *dotView = [self.view viewWithTag:43];
		UIImageView *imageView =[self.view viewWithTag:50];
		[UIView animateWithDuration:0.4 animations:^{
			button.alpha = 0;
			dotView.alpha = 0;
			imageView.alpha = 0;
		} completion:^(BOOL success) {
			[button removeFromSuperview];
			[dotView removeFromSuperview];
			[imageView removeFromSuperview];
            [self.view makeToast:@"Tap import to start" duration:4.0 position:CSToastPositionBottom];
            isTutorial = FALSE;
            [self.tabBarController.tabBar setHidden:NO];
			[self addStartButtonWithAnimation:TRUE];
		}];
	}
	else
		[self addStartButtonWithAnimation:FALSE];
}
-(void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
	[super traitCollectionDidChange:previousTraitCollection];
	UIImageView *imageView = [self.view viewWithTag:50];
	if (imageView) {
		UIColor *currentTraitColor = [TGColor isDarkInterface] ? [UIColor whiteColor] : [UIColor blackColor];
		imageView.image = [TGColor tintImage:imageView.image withColor:currentTraitColor];
	}
	imageView = [self.view viewWithTag:51];
	if (imageView) {
		if ([TGColor isDarkInterface])
			[imageView.layer setBorderColor: [[UIColor whiteColor] CGColor]];
		else
			[imageView.layer setBorderColor: [[UIColor blackColor] CGColor]];
	}
	UIButton *button = [self.view viewWithTag:42];
	if (button)
		[button setBackgroundImage:[TGButton rectedImageWithSize:CGSizeMake(400, 400) color:[TGColor dynamicTintColor]] forState:UIControlStateNormal];
	[self setUpWallpaper];
}
-(void)showNextPage {
	TGButton *button = [self.view viewWithTag:42];
	if (button)
		button.userInteractionEnabled = FALSE;
	_page++;
	__block int pageBlock = _page;
	UILabel *titleLabel = [self.view viewWithTag:40];
	UIImageView *imageView = [self.view viewWithTag:50];
	[UIView animateWithDuration:0.4 animations:^{
		titleLabel.alpha = 0;
		imageView.alpha = 0;
	} completion:^(BOOL success) {
		[titleLabel removeFromSuperview];
		[imageView removeFromSuperview];
		if (pageBlock < 5)
			[self showWelcomePage];
		else
			[self showHomePage];
	}];
}
-(void)showWelcomePage {
	CGRect originalFrame = self.view.frame;
	CGRect frame = CGRectMake(originalFrame.origin.x, originalFrame.origin.y, originalFrame.size.width, originalFrame.size.height/2);
	UIImage *image;
	NSString *string = nil;
	switch (_page) {
        case 1:
			string = @"Welcome to Vision\n\nVision allows you to recognize objects from a photo taken at the moment or already present in your library.";
			image = [UIImage imageNamed:@"Welcome1.png"];
            break;
        case 2:
			string = @"Precision\n\nYou can crop the image taken by choosing the precise object you want to be recognized. Or leave the whole image as it is.";
			image = [UIImage imageNamed:@"Welcome2.png"];
			break;
        case 3:
			string = @"Recognized objects\n\nYou will get the list of recognized objects. If you don't like an item you can delete it from the list with a swipe.";
			image = [UIImage imageNamed:@"Welcome3.png"];
			break;
        case 4:
			string = @"Quick search\n\nOnce finished, save the image and all the names of recognized objects will be merged with it. This will make your searches much faster and more efficient.";
			image = [UIImage imageNamed:@"Welcome4.png"];
    }
    if (image == NULL)
		image = [UIImage imageNamed:@"logo.png"];
	if ([TGColor isDarkInterface])
		image = [TGColor tintImage:image withColor:[UIColor whiteColor]];
	UIImageView *imageView = [[UIImageView alloc] initWithImage:image];	
	imageView.tag = 50;
	imageView.center = self.view.center;
	imageView.frame = CGRectMake(imageView.frame.origin.x, imageView.frame.origin.y/1.4, originalFrame.size.width/2, originalFrame.size.height/4);
	imageView.center = CGPointMake(self.view.center.x, imageView.frame.origin.y);
	if (_page > 1)
		imageView.alpha = 0;
	[self.view addSubview:imageView];
	TGLabel *description = [[TGLabel alloc] initWithFrame:frame];
	description.center = self.view.center;
	description.textAlignment = NSTextAlignmentCenter;
	description.numberOfLines = 0;
	description.tag = 40;
	UIFont *finalFont = [[UIFont boldSystemFontOfSize:[UIFont systemFontSize]]fontWithSize:22];
	NSArray *array = [string componentsSeparatedByString:@"\n"];
	NSString *substring = [array firstObject];
	NSMutableAttributedString* attrStr = [[NSMutableAttributedString alloc]initWithString:string];
	[attrStr beginEditing];
	[attrStr addAttribute:NSFontAttributeName value:finalFont range:NSMakeRange(0, substring.length)];
	[attrStr endEditing];
	description.attributedText = attrStr;
	if (_page == 1) {
        TGButton *button = [TGButton buttonNamed:@"Next" frame:CGRectMake(self.view.center.x, self.view.center.y + (self.view.center.y / 2), 200, 50) view:self.view];
		button.tag = 42;
		[button addTarget:self action:@selector(showNextPage)forControlEvents:UIControlEventTouchUpInside];
		[self.view addSubview:button];
        TGDotView *dotView = [[TGDotView alloc] initWithFrame:button.frame];
		dotView.tag = 43;
		[self.view addSubview:dotView];
        [dotView buildDots];
        [dotView updatePosition];
	}
	else {
		description.alpha = 0;
		TGDotView *dotView = [self.view viewWithTag:43];
		[dotView changeDot];
	}    
	[self.view addSubview:description];
	if (_page > 1) {
		TGButton *button = [self.view viewWithTag:42];
		if (_page == 4)
			[button setTitle:@"Start" forState:UIControlStateNormal];
		[UIView animateWithDuration:0.5 animations:^{
			imageView.alpha = 1.0;
			description.alpha = 1.0;
			if (button)
					[button setUserInteractionEnabled:TRUE];
		}];
	}
}
-(instancetype)init {
	self = [super init];
	return self;
}
-(void)setUpWallpaper {
	BOOL shouldAdd = FALSE;
	UIImageView *backgroundImage = [self.view viewWithTag:60];
	if (!backgroundImage) {
		backgroundImage = [[UIImageView alloc] initWithFrame:self.view.frame];
		backgroundImage.tag = 60;
		shouldAdd = TRUE;
	}
    
  NSString *path = [TGColor isDarkInterface] ? @"/tweak/Wallpaper-Dark.png" : @"/tweak/Wallpaper-Light.png";
	if ([[NSFileManager defaultManager] fileExistsAtPath:path]) // IF JAILBROKEN
		backgroundImage.image = [UIImage imageWithContentsOfFile:path];
	else // IF NOT JAILBROKEN
		backgroundImage.image = [UIImage imageNamed:[path stringByReplacingOccurrencesOfString:@"/tweak/" withString:@""]];
	if (shouldAdd) {
		[self.view addSubview:backgroundImage];
		[self.view sendSubviewToBack:backgroundImage];
	}
}
-(void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
    if(!isTutorial)
            [self.tabBarController.tabBar setHidden:NO];
	[self.navigationController setNavigationBarHidden:YES animated:YES];
}
-(BOOL)prefersStatusBarHidden {
    return YES;
}
-(void)didClearCache:(id)sender {
    UIImageView *imageView = [self.view viewWithTag:51];
    if(imageView){
        for(UIView *view in imageView.subviews)
            [view removeFromSuperview];
        [imageView removeFromSuperview];
    }
    UILabel *label = [self.view viewWithTag:52];
    if(label)
        [label removeFromSuperview];
}
-(void)viewDidLoad {
	[super viewDidLoad];
	_page = 1;
	if ([self shouldShowHomePage])
		[self showHomePage];
    else{
        isTutorial = TRUE;
        [self.tabBarController.tabBar setHidden:YES];
        [self showWelcomePage];
    }
	[self setUpWallpaper];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didClearCache:) name:@"CacheCleared" object:nil];
}
@end
