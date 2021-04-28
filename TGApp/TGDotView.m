#import "UIKit/UIKit.h"
#include "TGDotView.h"
#import "TGDotShapeLayer.h"
@implementation TGDotView
-(instancetype)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	//if (self)
    //    [self buildDots];
	return self;
}
-(TGDotShapeLayer*)dotShapeLayerWithTag:(int)tag {
	for (TGDotShapeLayer *layer in self.layer.sublayers)
		if (layer.tag == tag)
			return layer;
	return NULL;
}
-(void)buildDots{
    float middleButton = self.frame.size.width/2; // Calcola il punto medio della vista.
    int spaces = 20; // Specifica quanti spazi devono esserci tra un layer e un altro.
    int singleLocation = spaces;
    int lenght = ((spaces *2) + (7*4)); // Ci sono 4 layer. Ognuno dei quali ha una lunghezza pari a 7 (specificata nella sua creazione). 4 layer significa che abbiamo 3 porzioni vuote (spazi), ma ne indichiamo 2 per allargarle.
    int currentLocation = middleButton - (lenght/2); // Indica dove iniziare a mettere il primo layer.
	TGDotShapeLayer *firstLayer = [TGDotShapeLayer dotShapeLayerLocated:currentLocation tag:1];
	currentLocation = currentLocation + singleLocation; // Avanza.
	TGDotShapeLayer *secondLayer = [TGDotShapeLayer dotShapeLayerLocated:currentLocation tag:2];
	currentLocation = currentLocation + singleLocation; // Avanza.
	TGDotShapeLayer *thirdLayer = [TGDotShapeLayer dotShapeLayerLocated:currentLocation tag:3];
	currentLocation = currentLocation + singleLocation; // Avanza.
	TGDotShapeLayer *fourthLayer = [TGDotShapeLayer dotShapeLayerLocated:currentLocation tag:4];
	[firstLayer fillLayer]; // Il primo layer deve essere quello con il colore "fillato", perché aprendo l'app ci troviamo nella prima schermata.
	_activeDot = 1; // Il primo dot è quello attivo.
	[self.layer addSublayer:firstLayer]; // Aggiungi il layer alla lista dei layer.
	[self.layer addSublayer:secondLayer]; // Aggiungi il layer alla lista dei layer.
	[self.layer addSublayer:thirdLayer]; // Aggiungi il layer alla lista dei layer.
	[self.layer addSublayer:fourthLayer]; // Aggiungi il layer alla lista dei layer.
}
-(void)changeDot { // Funzione che cambia il dot che appare "fillato"
	TGDotShapeLayer *layer = [self dotShapeLayerWithTag:_activeDot]; // Ottieni il dot attualmente fillato.
	[layer unfillLayer]; // Togli il colore dentro.
	_activeDot++; // Passa al dot successivo.
	layer = [self dotShapeLayerWithTag:_activeDot]; // Ottieni il dot successivo.
	if (layer) // Se esiste...
		[layer fillLayer]; // Riempilo.
}
-(void)updatePosition {
    self.center = CGPointMake(self.superview.center.x, self.frame.origin.y - 6); // Ottieni il centro della supervista, ma spostati più sopra rispetto al bottone (Layer e Bottone hanno lo stesso frame).
    self.layer.position = self.center; // Aggiorna il centro dei layer.
}
@end
