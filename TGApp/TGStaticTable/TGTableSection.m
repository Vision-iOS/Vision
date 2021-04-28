#import "UIKit/UIKit.h"
#import "TGTableSection.h"

@implementation TGTableSection
-(instancetype)init {
	if (self = [super init]) {
		_section = [NSMutableArray array];
	}
	return self;
}
+(TGTableSection*)sectionWithTableRows:(NSArray*)array header:(NSString*)title {
	TGTableSection *section = [[TGTableSection alloc] init];
	for (TGTableRow *row in array)
		[section addRow:row];
	if (title)
		section.header = title;
	return section;
}
+(TGTableSection*)sectionWithRows:(NSArray*)array {
	TGTableSection *section = [[TGTableSection alloc] init];
	unsigned int count = (unsigned int)array.count;
	if (count % 2 == 1)
		return section;
	for (unsigned int i = 0; i < count; i=i+2) {
		TGTableRow *row = [TGTableRow rowWithTitle:[array objectAtIndex:i] key:[array objectAtIndex:i+1]];
		[section addRow:row];
	}
	return section;
}
+(TGTableSection*)sectionWithRows:(NSArray*)array header:(NSString*)header footer:(NSString*)footer {
	TGTableSection *section = [TGTableSection sectionWithRows:array];
	if (header)
		section.header = header;
	if (footer)
		section.footer = footer;
	return section;
}
-(void)setRestartRequired {
	for (TGTableRow *row in _section)
		row.restartRequired = TRUE;
}
-(TGTableRow*)firstRow {
	if (self.count > 0)
		return [_section firstObject];
	return NULL;
}
-(TGTableRow*)lastRow {
	if (self.count > 0)
		return [_section lastObject];
	return NULL;
}
-(TGTableRow*)rowAtIndex:(NSInteger)index {
	if ((index >= self.count) || (index < 0))
		return NULL;
	return [_section objectAtIndex:index];
}
-(void)addRow:(TGTableRow*)row {
	[_section addObject:row];
	self.count += 1;
}
-(void)removeRowAtIndex:(NSInteger)index {
	if ((index >= 0) && (index < self.count)) {
		[_section removeObjectAtIndex:index];
		self.count -=1;
	}
}
-(void)insertRow:(TGTableRow*)row atIndex:(NSInteger)index {
	if ((index >= 0) && (index < self.count)) {
		[_section insertObject:row atIndex:index];
		self.count +=1;
	}
	else
		[self addRow:row];
}
-(void)destruct {
	for (TGTableRow *row in _section) {
		row.cell = nil;
		row.image = nil;
		row.handler = nil;
		row.gestureHandler = nil;
	}
	[_section removeAllObjects];
	_section = nil;
}
@end
