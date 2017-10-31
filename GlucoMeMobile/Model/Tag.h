//
//  Tag.h
//  GlucoMe - Mobile
//
//  Created by dovi winberger on 5/19/15.
//  Copyright (c) 2015 Yiftah Ben Aharon. All rights reserved.
//
//this class is the local DB tags table

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Tag : NSManagedObject

@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * icon;
@property (nonatomic, retain) NSNumber * deletable;
@property (nonatomic, retain) NSNumber * didUploadToServer;

@end
