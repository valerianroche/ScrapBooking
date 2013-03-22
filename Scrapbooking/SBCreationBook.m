//
//  SBCreationBook.m
//  Scrapbooking
//
//  Created by Valérian Roche on 19/03/13.
//  Copyright (c) 2013 Valérian Roche. All rights reserved.
//

#import "SBCreationBook.h"
#define descriptionHeight 100

@interface SBCreationBook () {
    int choixCouleur;
    NSArray *couleurs;
    NSArray *nomCouleurs;
}

@property (nonatomic, strong) UITextField *champNom;
@property (nonatomic, strong) UITextView *champDescription;
@property (nonatomic, strong) UISlider *slider;

@end

@implementation SBCreationBook

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
    [self.navigationItem setTitle:NSLocalizedString(@"NEW_BOOK",nil)];
    
    [self.tableView setAllowsSelection:YES];
    UIButton *ajoutBook = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [ajoutBook setTitle:NSLocalizedString(@"CREATE_BOOK",nil) forState:UIControlStateNormal];
    [ajoutBook setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [[ajoutBook titleLabel] setFont:[UIFont boldSystemFontOfSize:17]];
    
    [ajoutBook setFrame:CGRectMake(10, [self hauteurTable], 300, 44)];
    [ajoutBook addTarget:self action:@selector(createBook) forControlEvents:UIControlEventTouchDown];
    
    [self.view addSubview:ajoutBook];
    
    /*UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOnTable:)];
    [self.view addGestureRecognizer:recognizer];*/
}

-(void)tapOnTable {
    [self.champNom resignFirstResponder];
    [self.champDescription resignFirstResponder];
}

-(void)createBook {
    [self.champDescription resignFirstResponder];
    [self.champNom resignFirstResponder];
    
    if ([self.delegate createBookWithName:[self.champNom text] andDescription:[self.champDescription text] andColor:[[self couleurs] objectAtIndex:choixCouleur] andTransparency:self.slider.value]) {
        [self.champNom setText:@""];
        [self.champDescription setText:@""];
        [self.navigationController popViewControllerAnimated:YES];
    }
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
    
    //return 2*50 + [self tableView:self.tableView heightForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]] + [self tableView:self.tableView heightForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]];
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section < 2)
        return 1;
    else if (section == 2)
        return 1 + [[self couleurs] count];
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
    if (section == 3)
        return 50;
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
                [self.champNom setPlaceholder:NSLocalizedString(@"NAME",nil)];
                [self.champNom setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
                [self.champNom setDelegate:self];
                [self.champNom setAutocapitalizationType:UITextAutocapitalizationTypeSentences];
                [self.champNom setAutocorrectionType:UITextAutocorrectionTypeNo];
                [self.champNom setClearButtonMode:UITextFieldViewModeWhileEditing];
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
    }
}

-(BOOL)textViewShouldEndEditing:(UITextView *)textView {
        
    return YES;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    if ([textField text] && ![[textField text] isEqualToString:@""]) {
        
    }
    [textField resignFirstResponder];
    return YES;
}


@end
