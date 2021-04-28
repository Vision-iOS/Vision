#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "TGCoordinates.h"


@implementation TGCoordinates

-(instancetype)initWithLatitude:(NSNumber *)latitude longitude:(NSNumber *)longitude{
    self = [super init];
    self.latitude = latitude;
    self.longitude = longitude;
    return self;
}
-(CGFloat)latitudeFloat{
    return self.latitude.floatValue;
}
-(CGFloat)longitudeFloat{
    return self.longitude.floatValue;
}
+(NSDictionary *)dictionaryWithCoordinates:(NSArray *)coordinates metadata:(NSArray *)metadata {
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    for(NSInteger i = 0; i < metadata.count; i++){
        TGCoordinates *coordinate = coordinates[i];
        [dictionary setObject:@[coordinate.latitude, coordinate.longitude, metadata[i]] forKey:[NSString stringWithFormat:@"%lu", i]];
    }
    return dictionary;
}

@end
