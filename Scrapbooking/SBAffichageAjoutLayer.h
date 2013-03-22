//
//  SBAffichageAjoutLayer.h
//  Scrapbooking
//
//  Created by Valérian Roche on 20/03/13.
//  Copyright (c) 2013 Valérian Roche. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SBAffichageOrdreLayersViewController.h"

@interface SBAffichageAjoutLayer : UITableViewController

@property (nonatomic, weak) id<SBEditionLayerDelegate> delegate;

-(CGFloat)hauteurTable;
-(BOOL)ajoutLayer;

@end
