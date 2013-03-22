//
//  SBAffichageAjoutLayer.m
//  Scrapbooking
//
//  Created by Valérian Roche on 20/03/13.
//  Copyright (c) 2013 Valérian Roche. All rights reserved.
//

#import "SBAffichageAjoutLayer.h"
#import <QuartzCore/QuartzCore.h>

@interface SBAffichageAjoutLayer () <UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate> {
    int choixType;
    int choixCouleur;
    NSArray *couleurs;
    NSArray *nomCouleurs;
    UIImage *image;

}
@property (nonatomic, strong) UITextField *champNom;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIImagePickerController *picker;
@property (nonatomic, strong) UISlider *slider;

-(NSArray *)couleurs;
-(NSArray *)nomCouleurs;

@end

@implementation SBAffichageAjoutLayer

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, [self hauteurTable] - 20, 300, ([self.nomCouleurs count] -1) * [self tableView:self.tableView heightForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]])];
        [_imageView setBackgroundColor:[UIColor grayColor]];
    }
    return _imageView;
}

-(UIImagePickerController *)picker {
    if (!_picker) {
        _picker = [[UIImagePickerController alloc] init];
        [_picker setDelegate:self];
       
    }
    return _picker;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

-(CGFloat)hauteurTable {
    CGFloat hauteur = 0;
    int nbSections = [self numberOfSectionsInTableView:self.tableView];
    hauteur += nbSections*50;
    
    CGFloat hauteurCell = [self tableView:self.tableView heightForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    
    for (int i = 0;i< nbSections; i++) {
        hauteur += [self tableView:self.tableView numberOfRowsInSection:i]*hauteurCell;
    }
    
    return hauteur;
}

-(BOOL)ajoutLayer {
    if (choixType == 0 && [self.champNom text] && ![[self.champNom text] isEqualToString:@""]) {
        Layer *layer = [self.delegate addNewLayer];
        [layer setText:[[NSAttributedString alloc] initWithString:[self.champNom text] attributes:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[[self couleurs] objectAtIndex:choixCouleur], [UIFont boldSystemFontOfSize:40],nil] forKeys:[NSArray arrayWithObjects:NSForegroundColorAttributeName,NSFontAttributeName,nil]]]];
        UILabel *label = [[UILabel alloc] init];
        [label setAttributedText:[layer text]];
        [layer setAlpha:[NSNumber numberWithDouble:self.slider.value]];
        [label sizeToFit];
        [layer setRect:CGRectMake(layer.rect.origin.x - label.bounds.size.width/2, layer.rect.origin.y - label.bounds.size.height/2, label.bounds.size.width, label.bounds.size.height)];
        
        [self.delegate afficheLayer:layer];
        
        image = nil;
        [self.champNom setText:nil];
        return [self.delegate saveStore];
    }
    else if (choixType == 1 && image) {
        
        Layer *layer = [self.delegate addNewLayer];
        [layer setImage:image];
        [layer setAlpha:[NSNumber numberWithDouble:self.slider.value]];
        
        double scale = image.size.width/image.size.height;
        
        CGFloat width = MIN(layer.rect.origin.x, layer.rect.origin.y*scale);
        CGFloat height = MIN(layer.rect.origin.y, layer.rect.origin.x/scale);
        
        [layer setRect:CGRectMake(layer.rect.origin.x - width/2, layer.rect.origin.y - height/2, width, height)];
        
        [self.delegate afficheLayer:layer];
        image = nil;
        [self.champNom setText:nil];
        return [self.delegate saveStore];
        
    }
    else
        return NO;
}

-(NSArray *)couleurs {
    if (!couleurs)
        couleurs = [NSArray arrayWithObjects:[UIColor whiteColor],[UIColor yellowColor], [UIColor greenColor], [UIColor orangeColor], [UIColor redColor], [UIColor purpleColor], [UIColor blueColor], [UIColor brownColor], [UIColor grayColor], [UIColor blackColor], nil];
    return couleurs;
}

-(NSArray *)nomCouleurs {
    if (!nomCouleurs)
        nomCouleurs = [NSArray arrayWithObjects:NSLocalizedString(@"WHITE",nil), NSLocalizedString(@"YELLOW",nil), NSLocalizedString(@"GREEN",nil), NSLocalizedString(@"ORANGE",nil), NSLocalizedString(@"RED",nil), NSLocalizedString(@"PURPLE",nil), NSLocalizedString(@"BLUE",nil), NSLocalizedString(@"BROWN",nil), NSLocalizedString(@"GRAY",nil), NSLocalizedString(@"BLACK",nil), nil];
    return nomCouleurs;
}

- (void)didReceiveMemoryWarning
{
    self.picker = nil;
    self.imageView = nil;
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (choixType == 0)
        return 4;
    else
        return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
        return 2;
    else if (section == 1) {
        return 1;
    }
    else if (section == 2) {
        if (choixType == 0) {
            return 1;
        }
        else if ([UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear])
            return 2;
        else
            return 1;
    }
    else {
        if (choixType == 0) {
            return [[self couleurs] count];
        }
        else
            return 0;
    }
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0)
        return NSLocalizedString(@"CHOOSE_LAYER_TYPE",nil);
    else if (section == 1)
        return NSLocalizedString(@"TRANSPARENCY",nil);
    else if (section == 2) {
        if (choixType == 0) {
            return NSLocalizedString(@"SET_TEXT",nil);
        }
        else {
            return NSLocalizedString(@"CHOOSE_PICTURE",nil);
        }
    }
    else {
        if (choixType == 0) {
            return NSLocalizedString(@"TEXT_COLOR",nil);
        }
        else
            return NSLocalizedString(@"PREVIEW",nil);
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifierChoixType = @"CellType";
    static NSString *CellIdentifierChoixSlider = @"CellSlider";
    static NSString *CellIdentifierSelectionPhoto = @"CellPhoto";
    static NSString *CellIdentifierChoixCouleur = @"CellCouleur";
    static NSString *CellIdentifierText = @"CellText";
    
    UITableViewCell *cell = nil;
    
    int section = [indexPath indexAtPosition:0];
    int rang = [indexPath indexAtPosition:1];
    
    if (section == 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifierChoixType];
        if (!cell)
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifierChoixType];
        
        if (rang == 0) {
            [[cell textLabel] setText:NSLocalizedString(@"TEXT",nil)];
        }
        else {
            [[cell textLabel] setText:NSLocalizedString(@"PICTURE",nil)];
        }
        
        if (choixType == rang)
            [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
        else
            [cell setAccessoryType:UITableViewCellAccessoryNone];
    }
    else if (section == 1) {
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifierChoixSlider];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifierChoixSlider];
            if (!self.slider) {
                self.slider = [[UISlider alloc] initWithFrame:CGRectMake(10, 0, cell.bounds.size.width-20, cell.bounds.size.height-0)];
                [self.slider setValue:1.0];
                [self.slider setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
            }
            [[cell contentView] addSubview:self.slider];
        }
    }
    else if (section == 2) {
        if (choixType == 0) {
            cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifierText];
            if (!cell)
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifierText];
            
            if (!self.champNom) {
                self.champNom = [[UITextField alloc] initWithFrame:CGRectMake(10, 0, cell.bounds.size.width-40, cell.bounds.size.height-0)];
                [self.champNom setPlaceholder:NSLocalizedString(@"TEXT",nil)];
                [self.champNom setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
                [self.champNom setDelegate:self];
                [self.champNom setAutocapitalizationType:UITextAutocapitalizationTypeSentences];
                [self.champNom setAutocorrectionType:UITextAutocorrectionTypeNo];
                [self.champNom setClearButtonMode:UITextFieldViewModeWhileEditing];
            }
            [[cell contentView] addSubview:self.champNom];
        }
        
        else {
            cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifierSelectionPhoto];
            if (!cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifierSelectionPhoto];
                [[cell textLabel] setTextAlignment:NSTextAlignmentCenter];
            }
            
            if (rang == 0)
                [[cell textLabel] setText:NSLocalizedString(@"PICK_EXISTING",nil)];
            else
                [[cell textLabel] setText:NSLocalizedString(@"TAKE_NEW",nil)];
        }
    }
    
    else {
        if (choixType == 0) {
            cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifierChoixCouleur];
            if (!cell)
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifierChoixCouleur];
            
            [[cell textLabel] setText:[[self nomCouleurs] objectAtIndex:rang]];
            [[cell textLabel] setTextColor:[[self couleurs] objectAtIndex:rang]];
            if (rang == 0) {
                [[cell textLabel] setTextColor:[UIColor lightGrayColor]];
            }
            
            if (rang == choixCouleur)
                [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
            else
                [cell setAccessoryType:UITableViewCellAccessoryNone];
        }
    }
    
    
    // Configure the cell...
    
    return cell;
}


#pragma mark - Table view delegate

-(NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([indexPath indexAtPosition:0] == 1 && choixType == 0) {
        return nil;
    }
    else {
        [self.champNom resignFirstResponder];
        return indexPath;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    int section = [indexPath indexAtPosition:0];
    int row = [indexPath indexAtPosition:1];
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (section == 0 && choixType != row) {
        choixType = row;
        [self.tableView reloadData];
        if (row == 1) {
            [self.view addSubview:self.imageView];
        }
        else if (_imageView) {
            [self.imageView removeFromSuperview];
        }
    }
    
    else if (section == 2 && choixType == 1) {
        if (row == 0 && [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
            [self.picker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
            [self.delegate presentImagePicker:self.picker];
            self.picker = nil;
        }
        else if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            [self.picker setSourceType:UIImagePickerControllerSourceTypeCamera];
            [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
            [self presentViewController:self.picker animated:YES completion:nil];
        }
    }
    
    else if (section == 3 && choixCouleur != row) {
        [[self.tableView cellForRowAtIndexPath:indexPath] setAccessoryType:UITableViewCellAccessoryCheckmark];
        [[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:choixCouleur inSection:3]] setAccessoryType:UITableViewCellAccessoryNone];
        choixCouleur = row;
    }
}

#pragma mark - Text field delegate

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    if ([textField text] && ![[textField text] isEqualToString:@""]) {
        
    }
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - Image picker delegate

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    image = nil;
    image = [info objectForKey:UIImagePickerControllerEditedImage];
    
    if (!image) {
        image = [info objectForKey:UIImagePickerControllerOriginalImage];
    }
    
    if (!image) {
        image = [info objectForKey:UIImagePickerControllerCropRect];
    }
    
    double scale = image.size.width/image.size.height;
    
    CGFloat width = MIN(300, ([self.nomCouleurs count] -1) * [self tableView:self.tableView heightForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]]*scale);
    CGFloat height = MIN(([self.nomCouleurs count] -1) * [self tableView:self.tableView heightForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]], 300/scale);
    
    [self.imageView setFrame:CGRectMake(10 + (300 - width)/2, self.imageView.frame.origin.y, width, height)];
    [self.imageView setImage:image];
    
    if ([[UIApplication sharedApplication] isStatusBarHidden]) {
        [self dismissViewControllerAnimated:YES completion:nil];
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
    }
    else
        [self.delegate removeImagePicker];
    self.picker = nil;
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    if ([[UIApplication sharedApplication] isStatusBarHidden]) {
        [self dismissViewControllerAnimated:YES completion:nil];
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
    }
    else
        [self.delegate removeImagePicker];
    self.picker = nil;
}

-(void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    UIBarButtonItem *cancel = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(annulePicker)];
    [viewController.navigationItem setRightBarButtonItem:cancel];
}

-(void)annulePicker {
    [self.delegate removeImagePicker];
}

@end
