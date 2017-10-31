//
//  Measurement.h
//  
//
//  Created by dovi winberger on 6/3/15.
//
//
//this class is the local DB measurements table
#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Measurement : NSManagedObject

@property (nonatomic, retain) NSString * comment;
@property (nonatomic, retain) NSString * source;
@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSNumber * didUploadToServer;
@property (nonatomic, retain) NSString * tags;
@property (nonatomic, retain) NSNumber * value;
@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSNumber * patient_id;
@property (nonatomic, retain) NSNumber * record_id;
@property (nonatomic, retain) NSNumber * type;
@property (nonatomic, retain) NSString * uuid;

@end
