//
//  SBEditionBook.h
//  Scrapbooking
//
//  Created by Valérian Roche on 19/03/13.
//  Copyright (c) 2013 Valérian Roche. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SBCreationBook.h"
#import "Book.h"

@interface SBEditionBook : UITableViewController 

@property (nonatomic, weak) id<SBCreationBookDelegate> delegate;
@property (nonatomic, weak) Book *book;

@end
