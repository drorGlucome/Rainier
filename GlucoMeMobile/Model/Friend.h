//
//  Friend.h
//  GlucoMe - Mobile
//
//  Created by dovi winberger on 7/27/15.
//  Copyright (c) 2015 Yiftah Ben Aharon. All rights reserved.
//
//this class is the local DB friends table

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Friend : NSManagedObject

@property (nonatomic, retain) NSNumber * didUploadToServer;
@property (nonatomic, retain) NSNumber * recordId;
@property (nonatomic, retain) NSNumber * isFiltered;
@property (nonatomic, retain) NSString * firstName;
@property (nonatomic, retain) NSNumber * friendId;
@property (nonatomic, retain) NSString * lastName;
@property (nonatomic, retain) NSNumber * score;
@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSNumber * didFriendAddedMe;

@end
