//
//  SBCoreDataStore.m
//  Scrapbooking
//
//  Created by Valérian Roche on 19/03/13.
//  Copyright (c) 2013 Valérian Roche. All rights reserved.
//

#import "SBCoreDataStore.h"

@interface SBCoreDataStore()

-(NSString *)booksArchivePath;

@end

@implementation SBCoreDataStore

-(id)initForUser:(NSString *)username {
    
    self = [super init];
    if (!self)
        return self;
    
    model = [NSManagedObjectModel mergedModelFromBundles:nil];
    
    NSPersistentStoreCoordinator *psc = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:model];
    NSURL *storeURL = [NSURL fileURLWithPath:self.booksArchivePath];
    
    
    //[[NSFileManager defaultManager] removeItemAtURL:storeURL error:NULL];
    
    NSError *error = nil;
    if (![psc addPersistentStoreWithType:NSSQLiteStoreType
                      configuration:nil
                                URL:storeURL
                            options:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:NSMigratePersistentStoresAutomaticallyOption]
                              error:&error])
    {
        [NSException raise:@"Could not load the database" format:@"Reason: %@", error.localizedDescription];
    }
    
    context = [[NSManagedObjectContext alloc] init];
    context.persistentStoreCoordinator = psc;
    context.undoManager = nil;
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Utilisateur"];
    [request setPredicate:[NSPredicate predicateWithFormat:@"name LIKE %@", username]];
    NSArray *result = [context executeFetchRequest:request error:NULL];
    
    if (result && [result count])
        user = [result objectAtIndex:0];
    
    return self;
}

-(Utilisateur *)createUser:(NSString *)username {
    Utilisateur *newUser = [NSEntityDescription insertNewObjectForEntityForName:@"Utilisateur" inManagedObjectContext:context];
    [newUser setName:username];
    user = newUser;
    return newUser;
}

-(void)loadAllBooks {
    if (!books) {
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Book"];
        [request setPredicate:[NSPredicate predicateWithFormat:@"createur == %@ OR editeur == %@",user, user]];
        [request setSortDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"id" ascending:YES]]];
        
        NSError *error = nil;
        NSArray *result = [context executeFetchRequest:request error:&error];
        if (!result) {
            [NSException raise:@"Fetch failed" format:@"Reason: %@", error.localizedDescription];
        }
        
        idObjMax = 0;
        [result enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            idObjMax = MAX(idObjMax, ((Book *)obj).id.intValue);
        }];
        
        books = [result mutableCopy];
    }
}

-(NSArray *)allBooks {
    return books;
}

-(Book *)createBook {
    Book *book = [NSEntityDescription insertNewObjectForEntityForName:@"Book" inManagedObjectContext:context];
    [book setCreateur:user];
    idObjMax++;
    [book setId:[NSNumber numberWithInt:idObjMax]];
    [books addObject:book];
    return book;
}

-(void)deleteBook:(Book *)book {
    [books removeObject:book];
    [context deleteObject:book];
}


-(void)loadAllLayersForBook:(Book *)book {
    
    if (!layers || currentBook != book) {
        currentBook = book;
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Layer"];
        [request setPredicate:[NSPredicate predicateWithFormat:@"book == %@", book]];
        [request setSortDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"layerOrder" ascending:YES]]];
        
        NSError *error = nil;
        NSArray *result = [context executeFetchRequest:request error:&error];
        if (!result) {
            [NSException raise:@"Fetch failed" format:@"Reason: %@", error.localizedDescription];
        }
        
        layerOrderMax = 0;
        idLayerMax = 0;
        [result enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            layerOrderMax = MAX(layerOrderMax, ((Layer *)obj).layerOrder.intValue);
            idLayerMax = MAX(idLayerMax, ((Layer *)obj).id.intValue);
        }];
        layers = [result mutableCopy];
    }
}

-(NSArray *)allLayersForBook:(Book *)book {
    if (!layers || currentBook != book) {
        [self loadAllLayersForBook:book];
    }
    return layers;
}

-(Layer *)createLayer {
    Layer *layer = [NSEntityDescription insertNewObjectForEntityForName:@"Layer" inManagedObjectContext:context];
    layerOrderMax++;
    idLayerMax++;
    [layer setLayerOrder:[NSNumber numberWithInt:layerOrderMax]];
    [layer setId:[NSNumber numberWithInt:idLayerMax]];
    [layers addObject:layer];
    return layer;
}

-(void)deleteLayer:(Layer *)layer {
    [layers removeObject:layer];
    [context deleteObject:layer];
}

-(void)moveLayer:(Layer *)layer toRank:(int)newRank {
    if (newRank < [layers count]) {
        
        NSNumber *numberNewRank = ((Layer *)[layers objectAtIndex:newRank]).layerOrder;
        int index = [layers indexOfObject:layer];
        if (index < newRank) {
            for (int i = index+1;i<newRank+1;i++) {
                ((Layer *)[layers objectAtIndex:i]).layerOrder = [NSNumber numberWithInt:((Layer *)[layers objectAtIndex:i]).layerOrder.intValue - 1];
            }
        }
        else {
            for (int i = newRank;i<index;i++) {
                ((Layer *)[layers objectAtIndex:i]).layerOrder = [NSNumber numberWithInt:((Layer *)[layers objectAtIndex:i]).layerOrder.intValue + 1];
            }
        }
        
        layer.layerOrder = numberNewRank;
        
        [layers removeObject:layer];
        [layers insertObject:layer atIndex:newRank];
    }
}

-(NSString *)booksArchivePath {
    NSArray *documentDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [documentDirectories objectAtIndex:0];
    return [documentDirectory stringByAppendingPathComponent:@"Scrapbooking.sqlite"];
}

-(BOOL)saveChanges {
    NSError *error = nil;
    if (![context save:&error])
    {
        NSLog(@"Error saving: %@", error.localizedDescription);
    }
    
    return YES;
}

@end
