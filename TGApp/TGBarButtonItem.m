#import "UIKit/UIKit.h"
#include "TGBarButtonItem.h"

@implementation TGBarButtonItem
+(TGBarButtonItem*)buttonInController:(UIViewController*)controller withTitle:(id)title handler:(void(^)(void))handler {
	TGBarButtonItem *item = [[TGBarButtonItem alloc] initWithTitle:title handler:handler]; // Crea un tasto con un titolo e un'azione.
	[item addToRight:controller]; // Aggiungiil tasto a destra.
	return item;
}
+(TGBarButtonItem*)withTitle:(id)title handler:(void(^)(void))handler {
	return [[TGBarButtonItem alloc] initWithTitle:title handler:handler]; // Crea un tasto con un titolo e un'azione.
}
-(instancetype)initWithTitle:(id)title handler:(void(^)(void))handler {
	self = [super initWithTitle:title style:UIBarButtonItemStylePlain target:self action:@selector(execHandler)]; // Crea un tasto con un titolo, uno stile di testo, con un azione posta nel selettore indicato.
	self.handler = handler; // Salva l'azione.
	return self;
}
-(instancetype)initWithTitle:(id)title style:(NSInteger)style handler:(void(^)(void))handler {
	self = [[TGBarButtonItem alloc] initWithTitle:title style:style target:self action:@selector(execHandler)]; // Crea un tasto con un titolo, uno stile di testo, con un azione posta nel selettore indicato.
	self.handler = handler; // Salva l'azione.
	return self;
}
-(void)execHandler {
	if (self.handler != nil) // Se c'è un azione...
		self.handler(); // Eseguila.
}
-(void)addToRight:(UIViewController*)controller {
	[controller.navigationItem setRightBarButtonItem:self animated:NO]; // Aggiungi il tasto a destra.
}
-(void)addToLeft:(UIViewController*)controller {
	[controller.navigationItem setLeftBarButtonItem:self animated:NO]; // Aggiungi il tasto a sinistra.
}
@end
