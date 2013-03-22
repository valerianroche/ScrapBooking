//
//  SBAffichageBooks.m
//  Scrapbooking
//
//  Created by Valérian Roche on 19/03/13.
//  Copyright (c) 2013 Valérian Roche. All rights reserved.
//

#import "SBAffichageBooks.h"
#import "SBCreationBook.h"
#import "SBEditionBook.h"
#import "Book.h"

@interface SBAffichageBooks ()

@property (weak, nonatomic) UIButton *ajoutBook;
@property (strong, nonatomic) NSDateFormatter *formatter;
@property (strong, nonatomic) SBCreationBook *vueCreation;
@property (strong, nonatomic) SBEditionBook *vueEdition;

@end

@implementation SBAffichageBooks

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        //[self.store createUser:@"Me"];
        [self.store loadAllBooks];
    }
    return self;
}

-(SBCoreDataStore *)store {
    if (!_store) _store = [[SBCoreDataStore alloc] initForUser:@"Me"];
    return _store;
}

-(NSDateFormatter *)formatter {
    if (!_formatter) {
        _formatter = [[NSDateFormatter alloc] init];
        [_formatter setLocale:[NSLocale currentLocale]];
        [_formatter setDateFormat:@"dd MMMM yyyy - hh:mm"];
    }
    return _formatter;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.affichageBook setStore:self.store];
    if ([[self.store allBooks] count]) {
        [self.affichageBook setBook:[self.store.allBooks objectAtIndex:0]];
    }
    
    self.ajoutBook = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.ajoutBook setTitle:@"Add new book..." forState:UIControlStateNormal];
    [self.ajoutBook setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [[self.ajoutBook titleLabel] setFont:[UIFont boldSystemFontOfSize:17]];
    [self.ajoutBook addTarget:self action:@selector(creationBook) forControlEvents:UIControlEventTouchDown];
    [self.ajoutBook setFrame:CGRectMake(10, [self hauteurDeLaTable], 300, 44)];
    
    [self.view addSubview:self.ajoutBook];
    
    [self.navigationItem setRightBarButtonItem:self.editButtonItem];
}

// Target action for the add button

-(void)creationBook {
    if (!self.vueCreation) {
        self.vueCreation = [[SBCreationBook alloc] initWithStyle:UITableViewStyleGrouped];
        [self.vueCreation setDelegate:self];
    }
    [self.navigationController pushViewController:self.vueCreation animated:YES];
}

// Display of the add button

-(void)updateButton {
    [UIView animateWithDuration:0.3 animations:^{
       [self.ajoutBook setFrame:CGRectMake(10, [self hauteurDeLaTable], 300, 44)]; 
    }];
}

-(CGFloat)hauteurDeLaTable {
    return 50 + [self tableView:self.tableView numberOfRowsInSection:0] * [self tableView:self.tableView heightForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
}

//

- (void)didReceiveMemoryWarning
{
    self.vueCreation = nil;
    self.vueEdition = nil;
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - SBCreationBook delegate

-(BOOL)createBookWithName:(NSString *)name andDescription:(NSString *)description andColor:(UIColor *)color andTransparency:(double)alpha {
    if (!name || [name isEqualToString:@""])
        return NO;
    
    Book *book = [self.store createBook];
    [book setName:name];
    [book setDescrip:description];
    [book setCouleur:color];
    [book setAlpha:[NSNumber numberWithDouble:alpha]];
    if (![self.store saveChanges]) {
        return NO;
    }
    if ([self.store.allBooks count] == 1)
        [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
    else
        [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:[self.store.allBooks count]-1 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.affichageBook setBook:book];
    [self updateButton];
    
    return YES;
}

-(BOOL)deleteBook:(Book *)book {
    int index = [self.store.allBooks indexOfObject:book];
    [self.store deleteBook:book];
    
    if (index == NSNotFound)
        return NO;
    
    if ([self.store saveChanges]) {
        if ([self.store.allBooks count] == 0)
            [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
        else
            [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
        [self updateButton];
        
        if (self.affichageBook.book == book) {
            if ([[self.store allBooks] count]) {
                if (index > 1)
                    [self.affichageBook setBook:[self.store.allBooks objectAtIndex:index-1]];
                else {
                    [self.affichageBook setBook:[self.store.allBooks objectAtIndex:0]];
                }
            }
            else
                [self.affichageBook setBook:nil];
        }
        
        return YES;
    }
    
    
    
    return NO;
}

-(void)reloadBookRow:(Book *)book {
    int index = [self.store.allBooks indexOfObject:book];
    
    if (index == NSNotFound)
        return;
    
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
}

-(void)majGraph {
    [self.affichageBook majGraph];
}

-(void)saveContext {
    [self.store saveChanges];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
        return MAX([[self.store allBooks] count], 1);
    else
        return 0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    if (![[self.store allBooks] count]) {
        [[cell textLabel] setText:@"No book available"];
        [[cell detailTextLabel] setText:@"Tap the button to create one"];
        [cell setAccessoryType:UITableViewCellAccessoryNone];
    }
    
    else {
        Book *book = [[self.store allBooks] objectAtIndex:[indexPath indexAtPosition:1]];
        [[cell textLabel] setText:[book name]];
        [[cell detailTextLabel] setText:[self.formatter stringFromDate:[book dateModif]]];
        [cell setAccessoryType:UITableViewCellAccessoryDetailDisclosureButton];
    }
    
    return cell;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0)
        return @"Books";
    else
        return @"";
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

#pragma mark - Table view delegate

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if (![[self.store allBooks] count])
        return NO;
    else {
        return YES;
    }
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        Book *b = [self.store.allBooks objectAtIndex:[indexPath indexAtPosition:1]];
        [self deleteBook:[self.store.allBooks objectAtIndex:[indexPath indexAtPosition:1]]];
        
        if (self.affichageBook.book == b) {
            if ([[self.store allBooks] count]) {
                if ([indexPath indexAtPosition:1] > 1)
                    [self.affichageBook setBook:[self.store.allBooks objectAtIndex:[indexPath indexAtPosition:1]-1]];
                else {
                    [self.affichageBook setBook:[self.store.allBooks objectAtIndex:0]];
                }
            }
            else
                [self.affichageBook setBook:nil];
        }
    }
}

-(void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    if (!self.vueEdition) {
        self.vueEdition = [[SBEditionBook alloc] initWithStyle:UITableViewStyleGrouped];
        [self.vueEdition setDelegate:self];
    }
    [self.vueEdition setBook:[self.store.allBooks objectAtIndex:[indexPath indexAtPosition:1]]];
    
    [self.navigationController pushViewController:self.vueEdition animated:YES];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.affichageBook setBook:[[self.store allBooks] objectAtIndex:[indexPath indexAtPosition:1]]];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


@end
