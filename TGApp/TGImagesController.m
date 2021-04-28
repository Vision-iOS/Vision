#import "TGImagesController.h"
#import "TGImageViewerViewController.h"
#import "TGColor.h"
#import "TGCoordinates.h"
#import "TGClusterableAnnotation.h"
#import "TGImage.h"
#import "TGPermissionsManager.h"
#import "UIMapButton.h"

@implementation TGImagesController
-(NSString*)imagePath {
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0]; // Get documents folder
	NSArray *components = [documentsDirectory componentsSeparatedByString:@"/Documents"];
	if (components.count > 0) {
		NSString *path = [components objectAtIndex:0];
		if (path)
			return [[NSString alloc] initWithFormat:@"%@/Library/Images/", path];
	}
	return NULL;
}
- (NSDictionary *)getImageProperties:(NSData *)imageData {
    if(imageData){
        CGImageSourceRef imageSourceRef = CGImageSourceCreateWithData((__bridge CFDataRef) imageData, NULL);
        if(imageSourceRef){
            CFDictionaryRef properties = CGImageSourceCopyPropertiesAtIndex(imageSourceRef, 0, NULL);
            if(properties){
                NSDictionary *props = (__bridge_transfer NSDictionary *) properties;
                CFRelease(imageSourceRef);
                return props;
            }
        }
    }
    return NULL;
}
-(void)insertMetadataNamed:(NSString *)string{
    NSArray *components = [string componentsSeparatedByString:@","];
    for(NSString *name in components){
        //NSString *realName = [[name stringByReplacingOccurrencesOfString:@" " withString:@""] lowercaseString];
        NSString *realName = [name hasPrefix:@" "] ? [[name substringFromIndex:1]lowercaseString] : [name lowercaseString];
        if(![_allMetadata containsObject:realName] && realName.length && ![realName containsString:@"latitude"] && ![realName containsString:@"longitude"])
            [_allMetadata addObject:realName];
    }
}
-(NSNumber *)latitudeNumberFromString:(NSString *)str{
    NSArray *components = [str componentsSeparatedByString:@","];
    for(NSString *name in components){
        NSString *realName = [name hasPrefix:@" "] ? [name substringFromIndex:1] :name;
        if([realName containsString:@"latitude"]){
            NSString *latitudeString = [realName stringByReplacingOccurrencesOfString:@"latitude" withString:@""];
            return @(latitudeString.floatValue);
        }
    }
    return NULL;
}
-(NSNumber *)longitudeNumberFromString:(NSString *)str{
    NSArray *components = [str componentsSeparatedByString:@","];
    for(NSString *name in components){
        NSString *realName = [name hasPrefix:@" "] ? [name substringFromIndex:1] :name;
        if([realName containsString:@"longitude"]){
            NSString *longitudeString = [realName stringByReplacingOccurrencesOfString:@"longitude" withString:@""];
            return @(longitudeString.floatValue);
        }
    }
    return NULL;
}
-(NSString *)realTiffStringFromString:(NSString *)tiffString{
    NSRange rangeSpace = [tiffString rangeOfString:@", latitude" options:NSBackwardsSearch];
    if(rangeSpace.location != NSNotFound){
        NSString *finalResult = [tiffString substringWithRange:NSMakeRange(0, rangeSpace.location)];
        return finalResult;
    }
    return tiffString;
}
-(BOOL)isEqualToMetadata:(NSString *)string{
    if(self.imageMetadata && string){
        NSArray *componentsImageMetadata, *componentsString;
        if([self.imageMetadata containsString:@","])
            componentsImageMetadata = [self.imageMetadata componentsSeparatedByString:@","];
        else
            componentsImageMetadata = @[self.imageMetadata];
        if([string containsString:@","])
            componentsString = [string componentsSeparatedByString:@","];
        else
            componentsString = @[string];
        for(NSString *nameString in componentsString){
            NSString *realNameString = [nameString hasPrefix:@" "] ? [[nameString substringFromIndex:1]lowercaseString] : [nameString lowercaseString];
            if([realNameString containsString:@"latitude"] || [realNameString containsString:@"longitude"])
                continue;
            for(NSString *nameImageMetatada in componentsImageMetadata){
                NSString *realImageMetadata = [nameImageMetatada hasPrefix:@" "] ? [[nameImageMetatada substringFromIndex:1]lowercaseString] : [nameImageMetatada lowercaseString];
              if([realImageMetadata isEqual:realNameString])
                  return TRUE;
            }
        }
    }
    return FALSE;
}
-(void)buildImages {
    [_images removeAllObjects];
    [_paths removeAllObjects];
    [_metadata removeAllObjects];
    [_locations removeAllObjects];
    [selectedPaths removeAllObjects];
    [indexPaths removeAllObjects];
    [_allMetadata removeAllObjects];
    [_coordinates removeAllObjects];
    [_realMetadata removeAllObjects];
    NSString *path = [self imagePath];
    NSArray *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:NULL];
    _locations = [NSMutableDictionary dictionary];
    NSInteger row = 0;
    for (NSString *file in contents) {
        NSMutableDictionary *subDictionary = [NSMutableDictionary dictionary];
        NSString *fullPath = [[NSString alloc] initWithFormat:@"%@%@", path, file];
        NSData *data = [NSData dataWithContentsOfFile:fullPath options:0 error:nil];
        NSDictionary *dictionary = [self getImageProperties:data];
        NSDictionary *tiffDictionary = [dictionary objectForKey:@"{TIFF}"];
        NSString *tiffString = [[tiffDictionary objectForKey:@"ImageDescription"] lowercaseString];
        UIImage *image = [UIImage imageWithData:data];
        if (image) {
            NSString *realTiffString = [self realTiffStringFromString:tiffString];
          //  if(self.mode == 0 || [realTiffString containsString:self.imageMetadata]){ NON CANCELLARE
            if(self.mode == 0 || [self isEqualToMetadata:realTiffString]){
                [_realMetadata addObject:tiffString];
                [subDictionary setObject:realTiffString forKey:@"name"];
                [subDictionary setObject:tiffString forKey:@"realMetadata"];
                [subDictionary setObject:image forKey:@"image"];
                [subDictionary setObject:fullPath forKey:@"fullPath"];
                [_images addObject:image];
                [_paths addObject:fullPath];
                [_metadata addObject:realTiffString];
                [self insertMetadataNamed:realTiffString];
                NSNumber *longitudeNumber = [self longitudeNumberFromString:tiffString];
                NSNumber *latitudeNumber = [self latitudeNumberFromString:tiffString];
                NSMutableDictionary *subCoordinates = [NSMutableDictionary dictionary];
                if(longitudeNumber && latitudeNumber){
                    [subCoordinates setObject:longitudeNumber forKey:@"longitude"];
                    [subCoordinates setObject:latitudeNumber forKey:@"latitude"];
                    TGCoordinates *coordinates = [[TGCoordinates alloc] initWithLatitude:latitudeNumber longitude:longitudeNumber];
                    [_coordinates addObject:coordinates];
                }
                else{
                    TGCoordinates *coordinates = [[TGCoordinates alloc] initWithLatitude:0 longitude:0];
                    [_coordinates addObject:coordinates];
                }
                [subDictionary setObject:subCoordinates forKey:@"coordinates"];
            }
            [_locations setObject:subDictionary forKey:[NSString stringWithFormat:@"%lu", ++row]];
        }
    }
    _searchedImages = [_images copy];
    _searchedPaths = [_paths copy];
    _searchedMetadata = [_metadata copy];
    _searchedRealMetadata = [_realMetadata copy];
    _searchedCoordinates = [_coordinates copy];
    _searchedLocations = [_locations copy];
    _allMetadata = [[_allMetadata sortedArrayUsingSelector:@selector(compare:)] mutableCopy];
    _searchedAllMetadata = [_allMetadata copy];
    [self updateIndex];
    if(_selectedTab == 0)
        [self installButton];
}
-(void)removeBorderForSelectedCells {
	for (NSIndexPath *indexPath in indexPaths) {
		UICollectionViewCell *cell = [_collectionView cellForItemAtIndexPath:indexPath];
		cell.layer.borderWidth = 0;
	}
	[indexPaths removeAllObjects];
}
-(void)deletePreviewedItem {
	NSMutableArray *oldImages = [NSMutableArray array];
	NSMutableArray *oldPaths = [NSMutableArray array];
    NSMutableArray *oldMetadata = [NSMutableArray array];
	NSString *path = [_paths objectAtIndex:previewedIndexPath.row];
	[[NSFileManager defaultManager] removeItemAtPath:path error:nil];
	[oldImages addObject:[_images objectAtIndex:previewedIndexPath.row]];
	[oldPaths addObject:[_paths objectAtIndex:previewedIndexPath.row]];
    [oldMetadata addObject:[_metadata objectAtIndex:previewedIndexPath.row]];
	[_images removeObjectsInArray:oldImages];
	[_paths removeObjectsInArray:oldPaths];
    [_metadata removeObjectsInArray:oldMetadata];
	[self updateCollectionView];
}
-(void)deleteItems {
	int count = (int) selectedPaths.count;
	NSString *title = count == 1 ? @"Do you want to delete 1 image?" : [NSString stringWithFormat:@"Do you want to delete %d images?", count];
	UIAlertController *controller = [UIAlertController alertControllerWithTitle:title message:nil preferredStyle:UIAlertControllerStyleAlert];
	controller.view.frame = [[UIScreen mainScreen] applicationFrame];
	[controller addAction:[UIAlertAction actionWithTitle:@"Delete" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
		[self removeBorderForSelectedCells];
		NSMutableArray *oldImages = [NSMutableArray array];
		NSMutableArray *oldPaths = [NSMutableArray array];
        NSMutableArray *oldMetadata = [NSMutableArray array];
		for (int index = 0; index < selectedPaths.count; index++) {
			NSString *path = [selectedPaths objectAtIndex:index];
            NSError *error;
			[[NSFileManager defaultManager] removeItemAtPath:path error:&error];
			[oldImages addObject:[_images objectAtIndex:index]];
			[oldPaths addObject:[_paths objectAtIndex:index]];
            [oldMetadata addObject:[_metadata objectAtIndex:index]];
		}
		[_images removeObjectsInArray:oldImages];
		[_paths removeObjectsInArray:oldPaths];
        [_metadata removeObjectsInArray:oldMetadata];
		[self toggleEditMode];
        [self buildImages];
		[self updateCollectionView];
	}]];
	[controller addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:nil]];
	[self presentViewController:controller animated:YES completion:nil];
}
-(void)removeDir {
	NSString *path = [self imagePath];
	[[NSFileManager defaultManager] removeItemAtPath:path error:nil];
}
-(void)updateCollectionView {
	[_collectionView performBatchUpdates:^{
			[_collectionView deleteItemsAtIndexPaths:selectedPaths];
			[selectedPaths removeAllObjects];
		} completion:^(BOOL finished) {
		}];
}
-(void)toggleEditMode {
	isMultiSelection = !isMultiSelection;
	[selectedPaths removeAllObjects];
	if (isMultiSelection) {
        [self disableSearchController];
		[self.navigationItem.rightBarButtonItem setTitle:@"Done"]; 
		UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:NSSelectorFromString(@"deleteItems")];
		[self.navigationItem setLeftBarButtonItem:button animated:NO];
		[button setTintColor:[UIColor redColor]];
		self.navigationItem.leftBarButtonItem.enabled = NO;;
	}
	else {
        [self enableSearchController];
		[self removeBorderForSelectedCells];
		[self.navigationItem.rightBarButtonItem setTitle:@"Edit"];
		self.navigationItem.leftBarButtonItem = nil;
		self.navigationItem.hidesBackButton = NO;
		self.navigationItem.leftBarButtonItem.enabled = YES;
	}
}
-(void)installButton {
    if(_selectedTab == 0){
        UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithTitle:@"Edit" style:UIBarButtonItemStylePlain target:self action:@selector(toggleEditMode)];
        button.enabled = _images.count;
        [self.navigationItem setRightBarButtonItem:button animated:NO];
    }
}
-(void)uninstallButton{
    [self.navigationItem setRightBarButtonItem:nil animated:NO];
}
-(void)removeItemAtIndexPath:(NSIndexPath*)indexPath {
	[_collectionView performBatchUpdates:^{
		[_images removeObjectAtIndex:indexPath.row];
		[_paths removeObjectAtIndex:indexPath.row];
		[_collectionView deleteItemsAtIndexPaths:[NSArray arrayWithObject:indexPath]];
	} completion:^(BOOL finished) {
	}];
}
-(void)viewWillDisappear:(BOOL)animated {
	if (isMultiSelection)
		[self toggleEditMode];
    [self configureStatusBar:TRUE];
    if(self.mode == 1)
        [self.tabBarController.tabBar setHidden:NO];
	[super viewWillDisappear:animated];
    [self.navigationController.view setNeedsLayout]; // force update layout
    [self.navigationController.view layoutIfNeeded]; // to fix height of the navigation bar
}
-(TGImageViewerViewController*)previewingContext:(id<UIViewControllerPreviewing>)previewingContext viewControllerForLocation:(CGPoint)location{
	if (isMultiSelection)
		return NULL;
	CGPoint cellPostion = [_collectionView convertPoint:location fromView:self.view];
	NSIndexPath *indexPath = [_collectionView indexPathForItemAtPoint:cellPostion];
	if (indexPath) {
		previewedIndexPath = indexPath;
		UICollectionViewCell *cell = [_collectionView cellForItemAtIndexPath:indexPath];
		UIImageView *imageView = [[cell.contentView subviews] firstObject];
		TGImageViewerViewController *controller = [TGImageViewerViewController forImage:imageView.image];
		controller.collectionController = self;
		controller.isPreviewing = TRUE;
		controller.images = [_images copy];
		controller.index = (int) indexPath.row;
		controller.isSingle = FALSE;
		CGFloat width = [UIScreen mainScreen].bounds.size.width;
		controller.preferredContentSize = CGSizeMake(width, width);
		previewingContext.sourceRect = [self.view convertRect:cell.frame fromView:_collectionView];
		return controller;
	}
	return nil;
}
-(void)previewingContext:(id)previewingContext commitViewController:(TGImageViewerViewController*)viewControllerToCommit {
	TGImageViewerViewController *controller = [TGImageViewerViewController forImage:viewControllerToCommit.image];
	controller.images = [viewControllerToCommit.images copy];
	controller.index = viewControllerToCommit.index; 
	controller.isSingle = FALSE;
	[self.navigationController showViewController:controller sender:nil];
}
-(void)forceTouchIntialize {
	if ([self isForceTouchAvailable]) {
		self.previewingContext = [self registerForPreviewingWithDelegate:self sourceView:self.view];
	}
}
-(BOOL)isForceTouchAvailable {
	BOOL isForceTouchAvailable = NO;
	if ([self.traitCollection respondsToSelector:@selector(forceTouchCapability)]) {
		isForceTouchAvailable = self.traitCollection.forceTouchCapability == UIForceTouchCapabilityAvailable;
	}
	return isForceTouchAvailable;
}
-(void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
	if ([self isMovingFromParentViewController]) {
	/*	[selectedPaths removeAllObjects];
		selectedPaths = nil;
		previewedIndexPath = nil;*/
        [[NSNotificationCenter defaultCenter] removeObserver:self];
	}
}
-(void)addObservers {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}
-(void)enableSearchController {
    _searchController.searchBar.userInteractionEnabled = YES;
    _searchController.searchBar.alpha = 1.0;
}
-(void)disableSearchController {
    _searchController.searchBar.userInteractionEnabled = NO;
    _searchController.searchBar.alpha = 0.5; 
}
-(NSMutableArray *)addMyLocation{
    TGPermissionsManager *manager = [TGPermissionsManager sharedInstance];
    NSMutableArray * annotations = [[NSMutableArray alloc] init];
    if([manager hasLocation]){
        UIImage *image = [UIImage imageNamed:@"pin"];
        NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
        [dictionary setObject:@"My Location" forKey:@"name"];
        [dictionary setObject:image forKey:@"image"];
        NSMutableDictionary *coordinates = [NSMutableDictionary dictionary];
        [coordinates setObject:@(manager.latitude) forKey:@"latitude"];
        [coordinates setObject:@(manager.longitude) forKey:@"longitude"];
        [dictionary setObject:coordinates forKey:@"coordinates"];
        TGClusterableAnnotation *annotation = [[TGClusterableAnnotation alloc] initWithDictionary:dictionary];
        annotation.isMyLocation = TRUE;
        [annotations addObject:annotation];
    }
    return [annotations mutableCopy];
}
-(NSMutableArray *)configureMap{
    NSMutableArray * annotations = [[NSMutableArray alloc] init];
    if(!self.mapView){
        self.mapView = [[TGClusterMapView alloc] initWithFrame:self.view.bounds];
        self.mapView.tag = 60;
        self.mapView.hidden = true;
        TGPermissionsManager *manager = [TGPermissionsManager sharedInstance];
        MKMapRect mapRect;
        if([manager hasLocation]){
            CLLocationCoordinate2D coordinate1 = CLLocationCoordinate2DMake(manager.latitude +1,manager.longitude -1);
            CLLocationCoordinate2D coordinate2 = CLLocationCoordinate2DMake(manager.latitude -1,manager.longitude +1);
            
            // convert them to MKMapPoint
            MKMapPoint p1 = MKMapPointForCoordinate (coordinate1);
            MKMapPoint p2 = MKMapPointForCoordinate (coordinate2);

            // and make a MKMapRect using mins and spans
            mapRect = MKMapRectMake(fmin(p1.x,p2.x), fmin(p1.y,p2.y), fabs(p1.x-p2.x), fabs(p1.y-p2.y));
          /*  UIImage *image = [UIImage imageNamed:@"pin"];
            NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
            [dictionary setObject:@"My Location" forKey:@"name"];
            [dictionary setObject:image forKey:@"image"];
            NSMutableDictionary *coordinates = [NSMutableDictionary dictionary];
            [coordinates setObject:@(manager.latitude) forKey:@"latitude"];
            [coordinates setObject:@(manager.longitude) forKey:@"longitude"];
            [dictionary setObject:coordinates forKey:@"coordinates"];
            TGClusterableAnnotation *annotation = [[TGClusterableAnnotation alloc] initWithDictionary:dictionary];
            annotation.isMyLocation = TRUE;
            [annotations addObject:annotation]; */
        }
        else
            mapRect = MKMapRectMake(135888858.533591, 92250098.902419, 190858.927912, 145995.678292);
        self.mapView.visibleMapRect = mapRect;
        self.mapView.delegate = self;
        [self.view addSubview:self.mapView];
    }
    [self.mapView removeAnnotations:self.mapView.annotations];
    annotations = [self addMyLocation];
    return [annotations mutableCopy];
}
-(void)installMap {
    NSMutableArray *annotations = [self configureMap];
       dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
           for(NSString *key in _searchedLocations){
               TGClusterableAnnotation *annotation = [[TGClusterableAnnotation alloc] initWithDictionary:[_searchedLocations objectForKey:key]];
               [annotations addObject:annotation];
           }
           dispatch_async(dispatch_get_main_queue(), ^{
               [self.mapView setAnnotations:annotations];
           });
       });
}
-(void)installSearchController {
    _searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    _searchController.searchResultsUpdater = self;
    _searchController.dimsBackgroundDuringPresentation = NO;
    _searchController.obscuresBackgroundDuringPresentation = FALSE;
    [_searchController.searchBar sizeToFit];
    self.navigationItem.searchController = _searchController;
    self.navigationItem.hidesSearchBarWhenScrolling = FALSE;
    self.definesPresentationContext = YES;
    _searchController.hidesNavigationBarDuringPresentation = NO;
    self.extendedLayoutIncludesOpaqueBars = YES;
    _searchController.searchBar.delegate = self;
    if(self.mode == 0){
        NSArray *titles = @[@"Grid", @"Tag", @"Map"];
        _searchController.searchBar.scopeButtonTitles = titles;
        _searchController.searchBar.showsScopeBar = TRUE;
    }
}
-(void)searchBar:(UISearchBar *)searchBar selectedScopeButtonIndexDidChange:(NSInteger)selectedScope{
    [self configureStatusBar:selectedScope==0];
    if(selectedScope==1){
        [self buildImages];
        [self uninstallButton];
    }
    else
        if(selectedScope==2)
            [self installMap];
    _selectedTab = selectedScope;
    [UIView animateWithDuration:0.2 animations:^{
        _collectionView.alpha = selectedScope == 0;
        _tableView.alpha =  selectedScope == 1;
        self.mapView.alpha = selectedScope == 2;
    } completion:^(BOOL success) {
        _collectionView.hidden = selectedScope != 0;
        _tableView.hidden = selectedScope != 1;
        self.mapView.hidden = selectedScope != 2;
      //  self.mapView.userInteractionEnabled = selectedScope != 2;
        if(selectedScope>0)
            [self uninstallButton];
        else
            [self installButton];
    }];
}
-(void)configureStatusBar:(BOOL)transparent{
    if (@available(iOS 13.0, *)) {
        UIView *statusBar = [[UIApplication sharedApplication].keyWindow viewWithTag:4587];
        if(statusBar){
            if(transparent)
                statusBar.backgroundColor = [UIColor clearColor];
            else
                statusBar.backgroundColor = [TGColor dynamicNavigationBarColor];
        }else{
          statusBar = [[UIView alloc]initWithFrame:[UIApplication sharedApplication].keyWindow.windowScene.statusBarManager.statusBarFrame];
          statusBar.tag = 4587;
          if(transparent)
              statusBar.backgroundColor = [UIColor clearColor];
          else
              statusBar.backgroundColor = [TGColor dynamicNavigationBarColor];
              [[UIApplication sharedApplication].keyWindow addSubview:statusBar];
        }
    } else {
        UIView *statusBar = [[[UIApplication sharedApplication] valueForKey:@"statusBarWindow"] valueForKey:@"statusBar"];
        if ([statusBar respondsToSelector:@selector(setBackgroundColor:)]){
            if(transparent)
                statusBar.backgroundColor = [UIColor clearColor];
            else
                statusBar.backgroundColor = [TGColor dynamicNavigationBarColor];
        }
    }
}
-(void)installTableView {
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    _tableView.hidden = TRUE;
    [self.navigationController.navigationBar setBackgroundColor:[TGColor dynamicBackgroundColor]];
    _tableView.bounces = FALSE;
    [self.view addSubview:_tableView];
}
-(void)keyboardWillShow:(NSNotification*)notification {
    self.navigationItem.rightBarButtonItem.enabled = NO;
}
-(void)keyboardWillHide:(NSNotification*)notification {
    if (!_isSearchMode)
        self.navigationItem.rightBarButtonItem.enabled = YES;
}
-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    self.navigationItem.rightBarButtonItem.enabled = YES;
}
-(void)searchBarSearchButtonClicked:(UISearchBar*)searchBar {
}
-(BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    _isSearchMode = TRUE;
    self.navigationItem.rightBarButtonItem.enabled = NO;
    return YES;
}
-(BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar {
    return YES;
}
-(void)updateSearchResultsForSearchController:(UISearchController *)searchController {
  //  return;
    NSString *searchText = [searchController.searchBar.text lowercaseString];
    if (searchText) {
        if (searchText.length != 0) {
            _isSearchMode = TRUE;
            self.navigationItem.rightBarButtonItem.enabled = NO;
            if(_selectedTab==0){
                _searchedImages = [NSMutableArray array];
                _searchedPaths = [NSMutableArray array];
                _searchedMetadata = [NSMutableArray array];
                _searchedRealMetadata = [NSMutableArray array];
               _searchedCoordinates = [NSMutableArray array];
                for (NSInteger i = 0; i < _images.count; i++) {
                    NSString *object = [_metadata objectAtIndex:i];
                    NSString *metadataString = [object lowercaseString];
                 
                    if ([metadataString containsString:searchText]) {
                        [_searchedImages addObject:_images[i]];
                        [_searchedPaths addObject:_paths[i]];
                      //  [_searchedCoordinates addObject:_coordinates[i]];
                        [_searchedMetadata addObject:_metadata[i]];
                        [_searchedRealMetadata addObject:_realMetadata[i]];
                    }
                }
            }else
            if(_selectedTab==1){
                _searchedAllMetadata = [NSMutableArray array];
                for(NSString *name in _allMetadata){
                    NSString *metadataString = [name lowercaseString];
                    if ([metadataString containsString:searchText])
                        [_searchedAllMetadata addObject:name];
                }
            }
            else{
                _searchedLocations = [NSMutableDictionary dictionary];
                for(NSString *key in _locations.allKeys){
                    if([_locations[key][@"name"] containsString:searchText])
                        [_searchedLocations setObject:_locations[key] forKey:key];
                }
            }
        }
        else {
            if(_selectedTab==0){
                _searchedImages = [_images copy];
                _searchedPaths = [_paths copy];
                _searchedMetadata = [_metadata copy];
                _searchedCoordinates = [_coordinates copy];
                _searchedRealMetadata = [_realMetadata copy];
            }else
            if(_selectedTab==1){
                _searchedAllMetadata = [_allMetadata copy];
            }
            else{
                _searchedLocations = [_locations copy];
            }
            _isSearchMode = FALSE;
            self.navigationItem.rightBarButtonItem.enabled = YES;
        }
        if(_selectedTab==0)
            [_collectionView reloadData];
        else
        if(_selectedTab==1){
            [self updateIndex];
            [_tableView reloadData];
        }
        else{
            [self installMap];
        }
    }
    else{
        _isSearchMode = FALSE;
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }
}
-(void)viewWillAppear:(BOOL)animated{
    if(self.mode == 1)
        [self.tabBarController.tabBar setHidden:YES];
    if(_collectionView)
        [self forceReloadData];
    [super viewWillAppear:animated];
    if(_selectedTab != 0)
        [self configureStatusBar:FALSE];
    if(_collectionView){
        [self buildImages];
        [self updateCollectionView];
        [self updateIndex];
        [_collectionView reloadData];
        if(_tableView)
            [_tableView reloadData];
        if(self.mapView)
            [self installMap];
    //    [self forceReloadData];
    }
}
-(void)forceReloadData {
    [_collectionView reloadSections:[NSIndexSet indexSetWithIndex:0]];
}
-(TGImagesController *)initWithMode:(NSInteger)mode withMetadata:(NSString *)metadata{
    self = [super init];
    self.mode = mode;
    self.imageMetadata = metadata;
    return self;
}
-(void)viewDidLoad {
	[super viewDidLoad];
    [self.navigationController setNavigationBarHidden:NO];
    //self.navigationController.navigationBar.prefersLargeTitles = true;
    self.navigationItem.largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeAlways;
	[self forceTouchIntialize];
    self.view.backgroundColor = [UIColor respondsToSelector:@selector(systemBackgroundColor)] ? [UIColor performSelector:@selector(systemBackgroundColor)] : [UIColor whiteColor];
	selectedPaths = [NSMutableArray array];
	indexPaths = [NSMutableArray array];
	_images = [NSMutableArray array];
	_paths = [NSMutableArray array];
    _metadata = [NSMutableArray array];
    _allMetadata = [NSMutableArray array];
    _realMetadata = [NSMutableArray array];
    _selectedTab = 0;
    isMultiSelection = FALSE;
    [self setTitle:@"Search"];
	[self buildImages];
    [self installSearchController];
    [self installCollectionView];
    if(self.mode == 0)
        [self installTableView];
    [self installMap];
    [self addObservers];
}
-(void)updateIndex{
    _letters = [NSMutableArray array];
    _dictionary = [NSMutableDictionary new];
    int index = -1;
    for(NSString *string in _searchedAllMetadata){
        index++;
        NSString *firstLetter = [[string substringWithRange:NSMakeRange(0,1)] uppercaseString];
        NSMutableArray *letters = [_dictionary objectForKey:firstLetter];
        if(letters==NULL){
            [_letters addObject:firstLetter];
            letters = [NSMutableArray array];
            [_dictionary setObject:letters forKey:firstLetter];
        }
        [letters addObject:@(index)];
    }
}
-(void)installCollectionView{
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    CGFloat screenWidth = [[UIScreen mainScreen] bounds].size.width;
    layout.sectionInset = UIEdgeInsetsMake(1, 0, 10, 0);
    layout.itemSize = CGSizeMake((screenWidth/3)-1, (screenWidth/3)-1);
    layout.minimumInteritemSpacing = 1;
    layout.minimumLineSpacing = 1;
    _collectionView = [[UICollectionView alloc] initWithFrame:self.view.frame collectionViewLayout:layout];
    _collectionView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [_collectionView setDataSource:self];
    [_collectionView setDelegate:self];
    [_collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"cellIdentifier"];
    _collectionView.backgroundColor = [UIColor respondsToSelector:@selector(systemBackgroundColor)] ? [UIColor performSelector:@selector(systemBackgroundColor)] : [UIColor whiteColor];
    [self.view addSubview:_collectionView];
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
	return 1;
}
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
	return _searchedImages.count;
}
-(void)manageMultipleSelectionForCell:(UICollectionViewCell*)cell atIndexPath:(NSIndexPath*)indexPath {
	if (cell.layer.borderWidth == 2.0f) {
		cell.layer.borderWidth = 0;
		[selectedPaths removeObject:[_paths objectAtIndex:indexPath.row]];
		[indexPaths removeObject:indexPath];
	}
	else {
		cell.layer.borderWidth = 2.0f;
		cell.layer.borderColor = [[TGColor dynamicTintColor] CGColor];
		[selectedPaths addObject:[_paths objectAtIndex:indexPath.row]];
		[indexPaths addObject:indexPath];
	}
	if (selectedPaths.count) {
		[self.navigationItem.leftBarButtonItem setTitle:[NSString stringWithFormat:@"Delete %d", (int)selectedPaths.count]];
		self.navigationItem.leftBarButtonItem.enabled = YES;
	}
	else {
		[self.navigationItem.leftBarButtonItem setTitle:@"Delete"];
		self.navigationItem.leftBarButtonItem.enabled = NO;
	}

}
-(UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
	UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cellIdentifier" forIndexPath:indexPath];
    if(cell.contentView.subviews){
        NSArray *array = cell.contentView.subviews;
        if(array.count){
            for(UIView *view in array)
                [view removeFromSuperview];
       //     UIView *view = array[0];
       //     [view removeFromSuperview];
        }
    }
	UIImageView *imageView = [[UIImageView alloc] initWithFrame:cell.contentView.frame];
	imageView.image = [_searchedImages objectAtIndex:indexPath.row];
	imageView.contentMode = UIViewContentModeScaleToFill;
    imageView.backgroundColor = [UIColor respondsToSelector:@selector(systemBackgroundColor)] ? [UIColor performSelector:@selector(systemBackgroundColor)] : [UIColor whiteColor];
   [cell.contentView addSubview:imageView];
	return cell;
}
-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
	[_collectionView.collectionViewLayout invalidateLayout];
}
-(void)collectionView:(UICollectionView*)collectionView didSelectItemAtIndexPath:(NSIndexPath*)indexPath {
	UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
	if (isMultiSelection)
		[self manageMultipleSelectionForCell:cell atIndexPath:indexPath];
	else {
		//UIImageView *imageView = [[cell.contentView subviews] firstObject];
        UIImage *image = _searchedImages[indexPath.row];
		TGImageViewerViewController *controller = [TGImageViewerViewController forImage:image];
		controller.images = [_searchedImages copy];
        controller.paths = [_searchedPaths copy];
		controller.index = indexPath.row;
        controller.metadata = [_searchedMetadata copy];
        controller.realMetadata = [_searchedRealMetadata copy];
		controller.isSingle = FALSE;
        controller.canEdit = self.mode == 0;
		[self.navigationController pushViewController:controller animated:YES];
	}
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _letters.count;
}
-(NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView{
    return _letters;
}
-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [_letters objectAtIndex:section];
}
-(NSInteger)tableView:(UITableView *)theTableView numberOfRowsInSection:(NSInteger)section {
    NSArray *array = [_dictionary objectForKey:[_letters objectAtIndex:section]];
    return array.count;
}
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *array = [_dictionary objectForKey:[_letters objectAtIndex:indexPath.section]];
    NSNumber *number = array[indexPath.row];
    int index = [number intValue];
    NSString *identifier = [NSString stringWithFormat:@"TGImagesCell_%lu_%lu", indexPath.section,indexPath.row];
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier];
    cell.textLabel.text = _searchedAllMetadata[index];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}
#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    TGImagesController *controller = [[TGImagesController alloc] initWithMode:self.mode+1 withMetadata:cell.textLabel.text];
    [self.navigationController pushViewController:controller animated:TRUE];
}

#pragma mark - Abstract methods
/*
- (NSString *)seedFileName {
    NSAssert(FALSE, @"This abstract method must be overridden!");
    return nil;
}

- (NSString *)pictoName {
    NSAssert(FALSE, @"This abstract method must be overridden!");
    return nil;
}

-(NSString *)clusterPictoName {
    NSAssert(FALSE, @"This abstract method must be overridden!");
    return nil;
}*/

#pragma mark - TGClusterMapViewDelegate
-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    //MKAnnotationView * pinView = (MKAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:@"TGClusterableAnnotation"];
    MKAnnotationView * pinView = nil;
    if (!pinView) {
        UIImage *image;
        BOOL isMyLocation = FALSE;
        NSString *string = @"";
        NSString *path = @"";
        NSString *realMetadata = @"";
        if([annotation respondsToSelector:@selector(cluster)]){
            id cluster = [annotation performSelector:@selector(cluster)];
            if([cluster respondsToSelector:@selector(annotation)]){
                id _annotation = [cluster performSelector:@selector(annotation)];
                if([_annotation respondsToSelector:@selector(annotation)]){
                    id __annotation = [_annotation performSelector:@selector(annotation)];
                    image = [__annotation performSelector:@selector(image)];
                    isMyLocation = [__annotation performSelector:@selector(isMyLocation)];
                    string = [__annotation performSelector:@selector(title)];
                    path = [__annotation performSelector:@selector(path)];
                    realMetadata = [__annotation performSelector:@selector(realMetadata)];
                }
            }
        }
       // pinView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"TGClusterableAnnotation"];
        pinView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:nil];
        pinView.image = [TGImage imageWithImage:image convertToSize:isMyLocation ? CGSizeMake(45, 45) : CGSizeMake(40, 40)];
        if(!isMyLocation){
            pinView.layer.borderWidth = 2.5f;
            pinView.layer.borderColor = [[UIColor whiteColor] CGColor];
            UIMapButton *button = [UIMapButton buttonWithType:UIButtonTypeDetailDisclosure];
            button.image = image;
            button.metadata = string;
            button.path = path;
            button.realMetadata = realMetadata;
            [button addTarget:self action:@selector(willOpenAnnotationViewWithSender:) forControlEvents:UIControlEventTouchUpInside];
            pinView.rightCalloutAccessoryView = button;
        }
        pinView.canShowCallout = YES;
    }
    else {
        pinView.annotation = annotation;
    }
    return pinView;
}

-(MKAnnotationView *)mapView:(TGClusterMapView *)mapView viewForClusterAnnotation:(id<MKAnnotation>)annotation {
    MKAnnotationView * pinView = (MKAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:@"TGMapCluster"];
    if (!pinView) {
        pinView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"TGMapCluster"];
        pinView.image = [annotation performSelector:@selector(image)];
        //pinView.image = [UIImage imageNamed:self.clusterPictoName];
        pinView.canShowCallout = YES;
    }
    else {
        pinView.annotation = annotation;
    }
    return pinView;
}


-(void)mapViewDidFinishClustering:(TGClusterMapView *)mapView {
}

- (NSInteger)numberOfClustersInMapView:(TGClusterMapView *)mapView {
    return 40; //40
}

- (double)clusterDiscriminationPowerForMapView:(TGClusterMapView *)mapView {
    return 1.8;
}

- (NSString *)pictoName {
    return NULL;
}

- (NSString *)clusterPictoName {
    return NULL;
}

- (NSString *)seedFileName {
    return NULL;
}

- (void)willOpenAnnotationViewWithSender:(UIMapButton *)sender{
    if(sender.image){
        TGImageViewerViewController *controller = [TGImageViewerViewController forImage:sender.image];
        controller.images = NULL;
        controller.index = 0;
        controller.paths = @[sender.path];
        NSArray *array = @[sender.metadata];
        if([[sender.metadata lowercaseString] hasPrefix:@"your photo"])
            controller.metadata = @[sender.realMetadata];
        else
            controller.metadata = array;
        controller.realMetadata = @[sender.realMetadata];
        controller.canEdit = self.mode == 0;
        controller.isSingle = TRUE;
        [self.navigationController pushViewController:controller animated:YES];
    }
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
   /* UIImage *image;
    NSString *string = @"";
    BOOL isMyLocation = FALSE;
    if([view respondsToSelector:@selector(annotation)]){
        id annotation = [view performSelector:@selector(annotation)];
        string = [annotation performSelector:@selector(title)];
        if([annotation respondsToSelector:@selector(cluster)]){
            id cluster = [annotation performSelector:@selector(cluster)];
            if([cluster respondsToSelector:@selector(annotation)]){
                id _annotation = [cluster performSelector:@selector(annotation)];
                if([_annotation respondsToSelector:@selector(annotation)]){
                    id __annotation = [_annotation performSelector:@selector(annotation)];
                    image = [__annotation performSelector:@selector(image)];
                    isMyLocation = [__annotation performSelector:@selector(isMyLocation)];
                }
            }
        }
    }
    if(image && !isMyLocation){
        TGImageViewerViewController *controller = [TGImageViewerViewController forImage:image];
        controller.images = NULL;
        controller.index = 0;
        NSArray *array = @[string];
        controller.metadata = array;
        controller.isSingle = TRUE;
        [self.navigationController pushViewController:controller animated:YES];
    }*/
}
@end
