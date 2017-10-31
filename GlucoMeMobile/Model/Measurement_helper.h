//
//  MeasurementHelper.h
//  GlucoMe - Mobile
//
//  Created by dovi winberger on 5/19/15.
//  Copyright (c) 2015 Yiftah Ben Aharon. All rights reserved.
//
//this class is the local DB measurements table
#import <Foundation/Foundation.h>
#import "Measurement.h"


@interface Measurement (helper) 

+(void)SaveMeasurementAndSendToServer:(long)value type:(int)type date:(NSDate*)date tags:(NSString*)tags comments:(NSString*)comments source:(NSString*)source completionBlock:(void (^)(Measurement*))completionBlock;
+(void)SaveMeasurementAndSendToServer:(long)value type:(int)type source:(NSString*)source completionBlock:(void (^)(Measurement*))completionBlock;
-(void)UpdateMeasurementAndSaveToServerWithTags:(NSString*)tags andComment:(NSString*)comment value:(long)value date:(NSDate*)date;
+(void)MergeMeasurmentsWithServer:(NSDictionary*)dic forPatient_id:(NSNumber*)patient_id;

+(NSArray*)GetAllMeasurementsForPatient_id:(NSNumber*)patient_id;
+(NSArray*)GetAllMeasurementsFromDate:(NSDate*)date forPatient_id:(NSNumber*)patient_id;
+(NSArray*)GetAllMeasurementsFromDate:(NSDate*)date andTags:(NSArray*)tags measurementType:(MeasurementType)type forPatient_id:(NSNumber*)patient_id;
+(double)GetHbA1cFromDate:(NSDate*)date andTags:(NSArray*)tags forPatient_id:(NSNumber*)patient_id;
//+(NSArray*)GetAllUsedTagsAfterDate:(NSDate*)date forPatient_id:(NSNumber*)patient_id;

-(NSString*)GetTagsAsString;
-(int)GetFirstTagID;
@end
