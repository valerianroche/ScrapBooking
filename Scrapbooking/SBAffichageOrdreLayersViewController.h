//
//  SBAffichageOrdreLayersViewController.h
//  Scrapbooking
//
//  Created by Valérian Roche on 20/03/13.
//  Copyright (c) 2013 Valérian Roche. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Book.h"
#import "Layer.h"

@protocol SBEditionLayerDelegate <NSObject>

@optional
-(Layer *)addNewLayer;
-(void)afficheLayer:(Layer *)layer;
-(void)refreshLayer:(Layer *)layer;
-(BOOL)deleteLayer:(Layer *)layer;
-(BOOL)moveLayer:(Layer *)layer toRow:(int)row;
-(BOOL)saveStore;

-(void)majPopUp:(CGFloat)hauteur;
-(void)presentImagePicker:(UIImagePickerController *)picker;
-(void)removeImagePicker;

@end

@interface SBAffichageOrdreLayersViewController : UITableViewController

@property (nonatomic, weak) Book *book;
@property (nonatomic, weak) NSArray *tabLayers;
@property (nonatomic, weak) id<SBEditionLayerDelegate> delegate;

-(CGFloat)hauteurTable;

@end
