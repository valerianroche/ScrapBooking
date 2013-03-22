//
//  SBAffichageBooks.h
//  Scrapbooking
//
//  Created by Valérian Roche on 19/03/13.
//  Copyright (c) 2013 Valérian Roche. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SBCreationBook.h"
#import "SBCoreDataStore.h"
#import "SBBookEditingController.h"

@interface SBAffichageBooks : UITableViewController <SBCreationBookDelegate>

@property (nonatomic, strong) SBCoreDataStore *store;
@property (nonatomic, weak) SBBookEditingController *affichageBook;

@end
