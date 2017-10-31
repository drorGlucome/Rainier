//
//  MeasurementHelper.m
//  GlucoMe - Mobile
//
//  Created by dovi winberger on 5/19/15.
//  Copyright (c) 2015 Yiftah Ben Aharon. All rights reserved.
//

#import "Measurement_helper.h"
#import "Tag.h"
#import "DataHandler_new.h"
#import "general.h"
@implementation Measurement(helper)

+(void)SaveMeasurementAndSendToServer:(long)value type:(int)type date:(NSDate*)date tags:(NSString*)tags comments:(NSString*)comments source:(NSString*)source completionBlock:(void (^)(Measurement*))completionBlock
{
    Measurement* m = [Measurement MR_createEntityInContext:[NSManagedObjectContext MR_defaultContext]];
    m.patient_id = [[DataHandler_new getInstance] getPatientIdAsNumber];
    m.value = @(value);
    m.date = date;
    m.tags = tags;
    m.comment = comments;
    m.didUploadToServer = @(NO);
    m.type = @(type);
    m.source = source;
    m.record_id = nil;
    m.uuid = [[NSUUID UUID] UUIDString];
    
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreWithCompletion:^(BOOL contextDidSave, NSError *error)
     {
         m.id = @(arc4random_uniform(10000000));
         if(completionBlock) completionBlock(m);
         
         [m SendToServer];
         
         if(contextDidSave == NO)
         {
             NSLog(@"WHHYYY");
         }
     }];
    
}
//convenience function
+(void)SaveMeasurementAndSendToServer:(long)value type:(int)type source:(NSString*)source completionBlock:(void (^)(Measurement*))completionBlock
{
    [Measurement SaveMeasurementAndSendToServer:value type:type date:[[NSDate alloc] init] tags:@"" comments:@"" source:source completionBlock:completionBlock];
}

-(void)SendToServer
{
    if(self.uuid == nil) //measurement from old apps, to be removed in the future
    {
        self.uuid = [[NSUUID alloc] init].UUIDString;
        [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreWithCompletion:nil];
    }
    [[DataHandler_new getInstance] sendMeasurementToServer:self withCompletionBlock:^(NSDictionary *dic) {
        self.didUploadToServer = @(YES);
        self.record_id = [dic objectForKey:@"id"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"MeasurementSentToServer" object:nil userInfo:@{@"measurement": self}];
        [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreWithCompletion:nil];
        
        [[DataHandler_new getInstance] RefreshFact];
    }];
}

-(void)UpdateMeasurementAndSaveToServerWithTags:(NSString*)tags andComment:(NSString*)comment value:(long)value date:(NSDate*)date
{
    self.tags = tags;
    self.comment = comment;
    self.value = @(value);
    self.date = date;
    self.didUploadToServer = @(NO);
    
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreWithCompletion:^(BOOL contextDidSave, NSError *error)
    {
        if(self.record_id == nil || [self.record_id integerValue] == 0) return;
        [[DataHandler_new getInstance] UpdateMeasurementInServer:self withCompletionBlock:^(NSDictionary *dic) {
            self.didUploadToServer = @(YES);
            [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreWithCompletion:nil];
        }];
    }];
}

+(void)MergeMeasurmentsWithServer:(NSDictionary*)dic forPatient_id:(NSNumber*)patient_id
{
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^
    {
        NSManagedObjectContext *myNewContext = [NSManagedObjectContext MR_context];
        
        //getting all measurements from server:
        //NSPredicate* p = [NSPredicate predicateWithFormat:@"patient_id = %@ AND didUploadToServer = true", patient_id];
        //[Measurement MR_deleteAllMatchingPredicate:p inContext:myNewContext];
        
        
        NSArray* log = [dic objectForKey:@"log"];
        for(NSDictionary* mDic in log)
        {
            NSNumber* recordId = [mDic objectForKey:@"id"];
            NSNumber* value = [NSNumber numberWithInt: [(NSString*)[mDic objectForKey:@"value"] intValue]];
            NSNumber* type = [NSNumber numberWithInt:0];
            if([[mDic allKeys] containsObject:@"measurement_type"] && [mDic objectForKey:@"measurement_type"] != [NSNull null])
                type = [NSNumber numberWithInt: [(NSString*)[mDic objectForKey:@"measurement_type"] intValue]];
            
            NSDate* date = rails2iosNSDate([mDic objectForKey:@"date"]);
            NSString* tags = @"";
            if([mDic objectForKey:@"tags"] && [mDic objectForKey:@"tags"] != [NSNull null])
                tags = [mDic objectForKey:@"tags"];
            
            NSString* comment = @"";
            if([mDic objectForKey:@"comment"] && [mDic objectForKey:@"comment"] != [NSNull null])
                comment = [mDic objectForKey:@"comment"];
            
            NSString* source = @"";
            if([mDic objectForKey:@"source"] && [mDic objectForKey:@"source"] != [NSNull null])
                source = [mDic objectForKey:@"source"];
            
            NSString* uuid = @"";
            if([mDic objectForKey:@"uuid"] && [mDic objectForKey:@"uuid"] != [NSNull null])
                uuid = [mDic objectForKey:@"uuid"];
            
            Measurement* measurement = [Measurement GetMeasurementByUUID:uuid inContext:myNewContext];
            if(measurement == nil)
            {
                measurement = [Measurement GetMeasurementByValue:value andDate:date inContext:myNewContext];
                if(measurement != nil)
                {
                    measurement.uuid = uuid;
                    [myNewContext MR_saveToPersistentStoreWithCompletion:nil];
                }
            }
            
            if(measurement == nil)
            {
                Measurement* m = [Measurement MR_createEntityInContext:myNewContext];
                
                m.patient_id = patient_id;
                m.record_id = recordId;
                m.value = value;
                m.type = type;
                m.date = date;
                m.tags = tags;
                m.comment = comment;
                m.source = source;
                m.uuid = uuid;
                
                m.didUploadToServer = @(YES); //came from the server..
                
                [myNewContext MR_saveToPersistentStoreWithCompletion:nil];
            }
            else
            {
                if([measurement.didUploadToServer boolValue] == YES)
                {
                    measurement.value = value;
                    measurement.type = type;
                    measurement.date = date;
                    measurement.tags = tags;
                    measurement.comment = comment;
                    measurement.source = source;
                    measurement.uuid = uuid;
                    [myNewContext MR_saveToPersistentStoreWithCompletion:nil];
                }
            }
        }
    });
    
    //uploading measurements that are local
    NSPredicate* p = [NSPredicate predicateWithFormat:@"didUploadToServer = false OR didUploadToServer = nil"];
    NSArray* localMeasurements = [Measurement MR_findAllWithPredicate:p inContext:[NSManagedObjectContext MR_defaultContext]];
    
    for(Measurement* m in localMeasurements)
    {
        if(m.record_id == nil || m.record_id == 0)
        {
            [m SendToServer];
        }
        else
        {
            [m UpdateMeasurementAndSaveToServerWithTags:m.tags andComment:m.comment value:[m.value longValue] date:m.date];
        }
    }
    
    
    
}
+(Measurement*)GetMeasurementByValue:(NSNumber*)value andDate:(NSDate*)date inContext:(NSManagedObjectContext*)context
{
    NSPredicate* p = [NSPredicate predicateWithFormat:@"value = %@ && date = %@", value, date];
    return [Measurement MR_findFirstWithPredicate:p inContext:context];
}
+(Measurement*)GetMeasurementByUUID:(NSString*)uuid inContext:(NSManagedObjectContext*)context
{
    return [Measurement MR_findFirstByAttribute:@"uuid" withValue:uuid inContext:context];
}
+(Measurement*)GetMeasurementByServerRecordId:(NSNumber*) recordId inContext:(NSManagedObjectContext*)context
{
    return [Measurement MR_findFirstByAttribute:@"record_id" withValue:recordId inContext:context];
}
+(NSArray*)GetAllMeasurementsForPatient_id:(NSNumber*)patient_id
{
    NSPredicate* p = [NSPredicate predicateWithFormat:@"patient_id = %@",patient_id];
    return [Measurement MR_findAllSortedBy:@"date" ascending:false withPredicate:p inContext:[NSManagedObjectContext MR_defaultContext]];
}
+(NSArray*)GetAllMeasurementsFromDate:(NSDate*)date forPatient_id:(NSNumber*)patient_id
{
    NSPredicate* p = [NSPredicate predicateWithFormat:@"patient_id = %@ AND date >= %@",patient_id, date];
    return [Measurement MR_findAllSortedBy:@"date" ascending:false withPredicate:p inContext:[NSManagedObjectContext MR_defaultContext]];
}
+(NSArray*)GetAllMeasurementsFromDate:(NSDate*)date measurementType:(MeasurementType)type forPatient_id:(NSNumber*)patient_id
{
    NSPredicate* p = [NSPredicate predicateWithFormat:@"patient_id = %@ AND type = %@ AND date >= %@",patient_id, @(type), date];
    return [Measurement MR_findAllSortedBy:@"date" ascending:false withPredicate:p inContext:[NSManagedObjectContext MR_defaultContext]];
}

+(NSArray*)GetAllMeasurementsFromDate:(NSDate*)date andTags:(NSArray*)tags measurementType:(MeasurementType)type forPatient_id:(NSNumber*)patient_id
{
    if(tags == nil) return [Measurement GetAllMeasurementsFromDate:date measurementType:type forPatient_id:patient_id];
    
    NSString* predicateString = @"patient_id = %@ AND type = %@ AND date >= %@ ";
    
    NSMutableArray* tagsConditions = [[NSMutableArray alloc] init];
    for(NSString* tag in tags)
    {
        if([tag isEqualToString:@"1000"])
            [tagsConditions addObject:@" (tags = \"\" OR tags = nil) "];
        else
            [tagsConditions addObject:[NSString stringWithFormat:@" tags == '%@' ", tag]];
    }
    
    if(tags.count == 0)
        return [[NSArray alloc] init];
    else if(tags.count == 1)
        predicateString = [NSString stringWithFormat:@"%@ AND %@",predicateString, tagsConditions[0]];
    else
    {
        predicateString = [NSString stringWithFormat:@"%@ AND (%@ ",predicateString, tagsConditions[0]];
        for(NSString* tagCondition in tagsConditions)
        {
            predicateString = [NSString stringWithFormat:@"%@ OR %@",predicateString, tagCondition];
        }
        predicateString = [NSString stringWithFormat:@"%@ )",predicateString];

    }
    
    NSPredicate* p = [NSPredicate predicateWithFormat:predicateString, patient_id, @(type), date];
    
    return [Measurement MR_findAllSortedBy:@"date" ascending:false withPredicate:p inContext:[NSManagedObjectContext MR_defaultContext] ];
}


+(double)GetHbA1cFromDate:(NSDate*)date andTags:(NSArray*)tags forPatient_id:(NSNumber*)patient_id
{
    NSArray* allMeasurements;
    if(tags == NULL)
    {
        allMeasurements = [Measurement GetAllMeasurementsFromDate:date measurementType:glucoseMeasurementType forPatient_id:patient_id];
    }
    else
    {
        allMeasurements = [Measurement GetAllMeasurementsFromDate:date andTags:tags measurementType:glucoseMeasurementType forPatient_id:patient_id];
    }
    
    float HbA1c = 0;
    
    float averageGlucose = 0;
    if(allMeasurements.count > 0) {
        for (Measurement* m in allMeasurements)
        {
            averageGlucose += [m.value integerValue];
        }
        averageGlucose = averageGlucose / allMeasurements.count;
        
        HbA1c = (averageGlucose + 46.7f) / 28.7f;
    }
    
    if(allMeasurements.count == 0 ) return -1;
    return HbA1c;
    
}

/*+(NSArray*)GetAllUsedTagsAfterDate:(NSDate*)date forPatient_id:(NSNumber*)patient_id
{
    NSArray* allMeasurements = [Measurement GetAllMeasurementsFromDate:date forPatient_id:patient_id];
    
    NSString* tagsString = @"";
    for(Measurement* m in allMeasurements)
    {
        tagsString = [NSString stringWithFormat:@"%@%@%@",tagsString, TAGS_SEPARATOR, m.tags];
    }
    
    NSArray* allTags = [tagsString componentsSeparatedByString:TAGS_SEPARATOR];
    NSSet* allTagsSet = [NSSet  setWithArray:allTags];
    
    return [allTagsSet allObjects];
}*/

-(NSString*)GetTagsAsString
{
    NSString* res = @"";
    if(self.tags && (NSObject*)self.tags != [NSNull null])
    {
        NSArray* tempTagsArray = [self.tags componentsSeparatedByCharactersInSet:
                                  [NSCharacterSet characterSetWithCharactersInString:TAGS_SEPARATOR]
                                  ];
        
        NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
        for (NSString* tagString in tempTagsArray)
        {
            NSNumber* tagNumber = [f numberFromString:tagString];
            if(tagNumber == nil)
            {
                continue;
            }
            
            NSPredicate* p = [NSPredicate predicateWithFormat:@"id = %@", tagNumber];
            NSArray* tags = [Tag MR_findAllWithPredicate:p inContext:[NSManagedObjectContext MR_defaultContext]];
            if(tags.count == 0) continue;
            Tag* tag = tags[0];
            if([res isEqualToString:@""])
                res = [NSString stringWithFormat:@"%@",loc(tag.name)];
            else
                res = [NSString stringWithFormat:@"%@ %@",res,loc(tag.name)];
        }
    }
    return res;
}

-(int)GetFirstTagID
{
    NSArray* tempTagsArray = [self.tags componentsSeparatedByCharactersInSet:
                              [NSCharacterSet characterSetWithCharactersInString:TAGS_SEPARATOR]
                              ];
    
    NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
    if(tempTagsArray.count > 0)
        if(![tempTagsArray[0] isEqualToString:@""])
            return [[f numberFromString:tempTagsArray[0]] intValue];
    return -1;
}

@end
