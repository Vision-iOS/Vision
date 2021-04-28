#import "UIKit/UIKit.h"
#import "TGTableRow.h"

@interface TGTableSection : NSObject {
	NSMutableArray *_section;
}
@property (nonatomic, retain) NSString *header;
@property (nonatomic, retain) NSString *footer;
@property(nonatomic, assign) unsigned int count;
+(TGTableSection*)sectionWithTableRows:(NSArray*)array header:(NSString*)title;
+(TGTableSection*)sectionWithRows:(NSArray*)array;
+(TGTableSection*)sectionWithRows:(NSArray*)array header:(NSString*)header footer:(NSString*)footer;
-(TGTableRow*)firstRow;
-(TGTableRow*)lastRow;
-(TGTableRow*)rowAtIndex:(NSInteger)index;
-(void)addRow:(TGTableRow*)row;
-(void)setRestartRequired;
-(void)destruct;
@end
