#import <Foundation/Foundation.h>

@interface TGMetadata : NSObject{
    NSMutableDictionary *_imageMetadata;
}
-(void)addDescription:(NSString *)description;
-(void)setValue:(NSString *)key forExifKey:(NSString *)value;
-(NSDictionary *)exifData;
+(UIImage *)addDescription:(NSString *)description toImage:(UIImage *)image;
@end

