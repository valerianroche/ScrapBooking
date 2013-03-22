//
//  SBBookEditingController.h
//  Scrapbooking
//
//  Created by Valérian Roche on 19/03/13.
//  Copyright (c) 2013 Valérian Roche. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SBCoreDataStore.h"
#import "SBAffichageOrdreLayersViewController.h"

@interface SBBookEditingController : UIViewController <UIPopoverControllerDelegate, SBEditionLayerDelegate, UISplitViewControllerDelegate>

@property (nonatomic, weak) Book *book;
@property (nonatomic, weak) SBCoreDataStore *store;

-(void)majGraph;
-(void)saveBook;

@end
