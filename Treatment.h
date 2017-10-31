//
//  Treatment.h
//  GlucoMe - Mobile
//
//  Created by dovi winberger on 24/01/2016.
//  Copyright © 2016 Yiftah Ben Aharon. All rights reserved.
//
//this class is the local DB treatment table

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Treatment : NSManagedObject

@property (nonatomic, retain) NSString *reason;
@property (nonatomic, retain) NSString *summary;
@property (nonatomic, retain) NSString *comment;
@property (nonatomic, retain) NSNumber *dosage;
@property (nonatomic, retain) NSDate   *dateGiven;
@property (nonatomic, retain) NSString *daypart;
@property (nonatomic, retain) NSNumber *doctorId;
@property (nonatomic, retain) NSNumber *treatmentTypeId;
@property (nonatomic, retain) NSString *treatmentTypeName;
@property (nonatomic, retain) NSNumber *priority;
@property (nonatomic, retain) NSNumber *recurrenceSunday;
@property (nonatomic, retain) NSNumber *recurrenceMonday;
@property (nonatomic, retain) NSNumber *recurrenceTuesday;
@property (nonatomic, retain) NSNumber *recurrenceWednesday;
@property (nonatomic, retain) NSNumber *recurrenceThursday;
@property (nonatomic, retain) NSNumber *recurrenceFriday;
@property (nonatomic, retain) NSNumber *recurrenceSaturday;

@end


