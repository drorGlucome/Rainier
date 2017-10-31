//
//  TreatmentDiary.m
//  GlucoMe - Mobile
//
//  Created by dovi winberger on 21/06/2016.
//  Copyright © 2016 Yiftah Ben Aharon. All rights reserved.
//

#import "TreatmentDiary.h"
#import "Treatment_helper.h"
#import "NSDate+Utilities.h"
#import "general.h"
#import "SingleMeasurementViewController.h"
NSString * const LastUpdateToTreatmentDiary  = @"LastUpdateToTreatmentDiary";

@implementation TreatmentDiary

+(void)RegisterForMeasurementsChanges
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        [[NSNotificationCenter defaultCenter] addObserver: [self class]
                                                 selector: @selector(UpdateDiaryElementIfNeeded:)
                                                     name: @"MeasurementSentToServer"
                                                   object: nil];
    });
}
+(void)UpdateDiaryElementIfNeeded:(NSNotification*)note
{
    //update sample id to the server sample id
    Measurement* m = [note.userInfo objectForKey:@"measurement"];
    if(m != nil)
    {
        NSPredicate* p = [NSPredicate predicateWithFormat:@"sampleId = %@", m.id];
        TreatmentDiary* t = [TreatmentDiary MR_findFirstWithPredicate:p inContext:[NSManagedObjectContext MR_defaultContext]];
        if(t != nil)
        {
            t.sampleId = m.record_id;
            [t SendToServer];
        }
    }
}

-(void)Done:(NSNumber*)sampleId;
{
    self.sampleId = sampleId;
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"TreatmentDiaryChanged" object:nil];
    [self SendToServer];
}
-(void)Undone
{
    /*self.executionDate = nil;
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"TreatmentDiaryChanged" object:nil];
    [self SendToServer];
     */
}

-(BOOL)isDone
{
    return self.sampleId != nil && [self.sampleId intValue] != 0;
}

+(TreatmentDiary*)NextTreatment
{
    NSPredicate* p = [NSPredicate predicateWithFormat:@"dueDate > %@ && (sampleId = nil || sampleId = 0)", [NSDate date]];
    TreatmentDiary* t = [TreatmentDiary MR_findFirstWithPredicate:p sortedBy:@"dueDate" ascending:YES inContext:[NSManagedObjectContext MR_defaultContext]];
    
    return t;
}

+(BOOL)IsTreatmentAvailable
{
    return [TreatmentDiary MR_countOfEntities] > 0;
}

+(void)AddEntry:(NSString*)name date:(NSDate*)dueDate isDueDateEstimated:(BOOL)isDueDateEstimated dosage:(NSNumber*)dosage treatmentTypeId:(NSNumber*)treatmentTypeId isBulkDataEntry:(BOOL)isBulkDataEntry
{
    if([[NSDate date] isLaterThanDate:dueDate]) return;
    if(![TreatmentDiary IsUnique:treatmentTypeId :dueDate]) return;
        
    TreatmentDiary* t = [TreatmentDiary MR_createEntityInContext:[NSManagedObjectContext MR_defaultContext]];
    t.name = name;
    t.dueDate = dueDate;
    t.isDueDateEstimated = @(isDueDateEstimated);
    t.treatmentTypeId = treatmentTypeId;
    t.dosage = dosage;

    UILocalNotification *notification = [[UILocalNotification alloc] init];
    notification.repeatInterval = 0;
    [notification setAlertBody:[NSString stringWithFormat:@"A reminder to: %@", t.name]];
    if(isDueDateEstimated == YES)
        [notification setCategory:NotificationTreatmentDiaryEntry];
    else
        [notification setCategory:NotificationMeasureReminderAfter2Hours]; //for now...
    [notification setFireDate:t.dueDate];
    [notification setTimeZone:[NSTimeZone  defaultTimeZone]];
    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
    
    if(isBulkDataEntry == NO)
    {
        [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreWithCompletion:^(BOOL contextDidSave, NSError *error) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"TreatmentDiaryChanged" object:nil];
        }];
    }
}

+(void)UpdateTreatmentDiary
{
    //updating treatment from now on
    NSPredicate* p = [NSPredicate predicateWithFormat:@"isDueDateEstimated = YES AND (sampleId = nil || sampleId = 0) AND dueDate > %@", [NSDate date]];
    [TreatmentDiary MR_deleteAllMatchingPredicate:p inContext:[NSManagedObjectContext MR_defaultContext]];
    
    //deleting local notifications
    UIApplication *app = [UIApplication sharedApplication];
    NSArray *eventArray = [app scheduledLocalNotifications];
    for (int i = 0; i < [eventArray count]; i++)
    {
        UILocalNotification* oneEvent = [eventArray objectAtIndex:i];
        NSString *category = oneEvent.category;
        if ([category isEqualToString:NotificationTreatmentDiaryEntry])
        {
            //Cancelling local notification
            [app cancelLocalNotification:oneEvent];
            break;
        }
    }
    
    //diary from injections treatments
    NSArray* lastTreatment = [Treatment LastTreatmentsGroup];
    for (int i = 0; i < 7; i++)
    {
        for (int j = 0; j < lastTreatment.count; j++)
        {
            Treatment* treatment = lastTreatment[j];
            NSDate* date = [[[[NSDate date] dateAtStartOfDay] dateByAddingDays:i] dateByAddingHours:[treatment daypartToApproximateHour]];
            NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitWeekday fromDate:date];

            BOOL addEntry = NO;
            if(([treatment.recurrenceSunday boolValue] && [components weekday] == 0) ||
               ([treatment.recurrenceMonday boolValue] && [components weekday] == 1) ||
               ([treatment.recurrenceTuesday boolValue] && [components weekday] == 2) ||
               ([treatment.recurrenceWednesday boolValue] && [components weekday] == 3) ||
               ([treatment.recurrenceThursday boolValue] && [components weekday] == 4) ||
               ([treatment.recurrenceFriday boolValue] && [components weekday] == 5) ||
               ([treatment.recurrenceSaturday boolValue] && [components weekday] == 6))
            {
                addEntry = YES;
            }
            if(addEntry)
            {
                [TreatmentDiary AddEntry:treatment.treatmentTypeName
                                date:date
                  isDueDateEstimated:YES
                              dosage:treatment.dosage
                     treatmentTypeId:treatment.treatmentTypeId
                     isBulkDataEntry:YES];
            }
        }
    }
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreWithCompletion:^(BOOL contextDidSave, NSError *error)
     {
         [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:LastUpdateToTreatmentDiary];
         [[NSNotificationCenter defaultCenter] postNotificationName:@"TreatmentDiaryChanged" object:nil];
     }];
    
}
+(BOOL)IsUnique:(NSNumber*)treatmentTypeId :(NSDate*)dueDate
{
    NSPredicate* p = [NSPredicate predicateWithFormat:@"dueDate = %@ AND treatmentTypeId = %@", dueDate, treatmentTypeId];
    NSArray* tmp = [TreatmentDiary MR_findAllWithPredicate:p];
    
    return tmp.count == 0;
}



+(void)MergeTreatmentDiaryWithServer:(NSDictionary*)dic
{
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^
                   {
                       NSManagedObjectContext *myNewContext = [NSManagedObjectContext MR_context];
                       
                       //getting all measurements from server:
                       //NSPredicate* p = [NSPredicate predicateWithFormat:@"didUploadToServer = true"];
                       //[TreatmentDiary MR_deleteAllMatchingPredicate:p inContext:myNewContext];
                       
                       NSArray* log = [dic objectForKey:@"treatment_diary"];
                       for(NSDictionary* mDic in log)
                       {
                           NSNumber* recordId = [NSNumber numberWithFloat:[[mDic objectForKey:@"id"] floatValue]];
                           
                           NSNumber* dosage = NULL;
                           if([[mDic allKeys] containsObject:@"dosage"] && [mDic objectForKey:@"dosage"] != [NSNull null])
                                dosage = [NSNumber numberWithFloat:[[mDic objectForKey:@"dosage"] floatValue]];
                           NSNumber* treatment_type_id = [NSNumber numberWithInt:0];
                           if([[mDic allKeys] containsObject:@"treatment_type_id"] && [mDic objectForKey:@"treatment_type_id"] != [NSNull null])
                               treatment_type_id = [NSNumber numberWithInt: [(NSString*)[mDic objectForKey:@"treatment_type_id"] intValue]];
                           NSString* name = [mDic objectForKey:@"name"];
                           
                           //NSString* treatment_type = nil;
                           //if([[mDic allKeys] containsObject:@"treatment_type"] && [mDic objectForKey:@"treatment_type"] != [NSNull null])
                           //    treatment_type = [mDic objectForKey:@"treatment_type"];
                           
                           NSDate* dueDate = rails2iosNSDate([mDic objectForKey:@"due_date"]);
                           NSNumber* is_due_date_estimated = [mDic objectForKey:@"is_due_date_estimated"];
                           NSNumber* sampleId = nil;
                           if([[mDic allKeys] containsObject:@"sample_id"] && [mDic objectForKey:@"sample_id"] != [NSNull null])
                               sampleId = [NSNumber numberWithFloat:[[mDic objectForKey:@"sample_id"] floatValue]];
                           
                           
                           TreatmentDiary* t = [TreatmentDiary GetTreatmenDiaryByServerRecordId:recordId inContext:myNewContext];
                           if(t == nil)
                           {
                               t = [TreatmentDiary MR_createEntityInContext:myNewContext];
                               
                               t.recordId = recordId;
                               t.dosage = dosage;
                               t.name = name;
                               t.treatmentTypeId = treatment_type_id;
                               t.dueDate = dueDate;
                               t.sampleId = sampleId;
                               t.isDueDateEstimated = is_due_date_estimated;
                               
                               t.didUploadToServer = @(YES); //came from the server..
                               
                               [myNewContext MR_saveToPersistentStoreWithCompletion:nil];
                           }
                           else
                           {
                               if([t.didUploadToServer boolValue] == YES)
                               {
                                   t.dosage = dosage;
                                   t.name = name;
                                   t.treatmentTypeId = treatment_type_id;
                                   t.dueDate = dueDate;
                                   t.sampleId = sampleId;
                                   t.isDueDateEstimated = is_due_date_estimated;
                                   [myNewContext MR_saveToPersistentStoreWithCompletion:nil];
                                   
                               }
                           }
                       }
                   });
    
    //uploading measurements that are local
    NSPredicate* p = [NSPredicate predicateWithFormat:@"dueDate <= %@ AND (didUploadToServer = false OR didUploadToServer = nil)", [NSDate date]];
    NSArray* localTreatmentDiaryEntries = [TreatmentDiary MR_findAllWithPredicate:p inContext:[NSManagedObjectContext MR_defaultContext]];
    
    for(TreatmentDiary* t in localTreatmentDiaryEntries)
    {
        if(t.recordId == nil || [t.recordId integerValue] == 0)
        {
            [t SendToServer];
        }
        else
        {
            [t UpdateInServer];
        }
    }
    
    
    
}
+(TreatmentDiary*)GetTreatmenDiaryByServerRecordId:(NSNumber*) recordId inContext:(NSManagedObjectContext*)context
{
    return [TreatmentDiary MR_findFirstByAttribute:@"recordId" withValue:recordId inContext:context];
}

-(void)SendToServer
{
    if(self.recordId == nil || [self.recordId integerValue] == 0)
    {
        [[DataHandler_new getInstance] sendTreatmentDiaryEntryToServer:self withCompletionBlock:^(NSDictionary *dic) {
            self.didUploadToServer = @(YES);
            self.recordId = [dic objectForKey:@"id"];
            [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreWithCompletion:nil];
        }];
    }
    else
    {
        [self UpdateInServer];
    }
}

-(void)UpdateInServer
{
    self.didUploadToServer = @(NO);
    
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreWithCompletion:^(BOOL contextDidSave, NSError *error)
     {
         if(self.recordId == nil || [self.recordId intValue] == 0) return;
         [[DataHandler_new getInstance] UpdateTreatmentDiaryEntryInServer:self withCompletionBlock:^(NSDictionary *dic) {
             if(dic == nil)
             {
                 //deleted from server because it is in the future
                 self.didUploadToServer = @(NO);
                 self.recordId = @(0);
             }
             else
             {
                 self.didUploadToServer = @(YES);
             }
             [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreWithCompletion:nil];
         }];
     }];
}

+(NSArray*)FindTreatmentDiaryElementNearDate:(NSDate*)date type:(MeasurementType)type
{
    if(type == medicineMeasurementType)
    {
        NSPredicate* p = [NSPredicate predicateWithFormat:@"dueDate > %@ AND dueDate < %@ AND treatmentTypeId > 0 AND (sampleId = nil || sampleId = 0)",[date dateBySubtractingHours:2], [date dateByAddingHours:2]];
        return [TreatmentDiary MR_findAllWithPredicate:p inContext:[NSManagedObjectContext MR_defaultContext]];
    }
    else if(type == glucoseMeasurementType)
    {
        NSPredicate* p = [NSPredicate predicateWithFormat:@"dueDate > %@ AND dueDate < %@ AND treatmentTypeId = 0 AND (sampleId = nil || sampleId = 0)",[date dateBySubtractingHours:2], [date dateByAddingHours:2]];
        return [TreatmentDiary MR_findAllWithPredicate:p inContext:[NSManagedObjectContext MR_defaultContext]];
    }
    return nil;
}

-(NSString*)SuggestedTagId
{
    if([self MeasurementType] == medicineMeasurementType)
        return [self SuggestedMedicineTagId];
    
    return @"";
}
-(NSString*)SuggestedMedicineTagId
{
    int treatmentTypeId = [self.treatmentTypeId intValue];
    if(treatmentTypeId >= 2500 && treatmentTypeId < 3000)
    {
        return [NSString stringWithFormat:@"%d",BASAL_TAG_ID];
    }
    if(treatmentTypeId >= 2000 && treatmentTypeId < 2500) //bolus
    {
        NSString* daypart = HourAsComponentOfDay((int)self.dueDate.hour);
        if([daypart isEqualToString:@"morning"])
        {
            return [NSString stringWithFormat:@"%d",BOLUS_MORNING_TAG_ID];
        }
        else if([daypart isEqualToString:@"noon"])
        {
            return [NSString stringWithFormat:@"%d",BOLUS_NOON_TAG_ID];
        }
        else if([daypart isEqualToString:@"evening"])
        {
            return [NSString stringWithFormat:@"%d",BOLUS_EVENING_TAG_ID];
        }
    }
    
    return @"";
}
-(MeasurementType)MeasurementType
{
    if([self.treatmentTypeId intValue] == 0)
        return glucoseMeasurementType;
    return medicineMeasurementType;
}
@end
