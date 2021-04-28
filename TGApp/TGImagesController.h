#import <UIKit/UIKit.h>
#import "TGViewController.h"
#import "TGClusterMapView.h"

@interface TGImagesController : TGViewController <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIViewControllerPreviewingDelegate, UITableViewDelegate, UITableViewDataSource, UISearchResultsUpdating,UISearchBarDelegate, TGClusterMapViewDelegate, MKMapViewDelegate> {
	UICollectionView *_collectionView;
    NSMutableArray *_images, *_paths, *_metadata, *_allMetadata, *_coordinates;
    UISearchController *_searchController;
    BOOL _isSearchMode;
    NSMutableArray *_searchedImages, *_searchedPaths, *_searchedMetadata, *_searchedAllMetadata, *_letters, *_searchedCoordinates;
    NSMutableArray *_realMetadata, *_searchedRealMetadata;
    NSInteger _selectedTab;
    NSMutableDictionary *_dictionary;
    NSMutableArray *selectedPaths, *indexPaths;
    NSIndexPath *previewedIndexPath;
    BOOL isMultiSelection;
    NSMutableDictionary *_locations, *_searchedLocations;
}
@property (nonatomic, strong) id previewingContext;
@property (nonatomic, retain) NSString *imageMetadata;
@property (nonatomic, assign) NSInteger mode;
@property (strong, nonatomic) IBOutlet TGClusterMapView * mapView;
@property (weak, readonly, nonatomic) NSString * seedFileName;
@property (weak, readonly, nonatomic) NSString * pictoName;
@property (weak, readonly, nonatomic) NSString * clusterPictoName;
-(TGImagesController *)initWithMode:(NSInteger)mode withMetadata:(NSString *)metadata;
-(void)deletePreviewedItem;
@end
