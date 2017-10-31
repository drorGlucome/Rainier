//
//  Alert_helper.h
//  GlucoMe - Mobile
//
//  Created by dovi winberger on 5/25/15.
//  Copyright (c) 2015 Yiftah Ben Aharon. All rights reserved.
//
//this class is the local DB alerts/shares table
#import <Foundation/Foundation.h>
#import "Alert.h"

@interface Alert(helper) 

+(void)SaveAlertAndSendToServerWithContactName:(NSString*)name contactDetails:(NSString*)details trigger:(int)alert_type_id params:(NSString*)params how:(int)media_type_id relationship:(NSString*)relationship completionBlock:(void (^)(Alert*))completionBlock;;
+(void)MergeAlertsWithServer:(NSDictionary*)dic;
-(void)DeleteAlert;


+(NSArray*)Contacts;
+(NSArray*)AlertsForContact:(NSString*)contact;
@end
