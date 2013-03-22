//
//  Book.h
//  Scrapbooking
//
//  Created by Valérian Roche on 20/03/13.
//  Copyright (c) 2013 Valérian Roche. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Layer, Utilisateur;

@interface Book : NSManagedObject

@property (nonatomic, retain) NSDate * dateCreation;
@property (nonatomic, retain) NSDate * dateModif;
@property (nonatomic, retain) NSString * descrip;
@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSNumber * alpha;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) UIColor * couleur;
@property (nonatomic, retain) NSString * couleurAsString;
@property (nonatomic, retain) Utilisateur *createur;
@property (nonatomic, retain) Utilisateur *editeur;
@property (nonatomic, retain) NSSet *layers;
@end

@interface Book (CoreDataGeneratedAccessors)

- (void)addLayersObject:(Layer *)value;
- (void)removeLayersObject:(Layer *)value;
- (void)addLayers:(NSSet *)values;
- (void)removeLayers:(NSSet *)values;

- (NSArray *)layersInOrder;

@end
