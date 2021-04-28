#import "TGClusterableAnnotation.h"

@interface TGClusterableAnnotation () {
    NSString *_name, *_path, *_realMetadata;
    UIImage *_image;
}
@end

@implementation TGClusterableAnnotation
-(instancetype)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
	if (self) {
        _name = [dictionary objectForKey:@"name"];
        _realMetadata = [dictionary objectForKey:@"realMetadata"];
        _path = [dictionary objectForKey:@"fullPath"];
        _image = [dictionary objectForKey:@"image"];
        NSDictionary * coordinateDictionary = [dictionary objectForKey:@"coordinates"];
        self.coordinate = CLLocationCoordinate2DMake([[coordinateDictionary objectForKey:@"latitude"] doubleValue], [[coordinateDictionary objectForKey:@"longitude"] doubleValue]);
    }
    return self;
}
-(NSString*)title {
	if ([_name hasPrefix:@"latitude"])
        return @"Your photo";
	return self.description;
}
-(NSString*)description {
    return _name;
}
-(NSString*)realMetadata {
    return _realMetadata;
}
-(NSString*)path {
    return _path;
}
-(UIImage*)image {
    return _image;
}
@end
