//
//  SBBookEditingController.m
//  Scrapbooking
//
//  Created by Valérian Roche on 19/03/13.
//  Copyright (c) 2013 Valérian Roche. All rights reserved.
//

#import "SBBookEditingController.h"
#import "SBAffichageOrdreLayersViewController.h"
#import "SBAffichageAjoutLayer.h"
#import <QuartzCore/QuartzCore.h>

@interface SBBookEditingController () {
    SBAffichageOrdreLayersViewController *tableControllerLayers;
    SBAffichageAjoutLayer *tableControllerAjout;
    UINavigationController *controllerAjout;
    NSArray *oldTouches;
    UIView *selectedView;
    double zoom;
    double angle;
    double decalageX;
    double decalageY;
}

@property (nonatomic, strong) UIPopoverController *affichageAjout;
@property (nonatomic, strong) UIPopoverController *affichageOrdre;

-(void)effacePopovers;

@end

@implementation SBBookEditingController

# pragma mark - Initializers

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(id)init {
    self = [super init];
    if (!self)
        return self;
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (self.book) {
        UIBarButtonItem *organizeLayers = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"LAYERS",nil) style:UIBarButtonItemStylePlain target:self action:@selector(afficheLayers:)];
        
        UIBarButtonItem *addLayer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addLayer:)];
        
        [self.navigationItem setRightBarButtonItems:[NSArray arrayWithObjects:organizeLayers, addLayer, nil] animated:NO];
        
        [self.navigationItem setTitle:self.book.name];
        NSArray *layers = [self.store allLayersForBook:self.book];
        for (Layer *layer in layers) {
            [self afficheLayer:layer];
        }
    }
    else {
        [self.navigationItem setTitle:NSLocalizedString(@"NO_BOOK",nil)];
    }
    
    UIBarButtonItem *photo = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"CAPTURE",nil) style:UIBarButtonItemStylePlain target:self action:@selector(saveBook)];
    NSMutableArray *bouttons = [[self.navigationItem leftBarButtonItems] mutableCopy];
    if ([bouttons count]) {
        [bouttons addObject:photo];
        [self.navigationItem setLeftBarButtonItems:bouttons animated:NO];
    }
    else {
        [self.navigationItem setLeftBarButtonItem:photo animated:NO];
    }
    
    [self.view setMultipleTouchEnabled:YES];
	// Do any additional setup after loading the view.
}

# pragma mark - Getters and setters

-(UIPopoverController *)affichageOrdre {
    if (!_affichageOrdre) {
        
        tableControllerLayers = [[SBAffichageOrdreLayersViewController alloc] initWithStyle:UITableViewStylePlain];
        [tableControllerLayers setBook:self.book];
        [tableControllerLayers setDelegate:self];
        [tableControllerLayers setTabLayers:[self.store allLayersForBook:self.book]];
        UINavigationController *controller = [[UINavigationController alloc] initWithRootViewController:tableControllerLayers];
        
        _affichageOrdre = [[UIPopoverController alloc] initWithContentViewController:controller];
        [_affichageOrdre setDelegate:self];
        
        [_affichageOrdre setPopoverContentSize:CGSizeMake(320, [tableControllerLayers hauteurTable])];
    }

    return _affichageOrdre;
}

-(UIPopoverController *)affichageAjout {
    if (!_affichageAjout) {
        
        tableControllerAjout = [[SBAffichageAjoutLayer alloc] initWithStyle:UITableViewStyleGrouped];
        [tableControllerAjout setDelegate:self];
        
        controllerAjout = [[UINavigationController alloc] initWithRootViewController:tableControllerAjout];
        UIBarButtonItem *ok = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(ajoutLayer)];
        UIBarButtonItem *cancel = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(effacePopovers)];
        [tableControllerAjout.navigationItem setLeftBarButtonItem:cancel];
        [tableControllerAjout.navigationItem setRightBarButtonItem:ok];
        
        _affichageAjout = [[UIPopoverController alloc] initWithContentViewController:controllerAjout];
        [_affichageAjout setDelegate:self];
        
        [_affichageAjout setPopoverContentSize:CGSizeMake(320, 37 + [tableControllerAjout hauteurTable])];
    }
    
    return _affichageAjout;
}

-(void)setBook:(Book *)book {
    if (!_book && book) {
        UIBarButtonItem *organizeLayers = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"LAYERS",nil) style:UIBarButtonItemStylePlain target:self action:@selector(afficheLayers:)];
        
        UIBarButtonItem *addLayer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addLayer:)];
        [self.navigationItem setRightBarButtonItems:[NSArray arrayWithObjects:organizeLayers, addLayer, nil] animated:NO];
    }
    
    else if (_book && !book) {
        [self.view setOpaque:YES];
        [self.view setBackgroundColor:[UIColor whiteColor]];
        [self.navigationItem setRightBarButtonItem:nil];
    }
    
    if (_book != book) {
        _book = book;
        [self.store loadAllLayersForBook:book];
        [self.navigationItem setTitle:_book.name];
        if (book) {
            [self.view setBackgroundColor:[book.couleur colorWithAlphaComponent:book.alpha.doubleValue]];
            /*if (book.alpha.doubleValue != 1) {
                [self.view setOpaque:NO];
                [self.view setAlpha:book.alpha.doubleValue];
            }
            else {
                [self.view setOpaque:YES];
            }*/
        }
        
        for (UIView *view in self.view.subviews) {
            [view removeFromSuperview];
        }
        
        NSArray *layers = [self.store allLayersForBook:self.book];
        for (Layer *layer in layers) {
            [self afficheLayer:layer];
        }
    }
}

-(void)afficheLayers:(UIBarButtonItem *)button {
    if ([self.affichageOrdre isPopoverVisible]) {
        [self.affichageOrdre dismissPopoverAnimated:YES];
        [button setStyle:UIBarButtonItemStylePlain];
    }
    else {
        if (tableControllerLayers.book != self.book)
            [tableControllerLayers setBook:self.book];
        [self.affichageOrdre setPopoverContentSize:CGSizeMake(320, [tableControllerLayers hauteurTable])];
        [self effacePopovers];
        [self.affichageOrdre presentPopoverFromBarButtonItem:button permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        [button setStyle:UIBarButtonItemStyleDone];
    }
}

-(void)addLayer:(UIBarButtonItem *)button {
    if ([self.affichageAjout isPopoverVisible]) {
        [self.affichageAjout dismissPopoverAnimated:YES];
        [button setStyle:UIBarButtonItemStylePlain];
    }
    else {
        [self effacePopovers];
        [self.affichageAjout presentPopoverFromBarButtonItem:button permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        [button setStyle:UIBarButtonItemStyleDone];
    }
}

-(void)ajoutLayer {
    if ([tableControllerAjout ajoutLayer])
        [self effacePopovers];
}

-(void)majGraph {
    if (self.book) {
        [self.view setBackgroundColor:[self.book.couleur colorWithAlphaComponent:self.book.alpha.doubleValue]];
    }
}

-(void)saveBook {
    UIGraphicsBeginImageContext(self.view.bounds.size);
    [self.view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
}

- (void)               image: (UIImage *) image
    didFinishSavingWithError: (NSError *) error
                 contextInfo: (void *) contextInfo {
    if (error != NULL) {
        [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"FAILURE",nil) message:NSLocalizedString(@"CAPTURE_FAIL",nil) delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil] show];
    }
    else {
        [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"SUCCESS",nil) message:NSLocalizedString(@"CAPTURE_SUCCESS",nil) delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil] show];
    }
}

#pragma mark - Layer edition delegate

-(Layer *)addNewLayer {
    Layer *layer = [self.store createLayer];
    [layer setBook:self.book];
    [layer setRect:CGRectMake(self.view.bounds.size.width/2, self.view.bounds.size.height/2, 0, 0)];
    return layer;
}

-(void)afficheLayer:(Layer *)layer {
    if ([layer image]) {
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[layer image]];
        [imageView setFrame:[layer rect]];
        [[imageView layer] setBorderWidth:1.0f];
        [[imageView layer] setBorderColor:[[UIColor clearColor] CGColor]];
        if (layer.alpha.doubleValue != 1) {
            [imageView setOpaque:NO];
            [imageView setAlpha:layer.alpha.doubleValue];
        }
        CGAffineTransform rot = CGAffineTransformMakeRotation([layer rotationRad].doubleValue);
        [imageView setTransform:rot];
        [self.view addSubview:imageView];
    }
    else {
        UILabel *label = [[UILabel alloc] initWithFrame:[layer rect]];
        [label setAttributedText:[layer text]];
        [label setOpaque:NO];
        [label setBackgroundColor:[UIColor clearColor]];
        [label setAlpha:layer.alpha.doubleValue];
        CGAffineTransform rot = CGAffineTransformMakeRotation([layer rotationRad].doubleValue);
        [label setTransform:rot];
        [self.view addSubview:label];
    }
}

-(void)refreshLayer:(Layer *)layer {
    int index = [[self.store allLayersForBook:self.book] indexOfObject:layer];
    if (index != NSNotFound && [layer image]) {
        UIImageView *view = [self.view.subviews objectAtIndex:index];
        if (layer.alpha.doubleValue != 1) {
            [view setOpaque:NO];
            [view setAlpha:layer.alpha.doubleValue];
        }
        else
            [view setOpaque:YES];
    }
    else if (index != NSNotFound) {
        UILabel *view = [self.view.subviews objectAtIndex:index];
        if (layer.alpha.doubleValue != 1) {
            [view setOpaque:NO];
            [view setAlpha:layer.alpha.doubleValue];
        }
        else
            [view setOpaque:YES];
        [view setAttributedText:[layer text]];
        [view setTransform:CGAffineTransformIdentity];
        [view setFrame:layer.rect];
        [view setTransform:CGAffineTransformMakeRotation(layer.rotationRad.doubleValue)];

    }
}

-(BOOL)deleteLayer:(Layer *)layer {
    int index = [[self.store allLayersForBook:self.book] indexOfObject:layer];
    if (index != NSNotFound) {
        [[self.view.subviews objectAtIndex:index] removeFromSuperview];
    }
    [self.store deleteLayer:layer];
    return [self.store saveChanges];
}

-(BOOL)moveLayer:(Layer *)layer toRow:(int)row {
    int index = [[self.store allLayersForBook:self.book] indexOfObject:layer];
    if (index != NSNotFound) {
        UIView *view = [self.view.subviews objectAtIndex:index];
        [view removeFromSuperview];
        if (index < row) {
            [self.view insertSubview:view atIndex:row];
        }
        else {
            [self.view insertSubview:view atIndex:row];
        }
            
    }
    
    [self.store moveLayer:layer toRank:row];
    return [self.store saveChanges];
}

-(BOOL)saveStore {
    return [self.store saveChanges];
}


-(void)majPopUp:(CGFloat)hauteur {
    [self.affichageOrdre setPopoverContentSize:CGSizeMake(320, hauteur) animated:YES];
}

-(void)presentImagePicker:(UIImagePickerController *)picker {
    [self.affichageAjout setContentViewController:picker animated:YES];
}

-(void)removeImagePicker {
    [self.affichageAjout setContentViewController:controllerAjout animated:YES];
}

# pragma mark - Popover Dismissal delegate

-(BOOL)popoverControllerShouldDismissPopover:(UIPopoverController *)popoverController {
    if (popoverController == self.affichageOrdre) {
        [(UIBarButtonItem *)[[self.navigationItem rightBarButtonItems] objectAtIndex:0] setStyle:UIBarButtonItemStylePlain];
    }
    else if (popoverController == self.affichageAjout) {
        [(UIBarButtonItem *)[[self.navigationItem rightBarButtonItems] objectAtIndex:1] setStyle:UIBarButtonItemStylePlain];
    }
    return YES;
}

-(void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController {
    if (popoverController == self.affichageAjout) {
        if ([self.affichageAjout contentViewController] != controllerAjout)
            [self.affichageAjout setContentViewController:controllerAjout];
    }
}

-(void)effacePopovers {
    if ([self.affichageAjout isPopoverVisible] && [self popoverControllerShouldDismissPopover:self.affichageAjout]) {
        [self.affichageAjout dismissPopoverAnimated:YES];
    }
    else if ([self.affichageOrdre isPopoverVisible] && [self popoverControllerShouldDismissPopover:self.affichageOrdre]) {
        [self.affichageOrdre dismissPopoverAnimated:YES];
    }
}

# pragma mark - Gesture Handling

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    NSArray *subviews = [self.view subviews];
    
    if ([touches count] == 1) {
        UITouch *touch = [[touches allObjects] objectAtIndex:0];

        for (int i = [subviews count]-1; i>=0; i--) {
            if ([[subviews objectAtIndex:i] pointInside:[touch locationInView:[subviews objectAtIndex:i]] withEvent:event]) {
                selectedView = [subviews objectAtIndex:i];
                break;
            }
        }
    }
    else if ([touches count] == 2) {
        UITouch *touch0 = [[touches allObjects] objectAtIndex:0];
        UITouch *touch1 = [[touches allObjects] objectAtIndex:1];
        
        for (int i = [subviews count]-1; i>=0; i--) {
            CGPoint centre = CGPointMake(([touch0 locationInView:[subviews objectAtIndex:i]].x + [touch1 locationInView:[subviews objectAtIndex:i]].x)/2 , ([touch0 locationInView:[subviews objectAtIndex:i]].y + [touch1 locationInView:[subviews objectAtIndex:i]].y)/2);
            
            if ([[subviews objectAtIndex:i] pointInside:centre withEvent:event]) {
                selectedView = [subviews objectAtIndex:i];
                break;
            }
        }
        
    }
    
    zoom = 1;
    angle = 0;
    decalageX = 0;
    decalageY = 0;
}

-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    if (selectedView) {
        if ([touches count] == 1) {
            CGPoint fin = [[[touches allObjects] objectAtIndex:0] locationInView:self.view];
            CGPoint debut = [[[touches allObjects] objectAtIndex:0] previousLocationInView:self.view];
            
            decalageX += fin.x - debut.x;
            decalageY += fin.y - debut.y;
            [selectedView setCenter:CGPointApplyAffineTransform(selectedView.center, CGAffineTransformMakeTranslation(fin.x - debut.x, fin.y - debut.y))];
        }
        else if ([touches count] == 2) {
            CGPoint debut0 = [[[touches allObjects] objectAtIndex:0] previousLocationInView:self.view];
            CGPoint debut1 = [[[touches allObjects] objectAtIndex:1] previousLocationInView:self.view];
            
            double angleDebut = atan2(debut1.y - debut0.y, debut1.x - debut0.x);
            double distanceDebut = sqrt((debut1.y - debut0.y)*(debut1.y - debut0.y)+(debut1.x - debut0.x)*(debut1.x - debut0.x));
            
            CGPoint fin0 = [[[touches allObjects] objectAtIndex:0] locationInView:self.view];
            CGPoint fin1 = [[[touches allObjects] objectAtIndex:1] locationInView:self.view];
            
            double angleFin = atan2(fin1.y - fin0.y, fin1.x - fin0.x);
            double distanceFin = sqrt((fin1.y - fin0.y)*(fin1.y - fin0.y)+(fin1.x - fin0.x)*(fin1.x - fin0.x));
            
            angle += angleFin - angleDebut;
            zoom *= distanceFin/distanceDebut;
            
            [selectedView setTransform:CGAffineTransformScale(CGAffineTransformRotate(selectedView.transform, angleFin - angleDebut),distanceFin/distanceDebut,distanceFin/distanceDebut)];
        }
    }
    else {
        if ([touches count] == 1) {
            CGPoint fin = [[[touches allObjects] objectAtIndex:0] locationInView:self.view];
            CGPoint debut = [[[touches allObjects] objectAtIndex:0] previousLocationInView:self.view];
            
            decalageX += fin.x - debut.x;
            decalageY += fin.y - debut.y;
            
            if (decalageX > 40 && decalageY < 20) {
            }
        }
    }
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    int index = [self.view.subviews indexOfObject:selectedView];
    if (index != NSNotFound) {
        Layer *layer = [[self.store allLayersForBook:self.book] objectAtIndex:index];
        CGRect newRect = CGRectMake((layer.rect.origin.x + (layer.rect.size.width)/2 + decalageX) - layer.rect.size.width * zoom/2, (layer.rect.origin.y + (layer.rect.size.height)/2 +decalageY) - layer.rect.size.height * zoom/2, layer.rect.size.width * zoom, layer.rect.size.height * zoom);
        
        if (layer.text) {
            NSMutableAttributedString *temp = [layer.text mutableCopy];
            NSRange *range = NULL;
            UIFont *font = [temp attribute:NSFontAttributeName atIndex:0 effectiveRange:range];
            [temp addAttribute:NSFontAttributeName value:[font fontWithSize:(int)[font pointSize]*zoom] range:NSMakeRange(0, [temp length])];
            layer.text = temp;
        }
        
        [layer setRect:newRect];
        [layer setRotationRad:[NSNumber numberWithDouble:layer.rotationRad.doubleValue + angle]];
        
        [self.store saveChanges];
    }
    
    selectedView = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Split View delegate

-(void)splitViewController:(UISplitViewController *)svc willHideViewController:(UIViewController *)aViewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)pc {
    [barButtonItem setTitle:NSLocalizedString(@"BOOKS",nil)];
    NSMutableArray *bouttons = [[self.navigationItem leftBarButtonItems] mutableCopy];
    if ([bouttons count]) {
        [bouttons insertObject:barButtonItem atIndex:0];
        [self.navigationItem setLeftBarButtonItems:bouttons animated:NO];
    }
}

-(void)splitViewController:(UISplitViewController *)svc willShowViewController:(UIViewController *)aViewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem {
    [self.navigationItem setLeftBarButtonItem:nil animated:NO];
}

-(BOOL)splitViewController:(UISplitViewController *)svc shouldHideViewController:(UIViewController *)vc inOrientation:(UIInterfaceOrientation)orientation {
    return YES;
}

@end
