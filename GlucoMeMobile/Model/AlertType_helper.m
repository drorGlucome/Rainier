//
//  AlertType_herlper.m
//  GlucoMe - Mobile
//
//  Created by dovi winberger on 5/20/15.
//  Copyright (c) 2015 Yiftah Ben Aharon. All rights reserved.
//

#import "AlertType_helper.h"

@implementation AlertType(herlper)



+(void)MergeAlertTypesWithServer:(NSDictionary*)dic
{
    [AlertType MR_truncateAllInContext:[NSManagedObjectContext MR_defaultContext]];
    
    NSArray* alertTypes = [dic objectForKey:@"alert_types"];
    for(NSDictionary* mDic in alertTypes)
    {
        AlertType* a = [AlertType MR_createEntityInContext:[NSManagedObjectContext MR_defaultContext]];
        a.name      = [mDic objectForKey:@"name"];
        a.id        = [mDic objectForKey:@"id"];
        if([mDic.allKeys containsObject:@"order"] && [mDic objectForKey:@"order"] != [NSNull null])
            a.order = [mDic objectForKey:@"order"];
        if([mDic.allKeys containsObject:@"when_array"] && [mDic objectForKey:@"when_array"] != [NSNull null])
            a.when_array = [mDic objectForKey:@"when_array"];
        if([mDic.allKeys containsObject:@"is_on_by_default"] && [mDic objectForKey:@"is_on_by_default"] != [NSNull null])
            a.is_on_by_default = [mDic objectForKey:@"is_on_by_default"];
        
        [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreWithCompletion:nil];
    }
}

+(NSArray*)AllAlertTypesSorted
{
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"order" ascending:YES selector:@selector(compare:)];
    NSArray* all = [AlertType MR_findAllInContext:[NSManagedObjectContext MR_defaultContext]];
    return [all sortedArrayUsingDescriptors:@[ sortDescriptor ]];
}

-(NSArray*)WhenArray
{
    return [self.when_array componentsSeparatedByString:@","];
}

-(NSString*)WhatAsString:(NSString*)what
{
    if([[what lowercaseString] isEqualToString:@"after test"])
        return loc(@"After_test");
    else if([[what lowercaseString] isEqualToString:@"after medication"])
        return loc(@"After_medication");
    else if([[what lowercaseString] isEqualToString:@"hypoglycemia"])
        return loc(@"Hypoglycemia");
    else if([[what lowercaseString] isEqualToString:@"result out of range"])
        return loc(@"Result_out_of_range");
    else if([[what lowercaseString] isEqualToString:@"amount of strips left"])
        return loc(@"Amount_of_strips_left");
    else if([[what lowercaseString] isEqualToString:@"no measurements"])
        return loc(@"No_measurements");
    return what;
}
-(NSString*)WhenAsString:(NSString*)when
{
    if([[self.name lowercaseString] containsString:@"strips"])
    {
        return [NSString stringWithFormat:@"%@ %@", loc(@"Less_than"), when];
    }
    else
    {
        if([when integerValue] == 0)
            return loc(@"immediately");
        else if ([when integerValue] == 1)
        {
            return loc(@"once_a_day");
        }
        else if ([when integerValue] == 7)
        {
            return loc(@"once_a_week");
        }
    }
    return when;
}

@end
