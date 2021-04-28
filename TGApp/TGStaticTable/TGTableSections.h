#import "UIKit/UIKit.h"
#import "TGTableSection.h"

@interface TGTableSections : NSObject {
	NSMutableArray *_sections;
}
@property (nonatomic, retain) NSString *title;
@property (nonatomic, assign) unsigned int count;
+(TGTableSections*)withSections:(NSArray*)array title:(NSString*)title;
-(TGTableSection*)sectionAtIndex:(NSInteger)index;
-(TGTableSection*)lastSection;
-(void)addSection:(TGTableSection*)section;
-(void)destruct;
@end
