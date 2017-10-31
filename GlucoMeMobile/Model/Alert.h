//
//  Alert.h
//  GlucoMe - Mobile
//
//  Created by dovi winberger on 5/19/15.
//  Copyright (c) 2015 Yiftah Ben Aharon. All rights reserved.
//
//this class is the local DB alerts/shares table
#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Alert : NSManagedObject

@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSNumber * when_alertTypeID;
@property (nonatomic, retain) NSNumber * how_mediaTypeID;
@property (nonatomic, retain) NSString * contactName;
@property (nonatomic, retain) NSString * contactDetails;
@property (nonatomic, retain) NSString * relationship;
@property (nonatomic, retain) NSString * params;
@property (nonatomic, retain) NSNumber * didUploadToServer;
@property (nonatomic, retain) NSNumber * is_deleted;

@end
