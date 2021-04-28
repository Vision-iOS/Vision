#import "UIKit/UIKit.h"
#import "TGImagesViewController.h"
#import "TGBarButtonItem.h"
#import "TGImage.h"
#import "TGMetadata.h"
#import "TGColor.h"
#import "UIView+Toast.h"
#import "TGPermissionsManager.h"
#import "TGMainViewController.h"


static UIView *footerView;
@implementation TGImagesViewController
-(instancetype)init {
    self = [super init];
    self.images = [TGImages sharedInstance]; // Ottieni l'istanza delle immagini.
    return self;
}
-(instancetype)initWithImage:(UIImage*)image originalImage:(UIImage*)originalImage{
    self = [super init];
    self.path = [TGImages randomImagePath];
    [[TGImages sharedInstance] addImage:image]; // Aggiungi una nuova immagine.
    self.images = [TGImages sharedInstance]; // Ottieni l'istanza delle immagini.
    _originalImage = originalImage; // Salva una copia del riferimento all'immagine (quindi in realtà non salva un duplicato ma solo la sua referenza).
    self.mode = 0;
    return self;
}
-(NSNumber *)latitudeNumberFromString:(NSString *)str{
    NSArray *components = [str componentsSeparatedByString:@","];
    for(NSString *name in components){
        NSString *realName = [name hasPrefix:@" "] ? [name substringFromIndex:1] :name;
        if([realName containsString:@"latitude"]){
            NSString *latitudeString = [realName stringByReplacingOccurrencesOfString:@"latitude" withString:@""];
            return @(latitudeString.floatValue);
        }
    }
    return NULL;
}
-(NSNumber *)longitudeNumberFromString:(NSString *)str{
    NSArray *components = [str componentsSeparatedByString:@","];
    for(NSString *name in components){
        NSString *realName = [name hasPrefix:@" "] ? [name substringFromIndex:1] :name;
        if([realName containsString:@"longitude"]){
            NSString *longitudeString = [realName stringByReplacingOccurrencesOfString:@"longitude" withString:@""];
            return @(longitudeString.floatValue);
        }
    }
    return NULL;
}
-(instancetype)initWithEditedImage:(UIImage*)image path:(NSString *)path metadata:(NSString *)metadata{
    self = [super init];
    self.images = [TGImages new];
    NSArray *metadataArray;
    if([metadata containsString:@","])
        metadataArray = [metadata componentsSeparatedByString:@","];
    else
        metadataArray = @[metadata];
    NSNumber *latitude = [self latitudeNumberFromString:metadata];
    NSNumber *longitude = [self longitudeNumberFromString:metadata];
    for(NSString *currentName in metadataArray){
        NSString *realName;
        NSRange range = [currentName rangeOfString:@" "];
        if (NSNotFound != range.location && [realName hasPrefix:@" "])
            realName = [currentName stringByReplacingCharactersInRange:range withString:@""];
        else
            realName = currentName;
        if(![realName containsString:@"latitude"] && ![realName containsString:@"longitude"]){
            TGImage *tgImage = [[TGImage alloc] initWithName:realName image:image confidence:201 latitude:latitude.floatValue longitude:longitude.floatValue];
            [self.images.images addObject:tgImage];
        }
    }
    self.path = path;
    _originalImage = image;
    _metadata = metadata;
    self.mode = 1;
    return self;
}
-(void)addActivityIndicator { // Aggiunge un indicatore circolare che specifica che qualcosa è in elaborazione. In realtà non appare mai in quanto il processo di identificazione degli oggetti è davvero rapido!
	UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)]; // Crea l'indicatore.
	[activityIndicator startAnimating]; // Avvia l'animazione.
	UIBarButtonItem *activityItem = [[UIBarButtonItem alloc] initWithCustomView:activityIndicator]; // Crea un tasto per la barra di navigazione.
	self.navigationItem.rightBarButtonItem = activityItem; // Impostalo.
}
-(void)updateTitle {
    if(self.mode==1){
        [self setTitle:@"Edit metadata"];
      //  [self addItemAddButton];
        _tableView.alwaysBounceVertical = TRUE;
        return;
    }
	//self.navigationItem.rightBarButtonItem = nil;
	if (self.images.count == 1) // Se ho trovato una sola immagine...
		[self setTitle:@"1 match"];
	else
	if (self.images.count > 1) // Se ce ne sono più di una...
		[self setTitle:[NSString stringWithFormat:@"%d matches", (int)self.images.count]];
	else {
      //  TGImages *images = self.images;
        TGImages *images = [TGImages sharedInstance];
        if (([images count]==0) && (images.done)) { // Se non ho trovato immagini e ho terminato il processo di analisi...
			[self setTitle:@"Image analysis"];
		//	self.navigationItem.rightBarButtonItem = nil;
			UILabel *label = [footerView viewWithTag:53];
			label.text = @"No objects found";
        }
		else{
			[self setTitle:@"Processing..."]; // Sto processando (non ho finito, perche images.done = FALSE)
			[self addActivityIndicator]; // Aggiungi l'indicatore circolare.
		}
	}
   // if (self.navigationItem.rightBarButtonItem == nil && self.images.count) // Se non c'è alcun bottone e c'è almeno un'immagine...
		//[self addExportButton]; // Aggiungi il tasto che permette di esportare l'immagine.
   //     [self addItemAddButton];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if(![defaults boolForKey:@"firstScan"]){
        static dispatch_once_t onceToken; // Inizializza un token.
        dispatch_once(&onceToken, ^{ // Se non è mai stato utilizzato...
            [defaults setBool:TRUE forKey:@"firstScan"];
            [defaults synchronize];
            self.confettiView = [[TGConfettiView alloc] initWithFrame:self.view.bounds];
            [self.view addSubview:self.confettiView];
            [self.view makeToast:@"Yeah! You have analyzed your first image!" duration:3.0 position:CSToastPositionBottom];
            [self.confettiView starConfetti];
            [self.confettiView performSelector:@selector(stopConfetti) withObject:nil afterDelay:3.0];
        });
    }
	_tableView.alwaysBounceVertical = self.images.count > 0; // Permetti di scorrere la vista solo se ci sono immagini, quindi se c'è effettivamente una tabella.
}
-(void)viewWillAppear:(BOOL)animated {       
	[super viewWillAppear:animated];
    if(self.mode==0)
        [self.navigationController setNavigationBarHidden:NO animated:YES]; // Mostra la barra di navigazione prima di mostrare la vista.
}
-(void)closeModal{
    [self dismissViewControllerAnimated:YES completion:nil];
}
-(void)addMetadataAction{
    TGPermissionsManager *manager = [TGPermissionsManager sharedInstance];
    NSNumber *latitudeNumber, *longitudeNumber;
    if(self.mode==0){
        latitudeNumber = @(manager.latitude);
        longitudeNumber = @(manager.longitude);
    }
    else{
        latitudeNumber = [self latitudeNumberFromString:_metadata];
        longitudeNumber = [self longitudeNumberFromString:_metadata];
    }
    __weak UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Don't you see an object?" message:@"Add an item below." preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"Type something...";
    }];
    __weak TGImages *weakImages = self.images;
    __weak UIImage *weakImage = _originalImage;
    __weak TGImagesViewController *weakSelf = self;
    __weak id weakDelegate = self.delegate;
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *addAction = [UIAlertAction actionWithTitle:@"Add item" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *alertAction) {
        UITextField *textField = alertController.textFields.firstObject;
        if (textField.text && textField.text.length > 0) {
            NSString *name = [[textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] lowercaseString];
            if(name && name.length > 250){
                [weakSelf showAlertWithTitle:@"This description is too long." message:nil];
            }
            else
            if (name && name.length > 0) {
                NSCharacterSet *s = [[NSCharacterSet characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwxyz0123456789 "] invertedSet];
                NSRange r = [name rangeOfCharacterFromSet:s];
                if (r.location != NSNotFound) {
                    [weakSelf showAlertWithTitle:@"Your description isn't valid because it contains illegal characters." message:@"You can use alphanumerical characters including the whitespace."];
                }
                else
                if([name containsString:@"latitude"] || [name containsString:@"longitude"] || [name containsString:@"your photo"]){
                    [weakSelf showAlertWithTitle:@"Your description isn't valid because it contains illegal words." message:@"Latitude, longitude and \"your photo\" are three private words."];
                }
                else{
                    if (![weakImages hasImageNamed:name]) { // Se non abbiamo già aggiunto una corrispondenza con lo stesso nome...
                        TGImage *tgImage = [[TGImage alloc]  initWithName:name image:weakImage confidence:self.mode==0 ? 200 : 201 latitude:latitudeNumber.floatValue longitude:longitudeNumber.floatValue]; // Definiamo l'immagine con le sue proprietà.
                        weakImages.done = YES;
                        [weakImages insertImage:tgImage]; // Aggiungiamola.
                        if(weakDelegate && [self.delegate respondsToSelector:@selector(updateCurrentMetadataWithMetadata:)])
                            [weakDelegate performSelector:@selector(updateCurrentMetadataWithMetadata:) withObject:[weakImages description]];
                    }else{
                        [weakSelf showAlertWithTitle:@"You have already inserted this description." message:nil];
                    }
                }
            }else
                [weakSelf showAlertWithTitle:@"The description cannot be empty." message:nil];
        }
    }];
    [alertController addAction:cancelAction];
    [alertController addAction:addAction];
    [self presentViewController:alertController animated:YES completion:nil];
}
-(BOOL)canBeAdded:(NSString *)name{
    if(!name)
        return TRUE;
    NSArray *metadataArray;
    if([name containsString:@","])
        metadataArray = [name componentsSeparatedByString:@","];
    else
        metadataArray = @[name];
    for(NSString *currentName in metadataArray){
        NSString *realName;
        NSRange range = [currentName rangeOfString:@" "];
        if (NSNotFound != range.location)
            realName = [currentName stringByReplacingCharactersInRange:range withString:@""];
        else
            realName = currentName;
        if([realName isEqual:name])
            return FALSE;
    }
    return TRUE;
}
-(void)addCloseButton{
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"Close" style:UIBarButtonItemStylePlain target:self action:@selector(closeModal)];
    [item setTintColor:[TGColor dynamicRedColor]];
    [self.navigationItem setLeftBarButtonItem:item];
}
-(void)addItemAddButton{
    // AGGIUNGERE CONTROLLO SELF.MODE
    UIBarButtonItem *item =  [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addMetadataAction)];
    if(self.mode==0)
        [self.images saveImage:_originalImage atPath:self.path]; // Salva l'immagine.
    [self.navigationItem setRightBarButtonItem:item animated:NO];
}

-(void)viewDidLoad {
	[super viewDidLoad];
    [self addItemAddButton];
  //  [self addCloseButton];
	_tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped]; // Crea una tabella con i frame della vista (escludendo barra di navigazione), con uno stile a sezioni.
	_tableView.delegate = self; // Il delegato sarà il controller stesso.
	_tableView.dataSource = self; // E' il controller stesso a fornire i dati.
	_tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth; // Auto layout per la tabella.
	[self.view addSubview:_tableView]; // Aggiungi la tabella alla vista del suddetto controller.
	[self updateTitle];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willUpdateDataSource:) name:@"NewTGImage" object:nil]; // Specifica quale metodo sarà chiamato quando verrà postata questa notifica.
    [[TGPermissionsManager sharedInstance] askLocationPermission];
}
-(void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
    if ([self isMovingFromParentViewController] && self.mode==0){
        [self.tabBarController.tabBar setHidden:NO];
    }
}
-(void)willUpdateDataSource:(id)source {
    if (footerView) // Se il footer esiste (che contiene la stringa che indica che l'immagine è sotto elaborazione)..
        footerView.hidden = TRUE; // Nascondilo, perché c'è una nuova corrispondenza!
    NSInteger oldCount = self.images.count; // Ottieni il numero edi immagini attuali.
    if(self.mode==0)
        self.images = [TGImages sharedInstance]; // Aggiorna le immagini.
    NSInteger newCount = self.images.count; // Ottieni ul nuovo numero di immagini attuali.
    if (newCount > oldCount) { // Se il nuovo numero è maggiore del vecchio, allora vuol dire che è stata aggiunta una corrispondenza.
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.images.count-1 inSection:0]; // Crea l'indexPath corrispondente alla cella nuova da aggiungere.
        [_tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationBottom]; // Inserisci la cella. Non carichiamo tutta la tabella con [_tableView reloadData] perché sarebbe dispendioso, piuttosto decidiamo di inserire solo la riga necessaria.
    }
    else // Se il nuovo numero è minore del vecchio, allora vuol dire che è stata rimossa una corrispondenza.
        [_tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation: UITableViewRowAnimationFade]; // In questo caso bisogna caricare la sezione, dato che c'è qualcosa è stato rimosso al suo interno.
    [self updateTitle];
    [self.images saveImage:_originalImage atPath:self.path]; // Salva l'immagine.
}
#pragma mark - UITableViewDataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1; // Solo una sezione in questa tabella.
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return self.images.count; // Ci sono self.images.count righe in questa sezione.
}
-(CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {    
	return UITableViewAutomaticDimension; // Segui le dimensioni del Dynamic Font di IOS.
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return UITableViewAutomaticDimension;  // Segui le dimensioni del Dynamic Font di IOS.
}
-(BOOL)tableView:(UITableView *)tableView shouldShowMenuForRowAtIndexPath:(NSIndexPath *)indexPath {
	return YES; // Permetti di mostrare il menu di iOS al tocco sulla cella.
}
-(BOOL)tableView:(UITableView *)tableView canPerformAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	return (action == @selector(copy:)); // Mostra solo l'azione "Copia".
}
-(void)tableView:(UITableView *)tableView performAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	if (action == @selector(copy:)) { // Se l'azione selezionata è "Copia"...
		UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath]; // Ottieni la cella su cui sto cliccando.
		[[UIPasteboard generalPasteboard] setString:cell.textLabel.text]; // Salva nella clipboard il nome della corrispondenza.
	}
}
-(UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
	if (self.images.count == 0) { // Se ho trovato 0 oggetti...
		UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, self.view.frame.size.width, 40)]; // Crea un label largo quanto lo schermo, alto 40 pixel, sufficienti per contenere un testo di una linea.
		label.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin; // Abilita l'auto layout.
		label.numberOfLines = 0; // Linee infinite, anche se in realtà ce ne serve solo una, ma è comunque buona norma impostarlo sempre a 0.
		label.font = [UIFont boldSystemFontOfSize:16]; // Imposta un font in grassetto.
        TGImages *images =  self.images;
        if (([images count]==0) && (images.done)){ // Se ho trovato 0 immagini e ho finito il processo di estrazione delle corrispondenze...
            if(self.mode==0)
                label.text = @"No objects found"; // Il footer conterrà questa stringa.
            else
                label.text = @"Add new metadata with the plus button";
        }
		else
        if (self.mode==0)// Se non ho finito ancora...
            label.text = @"Processing..."; // Il footer conterrà questa stringa.
        else
            label.text = @"Add new metadata with the plus button";
		label.textColor = [UIColor colorWithRed:0.43 green:0.43 blue:0.45 alpha:1.0]; // Imposta il colore del font, è in genere quello di default usato da iOS.
		label.textAlignment = NSTextAlignmentCenter; // Posiziona il label al centro del frame.
        label.tag = 53; // Assegniamo un tag al label, così da poterlo trovare facilmente in seguito.
		footerView = [[UIView alloc] init];
		footerView.autoresizingMask = UIViewAutoresizingFlexibleWidth; // Auto layout in larghezza.
		[footerView addSubview:label]; // Aggiungi il label al footer.
		return footerView;
	}
	return NULL;
}
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	int section = indexPath.section, row = indexPath.row;
	NSString *identifier = [NSString stringWithFormat:@"TGImagesCell%d-%d", section, row]; // Imposta come identificatore questo nome univoco.
	UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:identifier]; // Ottieni la cella, se già stata allocata in precedenza.
	if (cell == nil) // Se non è già stata allocata in precedenza...
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier]; // Crea la cella.
    TGImages *images = self.images;
	TGImage *image = [images.images objectAtIndex:row];
    NSString *name = image.name;
    if([name hasPrefix:@" "])
        name = [name substringFromIndex:1];
    cell.textLabel.text = name; // Imposta il nome della cella (corrispondenza).
	[cell.textLabel setFont:[UIFont boldSystemFontOfSize:cell.textLabel.font.pointSize]]; // Imposta un font in grassetto di sistema, basandosi sulla dimensione del testo della cella.
    if(image.confidence==200)
        cell.detailTextLabel.text = @"Added from the user";
    else
    if(image.confidence!=201)
        cell.detailTextLabel.text = [NSString stringWithFormat:@"Reliability: %3.2f%%", image.confidence * 100]; // Imposta come sottotitolo l'indice di affidabilità (confidenza).
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image.image]; // Crea una UIImageView partendo dall'immagine.
    imageView.clipsToBounds = TRUE; // Rendi i bordi arrotondati.
    imageView.layer.cornerRadius = 5.0; // Specifica di quanto i bordi devono essere arrotondati. Il valore di default usato da iOS è 5.0 per le icone nelle celle.
    cell.accessoryView = imageView; // Imposta l'immagine come vista accessoria, posta sempre al lato destro nella cella.
    cell.accessoryView.frame = cell.detailTextLabel.text.length ? CGRectMake(0, 0, 45.0, 45.0) :  CGRectMake(0, 0, 35.0, 35.0); // Imposta il frame massimo dell'accessorio, in modo tale che non tocchi mai i bordi della cella.
	[cell sizeToFit]; // Adatta la cella ai cambiamenti dell'accessory view.
	cell.textLabel.numberOfLines = 0; // Il label può contenere un nome molto lungo, invece di troncarlo permetti di andare a capo.
	return cell;
}
-(NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath{
	return @"Delete"; // Il nome del tasto da mostrare quando si esegue uno swipe left su una cella.
}
-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
/* Questo metodo viene chiamato quando si clicca su "Delete". Se ho potuto cliccare su "Delete" vuol dire che il processo di identificazione degli oggetti nell'immagine
   era terminato, quindi lo specifico nuovamente e rimuovo la corrispondenza dalla lista delle corrispondenze.
*/
    TGImages *images = self.images;
	images.done = YES;
	[images removeImageAtIndex:indexPath.row];
    if(self.delegate && [self.delegate respondsToSelector:@selector(updateCurrentMetadataWithMetadata:)])
        [self.delegate performSelector:@selector(updateCurrentMetadataWithMetadata:) withObject:[images description]];
      
}
#pragma mark - UITableViewDelegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}
@end
