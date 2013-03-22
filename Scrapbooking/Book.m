//
//  Book.m
//  Scrapbooking
//
//  Created by Valérian Roche on 20/03/13.
//  Copyright (c) 2013 Valérian Roche. All rights reserved.
//

#import "Book.h"
#import "Layer.h"
#import "Utilisateur.h"

@interface Book() {
    NSArray *layersInOrder;
    NSArray *couleurs;
    NSArray *nomCouleurs;
}

@end

@implementation Book

@dynamic dateCreation;
@dynamic dateModif;
@dynamic descrip;
@dynamic id;
@dynamic name;
@dynamic createur;
@dynamic editeur;
@dynamic layers;
@dynamic alpha;
@dynamic couleur;
@dynamic couleurAsString;

-(void)awakeFromFetch {
    [super awakeFromFetch];
    if ([self couleurAsString]) {
        int index = [[self nomCouleurs] indexOfObject:[self couleurAsString]];
        
        [self setPrimitiveValue:[[self couleurs] objectAtIndex:index] forKey:@"couleur"];
    }
}

-(NSArray *)couleurs {
    if (!couleurs)
        couleurs = [NSArray arrayWithObjects:[UIColor whiteColor],[UIColor yellowColor], [UIColor greenColor], [UIColor orangeColor], [UIColor redColor], [UIColor purpleColor], [UIColor blueColor], [UIColor brownColor], [UIColor grayColor], [UIColor blackColor], nil];
    return couleurs;
}

-(NSArray *)nomCouleurs {
    if (!nomCouleurs)
        nomCouleurs = [NSArray arrayWithObjects:@"White", @"Yellow", @"Green", @"Orange", @"Red", @"Purple", @"Blue", @"Brown", @"Gray", @"Black", nil];
    return nomCouleurs;
}

-(NSArray *)layersInOrder {
    layersInOrder = [self.layers sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"layerOrder" ascending:YES]]];
    return layersInOrder;
}

-(void)willSave {
    if (self.couleur) {
        int index = [[self couleurs] indexOfObject:[self couleur]];
        
        [self setPrimitiveValue:[[self nomCouleurs] objectAtIndex:index] forKey:@"couleurAsString"];
    }
    if (!self.dateModif || [[NSDate date] timeIntervalSinceDate:self.dateModif] > 100) {
        self.dateModif = [NSDate date];
    }
}

@end
