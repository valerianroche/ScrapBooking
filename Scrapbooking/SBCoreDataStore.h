//
//  SBCoreDataStore.h
//  Scrapbooking
//
//  Created by Valérian Roche on 19/03/13.
//  Copyright (c) 2013 Valérian Roche. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Utilisateur.h"
#import "Book.h"
#import "Layer.h"

@interface SBCoreDataStore : NSObject {
    NSMutableArray *books;
    NSMutableArray *layers;
    NSManagedObjectContext *context;
    NSManagedObjectModel *model;
    Utilisateur *user;
    Book *currentBook;
    int idObjMax;
    int idLayerMax;
    int layerOrderMax;
}

-(id)initForUser:(NSString *)username;

-(Utilisateur *)createUser:(NSString *)username;

-(void)loadAllBooks;
-(NSArray *)allBooks;
-(Book *)createBook;
-(void)deleteBook:(Book *)book;

-(void)loadAllLayersForBook:(Book *)book;
-(NSArray *)allLayersForBook:(Book *)book;
-(Layer *)createLayer;
-(void)deleteLayer:(Layer *)layer;
-(void)moveLayer:(Layer *)layer toRank:(int)newRank;

-(BOOL)saveChanges;

@end
