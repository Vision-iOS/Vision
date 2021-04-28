@interface TGDotShapeLayer : CAShapeLayer 
@property(nonatomic, assign) int tag;
@property (nonatomic, readwrite) BOOL isFilled;
+(TGDotShapeLayer*)dotShapeLayerFromSublayers:(NSArray*)array;
+(TGDotShapeLayer*)dotShapeLayerLocated:(int)location tag:(int)tag;
-(void)fillLayer;
-(void)unfillLayer;
@end