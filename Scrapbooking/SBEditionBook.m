//
//  SBEditionBook.m
//  Scrapbooking
//
//  Created by Valérian Roche on 19/03/13.
//  Copyright (c) 2013 Valérian Roche. All rights reserved.
//

#import "SBEditionBook.h"
#define descriptionHeight 100

@interface SBEditionBook () <UITextFieldDelegate, UITextViewDelegate> {
    BOOL modification;
    int choixCouleur;
    double valeurSlide;
    NSArray *couleurs;
    NSArray *nomCouleurs;
}

@property (nonatomic, strong) UITextField *champNom;
@property (nonatomic, strong) UITextView *champDescription;
@property (nonatomic, strong) UISlider *slider;

@end

@implementation SBEditionBook

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

    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button setTitle:NSLocalizedString(@"DELETE",nil) forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [[button titleLabel] setFont:[UIFont boldSystemFontOfSize:20]];
    [button setBackgroundImage:[[UIImage imageNamed:@"Supprimer.png"] stretchableImageWithLeftCapWidth:10 topCapHeight:0] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(deleteBook) forControlEvents:UIControlEventTouchDown];
    
    [button setFrame:CGRectMake(10, [self hauteurTable], 300, 44)];
    [self.view addSubview:button];
    
    /*UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOnTable)];
    [self.view addGestureRecognizer:recognizer];*/
}

-(CGFloat)hauteurTable {
    CGFloat hauteur = 0;
    int nbSections = [self numberOfSectionsInTableView:self.tableView];
    hauteur += (nbSections+1)*50;
    
    CGFloat hauteurCell = [self tableView:self.tableView heightForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    
    for (int i = 0;i< nbSections; i++) {
        hauteur += [self tableView:self.tableView numberOfRowsInSection:i]*hauteurCell;
    }
    
    return hauteur;
    //return 2*50 + [self tableView:self.tableView heightForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]] + [self tableView:self.tableView heightForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]];
}

-(void)tapOnTable {
    [self.champNom resignFirstResponder];
    [self.champDescription resignFirstResponder];
}

-(void)deleteBook {
    if ([self.delegate deleteBook:self.book]) {
        self.book = nil;
        [self.navigationController popViewControllerAnimated:YES];
    }
}

-(void)didMoveToParentViewController:(UIViewController *)parent {
    [self textFieldShouldReturn:self.champNom];
    [self textViewShouldEndEditing:self.champDescription];
    
    if (modification) {
        [self.delegate saveContext];
        [self.delegate reloadBookRow:self.book];
    }
    
    modification = NO;
}

-(void)setBook:(Book *)book {
    if (_book == book)
        return;
    
    _book = book;
    if (book) {
        [self.navigationItem setTitle:book.name];
        [self.champDescription setText:book.descrip];
        [self.champNom setText:book.name];
        choixCouleur = [[self couleurs] indexOfObject:book.couleur];
        if (choixCouleur > [[self couleurs] count])
            choixCouleur = 0;
        if (self.slider) {
            [self.slider setValue:book.alpha.doubleValue];
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:2] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
        else {
            valeurSlide = book.alpha.doubleValue;
        }
    }
    else {
        [self.navigationItem setTitle:@""];
        [self.champDescription setText:@""];
        [self.champNom setText:@""];
        choixCouleur = 0;
    }
}

-(void)majValue {
    [self.book setAlpha:[NSNumber numberWithDouble:self.slider.value]];
    [self.delegate majGraph];
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
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section < 2)
        return 1;
    else if (section == 2)
        return [[self couleurs] count] + 1;
    else
        return 0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([indexPath indexAtPosition:0] == 1)
        return descriptionHeight;
    else
        return 44;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (section == 2)
        return 75;
    else
        return UITableViewAutomaticDimension;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0)
        return NSLocalizedString(@"NAME",nil);
    else if (section == 1)
        return NSLocalizedString(@"DESCRIPTION",nil);
    else if (section == 2)
        return NSLocalizedString(@"APPEARANCE",nil);
    else
        return @"";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifierNom = @"CellNom";
    static NSString *CellIdentifierDescription = @"CellDescription";
    static NSString *CellIdentifierChoixSlider = @"CellSlider";
    static NSString *CellIdentifierChoixCouleur = @"CellCouleur";
    
    UITableViewCell *cell = nil;
    
    int section = [indexPath indexAtPosition:0];
    if (section == 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifierNom];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifierNom];
            
            if (!self.champNom) {
                self.champNom = [[UITextField alloc] initWithFrame:CGRectMake(10, 0, cell.bounds.size.width-40, cell.bounds.size.height-0)];
                [self.champNom setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
                [self.champNom setDelegate:self];
                [self.champNom setAutocapitalizationType:UITextAutocapitalizationTypeSentences];
                [self.champNom setAutocorrectionType:UITextAutocorrectionTypeNo];
                [self.champNom setClearButtonMode:UITextFieldViewModeWhileEditing];
                [self.champNom setText:self.book.name];
            }
            [[cell contentView] addSubview:self.champNom];
        }
        
    }
    
    else if (section == 1) {
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifierNom];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifierDescription];
            
            CGRect rect = cell.bounds;
            rect.origin.x += 8;
            rect.origin.y += 5;
            rect.size.width -= 20 + 16;
            rect.size.height = descriptionHeight - 10;
            self.champDescription = [[UITextView alloc] initWithFrame:rect];
            [self.champDescription setDelegate:self];
            [self.champDescription setFont:[UIFont systemFontOfSize:[UIFont systemFontSize]]];
            [self.champDescription setBackgroundColor:[UIColor groupTableViewBackgroundColor]];
            [self.champDescription setText:self.book.descrip];
            [cell.contentView addSubview:self.champDescription];
        }
        
    }
    
    else {
        if ([indexPath indexAtPosition:1] == 0) {
            cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifierChoixSlider];
            if (!cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifierChoixSlider];
                if (!self.slider) {
                    self.slider = [[UISlider alloc] initWithFrame:CGRectMake(10, 0, cell.bounds.size.width-20, cell.bounds.size.height-0)];
                    [self.slider setValue:1.0];
                    [self.slider setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
                    [self.slider setValue:valeurSlide];
                    [self.slider addTarget:self action:@selector(majValue) forControlEvents:UIControlEventValueChanged];
                }
                [[cell contentView] addSubview:self.slider];
            }
        }
        else {
            int rang = [indexPath indexAtPosition:1]-1;
            cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifierChoixCouleur];
            if (!cell)
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifierChoixCouleur];
            
            [[cell textLabel] setText:[[self nomCouleurs] objectAtIndex:rang]];
            [[cell textLabel] setTextColor:[[self couleurs] objectAtIndex:rang]];
            if (rang == 0) {
                [[cell textLabel] setTextColor:[UIColor lightGrayColor]];
            }
            
            if (choixCouleur == rang) {
                [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
            }
            else
                [cell setAccessoryType:UITableViewCellAccessoryNone];
        }
    }
    
    return cell;
}

-(NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self tapOnTable];
    if ([indexPath indexAtPosition:0] == 2 && [indexPath indexAtPosition:1] != 0) {
        return indexPath;
    }
    else
        return nil;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    int row = [indexPath indexAtPosition:1] -1;
    if (choixCouleur != row) {
        [[self.tableView cellForRowAtIndexPath:indexPath] setAccessoryType:UITableViewCellAccessoryCheckmark];
        [[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:choixCouleur+1 inSection:2]] setAccessoryType:UITableViewCellAccessoryNone];
        choixCouleur = row;
        [self.book setAlpha:[NSNumber numberWithDouble:self.slider.value]];
        [self.book setCouleur:[[self couleurs] objectAtIndex:row]];
        [self.delegate majGraph];
    }
}

-(BOOL)textViewShouldEndEditing:(UITextView *)textView {
    [self.book setDescrip:[textView text]];
    [textView resignFirstResponder];
    modification = YES;
    return YES;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    if ([textField text] && ![[textField text] isEqualToString:@""]) {
        [self.book setName:[textField text]];
        [self.navigationItem setTitle:[textField text]];
        modification = YES;
    }
    [textField resignFirstResponder];
    return YES;
}

@end
