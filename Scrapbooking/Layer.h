//
//  Layer.h
//  Scrapbooking
//
//  Created by Valérian Roche on 19/03/13.
//  Copyright (c) 2013 Valérian Roche. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Book;


@interface Layer : NSManagedObject

@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * rectAsString;
@property (nonatomic, assign) CGRect rect;
@property (nonatomic, retain) NSNumber * rotationRad;
@property (nonatomic, retain) NSNumber * layerOrder;
@property (nonatomic, retain) NSData * imageData;
@property (nonatomic, retain) NSAttributedString * text;
@property (nonatomic, retain) NSData *textAsData;
@property (nonatomic, retain) NSString * classe;
@property (nonatomic, strong) UIImage * image;
@property (nonatomic, retain) NSNumber * alpha;
@property (nonatomic, retain) Book *book;


@end
