#import "UIKit/UIKit.h"
#include "TGButton.h"
#import "TGColor.h"

@implementation TGButton
+(UIImage*)rectedImageWithSize:(CGSize)size color:(UIColor*)color {
	UIGraphicsBeginImageContextWithOptions(size, true, 0.0); // Inizializza il processo di creazione di una nuova immagine, con una data dimensione, senza compressione.
	[color setFill]; // Riempi l'immagine di questo colore.
	UIRectFill(CGRectMake(0.0, 0.0, size.width, size.height)); // Estendi il colore dappertutto nell'immagine
	UIImage *image = UIGraphicsGetImageFromCurrentImageContext(); // Ottieni l'immagine risultante.
	UIGraphicsEndImageContext(); // Concludi il processo di creazione dell'immagine.
	return image;
}

/*
-(instancetype)initWithCoder:(NSCoder *)coder {
	self = [super initWithCoder:coder];
	if (self) {
		[self setBackgroundImage:[TGButton rectedImageWithSize:self.bounds.size color:UIColor.blueColor] forState:UIControlStateNormal];
		[self setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
		self.layer.cornerRadius = 5.0;
		self.layer.masksToBounds = YES;
		self.titleLabel.font = [UIFont systemFontOfSize:18.0 weight:UIFontWeightRegular];
	}
	return self;
}
*/
+(TGButton*)buttonNamed:(NSString*)name frame:(CGRect)frame view:(UIView*)view {
	TGButton *button = [[TGButton alloc] initWithFrame:frame]; // Crea un nuovo bottone con il frame indicato.
	if (button) { // Se l'inizializzazione è riuscita...
		[button setTitle:name forState:UIControlStateNormal]; // Imposta un titolo al bottone.
		[button setBackgroundImage:[TGButton rectedImageWithSize:CGSizeMake(400, 400) color:[TGColor dynamicTintColor]] forState:UIControlStateNormal]; // Imposta un'immagine di sfondo del bottone.
		[button setTitleColor:UIColor.whiteColor forState:UIControlStateNormal]; // Imposta la tinta del bottone.
		button.layer.cornerRadius = 14.0; // Configura i bordi del bottone.
		button.layer.masksToBounds = TRUE; // Specifica ancora che il bottone deve avere i bordi arrotondati.
		button.titleLabel.font = [UIFont systemFontOfSize:18.0 weight:UIFontWeightRegular]; // Specifica il font del titolo del bottone.
		if (view) // Se la vista è specificata...
			button.frame = CGRectMake(view.center.x, frame.origin.y, button.frame.size.width, button.frame.size.height); // Modifica la posizione del bottone, mettendolo al centro orizzontalmente nel frame indicato.
		button.center = CGPointMake(view.center.x, frame.origin.y);
	}
	return button;
}
@end
