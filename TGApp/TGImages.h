#import "TGImage.h"

@interface TGImages : NSObject{
    CGFloat _latitude, _longitude;
}
@property (nonatomic, retain) NSMutableArray <TGImage *> *images;
@property (nonatomic, readwrite) BOOL done;
+(TGImages*)sharedInstance;
-(NSUInteger)count;
-(void)addImage:(UIImage*)image;
-(void)removeImageAtIndex:(NSInteger)index;
-(NSString *)description;
-(void)saveImage:(UIImage *)image atPath:(NSString *)path;
-(void)destruct;
+(void)compileModels;
-(BOOL)hasImageNamed:(NSString*)name;
-(void)insertImage:(id)image;
+(NSString*)randomImagePath;
+(NSInteger)uniqueImages;
@end
