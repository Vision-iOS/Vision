#import "TGImageViewerViewController.h"
#import "TGImage.h"
#import "UIScrollableLabel.h"
#import "TGColor.h"
#import "TGImagesViewController.h"
#import "UIView+Toast.h"
#import "TGHeaderView.h"
#import <Photos/Photos.h>

static BOOL isDebug = TRUE;

@implementation TGImageViewerViewController
-(void)showAlertWithTitle:(NSString*)title message:(NSString*)message {
    UIAlertController *controller = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    controller.view.frame = [[UIScreen mainScreen] bounds];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    [action setValue:[TGColor dynamicTintColor] forKey:@"titleTextColor"];
    [controller addAction:action];
    [self presentViewController:controller animated:YES completion:nil];
}
+(instancetype)forImage:(UIImage*)image {
	return [[self alloc] initWithImage:image];
}
-(id)initWithImage:(UIImage*)image {
	self = [super initWithNibName:nil bundle:nil];
	if (self)
		self.image = image;
	return self;
}
-(void)labelTapped{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:TRUE forKey:@"labelTapped"];
    [defaults synchronize];
    NSString *myMetadata = [self.metadata[self.index] lowercaseString];
    if([myMetadata containsString:@", latitude"]){
        NSArray *array = [myMetadata componentsSeparatedByString:@", latitude"];
        myMetadata = array[0];
    }
    [self showAlertWithTitle:@"Metadata" message:myMetadata];
}
-(void)updateCurrentMetadataWithMetadata:(NSString *)string {
    NSString *lowerString = string.lowercaseString;
    NSString *metadata = string.lowercaseString;
  /*  if([lowerString containsString:@", latitude"]){
        NSArray *array = [metadata componentsSeparatedByString:@", latitude"];
        metadata = array[0];
    }
    else
    if([lowerString hasPrefix:@"latitude"]){
        metadata = @"";
    }*/
    NSMutableArray *array = self.metadata.mutableCopy;
    NSMutableArray *realArray = self.realMetadata.mutableCopy;
    [array replaceObjectAtIndex:self.index withObject:string];
    [realArray replaceObjectAtIndex:self.index withObject:metadata];
    self.metadata = array.copy;
    self.realMetadata = realArray.copy;
    [self loadTitle];
}
-(void)loadTitle {
    if (!self.isSingle)
        self.title = [NSString stringWithFormat:@"%d of %d", self.index+1, (int)self.images.count];
    BOOL hasMetadata = TRUE;
    NSString *metadata = [self.metadata[self.index] lowercaseString];
    if ([metadata hasSuffix:@", "])
        metadata = [metadata substringToIndex:[metadata length]-2];
    metadata = [NSString stringWithFormat:@"%@",metadata];
    if([metadata hasPrefix:@"latitude"]){
        metadata = @"No metadata found";
        hasMetadata = FALSE;
    }
    if([metadata containsString:@", latitude"]){
        NSArray *array = [metadata componentsSeparatedByString:@", latitude"];
        metadata = array[0];
    }
    TGHeaderView *headerView = [[TGHeaderView alloc] initWithTitle:metadata subtitle:self.title];
    if(hasMetadata){
        [headerView addHandler:^{
            [self labelTapped];
        }];
    }
    self.navigationItem.titleView = headerView;
    if(self.title)
        return;
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 25)];
    label.text = metadata;
    [label sizeToFit];
    if(label.frame.size.width < 200){
        if(hasMetadata){
            UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(labelTapped)];
            tapGestureRecognizer.numberOfTapsRequired = 1;
            [label addGestureRecognizer:tapGestureRecognizer];
            label.userInteractionEnabled = YES;
        }
        self.navigationItem.titleView = label;
        return;
    }
    UIScrollableLabel *subTitleLabel = [[UIScrollableLabel alloc] initWithFrame:CGRectMake(0, 0, 200, 25)];
    if(hasMetadata){
        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(labelTapped)];
        tapGestureRecognizer.numberOfTapsRequired = 1;
        [subTitleLabel addGestureRecognizer:tapGestureRecognizer];
        subTitleLabel.userInteractionEnabled = YES;
    }
    [subTitleLabel setLabelText:metadata];
    self.navigationItem.titleView = subTitleLabel;
}
-(void)updateImageWithState:(BOOL)isNext {
	if (isNext) {
		self.image = [self.images objectAtIndex:self.index+1];
		self.index = self.index+1;
	}
	else {
		self.image = [self.images objectAtIndex:self.index-1];
		self.index = self.index-1;
	}
	[self updateImage];
}
-(BOOL)hasNextImage {
	return self.index+1 < self.images.count;
}
-(BOOL)hasPreviousImage {
	return self.index+1 > 1;
}
-(BOOL)isFullScreenImage {
	return self.scrollView.minimumZoomScale == self.scrollView.zoomScale;
}
-(void)handleSwipe:(UIPanGestureRecognizer *)pan {
	if ((pan.state == UIGestureRecognizerStateEnded) && ([self isFullScreenImage])) {
		CGPoint velocity = [pan velocityInView:self.view];
		NSString *direction = nil;
		if ((velocity.x < 0) && ([self hasNextImage])) {
			direction = kCATransitionFromRight;
			[self updateImageWithState:TRUE];
		}
		else
		if ((velocity.x > 0) && ([self hasPreviousImage])) {
			direction = kCATransitionFromLeft;
			[self updateImageWithState:FALSE];
		}
		if (direction) {
			[self loadTitle];
			CATransition *transition = [CATransition animation];
			transition.duration = 0.35;
			transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
			transition.type = kCATransitionPush;
			transition.subtype = direction;
			transition.delegate = self;
			[self.scrollView.layer addAnimation:transition forKey:nil];
		}
	}
}
-(void)updateImage {
	self.imageView.image = self.image;
	CGFloat width = [UIScreen mainScreen].bounds.size.width;
	CGFloat height = [UIScreen mainScreen].bounds.size.height;
	CGFloat value = width < height ? width : height;
	self.imageView.frame = CGRectMake(self.imageView.frame.origin.x, self.imageView.frame.origin.y, value, value);
}
-(void)loadImage {
	self.imageView = [[UIImageView alloc] initWithImage:self.image];
	CGFloat tabBarHeight = [[self tabBarController] tabBar].bounds.size.height;
	CGFloat width = [UIScreen mainScreen].bounds.size.width;
	CGFloat height = [UIScreen mainScreen].bounds.size.height;
	CGFloat value = width < height ? width : height;
	self.imageView.frame = CGRectMake(self.imageView.frame.origin.x, self.imageView.frame.origin.y, value, value);
	if (self.isPreviewing) {
		[self.view addSubview:self.imageView];
		return;
	}
	self.scrollView = [[UIScrollView alloc] initWithFrame: CGRectMake(self.view.bounds.origin.x, self.view.bounds.origin.y, self.view.bounds.size.width, self.view.bounds.size.height - tabBarHeight)];
	self.scrollView.delegate = self;
	self.scrollView.backgroundColor = self.view.backgroundColor;
	self.scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	[self.scrollView addSubview:self.imageView];
	self.scrollView.contentSize = self.imageView.frame.size;
	self.scrollView.minimumZoomScale = 1.0;
	self.scrollView.maximumZoomScale = 2.0;
	[self.scrollView setShowsHorizontalScrollIndicator:NO];
	[self.scrollView setShowsVerticalScrollIndicator:NO];
	if (!self.isSingle) {
		UIPanGestureRecognizer *gesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
		[self.view addGestureRecognizer:gesture];
	}
	[self.view addSubview:self.scrollView];
}
-(NSArray<id> *)previewActionItems {
	UIPreviewAction *previewAction1 = [UIPreviewAction actionWithTitle:@"Save" style:UIPreviewActionStyleDefault handler:^(UIPreviewAction *action, UIViewController *previewViewController) {
		[self saveImage];
	}];
	UIPreviewAction *previewAction2 = [UIPreviewAction actionWithTitle:@"Delete" style:UIPreviewActionStyleDestructive handler:^(UIPreviewAction *action, UIViewController *previewViewController) {
		[self.collectionController deletePreviewedItem];
	}];
	return @[previewAction1, previewAction2];
}
-(void)viewWillDisappear:(BOOL)animated{
    [self.tabBarController.tabBar setHidden:NO];
    [super viewWillDisappear:animated];
}
-(void)viewWillAppear:(BOOL)animated{
    [self.tabBarController.tabBar setHidden:YES];
    [super viewWillAppear:animated];
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if(![[NSUserDefaults standardUserDefaults] boolForKey:@"labelTapped"] && [self navigationController])
        [self.view makeToast:@"Tap the title to read all metadata" duration:4.0 position:CSToastPositionBottom];
}
-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
}
-(void)viewDidLoad {
	[super viewDidLoad];
    [self.navigationItem.backBarButtonItem setTitle:@""];
	self.view.backgroundColor = [UIColor respondsToSelector:@selector(systemBackgroundColor)] ? [UIColor performSelector:@selector(systemBackgroundColor)] : [UIColor whiteColor];
	[self loadImage];
	[self loadTitle];
   // self.navigationItem.largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeNever;
   // self.navigationController.navigationBar.prefersLargeTitles = FALSE;
    if(self.canEdit){
        UIBarButtonItem *saveItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(actionButtonPressed:)];
        UIBarButtonItem *editItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"edit"] style:UIBarButtonItemStylePlain target:self action:@selector(editButtonPressed:)];
        self.navigationItem.rightBarButtonItems = @[saveItem,editItem];
        [editItem setBackgroundVerticalPositionAdjustment:2.0 forBarMetrics:UIBarMetricsDefault];
    }
    else{
        UIBarButtonItem *saveItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(actionButtonPressed:)];
        self.navigationItem.rightBarButtonItems = @[saveItem];
    }
}
-(void)viewDidLayoutSubviews {
	[self centerContentInScrollViewIfNeeded];
}
-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
	return self.imageView;
}
-(void)scrollViewDidZoom:(UIScrollView *)scrollView {
	[self centerContentInScrollViewIfNeeded];
}
-(void)centerContentInScrollViewIfNeeded {
	CGFloat horizontalInset = 0.0;
	CGFloat verticalInset = 0.0;
	if (self.scrollView.contentSize.width < self.scrollView.bounds.size.width) {
		horizontalInset = (self.scrollView.bounds.size.width - self.scrollView.contentSize.width) / 2.0;
    }
	if (self.scrollView.contentSize.height < self.scrollView.bounds.size.height) {
		verticalInset = (self.scrollView.bounds.size.height - self.scrollView.contentSize.height) / 2.0;
    }
	self.scrollView.contentInset = UIEdgeInsetsMake(verticalInset, horizontalInset, verticalInset, horizontalInset);
}
-(void)actionButtonPressed:(id)sender {
	static BOOL canSaveToCameraRoll = NO;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		if ([UIDevice currentDevice].systemVersion.floatValue < 10) {
			canSaveToCameraRoll = YES;
			return;
		}
		NSBundle *mainBundle = NSBundle.mainBundle;
		if ([mainBundle.infoDictionary.allKeys containsObject:@"NSPhotoLibraryUsageDescription"])
			canSaveToCameraRoll = YES;
    });
    if (canSaveToCameraRoll)
        [self saveImage];
}
-(void)editButtonPressed:(id)sender {
    TGImagesViewController *controller = [[TGImagesViewController alloc] initWithEditedImage:self.image path:self.paths[self.index] metadata:self.realMetadata[self.index]];
    controller.delegate = self;
    [self.navigationController pushViewController:controller animated:TRUE];
    
}
-(void)saveImage{
    UIImage *image = [TGImage fixrotation:self.image];
    NSString *description = self.metadata[self.index]; // Ottieni una descrizione dell'immagine.
    NSData *imageData = UIImageJPEGRepresentation(image, 1.0f); // Ottieni una rappresentazione esadecimale dell'immagine, senza compressione.
    CGImageSourceRef source = CGImageSourceCreateWithData((__bridge CFDataRef) imageData, NULL); // Crea un riferimento CGImage dall'imageData.
    CFStringRef UTI = CGImageSourceGetType(source); // Ottieni il tipo dell'immagine CG (jpeg, png...)
    NSMutableData *mutableData = [[NSMutableData alloc] init]; // Inizializza un NSData mutabile.
    CGImageDestinationRef destination = CGImageDestinationCreateWithData((__bridge CFMutableDataRef)mutableData, UTI, 1, NULL); // Imposta una destinazione (locale) usando il dato su cui lavorare e il suo tipo.
    CGMutableImageMetadataRef metadataRef = CGImageMetadataCreateMutable(); // Crea un dizionario che conterrà le chiavi metadata da popolare.
    CGImageMetadataSetValueMatchingImageProperty(metadataRef, kCGImagePropertyTIFFDictionary, kCGImagePropertyTIFFMake, (__bridge CFStringRef)description); // Imposta il metadata nel dizionario.
    CGImageMetadataSetValueMatchingImageProperty(metadataRef, kCGImagePropertyIPTCDictionary, kCGImagePropertyIPTCObjectName, (__bridge CFStringRef)description); // Imposta il metadata nel dizionario.
    CGImageMetadataSetValueMatchingImageProperty(metadataRef, kCGImagePropertyIPTCDictionary, kCGImagePropertyIPTCKeywords, (__bridge CFStringRef)description); // Imposta il metadata nel dizionario.
    CGImageMetadataSetValueMatchingImageProperty(metadataRef, kCGImagePropertyTIFFDictionary, kCGImagePropertyTIFFImageDescription, (__bridge CFStringRef)description); // Imposta il metadata nel dizionario.
    CGImageMetadataSetValueMatchingImageProperty(metadataRef, kCGImagePropertyPNGDictionary, kCGImagePropertyPNGDescription, (__bridge CFStringRef)description); // Imposta il metadata nel dizionario.
    CGImageDestinationAddImageAndMetadata(destination, image.CGImage, metadataRef, NULL); // Nella destinazione locale, collega l'immagine con i metadata.
    CGImageDestinationFinalize(destination); // Dopo aver effettuato il collegamento, finalizzalo.
    CFRelease(source); // Dealloca...
    CFRelease(destination); // Dealloca...
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        PHAssetResourceCreationOptions *options = [[PHAssetResourceCreationOptions alloc] init]; // Crea le opzioni.
        options.originalFilename = description; // Come prima opzione impostiamo la descrizione dell'immagine.
        PHAssetCreationRequest *createReq = [PHAssetCreationRequest creationRequestForAsset]; // Crea la richiesta.
        [createReq addResourceWithType:PHAssetResourceTypePhoto data:mutableData options:options]; // Chiedi alla richiesta di aggiungere la foto (in rappresentazione esadecimale) nel rullino.
    } completionHandler:^(BOOL success, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Saved" message:@"You can find the image in your gallery by searching for one of the items on the list." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        });
    }];
}

@end
