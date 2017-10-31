//
//  MediaType_helper.m
//  GlucoMe - Mobile
//
//  Created by dovi winberger on 5/20/15.
//  Copyright (c) 2015 Yiftah Ben Aharon. All rights reserved.
//

#import "Treatment_helper.h"
#import "general.h"
#import "TreatmentDiary.h"
@implementation Treatment(helper)

+(NSArray*)LastTreatmentsGroup
{
    return [self LastTreatmentsGroupBefore:nil];
}

+(NSArray*)LastTreatmentsGroupBefore:(NSDate*)date
{
    if([Treatment IsTreatmentAvailable] == NO) return nil;
    
    if(date == nil) date = [NSDate date];
    
    NSPredicate* datePredicate = [NSPredicate predicateWithFormat:@"dateGiven < %@", date];
    Treatment* t = [Treatment MR_findFirstWithPredicate:datePredicate sortedBy:@"dateGiven" ascending:NO inContext:[NSManagedObjectContext MR_defaultContext]];
    if(t == nil) return nil;
    
    NSPredicate* p = [NSPredicate predicateWithFormat:@"dateGiven = %@", t.dateGiven];
    NSArray* treatments = [Treatment MR_findAllSortedBy:@"priority" ascending:YES withPredicate:p inContext:[NSManagedObjectContext MR_defaultContext]];
    
    treatments = [treatments sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull _a, id  _Nonnull _b) {
        Treatment* a = _a;
        Treatment* b = _b;
        
//        if(a.priority < b.priority)
//            return NSOrderedAscending;
//        
//        if(a.priority > b.priority)
//            return NSOrderedDescending;
        
        //priority is equal
        if([a.daypart isEqualToString:@"morning"] && ([b.daypart isEqualToString:@"noon"] || [b.daypart isEqualToString:@"evening"] || [b.daypart isEqualToString:@"night"]) )
            return NSOrderedAscending;
        
        if([a.daypart isEqualToString:@"noon"]) {
            if ([b.daypart isEqualToString:@"evening"] || [b.daypart isEqualToString:@"night"])
                return NSOrderedAscending;
            
            if ([b.daypart isEqualToString:@"morning"])
                return NSOrderedDescending;
        }
        
        if([a.daypart isEqualToString:@"evening"])
        {
            if ([b.daypart isEqualToString:@"night"])
                return NSOrderedAscending;
            
            if ([b.daypart isEqualToString:@"morning"] || [b.daypart isEqualToString:@"noon"])
                return NSOrderedDescending;
            
        }
        
        if([a.daypart isEqualToString:@"night"])
        {
            if (![b.daypart isEqualToString:@"night"])
                return NSOrderedDescending;
            
        }
        
        return NSOrderedSame;
    }];
    
    return treatments;
}

+(BOOL)IsTreatmentAvailable
{
    return [Treatment MR_countOfEntities] > 0;
}

+(NSArray*)AllTreatmentsGrouped
{
    NSMutableArray* res = [[NSMutableArray alloc] init];
    
    NSArray* treatmentsGroup = [self LastTreatmentsGroupBefore:nil];
    while (treatmentsGroup != nil && treatmentsGroup.count > 0) {
        [res addObject:treatmentsGroup];
        treatmentsGroup = [self LastTreatmentsGroupBefore:((Treatment*)treatmentsGroup[0]).dateGiven];
    }
    return res;
}





+(void)AddNewTreatment:(NSArray*)treatments
{
    if(treatments == nil) return;
    if(treatments.count == 0) {
        [Treatment MR_truncateAllInContext:[NSManagedObjectContext MR_defaultContext]];
        [TreatmentDiary UpdateTreatmentDiary];
        return;
    }
        
    NSDate* dateGiven = rails2iosNSDate(treatments[0][@"date_submitted"]);

    NSPredicate* p = [NSPredicate predicateWithFormat:@"dateGiven = %@", dateGiven];
    NSArray* old = [Treatment MR_findAllSortedBy:@"treatmentTypeId" ascending:YES withPredicate:p inContext:[NSManagedObjectContext MR_defaultContext]];
    if(old != nil && old.count > 0)
    {
        [TreatmentDiary UpdateTreatmentDiary];
        return; //this was already submitted
    }
    
    for (int i = 0; i < treatments.count; i++) {
        
        Treatment* t = [Treatment MR_createEntityInContext:[NSManagedObjectContext MR_defaultContext]];
        
        NSNumber* doctorId = treatments[i][@"doctor_id"];
        
        if(treatments[i][@"reason"] != [NSNull null])
            t.reason = treatments[i][@"reason"];
        if(treatments[i][@"summary"] != [NSNull null])
            t.summary = treatments[i][@"summary"];
        if(treatments[i][@"comment"] != [NSNull null])
            t.comment = treatments[i][@"comment"];
        if(treatments[i][@"name"] != [NSNull null])
            t.treatmentTypeName = treatments[i][@"name"];
        if(treatments[i][@"dosage"] != [NSNull null])
            t.dosage = [NSNumber numberWithFloat:[(NSString*)treatments[i][@"dosage"] floatValue]];
        //if(treatments[i][@"approximate_hour123"] != [NSNull null])
        //    t.approximate_hour = [NSNumber numberWithFloat:[(NSString*)treatments[i][@"approximate_hour"] floatValue]];
        if(treatments[i][@"daypart"] != [NSNull null])
            t.daypart = treatments[i][@"daypart"];
        
        if(treatments[i][@"priority"] != [NSNull null])
            t.priority = [NSNumber numberWithInt: [(NSString*)treatments[i][@"priority"] intValue]];
        
        if(treatments[i][@"recurrence_sunday"] != [NSNull null])
            t.recurrenceSunday = [NSNumber numberWithBool:[(NSString*)treatments[i][@"recurrence_sunday"] boolValue]];
        if(treatments[i][@"recurrence_monday"] != [NSNull null])
            t.recurrenceMonday = [NSNumber numberWithBool:[(NSString*)treatments[i][@"recurrence_monday"] boolValue]];
        if(treatments[i][@"recurrence_tuesday"] != [NSNull null])
            t.recurrenceTuesday = [NSNumber numberWithBool:[(NSString*)treatments[i][@"recurrence_tuesday"] boolValue]];
        if(treatments[i][@"recurrence_wednesday"] != [NSNull null])
            t.recurrenceWednesday = [NSNumber numberWithBool:[(NSString*)treatments[i][@"recurrence_wednesday"] boolValue]];
        if(treatments[i][@"recurrence_thursday"] != [NSNull null])
            t.recurrenceThursday = [NSNumber numberWithBool:[(NSString*)treatments[i][@"recurrence_thursday"] boolValue]];
        if(treatments[i][@"recurrence_friday"] != [NSNull null])
            t.recurrenceFriday = [NSNumber numberWithBool:[(NSString*)treatments[i][@"recurrence_friday"] boolValue]];
        if(treatments[i][@"recurrence_saturday"] != [NSNull null])
            t.recurrenceSaturday = [NSNumber numberWithBool:[(NSString*)treatments[i][@"recurrence_saturday"] boolValue]];
        
        
        t.doctorId = doctorId;
        t.dateGiven = dateGiven;
        
        t.treatmentTypeId = [NSNumber numberWithInt: [(NSString*)treatments[i][@"treatment_type_id"] intValue]];
    }
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreWithCompletion:^(BOOL contextDidSave, NSError *error)
     {
         [TreatmentDiary UpdateTreatmentDiary];
     }];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"NewTreatmentAvailable" object:nil];

}

-(int)daypartToApproximateHour
{
    if([self.daypart isEqualToString:@"morning"])
        return 10;
    if([self.daypart isEqualToString:@"noon"])
        return 15;
    if([self.daypart isEqualToString:@"evening"])
        return 21;
    if([self.daypart isEqualToString:@"night"])
        return 23;
    return 0;
}


+(Treatment*)GetBasal
{
    NSArray* treatments = [Treatment LastTreatmentsGroup];
    for(Treatment* t in treatments)
    {
        if([t.treatmentTypeId intValue] >= 2500 && [t.treatmentTypeId intValue] < 3000)
            return t;
    }
    return nil;
}

+(Treatment*)GetBolus:(NSString*)daypart
{
    NSArray* treatments = [Treatment LastTreatmentsGroup];
    for(Treatment* t in treatments)
    {
        if([t.treatmentTypeId intValue] >= 2000 && [t.treatmentTypeId intValue] < 2500 && [t.daypart isEqualToString:daypart])
            return t;
    }
    return nil;
}
+(Treatment*)GetBolusMorning
{
    return [Treatment GetBolus:@"morning"];
}
+(Treatment*)GetBolusNoon;
{
    return [Treatment GetBolus:@"noon"];
}
+(Treatment*)GetBolusEvening;
{
    return [Treatment GetBolus:@"evening"];
}
@end
