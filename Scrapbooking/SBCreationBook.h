//
//  SBCreationBook.h
//  Scrapbooking
//
//  Created by Valérian Roche on 19/03/13.
//  Copyright (c) 2013 Valérian Roche. All rights reserved.
//

@class Book;
#import <UIKit/UIKit.h>

@protocol SBCreationBookDelegate <NSObject>

-(BOOL)createBookWithName:(NSString *)name andDescription:(NSString *)description andColor:(UIColor *)color andTransparency:(double)alpha;
-(void)reloadBookRow:(Book *)book;
-(BOOL)deleteBook:(Book *)book;
-(void)majGraph;
-(void)saveContext;

@end

@interface SBCreationBook : UITableViewController <UITextFieldDelegate, UITextViewDelegate>

@property (nonatomic, weak) id<SBCreationBookDelegate> delegate;

@end
