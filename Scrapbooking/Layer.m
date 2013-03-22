//
//  Layer.m
//  Scrapbooking
//
//  Created by Valérian Roche on 19/03/13.
//  Copyright (c) 2013 Valérian Roche. All rights reserved.
//

#import "Layer.h"
#import "Book.h"

@implementation Layer

@dynamic id;
@dynamic name;
@dynamic rectAsString;
@dynamic rotationRad;
@dynamic layerOrder;
@dynamic image;
@dynamic imageData;
@dynamic text;
@dynamic textAsData;
@dynamic classe;
@dynamic alpha;
@dynamic book;

-(void)awakeFromInsert {
    [super awakeFromInsert];
}

-(void)setRect:(CGRect)rect {
    [self setPrimitiveValue:NSStringFromCGRect(rect) forKey:@"rectAsString"];
}

-(CGRect)rect {
    return CGRectFromString(self.rectAsString);
}

-(void)awakeFromFetch {
    [super awakeFromFetch];
    if (self.imageData) {
        UIImage * image = [UIImage imageWithData:self.imageData];
        [self setPrimitiveValue:image forKey:@"image"];
    }
    if (self.textAsData) {
        self.text = [NSKeyedUnarchiver unarchiveObjectWithData:self.textAsData];
    }
    if (self.rectAsString)
        self.rect = CGRectFromString(self.rectAsString);
}

-(void)willSave {
    if (self.image) {
        NSData *data = UIImagePNGRepresentation(self.image);
        [self setPrimitiveValue:data forKey:@"imageData"];
    }
    else {
        [self setPrimitiveValue:nil forKey:@"imageData"];
    }
    if (self.text) {
        [self setPrimitiveValue:[NSKeyedArchiver archivedDataWithRootObject:self.text] forKey:@"textAsData"];
    }
}

@end
