@interface TGCoordinates : NSObject;
@property (nonatomic, retain) NSNumber *latitude;
@property (nonatomic, retain) NSNumber *longitude;
-(instancetype)initWithLatitude:(NSNumber *)latitude longitude:(NSNumber *)longitude;
-(CGFloat)latitudeFloat;
-(CGFloat)longitudeFloat;

@end
