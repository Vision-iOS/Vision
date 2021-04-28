#import "UIKit/UIKit.h"
#import <Vision/Vision.h>
#import <CoreML/CoreML.h>
#import "TGMainViewController.h"
#import "TGAppDelegate.h"
#include "TGImages.h"
#import "TGPermissionsManager.h"
#import <Photos/Photos.h>
#import <MobileCoreServices/MobileCoreServices.h>

static TGImages *instance = nil;
static NSInteger uniqueImages = 0;
@implementation TGImages
+(NSInteger)uniqueImages{
    return uniqueImages;
}
+(instancetype)sharedInstance {
	static dispatch_once_t onceToken; // Inizializza un token.
	dispatch_once(&onceToken, ^{ // Se non è mai stato utilizzato...
		instance = [[TGImages alloc] init]; // Crea un singleton.
	});
	return instance;
}
+(NSString*)randomImagePath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0]; // Get documents folder
    NSArray *components = [documentsDirectory componentsSeparatedByString:@"/Documents"];
    if (components.count > 0) {
        NSString *path = [components objectAtIndex:0];
        if (path) {
            NSString *name = [NSString stringWithFormat:@"%lu.png", (unsigned long)([[NSDate date] timeIntervalSince1970]*10.0)];
            NSString *mainPath =  [[NSString alloc] initWithFormat:@"%@/Library/Images/", path];
            [[NSFileManager defaultManager] createDirectoryAtPath:mainPath withIntermediateDirectories:YES attributes:nil error:nil];
            return [[NSString alloc] initWithFormat:@"%@%@", mainPath, name];
        }
    }
    return NULL;
}
+(void)saveImageData:(NSData*)data atPath:(NSString *)path{
    if (data) {
        [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
        [data writeToURL:[NSURL fileURLWithPath:path] options:NSDataWritingAtomic error:nil];
    }
}
+(void)compileModels {
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{ // Esegui questo codice in background.
		NSArray *models = @[@"Inceptionv3", @"MobileNet", @"Resnet50"]; // I nomi dei modelli salvati nell'app sono memorizzati in questo array.
		BOOL shouldCompile = [[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithFormat:@"/tweak/%@.mlmodel", [models firstObject]]]; // Se siamo in un ambiente di sviluppo che non permette la pre-compilazione dei modelli, e quindi il modello è salvato in questa posizione...
		if (shouldCompile) { // Allora devo compilarlo a runtime.
			TGAppDelegate *delegate = (TGAppDelegate*)[[UIApplication sharedApplication] delegate]; // Ottengo il delegato dell'app.
			for (NSString *name in models) { // Itero l'array.
				NSURL *url = [NSURL fileURLWithPath:[NSString stringWithFormat:@"/tweak/%@.mlmodel", name]]; // Ottengo l'URL del modello.o
				NSURL *newURL = [MLModel compileModelAtURL:url error:nil]; // Lo compilo a runtime.
				[delegate.modelURLs setObject:newURL forKey:name]; // Salvo nel dizionario del delegato il nome del modello e il corrispondente URL del modello compilato.
			}
		}
	});
}
-(void)insertImage:(TGImage*)image{
    [self.images insertObject:image atIndex:0];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"NewTGImage" object:nil]; // Nuova immagine aggiunta! Segnalalo inviando una notifica.
}

-(BOOL)hasImageNamed:(NSString*)name { // Questa funzione verifica se sto tentando di aggiungere un nome già individuato e salvato da un altro modello.
	for (TGImage *image in self.images) {
        NSString *imageName = [image.name hasPrefix:@" "] ? [image.name substringFromIndex:1] : image.name;
		if ([imageName isEqualToString:name])
			return TRUE;
	}
	return FALSE;
}
-(instancetype)init {
	self = [super init];
	self.images = [NSMutableArray array];
	return self;
}
-(void)destruct {
	[self.images removeAllObjects];
}
-(void)sort { // Questa funzione ordina l'array in ordine di attendibilità.
	NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"confidence" ascending:NO]; // Crea un descrittore basandosi sulla proprietà confidence dell'oggetto.
	NSArray *sortDescriptors = @[descriptor]; // Specifica tutti i descrittori da usare in un array.
	self.images = [[self.images sortedArrayUsingDescriptors:sortDescriptors] mutableCopy]; // Ordina l'array con la regola del descrittore. Rilascia un NSArray ma a noi serve un NSMutableArray, quindi ottieni una copia mutabile.
    [[NSNotificationCenter defaultCenter] postNotificationName:@"NewTGImage" object:nil]; // Aggiorna la tabella inviando una notifica.
}
-(void)addImage:(UIImage*)image {
	self.done = FALSE;
    uniqueImages++;
	[self processImage:image modelNamed:@"Inceptionv3" sort:NO]; // Processa l'immagine usando il modello Inceptionv3, e non ordinare i risultati.
	[self processImage:image modelNamed:@"MobileNet" sort:NO]; // Processa l'immagine usando il modello MobileNew, e non ordinare i risultati.
	[self processImage:image modelNamed:@"Resnet50" sort:YES]; // Processa l'immagine usando il modello Resnet50, e ordina i risultati.
// L'ordinamento va fatto solo alla fine perché sarebbe ridondante eseguirlo ad ogni elaborazione.
// Infatti, se per esempio otteniamo 2 corrispondenze da Inceptionv3, e 2 da MobileNet, esse vengono unite. Ordinarle ora sarebbe ridondante in quando bisogna anche aggiungere quelle da Resnet50.
}
-(NSString *)description { // Overrida la descrizione dell'oggetto, dicendo che deve listare tutti gli oggetti trovati.
	if (self.images.count == 1) {
		TGImage *image = self.images.firstObject;
        NSMutableString *string = [NSMutableString string];
        [string appendString:image.name];
        [string appendString:@", "];
        [string appendString:[self latitudeString]];
        [string appendString:@", "];
        [string appendString:[self longitudeString]];
        return [string copy];
	}
	NSMutableString *string = [NSMutableString string];
    NSInteger count = 0;
	for (TGImage *image in self.images) {
        count++;
        NSString *str;
        if([image.name hasPrefix:@" "])
            image.name = [image.name substringFromIndex:1];
     //   NSString *newName = [image.name hasPrefix:@" "] ? [image.name substringFromIndex:1] : image.name;
        if(count == 1)
            str = [NSString stringWithFormat:@"%@",image.name];
        else
            str = [NSString stringWithFormat:@", %@",image.name];
		[string appendString:str];
	}
  //  if(count>0 && ![string hasSuffix:@", "])
  //      [string appendString:@", "];
    if(count>0)
        [string appendString:@", "];
    [string appendString:[self latitudeString]];
    [string appendString:@", "];
    [string appendString:[self longitudeString]];
	return [string copy];
}
-(NSString *)longitudeString{
    if(self.images.count == 0)
        return [NSString stringWithFormat:@"LONGITUDE%4.6f",_longitude];
    return [NSString stringWithFormat:@"LONGITUDE%4.6f",self.images.firstObject.longitude];
}
-(NSString *)latitudeString{
    if(self.images.count == 0)
        return [NSString stringWithFormat:@"LATITUDE%4.6f",_latitude];
    return [NSString stringWithFormat:@"LATITUDE%4.6f",self.images.firstObject.latitude];
}
-(void)saveImage:(UIImage *)image atPath:(NSString *)path{
    image = [TGImage fixrotation:image];
    NSString *description = [self description]; // Ottieni una descrizione dell'immagine.
	NSData *imageData = UIImageJPEGRepresentation(image, 1.0f); // Ottieni una rappresentazione esadecimale dell'immagine, senza compressione.
    CGImageSourceRef source = CGImageSourceCreateWithData((__bridge CFDataRef) imageData, NULL); // Crea un riferimento CGImage dall'imageData.
	CFStringRef UTI = CGImageSourceGetType(source); // Ottieni il tipo dell'immagine CG (jpeg, png...)
	NSMutableData *mutableData = [[NSMutableData alloc] init]; // Inizializza un NSData mutabile.
	CGImageDestinationRef destination = CGImageDestinationCreateWithData((__bridge CFMutableDataRef)mutableData, UTI, 1, NULL); // Imposta una destinazione (locale) usando il dato su cui lavorare e il suo tipo.
	CGMutableImageMetadataRef metadataRef = CGImageMetadataCreateMutable(); // Crea un dizionario che conterrà le chiavi metadata da popolare.
	CGImageMetadataSetValueMatchingImageProperty(metadataRef, kCGImagePropertyTIFFDictionary, kCGImagePropertyTIFFMake, (__bridge CFStringRef)description); // Imposta il metadata nel dizionario.
	CGImageMetadataSetValueMatchingImageProperty(metadataRef, kCGImagePropertyIPTCDictionary, kCGImagePropertyIPTCObjectName, (__bridge CFStringRef)description); // Imposta il metadata nel dizionario.
	CGImageMetadataSetValueMatchingImageProperty(metadataRef, kCGImagePropertyIPTCDictionary, kCGImagePropertyIPTCKeywords, (__bridge CFStringRef)description); // Imposta il metadata nel dizionario.
	CGImageMetadataSetValueMatchingImageProperty(metadataRef, kCGImagePropertyTIFFDictionary, kCGImagePropertyTIFFImageDescription, (__bridge CFStringRef)description); // Imposta il metadata nel dizionario.
	CGImageMetadataSetValueMatchingImageProperty(metadataRef, kCGImagePropertyPNGDictionary, kCGImagePropertyPNGDescription, (__bridge CFStringRef)description); // Imposta il metadata nel dizionario.
	CGImageDestinationAddImageAndMetadata(destination, image.CGImage, metadataRef, NULL); // Nella destinazione locale, collega l'immagine con i metadata.
	CGImageDestinationFinalize(destination); // Dopo aver effettuato il collegamento, finalizzalo.
    CFRelease(source); // Dealloca...
    CFRelease(destination); // Dealloca...
    [TGImages saveImageData:mutableData atPath:path];
	/*[[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
		PHAssetResourceCreationOptions *options = [[PHAssetResourceCreationOptions alloc] init]; // Crea le opzioni.
		options.originalFilename = description; // Come prima opzione impostiamo la descrizione dell'immagine.
		PHAssetCreationRequest *createReq = [PHAssetCreationRequest creationRequestForAsset]; // Crea la richiesta.
		[createReq addResourceWithType:PHAssetResourceTypePhoto data:mutableData options:options]; // Chiedi alla richiesta di aggiungere la foto (in rappresentazione esadecimale) nel rullino.
	} completionHandler:^(BOOL success, NSError * _Nullable error) {
		dispatch_async(dispatch_get_main_queue(), ^{
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Saved" message:@"You can find the image in your gallery by searching for one of the items on the list." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
			[alert show];
		});
	}];*/
}
-(NSUInteger)count {
	return self.images.count; // Ottieni il numero di corrispondenze trovate.
}
-(void)removeImageAtIndex:(NSInteger)index { // Se ho richiesto di eliminare una corrispondenza, verrà chiamata questa funzione.
    TGImage *image = [self.images objectAtIndex:index];
    _latitude = image.latitude;
    _longitude = image.longitude;
    [self.images removeObjectAtIndex:index];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"NewTGImage" object:nil]; // La lista necessita di un aggiornamento. Invia una notifica locale!
}
-(void)processImage:(UIImage *)image modelNamed:(NSString*)name sort:(BOOL)sort {
	if (!name)
		name = @"Inceptionv3";
	Class cls = NSClassFromString(name); // Ottieni la classe dal nome del modello.
	VNCoreMLModel *VNModel;
	if (cls) { // Se la classe esiste, vuol dire che la compilazione in fase pre-compilativa è avvenuta con successo.
		id v3 = [[NSClassFromString(name) alloc] init]; // Crea un'istanza della classe.
		VNModel = [VNCoreMLModel modelForMLModel:[v3 performSelector:@selector(model)] error:nil]; // Ottieni il modello dall'oggetto istanziato.
	}
	else { // Se la classe non esiste, allora vuol dire che la compilazione in fase pre-compilativa non è avvenuta con successo. Compila ora!
		NSURL *newURL; // Conterrà l'URL del modello compilato a runtime.
		TGAppDelegate *delegate = (TGAppDelegate*)[[UIApplication sharedApplication] delegate]; // Ottieni il delegato dell'app.
		if ([delegate.modelURLs objectForKey:name]) // Se il modello è stato compilato precedentemente in background (e questo statement sarà sempre vero)...
			newURL = [delegate.modelURLs objectForKey:name]; // Ottieni l'URL.
        else { // Altrimenti compilalo ora (ma non dovrebbe mai andare qui, dato che abbiamo compilato in precedenza, tuttavia rimettiamo il codice per completezza).
			NSURL *url = [NSURL fileURLWithPath:[NSString stringWithFormat:@"/tweak/%@.mlmodel", name]]; // Ottieni il path del modello.
			newURL = [MLModel compileModelAtURL:url error:nil]; // Compilalo.
			[delegate.modelURLs setObject:newURL forKey:name]; // Salva il path del modello.
        }
		MLModel *model = [MLModel modelWithContentsOfURL:newURL error:nil]; // Ottieni il modello.
		VNModel = [VNCoreMLModel modelForMLModel:model error:nil]; // Ottieni il modello nel dettaglio.
	}
	VNCoreMLRequest * VNMLRequest = [[VNCoreMLRequest alloc] initWithModel:VNModel completionHandler:^(VNRequest * _Nonnull request, NSError * _Nullable error) {
		int index = 0;
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        int selectedRow = [defaults integerForKey:@"confidenceLevel"];
        TGPermissionsManager *manager = [TGPermissionsManager sharedInstance];
        for (VNClassificationObservation * classification in request.results) {
            if (selectedRow == 0 && index > 1 && (classification.confidence * 100 < 4))
                break;
            if (selectedRow == 1 && index > 1 && (classification.confidence * 100 < 20))
                break;
            if(selectedRow == 2 && index > 1 && (classification.confidence * 100 < 40))
                break;
			index++;
            NSString *name = [classification.identifier lowercaseString];
			if (![self hasImageNamed:name]) { // Se non abbiamo già aggiunto una corrispondenza con lo stesso nome...
                TGImage *tgImage = [[TGImage alloc] initWithName:name image:image confidence:classification.confidence latitude:manager.latitude longitude:manager.longitude]; // Definiamo l'immagine con le sue proprietà.
				[self.images addObject:tgImage]; // Aggiungiamola.
				[[NSNotificationCenter defaultCenter] postNotificationName:@"NewTGImage" object:nil]; // Nuova immagine aggiunta! Segnalalo inviando una notifica.
			}
		}
		if (sort) { // Se bisogna ordinare le corrispondenze per attendibilità...
			NSInteger count = [self count]; // Controlla quante ce ne sono.
			if (count > 1) // Se ce ne sono più di una, allora ordina (non ha senso ordinare se ci sono 0 o 1 immagine).
				[self sort];
			else
			if(count==0){ // altrimenti se ce ne sono zero...
				self.done = TRUE; // Abbiamo finito.
				[[NSNotificationCenter defaultCenter] postNotificationName:@"NewTGImage" object:nil]; // Segnala che abbiamo finito inviando una notifica. Chi la riceve leggerà self.done = TRUE e capirà che il processo e terminato e non ci sono corrispondenze.
			}               
        }
	}];
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{ // Esegui il codice nel thread principale (cambi di interfaccia grafica vanno sempre fatti nel main thread, e questi cambi vengono eseguiti postando una notifica, e chi la riceve aggiorna la tabella).
		VNImageRequestHandler *VNImageRequest = [[VNImageRequestHandler alloc] initWithCGImage:image.CGImage options:@{}]; // Crea una nuova richiesta specificando l'immagine.
		[VNImageRequest performRequests:@[VNMLRequest] error:nil]; // Esegui la richiesta.
	});
}
@end
