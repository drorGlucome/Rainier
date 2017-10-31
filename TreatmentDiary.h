//
//  TreatmentDiary.h
//  GlucoMe - Mobile
//
//  Created by dovi winberger on 21/06/2016.
//  Copyright © 2016 Yiftah Ben Aharon. All rights reserved.
//
//this class is the local DB treatment diary table

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface TreatmentDiary : NSManagedObject

// Insert code here to declare functionality of your managed object subclass
+(void)RegisterForMeasurementsChanges;

-(BOOL)isDone;
-(void)Done:(NSNumber*)sampleId;
-(void)Undone;

+(BOOL)IsTreatmentAvailable;
+(void)UpdateTreatmentDiary;
+(void)AddEntry:(NSString*)name date:(NSDate*)dueDate isDueDateEstimated:(BOOL)isDueDateEstimated dosage:(NSNumber*)dosage treatmentTypeId:(NSNumber*)treatmentTypeId isBulkDataEntry:(BOOL)isBulkDataEntry;
+(TreatmentDiary*)NextTreatment;
+(BOOL)IsUnique:(NSNumber*)treatmentTypeId :(NSDate*)dueDate;

+(void)MergeTreatmentDiaryWithServer:(NSDictionary*)dic;

+(NSArray*)FindTreatmentDiaryElementNearDate:(NSDate*)date type:(MeasurementType)type;

-(NSString*)SuggestedTagId;
-(MeasurementType)MeasurementType;
@end


#import "TreatmentDiary+CoreDataProperties.h"
