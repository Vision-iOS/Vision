#import "UIKit/UIKit.h"
#import <ImageIO/ImageIO.h>
#import <CoreLocation/CoreLocation.h>
#import "TGMetadata.h"
#define kCGImagePropertyProjection @"ProjectionType"

@implementation TGMetadata

-(instancetype)init {
    self = [super init];
    if (self) {
        _imageMetadata = [[NSMutableDictionary alloc] init];   
    }
    return self;
    
}

-(void)addDescription:(NSString*)description {
    [self.tiffDictionary setObject:description forKey:(NSString *)kCGImagePropertyTIFFImageDescription];   
}

-(void)setValue:(NSString *)key forExifKey:(NSString *)value {
    [self.exifDictionary setObject:value forKey:key];
}

- (NSDictionary *)exifData {
    
    return _imageMetadata;
    
}

-(NSMutableDictionary *)exifDictionary {
    
    return [self dictionaryForKey:(NSString*)kCGImagePropertyExifDictionary];
    
}

-(NSMutableDictionary *)tiffDictionary {
    
    return [self dictionaryForKey:(NSString*)kCGImagePropertyTIFFDictionary];
    
}

- (NSMutableDictionary *)dictionaryForKey:(NSString *)key {
    
    NSMutableDictionary *dict = _imageMetadata[key];
    
    if (!dict) {
        dict = [[NSMutableDictionary alloc] init];
        _imageMetadata[key] = dict;
    }
    
    return dict;
    
}

+(UIImage *)addDescription:(NSString *)description toImage:(UIImage *)image{
    TGMetadata *metadata = [[TGMetadata alloc]init];
    [metadata addDescription:description];
    return [TGMetadata addExif:metadata toImage:image];
}

+(UIImage *)addExif:(TGMetadata *)container toImage:(UIImage *)image{
    
    NSData *imageData = UIImageJPEGRepresentation(image, 1.0f);
    CGImageSourceRef source = CGImageSourceCreateWithData((__bridge CFDataRef) imageData, NULL);
    CFStringRef UTI = CGImageSourceGetType(source);
    NSMutableData *dest_data = [NSMutableData data];
    CGImageDestinationRef destination = CGImageDestinationCreateWithData((__bridge CFMutableDataRef)dest_data, UTI, 1, NULL);
    
    if (!destination) {
        NSLog(@"Error: Could not create image destination");
    }
    
    CGImageDestinationAddImageFromSource(destination, source, 0, (__bridge CFDictionaryRef) container.exifData);
    BOOL success = NO;
    success = CGImageDestinationFinalize(destination);
    
    if (!success) {
        NSLog(@"Error: Could not create data from image destination");
    }
    
    CFRelease(destination);
    CFRelease(source);
    
    return [UIImage imageWithData:dest_data];
}



@end
