//
//  SBAffichageOrdreLayersViewController.m
//  Scrapbooking
//
//  Created by Valérian Roche on 20/03/13.
//  Copyright (c) 2013 Valérian Roche. All rights reserved.
//

#import "SBAffichageOrdreLayersViewController.h"
#import "SBEditionLayer.h"

@interface SBAffichageOrdreLayersViewController () <SBEditionLayerDelegate>

@property (nonatomic, strong) SBEditionLayer *vueEdition;

@end

@implementation SBAffichageOrdreLayersViewController

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
    
}

-(CGFloat)hauteurTable {
    if ([[self.navigationController viewControllers] containsObject:self.vueEdition]){
        return [self.vueEdition hauteurTable]+60;
    }
    CGFloat hauteur = 0;
    if ([self.tabLayers count])
        hauteur += 37;
    
    hauteur += [self tableView:self.tableView numberOfRowsInSection:0]*[self tableView:self.tableView heightForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    return hauteur;
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tableView reloadData];
    [self setContentSizeForViewInPopover:CGSizeMake(320, [self hauteurTable] - 37)];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.delegate majPopUp:[self hauteurTable]];
}

-(void)setTabLayers:(NSArray *)tabLayers {
    if (_tabLayers != tabLayers && self.tableView) {
        _tabLayers = tabLayers;
    }
}

- (void)didReceiveMemoryWarning
{
    self.vueEdition = nil;
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([self.tabLayers count]) {
        [self.navigationController setNavigationBarHidden:NO animated:YES];
        self.navigationItem.rightBarButtonItem = self.editButtonItem;
    }
    else
        [self.navigationController setNavigationBarHidden:YES animated:YES];
    return MAX(1,[self.tabLayers count]);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        [cell setAccessoryType:UITableViewCellAccessoryDetailDisclosureButton];
    }
    
    if ([self.tabLayers count]) {
        Layer *layer = [self.tabLayers objectAtIndex:[indexPath indexAtPosition:1]];
        [cell setAccessoryType:UITableViewCellAccessoryDetailDisclosureButton];
        if ([layer imageData]) {
            [[cell textLabel] setText:[NSString stringWithFormat:NSLocalizedString(@"LAYER_PICTURE",nil)]];
            [[cell detailTextLabel] setText:@""];
            [[cell imageView] setImage:layer.image];
        }
        
        else {
            [[cell textLabel] setText:[NSString stringWithFormat:NSLocalizedString(@"LAYER_STRING",nil)]];
            [[cell detailTextLabel] setText:layer.text.string];
            [[cell imageView] setImage:nil];
        }
    }
    else {
        [[cell textLabel] setText:NSLocalizedString(@"NO_LAYER",nil)];
        [[cell detailTextLabel] setText:@""];
        [[cell imageView] setImage:nil];
        
        [cell setAccessoryType:UITableViewCellAccessoryNone];
    }
    
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        if ([self.delegate deleteLayer:[self.tabLayers objectAtIndex:[indexPath indexAtPosition:1]]]) {
            if ([self.tabLayers count])
                [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            else {
                [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                [self setEditing:NO animated:YES];
            }
        }
    }   
}



// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    if ([self.delegate moveLayer:[self.tabLayers objectAtIndex:[fromIndexPath indexAtPosition:1]] toRow:[toIndexPath indexAtPosition:1]]) {
        [self.delegate saveStore];
    }
}

-(void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    if (!self.vueEdition) {
        self.vueEdition = [[SBEditionLayer alloc] initWithStyle:UITableViewStyleGrouped];
        [self.vueEdition setDelegate:self.delegate];
    }
    [self.vueEdition setLayer:[self.tabLayers objectAtIndex:[indexPath indexAtPosition:1]]];
    [self.navigationController pushViewController:self.vueEdition animated:YES];
}

#pragma mark - Table view delegate

-(NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.tabLayers count])
        return indexPath;
    else
        return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
