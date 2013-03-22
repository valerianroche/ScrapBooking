//
//  SBEditionLayer.h
//  Scrapbooking
//
//  Created by Valérian Roche on 21/03/13.
//  Copyright (c) 2013 Valérian Roche. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SBAffichageOrdreLayersViewController.h"
#import "Layer.h"

@interface SBEditionLayer : UITableViewController

@property (nonatomic, strong) Layer *layer;
@property (nonatomic, weak) id<SBEditionLayerDelegate> delegate;

-(CGFloat)hauteurTable;

@end
