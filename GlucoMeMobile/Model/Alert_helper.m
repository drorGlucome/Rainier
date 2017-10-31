//
//  Alert_helper.m
//  GlucoMe - Mobile
//
//  Created by dovi winberger on 5/25/15.
//  Copyright (c) 2015 Yiftah Ben Aharon. All rights reserved.
//

#import "Alert_helper.h"
#import "DataHandler_new.h"

@implementation Alert(helper)


+(void)SaveAlertAndSendToServerWithContactName:(NSString*)name contactDetails:(NSString*)details trigger:(int)alert_type_id params:(NSString*)params how:(int)media_type_id relationship:(NSString*)relationship completionBlock:(void (^)(Alert*))completionBlock;
{
    Alert* a = [Alert MR_createEntityInContext:[NSManagedObjectContext MR_defaultContext]];
    a.id = @(arc4random_uniform(10000000));
    a.contactDetails = details;
    a.contactName = name;
    a.params = params;
    a.how_mediaTypeID = @(media_type_id);
    a.when_alertTypeID = @(alert_type_id);
    a.relationship = relationship;
    a.is_deleted = @(NO);
    a.didUploadToServer = @(NO);
    
    
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreWithCompletion:^(BOOL contextDidSave, NSError *error)
     {
         if(completionBlock) completionBlock(a);
         [[DataHandler_new getInstance] sendAlertToServer:a withCompletionBlock:^(NSDictionary *dic) {
             NSNumber* id = [NSNumber numberWithInt:[[dic objectForKey:@"id"] intValue]];
             a.id = id;
             a.didUploadToServer = @(YES);
             [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreWithCompletion:nil];
         }];
         
         if(contextDidSave == NO)
         {
             NSLog(@"WHHYYY");
         }
     }];
    
}

-(void)DeleteAlert
{
    
    //sync deletion with the server
    
    self.is_deleted = @(YES);
    self.didUploadToServer = @(NO);
    
    int alertID = [self.id intValue];

    [[DataHandler_new getInstance] deleteAlert:alertID withCompletionBlock:^{
        self.didUploadToServer = @(YES);
        [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreWithCompletion:^(BOOL contextDidSave, NSError *error) {
            
        }];
    }];

    //NSPredicate* p = [NSPredicate predicateWithFormat:@"id = %@",self.id];
    //[Alert MR_deleteAllMatchingPredicate:p inContext:[NSManagedObjectContext MR_defaultContext]];
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreWithCompletion:^(BOOL contextDidSave, NSError *error) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"DataChanged" object:nil];
    }];
    
    
}

+(void)MergeAlertsWithServer:(NSDictionary*)dic
{
    NSPredicate* p = [NSPredicate predicateWithFormat:@"didUploadToServer = true"];
    //NSArray* allAlertsThatWereUploadedToTheServer = [Alert MR_findAllWithPredicate:p inContext:[NSManagedObjectContext MR_defaultContext]];
    [Alert MR_deleteAllMatchingPredicate:p inContext:[NSManagedObjectContext MR_defaultContext]];
    
    NSArray* log = [dic objectForKey:@"alerts"];
    for(NSDictionary* mDic in log)
    {
        NSNumber* alert_id = [NSNumber numberWithInt: [(NSString*)[mDic objectForKey:@"id"] intValue]];
        NSPredicate* does_exists_predicate = [NSPredicate predicateWithFormat:@"id = %@ AND is_deleted = true", alert_id];
        if([Alert MR_findFirstWithPredicate:does_exists_predicate inContext:[NSManagedObjectContext MR_defaultContext]] != nil)
        {
            //alert has been deleted localy, dont create new one. will be deleted from the server below
            continue;
        }
        
        Alert* a = [Alert MR_createEntityInContext:[NSManagedObjectContext MR_defaultContext]];
        a.id = alert_id;
        a.when_alertTypeID  = [NSNumber numberWithInt: [(NSString*)[mDic objectForKey:@"alert_type_id"] intValue]];
        a.how_mediaTypeID   = [NSNumber numberWithInt: [(NSString*)[mDic objectForKey:@"media_type_id"] intValue]];
        if([mDic.allKeys containsObject:@"contact_details"] && mDic[@"contact_details"] != [NSNull null])
            a.contactDetails    = [mDic objectForKey:@"contact_details"];
        if([mDic.allKeys containsObject:@"contact_name"] && mDic[@"contact_name"] != [NSNull null])
            a.contactName       = [mDic objectForKey:@"contact_name"];
        if([mDic.allKeys containsObject:@"params"] && mDic[@"params"] != [NSNull null])
            a.params            = [mDic objectForKey:@"params"];
        if([mDic.allKeys containsObject:@"relationship"] && mDic[@"relationship"] != [NSNull null])
            a.relationship = [mDic objectForKey:@"relationship"];
        if([mDic.allKeys containsObject:@"is_deleted"] && mDic[@"is_deleted"] != [NSNull null])
            a.is_deleted = [mDic objectForKey:@"is_deleted"];
        a.didUploadToServer = @(YES);
        
        
        [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreWithCompletion:^(BOOL contextDidSave, NSError *error) {
            
        }];
    }
    
    
    //uploading alerts that are local
    p = [NSPredicate predicateWithFormat:@"didUploadToServer = false OR didUploadToServer = nil"];
    NSArray* localAlerts = [Alert MR_findAllWithPredicate:p inContext:[NSManagedObjectContext MR_defaultContext]];
    
    for(Alert* a in localAlerts)
    {
        if([a.is_deleted boolValue] == YES)
        {
            [a DeleteAlert];
        }
        else
        {
            [[DataHandler_new getInstance] sendAlertToServer:a withCompletionBlock:^(NSDictionary *dic) {
                NSNumber* id = [NSNumber numberWithInt:[[dic objectForKey:@"id"] intValue]];
                a.id = id;
                a.didUploadToServer = @(YES);
                [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreWithCompletion:nil];
            }];
        }
    }
    
}

+(NSArray*)Contacts
{
    NSPredicate* p = [NSPredicate predicateWithFormat:@"is_deleted = false"];
    NSArray* all = [Alert MR_findAllWithPredicate:p inContext:[NSManagedObjectContext MR_defaultContext]];
    //NSArray* all = [Alert MR_findAllInContext:[NSManagedObjectContext MR_defaultContext]];
    NSMutableSet* namesSet = [NSMutableSet setWithArray:[[all valueForKey:@"contactName"] valueForKey:@"lowercaseString"]];
    if([namesSet containsObject:[NSNull null]])
    {
        [namesSet removeObject:[NSNull null]];
        
        NSArray* allNulls = [Alert MR_findByAttribute:@"contactName" withValue:[NSNull null] inContext:[NSManagedObjectContext MR_defaultContext]];
        NSMutableSet* nullSet = [NSMutableSet setWithArray:[allNulls valueForKey:@"contactDetails"]];
        
        [namesSet addObjectsFromArray:[nullSet allObjects]];
    }

    NSArray* res = [namesSet allObjects];
    return [res sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    
}

+(NSArray*)AlertsForContact:(NSString*)contact
{
    NSPredicate* p = [NSPredicate predicateWithFormat:@"contactName LIKE[c] %@ AND is_deleted = false", contact];
    NSArray* res = [Alert MR_findAllSortedBy:@"how_mediaTypeID" ascending:YES withPredicate:p inContext:[NSManagedObjectContext MR_defaultContext]];
//    NSArray* res = [Alert MR_findByAttribute:@"contactName" withValue:contact andOrderBy:@"how_mediaTypeID" ascending:YES inContext:[NSManagedObjectContext MR_defaultContext]];
    if(res == nil || res.count == 0)
    {
        p = [NSPredicate predicateWithFormat:@"contactDetails LIKE[c] %@", contact];
        res = [Alert MR_findAllSortedBy:@"how_mediaTypeID" ascending:YES withPredicate:p inContext:[NSManagedObjectContext MR_defaultContext]];
        //res = [Alert MR_findByAttribute:@"contactDetails" withValue:contact andOrderBy:@"how_mediaTypeID" ascending:YES inContext:[NSManagedObjectContext MR_defaultContext]];
    }
    return res;
}

@end
