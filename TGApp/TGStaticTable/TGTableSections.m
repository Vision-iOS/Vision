#import "UIKit/UIKit.h"
#include "TGTableSections.h"

@implementation TGTableSections
-(instancetype)init {
	if (self = [super init]) {
		_sections = [NSMutableArray array];
		self.count = 0;
	}
	return self;
}
+(TGTableSections*)withSections:(NSArray*)array title:(NSString*)title {
	TGTableSections *sections = [[TGTableSections alloc] init];
	for (TGTableSection *section in array) 
		[sections addSection:section];
	sections.title = title;
	return sections;
}
-(TGTableSection*)firstSection {
	if (self.count > 0)
		return [_sections firstObject];
	return NULL;
}
-(TGTableSection*)lastSection {
	if (self.count > 0)
		return [_sections lastObject];
	return NULL;
}
-(TGTableSection*)sectionAtIndex:(NSInteger)index {
	if ((index >= self.count) || (index < 0))
		return NULL;
	return [_sections objectAtIndex:index];
}
-(void)addSection:(TGTableSection*)section {
	[_sections addObject:section];
	self.count += 1;
}
-(void)removeSectionAtIndex:(NSInteger)index {
	if ((index >= 0) && (index < self.count)) {
		[_sections removeObjectAtIndex:index];
		self.count -=1;
	}
}
-(void)insertSection:(TGTableSection*)section atIndex:(NSInteger)index {
	if ((index >= 0) && (index < self.count)) {
		[_sections insertObject:section atIndex:index];
		self.count +=1;
	}
	else
		[self addSection:section];
}
-(void)destruct {
	for (TGTableSection *section in _sections)
		[section destruct];
	[_sections removeAllObjects];
	_sections = nil;
}
@end
