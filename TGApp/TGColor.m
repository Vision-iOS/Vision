#import "UIKit/UIKit.h"
#include "TGColor.h"

static TGColor *manager = nil;

int __isOSVersionAtLeast(int major, int minor, int patch) { // Inserisco questa funzione perché xCode non la trova di default. Permette di controllare la versione iOS attuale.
	NSOperatingSystemVersion version; // Creo una nuova struttura di tipo NSOperatingSystemVersion.
	version.majorVersion = major; // Inserisco la versione maggiore - Esempio: iOS [14].0.1
	version.minorVersion = minor; // Inserisci la versione intermedia - Esempio: iOS 14.[0].1
	version.patchVersion = patch; // Inserisco la versione di basso livello (patch) - Esempio: iOS 14.0.[1]
	return [[NSProcessInfo processInfo] isOperatingSystemAtLeastVersion:version]; // Verifica se è almeno questa versione.
}

@implementation TGColor
+(NSInteger)userInterfaceStyleFromTraitCollection:(UITraitCollection*)collection {
	SEL selector = @selector(userInterfaceStyle); // Inizializzo una variabile che contiene il selettore interessato.
	if ([collection respondsToSelector:selector]) { // Se l'oggetto collection risponde al selettore specificato (in questo caso da iOS 12 in poi...)
		NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[collection methodSignatureForSelector:selector]]; // Crea l'invocazione con la firma del metodo.
		[invocation setSelector:selector]; // Imposta il selettore.
		[invocation setTarget:collection]; // Imposta l'oggetto.
		[invocation invoke]; // Invoca.
		NSInteger value;
		[invocation getReturnValue:&value]; // Ottieni il risultato (0 light, 1 dark).
		return value;
	}
	return 0;
}
+(BOOL)isDarkInterface {
	if ([UITraitCollection respondsToSelector:@selector(currentTraitCollection)]) { // Se la classe UITraitCollection risponde al selettore indicato (da iOS 13 in poi...)
		UITraitCollection *currentTraitCollection = [UITraitCollection performSelector:@selector(currentTraitCollection)]; // Ottieni il trait attuale.
		if (currentTraitCollection) // Se esiste...
			return [TGColor userInterfaceStyleFromTraitCollection:currentTraitCollection] == 2; // verifica se siamo in ambiente dark.
	}
	return FALSE;
}
+(UIImage*)tintImage:(UIImage*)image withColor:(UIColor*)color {
	if ((image) && (color)) {
		UIGraphicsBeginImageContextWithOptions(image.size, NO, image.scale); // Inizializza il processo di creazione di un'immagine con una data dimensione e scala, senza compressione.
		CGContextRef context = UIGraphicsGetCurrentContext(); // Inizializza il contesto.
		[color setFill]; // Riempi con il colore indicato.
		CGContextTranslateCTM(context, 0, image.size.height); // Analizza tutta l'altezza dell'immagine.
		CGContextScaleCTM(context, 1.0, -1.0); // Spostati in diagonale.
		CGContextClipToMask(context, CGRectMake(0, 0, image.size.width, image.size.height), [image CGImage]); // Applica all'immagine passata come parametro una maschera creata dal contesto.
		CGContextFillRect(context, CGRectMake(0, 0, image.size.width, image.size.height)); // Prendi il frame e fillalo nel contesto.
		UIImage *coloredImg = UIGraphicsGetImageFromCurrentImageContext(); // Ottieni l'immagine dal contesto.
		UIGraphicsEndImageContext(); // Termina il contesto.
		return coloredImg;
	}
	return NULL;
}
+(instancetype)sharedInstance {
    static dispatch_once_t onceToken; // Crea un token statico.
    dispatch_once(&onceToken, ^{ // Se il token non è mai stato caricato, crea un singleton.
		manager = [[TGColor alloc] init];
	});
	return manager;
}
-(instancetype)init {
	if (self = [super init]) { // Se l'inizializzazione è riuscita, crea 3 colori dinamici.
		self.tintColor = [TGColor dynamicColorWithLight:[TGColor defaultBlueColor] dark:[UIColor colorWithRed:0.204f green:0.627f blue:1.0f alpha:1.0f]];
		self.redColor = [TGColor dynamicColorWithLight:[UIColor colorWithRed:1.0f green:0.231f blue:0.188f alpha:1.0f] dark:[UIColor colorWithRed:1.0f green:0.271f blue:0.227f alpha:1.0f]];
		self.yellowColor = [TGColor dynamicColorWithLight:[UIColor colorWithRed:1.0f green:0.6f blue:0.2f alpha:1.0f] dark:[UIColor colorWithRed:1.0f green:0.8f blue:0.4f alpha:1.0f]];
        self.subTextColor = [TGColor dynamicColorWithLight:[UIColor colorWithWhite:0.25f alpha:1.0f] dark:[UIColor colorWithWhite:0.75f alpha:1.0f]];
	}
	return self;
}
+(id)dynamicColorWithLight:(UIColor*)light dark:(UIColor*)dark {
	if ([UIColor respondsToSelector:@selector(colorWithDynamicProvider:)]) // Se i colori dinamici sono disponibili...
		return [UIColor performSelector:@selector(colorWithDynamicProvider:) withObject:^UIColor * _Nonnull(UITraitCollection * _Nonnull traits) { // Creane uno
			if (@available(iOS 12.0, *)) // Se siamo almeno su iOS 12...
				return [traits userInterfaceStyle] == 2 ? dark : light; // Se siamo in ambiente dark, usa il colore dark, altrimenti light.
			return light; // Se non siamo su iOS 12, non esiste la Dark Mode, quindi ritorna il colore light.
		}];
	return light; // Se i colori dinamici non sono disponibili, vuol dire che non esiste la Dark Mode, quindi ritorna il colore light.
}
+(id)dynamicRedColor {
	return [TGColor sharedInstance].redColor;
}
+(id)dynamicYellowColor {
	return [TGColor sharedInstance].yellowColor;
}
+(id)dynamicSubTextColor {
    return [TGColor sharedInstance].subTextColor;
}
+(UIColor*)defaultBlueColor {
	return [UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0];
}
+(UIColor*)darkBlueColor {
	return [UIColor colorWithRed:7.0f/255.0f green:119.0f/255.0f blue:178.0f/255.0f alpha:1.0f];
}
+(id)dynamicTintColor {
	return [TGColor sharedInstance].tintColor;
}
+(id)dynamicBackgroundColor {
	return [TGColor dynamicColorWithLight:[UIColor whiteColor] dark:[UIColor blackColor]];
}
+(id)dynamicNavigationBarColor {
    return [TGColor dynamicColorWithLight:[UIColor colorWithRed:246.0f/255.0f green:246.0f/255.0f blue:247.0f/255.0f alpha:1.0f] dark:[UIColor blackColor]];
}
+(id)dynamicTextColor {
	return [TGColor dynamicColorWithLight:[UIColor blackColor] dark:[UIColor whiteColor]];
}
+(id)dynamicToastBackgroundColor {
    return [TGColor dynamicColorWithLight:[[UIColor blackColor] colorWithAlphaComponent:0.8] dark:[[UIColor whiteColor] colorWithAlphaComponent:0.8]];
}
+(id)dynamicToastTextColor {
    return [TGColor dynamicColorWithLight:[UIColor whiteColor] dark:[UIColor blackColor]];
}
@end
