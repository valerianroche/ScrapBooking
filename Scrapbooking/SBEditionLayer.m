//
//  SBEditionLayer.m
//  Scrapbooking
//
//  Created by Valérian Roche on 21/03/13.
//  Copyright (c) 2013 Valérian Roche. All rights reserved.
//

#import "SBEditionLayer.h"

@interface SBEditionLayer () <UITextFieldDelegate> {
    double slideValue;
    int choixCouleur;
    int choixType;
    NSArray *couleurs;
    NSArray *nomCouleurs;
    NSString *chaine;
}

@property (nonatomic, strong) UISlider *slider;
@property (nonatomic, strong) UITextField *champNom;
@property (nonatomic, strong) UIButton *suppress;

@end

@implementation SBEditionLayer

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.suppress = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.suppress setTitle:@"Delete" forState:UIControlStateNormal];
    [self.suppress setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [[self.suppress titleLabel] setFont:[UIFont boldSystemFontOfSize:20]];
    [self.suppress setBackgroundImage:[[UIImage imageNamed:@"Supprimer.png"] stretchableImageWithLeftCapWidth:10 topCapHeight:0] forState:UIControlStateNormal];
    [self.suppress addTarget:self action:@selector(deleteLayer) forControlEvents:UIControlEventTouchDown];
    
    [self.suppress setFrame:CGRectMake(10, [self hauteurTable], 300, 44)];
    [self.view addSubview:self.suppress];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self setContentSizeForViewInPopover:CGSizeMake(320, [self hauteurTable] + 60)];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    //[self.delegate majPopUp:[self hauteurTable] + 60];
}

-(void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.delegate saveStore];
}

-(void)updateButton {
    [self.suppress setFrame:CGRectMake(10, [self hauteurTable], 300, 44)];
}

-(CGFloat)hauteurTable {
    CGFloat hauteur = 0;
    int nbSections = [self numberOfSectionsInTableView:self.tableView];
    hauteur += (nbSections - 1)*50;
    
    CGFloat hauteurCell = [self tableView:self.tableView heightForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    
    for (int i = 0;i< nbSections; i++) {
        hauteur += [self tableView:self.tableView numberOfRowsInSection:i]*hauteurCell;
    }
    
    return hauteur;
}

-(void)valueChanged {
    [self.layer setAlpha:[NSNumber numberWithDouble:self.slider.value]];
    [self.delegate refreshLayer:self.layer];
}

-(void)setLayer:(Layer *)layer {
    if (_layer != layer) {
        _layer = layer;
        choixType = 0;
        slideValue = layer.alpha.doubleValue;
        chaine = [layer.text string];
        [self.slider setValue:slideValue];
        if ([layer image])
            choixType = 1;
        else {
            [self.champNom setText:[layer.text string]];
            NSRange *range = NULL;
            choixCouleur = [[self couleurs] indexOfObject:[[layer text] attribute:NSForegroundColorAttributeName atIndex:0 effectiveRange:range]];
        }
        [self.tableView reloadData];
        [self updateButton];
    }
}

-(void)deleteLayer {
    if ([self.delegate deleteLayer:self.layer]) {
        self.layer = nil;
        [self.navigationController popViewControllerAnimated:YES];
    }
}

-(NSArray *)couleurs {
    if (!couleurs)
        couleurs = [NSArray arrayWithObjects:[UIColor whiteColor],[UIColor yellowColor], [UIColor greenColor], [UIColor orangeColor], [UIColor redColor], [UIColor purpleColor], [UIColor blueColor], [UIColor brownColor], [UIColor grayColor], [UIColor blackColor], nil];
    return couleurs;
}

-(NSArray *)nomCouleurs {
    if (!nomCouleurs)
        nomCouleurs = [NSArray arrayWithObjects:@"White", @"Yellow", @"Green", @"Orange", @"Red", @"Purple", @"Blue", @"Brown", @"Gray", @"Black", nil];
    return nomCouleurs;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (choixType == 0) 
        return 4;
    else return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
        return 1;
    else if (section == 1 && choixType == 0)
        return 1;
    else if (section == 1 && choixType == 1)
        return 0;
    else if (section == 2)
        return [[self couleurs] count];
    else return 0;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0)
        return @"Transparency";
    else if (section == 1) {
        if (choixType == 0) {
            return @"Text";
        }
        else {
            return @"";
        }
    }
    else if (section == 2) {
            return @"Text Colour";
    }
    else return @"";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifierChoixSlider = @"CellSlider";
    static NSString *CellIdentifierChoixCouleur = @"CellCouleur";
    static NSString *CellIdentifierText = @"CellText";
    
    UITableViewCell *cell = nil;
    
    int section = [indexPath indexAtPosition:0];
    int rang = [indexPath indexAtPosition:1];
    
    if (section == 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifierChoixSlider];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifierChoixSlider];
            if (!self.slider) {
                self.slider = [[UISlider alloc] initWithFrame:CGRectMake(10, 0, cell.bounds.size.width-20, cell.bounds.size.height-0)];
                [self.slider setValue:slideValue];
                [self.slider setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
                [self.slider addTarget:self action:@selector(valueChanged) forControlEvents:UIControlEventValueChanged];
            }
            [[cell contentView] addSubview:self.slider];
        }
    }
    else if (section == 1) {
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifierText];
        if (!cell)
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifierText];
        
        if (!self.champNom) {
            self.champNom = [[UITextField alloc] initWithFrame:CGRectMake(10, 0, cell.bounds.size.width-40, cell.bounds.size.height-0)];
            [self.champNom setPlaceholder:@"Text"];
            [self.champNom setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
            [self.champNom setDelegate:self];
            [self.champNom setAutocapitalizationType:UITextAutocapitalizationTypeSentences];
            [self.champNom setAutocorrectionType:UITextAutocorrectionTypeNo];
            [self.champNom setClearButtonMode:UITextFieldViewModeWhileEditing];
            [self.champNom setText:chaine];
        }
        [[cell contentView] addSubview:self.champNom];
    }
    
    else {
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
    
    return cell;
}

-(NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.champNom resignFirstResponder];
    if ([indexPath indexAtPosition:0] == 2) {
        return indexPath;
    }
    else
        return nil;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    int row = [indexPath indexAtPosition:1];
    if (choixCouleur != row) {
        [[self.tableView cellForRowAtIndexPath:indexPath] setAccessoryType:UITableViewCellAccessoryCheckmark];
        [[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:choixCouleur inSection:2]] setAccessoryType:UITableViewCellAccessoryNone];
        choixCouleur = row;
        [self.layer setAlpha:[NSNumber numberWithDouble:self.slider.value]];
        
        NSRange *range = NULL;
        UIFont * font = [[self.layer text] attribute:NSFontAttributeName atIndex:0 effectiveRange:range];
        NSAttributedString *att = [[NSAttributedString alloc] initWithString:[self.champNom text] attributes:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[[self couleurs] objectAtIndex:choixCouleur], [UIFont boldSystemFontOfSize:[font pointSize]],nil] forKeys:[NSArray arrayWithObjects:NSForegroundColorAttributeName,NSFontAttributeName,nil]]];
        [self.layer setText:att];
        
        UILabel *label = [[UILabel alloc] init];
        [label setAttributedText:att];
        [label sizeToFit];
        
        
        [self.layer setRect:CGRectMake(self.layer.rect.origin.x + self.layer.rect.size.width/2 - label.bounds.size.width/2, self.layer.rect.origin.y + self.layer.rect.size.height/2- label.bounds.size.height/2, label.bounds.size.width, label.bounds.size.height)];
        
        [self.delegate refreshLayer:self.layer];
    }
}

#pragma mark - Text field delegate

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    if ([textField text] && ![[textField text] isEqualToString:@""]) {
        NSRange *range = NULL;
        UIFont * font = [[self.layer text] attribute:NSFontAttributeName atIndex:0 effectiveRange:range];
        NSAttributedString *att = [[NSAttributedString alloc] initWithString:[textField text] attributes:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[[self couleurs] objectAtIndex:choixCouleur], [UIFont boldSystemFontOfSize:[font pointSize]],nil] forKeys:[NSArray arrayWithObjects:NSForegroundColorAttributeName,NSFontAttributeName,nil]]];
        [self.layer setText:att];
        
        UILabel *label = [[UILabel alloc] init];
        [label setAttributedText:att];
        [label sizeToFit];
        
        [self.layer setRect:CGRectMake(self.layer.rect.origin.x + self.layer.rect.size.width/2 - label.bounds.size.width/2, self.layer.rect.origin.y + self.layer.rect.size.height/2- label.bounds.size.height/2, label.bounds.size.width, label.bounds.size.height)];
        [self.delegate refreshLayer:self.layer];
        
        [self.delegate saveStore];
    }
    [textField resignFirstResponder];
    return YES;
}

@end
