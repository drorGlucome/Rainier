//
//  DataHandler_new.m
//  GlucoMe - Mobile
//
//  Created by dovi winberger on 5/19/15.
//  Copyright (c) 2015 Yiftah Ben Aharon. All rights reserved.
//

#import "DataHandler_new.h"

#import "general.h"
#import "Utilities.h"
#import "ProfileViewController.h"
#import <sys/utsname.h>
#import "MyAFHTTPSessionManager.h"


@interface DataHandler_new ()

@end

@implementation DataHandler_new
@synthesize afNetworking;

static DataHandler_new *sharedInstance = nil;
+(DataHandler_new*)getInstance
{
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[DataHandler_new alloc] init];
        // Do any other initialisation stuff here
        //sharedInstance->hk = [[HealthKitHelper alloc] init];
        
        [DataHandler_new InitializeNetwork];
        
    });
    return sharedInstance;
}

+(void)InitializeNetwork
{
    NSString* url = [[NSUserDefaults standardUserDefaults] objectForKey:server_url];
    
    if(url == nil || [url isEqualToString:@""] || [url isEqualToString:@"https://app.glucome.com"])
    {
        [[NSUserDefaults standardUserDefaults] setObject:@"https://ddc.glucome.com" forKey:server_url];
        [[NSUserDefaults standardUserDefaults] synchronize];
        url = [[NSUserDefaults standardUserDefaults] objectForKey:server_url];
    }
    NSURL *baseURL = [NSURL URLWithString:url];
    //baseURL = [NSURL URLWithString:@"http://192.168.1.104:3000"];
    
    //dont save cookies
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    sessionConfiguration.HTTPCookieStorage = nil;
    sessionConfiguration.HTTPCookieAcceptPolicy = NSHTTPCookieAcceptPolicyNever;
    
    AFSecurityPolicy *sec=[[AFSecurityPolicy alloc] init];
    [sec setAllowInvalidCertificates:YES];
    
    
    sharedInstance->afNetworking = [[MyAFHTTPSessionManager alloc] initWithBaseURL:baseURL sessionConfiguration:sessionConfiguration];
    sharedInstance->afNetworking.securityPolicy = sec;
    sharedInstance->afNetworking.requestSerializer = [AFJSONRequestSerializer serializer];
    [sharedInstance->afNetworking.requestSerializer setAuthorizationHeaderFieldWithUsername:@"glucome" password:@"notebook3"];
    [sharedInstance SetRequestHeaders];
    sharedInstance->afNetworking.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
    sharedInstance.hostReachability = [Reachability reachabilityWithHostName:baseURL.host];
    [sharedInstance.hostReachability startNotifier];
}

/*!
 * Called by Reachability whenever status changes.
 */
+ (void) reachabilityChanged:(NSNotification *)note
{
    Reachability* curReach = [note object];
    NSParameterAssert([curReach isKindOfClass:[Reachability class]]);
    [DataHandler_new getInstance]->lastNetworkStatus = [curReach currentReachabilityStatus];
}

+ (void)NotifyUserAboutNetworkProblems
{
    if([DataHandler_new getInstance]->lastNetworkStatus == NotReachable)
    {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [TSMessage showNotificationInViewController:[((AppDelegate*)[UIApplication sharedApplication].delegate) GetTopViewController]
                                                  title:@"No internet connection"
                                               subtitle:@"Data will be synced later"
                                                  image:nil
                                                   type:TSMessageNotificationTypeWarning
                                               duration:TSMessageNotificationDurationAutomatic
                                               callback:nil
                                            buttonTitle:nil
                                         buttonCallback:^{
                                             NSLog(@"User tapped the button");
                                         }
                                             atPosition:TSMessageNotificationPositionBottom
                                   canBeDismissedByUser:YES];
        });
        
//        
//        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:((AppDelegate*)[UIApplication sharedApplication].delegate).window animated:YES];
//        hud.mode = MBProgressHUDModeText;
//        hud.position
//        hud.label.text = @"No internet connection";
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            dispatch_async(dispatch_get_main_queue(), ^{
//                [MBProgressHUD hideHUDForView:((AppDelegate*)[UIApplication sharedApplication].delegate).window animated:YES];
//            });
//        });
    }
    else
    {
        NSLog(@"INTERNETTTTTT!");
    }
}

-(void)SetRequestHeaders
{
    NSString* authentication_token = [[NSUserDefaults standardUserDefaults] objectForKey:profile_authentication_token];
    NSString* email = [[NSUserDefaults standardUserDefaults] objectForKey:profile_email];
    
    if(email == nil) email = @"123123123";
    if(authentication_token == nil) {
        authentication_token = @"asdasdasd";
    }
    [afNetworking.requestSerializer setValue:email forHTTPHeaderField:@"X-User-Email"];
    [afNetworking.requestSerializer setValue:authentication_token forHTTPHeaderField:@"X-User-Token"];
    NSString* version     = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    [afNetworking.requestSerializer setValue:version forHTTPHeaderField:@"GlucoMe-App-Version"];
}

-(NSString*)getEmail
{
    NSString* email = [[NSUserDefaults standardUserDefaults] stringForKey:profile_email];
    if(email == nil) {
        return @"N/A";
    }
    return email;
    
}


-(void) setAuthentication_token:(NSString*)authentication_token
{
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:authentication_token forKey:profile_authentication_token];
    [defaults synchronize];
    
    [self SetRequestHeaders];
    
}

- (void) setPatientId:(NSString*)patientId
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:patientId forKey:profile_id];
    [defaults synchronize];
}

- (NSString*) getPatientId
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString* patientId = [[defaults objectForKey:profile_id] stringValue];

    return patientId;
}
-(NSNumber*)getPatientIdAsNumber
{
    NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
    f.numberStyle = NSNumberFormatterDecimalStyle;
    NSNumber *idNumber = [f numberFromString:[self getPatientId]];
    return idNumber;
}

- (NSString*) getLastPushNotificationsToken
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString* token = [defaults objectForKey:profile_last_push_notifications_token];
    
    return token;
}

//this should be periodic
-(void)GetUserMeasurementsFromServer
{
    if(DLG.isConnectedVersion == NO) return;
    
    NSString* url = [NSString stringWithFormat:@"mobile_measurement/%@.json", [self getPatientId]];

    NSMutableDictionary* params = [[NSMutableDictionary alloc] init];
    
    [afNetworking GET:url parameters:params success:^void(NSURLSessionDataTask * task, NSDictionary* responseObject){
        NSDictionary* dic = responseObject;//[NSJSONSerialization JSONObjectWithData:operation.HTTPRequestOperation.responseData options:NSJSONReadingMutableContainers error:nil];
        [Measurement MergeMeasurmentsWithServer:dic forPatient_id:[[DataHandler_new getInstance] getPatientIdAsNumber]];
        [MediaType MergeMediaTypesWithServer:dic];
        [AlertType MergeAlertTypesWithServer:dic];
        [Fact MergeFactsWithServer:dic];
        [Alert MergeAlertsWithServer:dic];
        [Friend MergeFriendsWithServer:dic];
        
        NSArray* treatmentDiary = [dic objectForKey:@"treatment_diary"];
        if(treatmentDiary != nil)
            [TreatmentDiary MergeTreatmentDiaryWithServer:dic];

        //saving score
        NSDictionary* scoreDic = [dic valueForKey:@"score"];
        NSNumber* score = [NSNumber numberWithInt: [(NSString*)[scoreDic objectForKey:@"value"] intValue]];
        [[NSUserDefaults standardUserDefaults] setObject:score forKey:profile_score];
        
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:@"DataChanged" object:nil];
        });
    } failure:^void(NSURLSessionDataTask * task, NSError * error) {
        NSLog(@"%@",error.description);
    }];
}

-(void)GetFriendMeasurementsFromServer:(NSNumber*)friend_id
{
    if(DLG.isConnectedVersion == NO) return;
    
    NSString* url = [NSString stringWithFormat:@"mobile_measurement/%@.json", friend_id];
    
    NSMutableDictionary* params = [[NSMutableDictionary alloc] init];
    
    [afNetworking GET:url parameters:params success:^void(NSURLSessionDataTask * task, NSDictionary* responseObject){
        NSDictionary* dic = responseObject;//[NSJSONSerialization JSONObjectWithData:operation.HTTPRequestOperation.responseData options:NSJSONReadingMutableContainers error:nil];
        [Measurement MergeMeasurmentsWithServer:dic forPatient_id:friend_id];

        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:@"FriendDataChanged" object:nil];
        });
    } failure:^void(NSURLSessionDataTask * task, NSError * err) {
        
    }];
}

-(void)UpdateMeasurementInServer:(Measurement*)m withCompletionBlock:(void (^)(NSDictionary*))completionBlock
{
    if(DLG.isConnectedVersion == NO) return;
    
    NSString* url = [NSString stringWithFormat:@"/samples/update_sample_by_uuid/%@.json",m.uuid];
    
    NSMutableDictionary* params = [[NSMutableDictionary alloc] init];

    if(m.tags != nil)
        [params setObject:m.tags forKey:@"tags"];
    if(m.comment != nil)
        [params setObject:m.comment forKey:@"comment"];
    
    if([m.source isEqualToString:@"manual"])
    {
        [params setObject:m.value forKey:@"value"];
        NSString* dateString = NSDate2rails(m.date);
        [params setObject:dateString forKey:@"date"];
    }
    
    [afNetworking PUT:url parameters:params success:^void(NSURLSessionDataTask * task, NSDictionary* responseObject) {
        //NSDictionary* dic = responseObject;//[NSJSONSerialization JSONObjectWithData:operation.HTTPRequestOperation.responseData options:NSJSONReadingMutableContainers error:nil];
        //NSLog(@"Measurement %@ updated", m.record_id);
        if(completionBlock) completionBlock(responseObject);
    } failure:^void(NSURLSessionDataTask * task, NSError * error) {
        NSLog(@"%@",error.description);
    }];

}

-(void)sendMeasurementToServer:(Measurement*)m withCompletionBlock:(void (^)(NSDictionary*))completionBlock
{
    [DataHandler_new NotifyUserAboutNetworkProblems];
    
    int value       = [m.value intValue];
    int type        = [m.type intValue];
    //if(m.type == 0)
    //    [hk saveGlucoseIntoHealthStore:value];
    
    if(DLG.isConnectedVersion == NO) return;
    
    
    NSDate* date    = m.date;
    
    
    
    NSString* url = [NSString stringWithFormat:@"/mobile_measurement/%@.json",[self getPatientId]];
    
    NSMutableDictionary* params = [[NSMutableDictionary alloc] init];
    NSString* str_value = [[NSString alloc] initWithFormat:@"%d", value];
    NSString* str_type = [[NSString alloc] initWithFormat:@"%d", type];
    
    NSString* dateString = NSDate2rails(date);
    [params setObject:m.uuid forKey:@"uuid"];
    [params setObject:str_value forKey:@"value"];
    [params setObject:dateString forKey:@"date"];
    [params setObject:str_type forKey:@"measurement_type"];
    if(m.comment != nil)
        [params setObject:m.comment forKey:@"comment"];
    if(m.tags != nil)
        [params setObject:m.tags forKey:@"tags"];
    if(m.source != nil)
        [params setObject:m.source forKey:@"source"];
    

    [afNetworking POST:url parameters:params success:^void(NSURLSessionDataTask * task, NSDictionary* responseObject) {
        NSDictionary* dic = responseObject;//[NSJSONSerialization JSONObjectWithData:operation.HTTPRequestOperation.responseData options:NSJSONReadingMutableContainers error:nil];
        if(completionBlock) completionBlock(dic);
    } failure:^void(NSURLSessionDataTask * task, NSError * error) {
        NSLog(@"%@",error.description);
        NSString* msg = @"";//operation.HTTPRequestOperation.responseString;
        msg = [[NSString alloc] initWithData:error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] encoding:NSUTF8StringEncoding];
        NSLog(@"%@",msg);
    }];

    
}

- (void) sendAlertToServer:(Alert*)a withCompletionBlock:(void (^)(NSDictionary*))completionBlock
{
    if(DLG.isConnectedVersion == NO) return;
    
    int alertType = [a.when_alertTypeID intValue];
    int mediaType = [a.how_mediaTypeID intValue];
    NSString* details   = a.contactDetails;
    NSString* name      = a.contactName;
    NSString* alert_params = a.params;
    NSString* relationship = a.relationship;
    
    NSMutableDictionary* params = [[NSMutableDictionary alloc] init];
    
    // handle user data
    [params setObject:[[NSString alloc] initWithFormat:@"%d",alertType]  forKey:@"alert_type_id"];
    [params setObject:[[NSString alloc] initWithFormat:@"%d",mediaType]  forKey:@"media_type_id"];
    [params setObject:[[NSString alloc] initWithFormat:@"%@",details]  forKey:@"contact_details"];
    [params setObject:[[NSString alloc] initWithFormat:@"%@",name]  forKey:@"contact_name"];
    [params setObject:[[NSString alloc] initWithFormat:@"%@",alert_params]  forKey:@"params"];
    [params setObject:[[NSString alloc] initWithFormat:@"%@",relationship]  forKey:@"relationship"];
    [params setObject:[[NSString alloc] initWithFormat:@"%@",[self getPatientId]]  forKey:@"patient_id"];
    
    
    NSString* url = @"/alerts.json";
    
    [afNetworking POST:url parameters:params success:^void(NSURLSessionDataTask * task, NSDictionary* responseObject) {
        NSDictionary* dic = responseObject;//[NSJSONSerialization JSONObjectWithData:operation.HTTPRequestOperation.responseData options:NSJSONReadingMutableContainers error:nil];
        
        if(completionBlock) completionBlock(dic);
    } failure:^void(NSURLSessionDataTask * task, NSError * error) {
        //NSDictionary* dic = [NSJSONSerialization JSONObjectWithData:operation.HTTPRequestOperation.responseData options:NSJSONReadingMutableContainers error:nil];
        NSLog(@"%@",error.description);
    }];
    /*[[RKObjectManager sharedManager] postObject:params path:url parameters:params success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        NSDictionary* dic = [NSJSONSerialization JSONObjectWithData:operation.HTTPRequestOperation.responseData options:NSJSONReadingMutableContainers error:nil];
        
        if(completionBlock) completionBlock(dic);
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        //NSDictionary* dic = [NSJSONSerialization JSONObjectWithData:operation.HTTPRequestOperation.responseData options:NSJSONReadingMutableContainers error:nil];
        NSLog(@"%@",error.description);
    }];*/
    
}

-(void)deleteAlert:(int)alertId withCompletionBlock:(void (^)(void))completionBlock
{
    if(DLG.isConnectedVersion == NO) return;
    
    NSMutableDictionary* params = [[NSMutableDictionary alloc] init];
    NSString* url = [[NSString alloc] initWithFormat:@"alerts/%d.json", alertId];
    
    [afNetworking DELETE:url parameters:params success:^void(NSURLSessionDataTask * task, NSDictionary* responseObject) {
        NSDictionary* dic = responseObject;//[NSJSONSerialization JSONObjectWithData:operation.HTTPRequestOperation.responseData options:NSJSONReadingMutableContainers error:nil];
        NSLog(@"%@",dic);
        if(completionBlock) completionBlock();
    } failure:^void(NSURLSessionDataTask * task, NSError * error) {
        //NSDictionary* dic = responseObject;//[NSJSONSerialization JSONObjectWithData:operation.HTTPRequestOperation.responseData options:NSJSONReadingMutableContainers error:nil];
        NSLog(@"%@",error.description);
    }];
    
    
}

-(int)GetStrips
{
    return [[[NSUserDefaults standardUserDefaults] objectForKey:profile_strips] intValue];
}

-(void)DeductOneStrip
{
    int strips = [self GetStrips];
    strips -= 1;
    if(strips < 0) strips = 0;
    [self UpdateStrips:strips];
}
-(void)UpdateStrips:(int)number
{
    [[NSUserDefaults standardUserDefaults] setObject:@(number) forKey:profile_strips];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"DataChanged" object:nil];

    if(DLG.isConnectedVersion == NO) return;
    
    
    NSString* strips = [[NSString alloc] initWithFormat:@"%d", number];
    NSMutableDictionary* params = [[NSMutableDictionary alloc] init];

    [params setObject:strips forKey:@"strips"];
    
    NSString* url = [NSString stringWithFormat:@"/patients/%@.json", [self getPatientId]];
    
    [afNetworking PUT:url parameters:params success:^void(NSURLSessionDataTask * task, NSDictionary* responseObject) {
        NSDictionary* dic = responseObject;//[NSJSONSerialization JSONObjectWithData:operation.HTTPRequestOperation.responseData options:NSJSONReadingMutableContainers error:nil];
        NSLog(@"%@",dic);
    } failure:^void(NSURLSessionDataTask * task, NSError * error) {
        //NSDictionary* dic = [NSJSONSerialization JSONObjectWithData:operation.HTTPRequestOperation.responseData options:NSJSONReadingMutableContainers error:nil];
        NSLog(@"%@",error.description);
    }];
}

-(void)RefreshFact
{
    if(DLG.isConnectedVersion == NO) return;
    
    NSString* url = [NSString stringWithFormat:@"facts/%@.json", [self getPatientId]];
    
    NSMutableDictionary* params = [[NSMutableDictionary alloc] init];
    
    [afNetworking GET:url parameters:params success:^void(NSURLSessionDataTask * task, NSDictionary* responseObject) {
        NSDictionary* dic = responseObject;//[NSJSONSerialization JSONObjectWithData:operation.HTTPRequestOperation.responseData options:NSJSONReadingMutableContainers error:nil];
        [Fact MergeFactsWithServer:dic];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:@"DataChanged" object:nil];
        });
    } failure:^void(NSURLSessionDataTask * task, NSError * error) {
        
    }];
    
    /*[[RKObjectManager sharedManager] getObjectsAtPath:url parameters:params success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        
        NSDictionary* dic = [NSJSONSerialization JSONObjectWithData:operation.HTTPRequestOperation.responseData options:NSJSONReadingMutableContainers error:nil];
        [Fact MergeFactsWithServer:dic];

        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:@"DataChanged" object:nil];
        });
        
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        
    }];*/
}

-(void)sendProfileToServer
{
    if(DLG.isConnectedVersion == NO) return;
    
    NSMutableDictionary* params = [[NSMutableDictionary alloc] init];
    
    NSUserDefaults* d = [NSUserDefaults standardUserDefaults];
    
    if([d objectForKey:profile_first_name] != nil && [d objectForKey:profile_first_name] != [NSNull null])
        [params setObject:[d objectForKey:profile_first_name] forKey:@"first"];
    
    if([d objectForKey:profile_last_name] != nil && [d objectForKey:profile_last_name] != [NSNull null])
        [params setObject:[d objectForKey:profile_last_name] forKey:@"last"];
    
    if([d objectForKey:profile_height] != nil && [d objectForKey:profile_height] != [NSNull null])
        [params setObject:[d objectForKey:profile_height] forKey:@"height"];
    
    if([d objectForKey:profile_weight] != nil && [d objectForKey:profile_weight] != [NSNull null])
        [params setObject:[d objectForKey:profile_weight] forKey:@"weight"];
    
    if([d objectForKey:profile_upper_limit] != nil && [d objectForKey:profile_upper_limit] != [NSNull null])
        [params setObject:[d objectForKey:profile_upper_limit] forKey:@"upper_range"];
    
    if([d objectForKey:profile_lower_limit] != nil && [d objectForKey:profile_lower_limit] != [NSNull null])
        [params setObject:[d objectForKey:profile_lower_limit] forKey:@"lower_range"];
    
    if([d objectForKey:profile_daily_measurements] != nil && [d objectForKey:profile_daily_measurements] != [NSNull null])
        [params setObject:[d objectForKey:profile_daily_measurements] forKey:@"daily_measurements"];
    
    if([d objectForKey:profile_diabetes_type] != nil && [d objectForKey:profile_diabetes_type] != [NSNull null])
        [params setObject:[d objectForKey:profile_diabetes_type] forKey:@"diabetes_type"];
    
    if([d objectForKey:profile_glucose_units] != nil && [d objectForKey:profile_glucose_units] != [NSNull null])
        [params setObject:[d objectForKey:profile_glucose_units] forKey:@"units"];
    
    if([d objectForKey:profile_pre_meal_target] != nil && [d objectForKey:profile_pre_meal_target] != [NSNull null])
        [params setObject:[d objectForKey:profile_pre_meal_target] forKey:@"pre_meal_target"];
    
    if([d objectForKey:profile_post_meal_target] != nil && [d objectForKey:profile_post_meal_target] != [NSNull null])
        [params setObject:[d objectForKey:profile_post_meal_target] forKey:@"post_meal_target"];
    
    if([d objectForKey:profile_hypo_threshold] != nil && [d objectForKey:profile_hypo_threshold] != [NSNull null])
        [params setObject:[d objectForKey:profile_hypo_threshold] forKey:@"hypo_threshold"];
    
    if([d objectForKey:server_url] != nil && [d objectForKey:server_url] != [NSNull null])
        [params setObject:[d objectForKey:server_url] forKey:@"server_url"];

    NSString* url = [NSString stringWithFormat:@"/patients/%@.json", [self getPatientId]];
    
    
    [afNetworking PUT:url parameters:params success:^void(NSURLSessionDataTask * task, NSDictionary* responseObject) {
        NSDictionary* dic = responseObject;//[NSJSONSerialization JSONObjectWithData:operation.HTTPRequestOperation.responseData options:NSJSONReadingMutableContainers error:nil];
        NSLog(@"%@",dic);
    } failure:^void(NSURLSessionDataTask * task, NSError * error) {
        //NSDictionary* dic = [NSJSONSerialization JSONObjectWithData:operation.HTTPRequestOperation.responseData options:NSJSONReadingMutableContainers error:nil];
        NSLog(@"%@",error.description);
    }];
}
-(void)SendLocaleToServer
{
    if(DLG.isConnectedVersion == NO) return;
    if([self getPatientId] == nil) return;
    
    NSMutableDictionary* params = [[NSMutableDictionary alloc] init];
    
    NSString* language = [[NSLocale preferredLanguages] objectAtIndex:0];
    NSString* countryCode = [Utilities GetCountryCode];
    [params setObject:[NSString stringWithFormat:@"%@ %@",language, countryCode] forKey:@"locale"];
    
    NSInteger minutesFromGMT = [[NSTimeZone localTimeZone] secondsFromGMT] / 60.0;
    [params setObject:@(minutesFromGMT) forKey:@"timezone"];
    
    NSString* url = [NSString stringWithFormat:@"/patients/%@.json", [self getPatientId]];
    
    
    [afNetworking PUT:url parameters:params success:^void(NSURLSessionDataTask * task, NSDictionary* responseObject) {
        NSDictionary* dic = responseObject;//[NSJSONSerialization JSONObjectWithData:operation.HTTPRequestOperation.responseData options:NSJSONReadingMutableContainers error:nil];
        NSLog(@"%@",dic);
    } failure:^void(NSURLSessionDataTask * task, NSError * error) {
        //NSDictionary* dic = [NSJSONSerialization JSONObjectWithData:operation.HTTPRequestOperation.responseData options:NSJSONReadingMutableContainers error:nil];
        NSLog(@"%@",error.description);
    }];
}
//this should be periodic
-(void)GetProfileFromServerWithCompletionBlock:(void (^)())completionBlock
{
    if(DLG.isConnectedVersion == NO) return;
    
    NSMutableDictionary* params = [[NSMutableDictionary alloc] init];

    NSString* url = [NSString stringWithFormat:@"/patients/%@.json", [self getPatientId]];
    
    [afNetworking GET:url parameters:params success:^void(NSURLSessionDataTask * task, NSDictionary* responseObject) {
        NSDictionary* dic = responseObject;//[NSJSONSerialization JSONObjectWithData:operation.HTTPRequestOperation.responseData options:NSJSONReadingMutableContainers error:nil];
        //NSLog(@"%@",dic);
        [self SaveProfile:dic];
        
        NSArray* treatment = [dic objectForKey:@"treatment"];
        if(treatment != nil)
            [Treatment AddNewTreatment:treatment];
        
        if(completionBlock) completionBlock();
    } failure:^void(NSURLSessionDataTask * task, NSError * error) {
        //NSDictionary* dic = [NSJSONSerialization JSONObjectWithData:operation.HTTPRequestOperation.responseData options:NSJSONReadingMutableContainers error:nil];
        NSLog(@"%@",error.description);
    }];
}


-(void)PostDevice
{
    NSMutableDictionary* params = [[NSMutableDictionary alloc] init];

    if([self getPatientId])
        [params setObject:[self getPatientId] forKey:@"patient_id"];
    else
        return;
    
    [params setObject:@"iOS" forKey:@"os_type"];
    [params setObject:@"Apple" forKey:@"manufacturer"];
    
    if([self getLastPushNotificationsToken])
        [params setObject:[self getLastPushNotificationsToken] forKey:@"notifications_token"];

    
    NSString* buildNumber = [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString*)kCFBundleVersionKey];
    NSString* version     = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    [params setObject:[NSString stringWithFormat:@"%@(%@)",version,buildNumber] forKey:@"app_version"];

    NSString* language = [[NSLocale preferredLanguages] objectAtIndex:0];
    NSString* countryCode = [Utilities GetCountryCode];
    [params setObject:[NSString stringWithFormat:@"%@ %@",language, countryCode] forKey:@"locale"];
    
    
    [params setObject:[[UIDevice currentDevice] systemVersion] forKey:@"os_version"];
    [params setObject:[self deviceName] forKey:@"model"];
    [params setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"uuid"] forKey:@"udid"];
    
    NSString* url = @"/devices.json";
    
    
    
    [afNetworking POST:url parameters:params success:^void(NSURLSessionDataTask * task, NSDictionary* responseObject) {
        //NSDictionary* dic = [NSJSONSerialization JSONObjectWithData:operation.HTTPRequestOperation.responseData options:NSJSONReadingMutableContainers error:nil];
        //NSLog(@"%@",dic);
    } failure:^void(NSURLSessionDataTask * task, NSError * error) {
        //NSDictionary* dic = [NSJSONSerialization JSONObjectWithData:operation.HTTPRequestOperation.responseData options:NSJSONReadingMutableContainers error:nil];
        NSLog(@"%@",error.description);
    }];
    
    /*[[RKObjectManager sharedManager] postObject:params path:url parameters:params success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        //NSDictionary* dic = [NSJSONSerialization JSONObjectWithData:operation.HTTPRequestOperation.responseData options:NSJSONReadingMutableContainers error:nil];
        //NSLog(@"%@",dic);
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        //NSDictionary* dic = [NSJSONSerialization JSONObjectWithData:operation.HTTPRequestOperation.responseData options:NSJSONReadingMutableContainers error:nil];
        NSLog(@"%@",error.description);
    }];*/

}

-(NSString*)deviceName
{
    struct utsname systemInfo;
    uname(&systemInfo);
    
    return [NSString stringWithCString:systemInfo.machine
                              encoding:NSUTF8StringEncoding];
}



-(void)SaveProfile:(NSDictionary*)profile
{
    NSObject* email     = @"";
    NSObject* firstName = @"";
    NSObject* lastName  = @"";
    NSObject* height    = @"";
    NSObject* weight    = @"";
    NSObject* lowerLimit = @"";
    NSObject* upperLimit = @"";
    NSObject* pre_meal_target = @"";
    NSObject* post_meal_target = @"";
    NSObject* hypo_threshold = @"";
    NSObject* diabetes_type = @"";
    NSObject* daily_measurements = @"";
    NSObject* units = @"";
    NSObject* serverURL     = @"";
    NSObject* correctionFactor = @"";
    
    email = [profile objectForKey:@"email"];
    firstName = [profile objectForKey:@"first"];
    lastName = [profile objectForKey:@"last"];
    height = [profile objectForKey:@"height"];
    weight = [profile objectForKey:@"weight"];
    lowerLimit = [profile objectForKey:@"lower_range"];
    upperLimit = [profile objectForKey:@"upper_range"];
    diabetes_type = [profile objectForKey:@"diabetes_type"];
    daily_measurements = [profile objectForKey:@"daily_measurements"];
    units = [profile objectForKey:@"units"];
    pre_meal_target = [profile objectForKey:@"pre_meal_target"];
    post_meal_target = [profile objectForKey:@"post_meal_target"];
    hypo_threshold = [profile objectForKey:@"hypo_threshold"];
    serverURL = [profile objectForKey:@"server_url"];
    correctionFactor = [profile objectForKey:profile_correction_factor];
    
    NSUserDefaults* defaules = [NSUserDefaults standardUserDefaults];
    if (firstName != [NSNull null]) [defaules setObject:firstName forKey:profile_first_name];
    if (lastName != [NSNull null])[defaules setObject:lastName forKey:profile_last_name];
    if (height != [NSNull null])[defaules setObject:height forKey:profile_height];
    if (weight != [NSNull null])[defaules setObject:weight forKey:profile_weight];
    if (upperLimit != [NSNull null])[defaules setObject:upperLimit forKey:profile_upper_limit];
    if (lowerLimit != [NSNull null])[defaules setObject:lowerLimit forKey:profile_lower_limit];
    if (daily_measurements != [NSNull null])[defaules setObject:daily_measurements forKey:profile_daily_measurements];
    if (diabetes_type != [NSNull null])[defaules setObject:diabetes_type forKey:profile_diabetes_type];
    if (units != [NSNull null])[defaules setObject:units forKey:profile_glucose_units];
    if (pre_meal_target != [NSNull null])[defaules setObject:pre_meal_target forKey:profile_pre_meal_target];
    if (post_meal_target != [NSNull null])[defaules setObject:post_meal_target forKey:profile_post_meal_target];
    if (hypo_threshold != [NSNull null])[defaules setObject:hypo_threshold forKey:profile_hypo_threshold];
    if (serverURL != [NSNull null])[defaules setObject:serverURL forKey:server_url];
    if (correctionFactor != [NSNull null]) {
        [defaules setObject:correctionFactor forKey:profile_correction_factor];
    }
    else {
        [defaules setObject:@"1" forKey:profile_correction_factor];
    }

    [DataHandler_new InitializeNetwork];
    
    //clinic
    @try {
        NSDictionary* clinic = [profile objectForKey:@"clinic"];
        if(clinic != nil)
        {
            NSObject* clinicName = [clinic objectForKey:@"name"];
            NSObject* clinicId = [clinic objectForKey:@"id"];
            
            if (clinicName != [NSNull null])[defaules setObject:clinicName forKey:profile_clinic_name];
            if (clinicId != [NSNull null])[defaules setObject:clinicId forKey:profile_clinic_id];
        }
    } @catch (NSException *exception) {
        
    } @finally {
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    //doctor
    [defaules setObject:nil forKey:profile_doctor_name];
    [defaules setObject:nil forKey:profile_doctor_id];
    @try {
        NSDictionary* doctor = [profile objectForKey:@"doctor"];
        if(doctor != nil)
        {
            NSObject* doctorName = [doctor objectForKey:@"name"];
            NSObject* doctorId = [doctor objectForKey:@"id"];
                        
            if (doctorName != nil && doctorName != [NSNull null])[defaules setObject:doctorName forKey:profile_doctor_name];
            if (doctorId != nil && doctorId != [NSNull null])[defaules setObject:doctorId forKey:profile_doctor_id];
        }
    } @catch (NSException *exception) {
        
    } @finally {
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    
    //strips
    @try {
        int strips = [[profile objectForKey:@"strips"] intValue];
        [defaules setObject:@(strips) forKey:profile_strips];
    }
    @catch (NSException *exception) {
        [defaules setObject:@(default_profile_strips) forKey:profile_strips];
    }
    @finally {
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"DataChanged" object:nil];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ProfileChanged" object:nil];
}

-(void) resetPassword:(NSString*)email
{
    NSString* url = @"/users/password";
    NSMutableDictionary* params = [[NSMutableDictionary alloc] init];
    NSMutableDictionary* user = [[NSMutableDictionary alloc] init];
    [user setObject:email forKey:@"email"];
    [params setObject:user forKey:@"user"];
    [params setObject:@"Send me reset password instructions" forKey:@"commit"];
    
    [afNetworking POST:url parameters:params success:^void(NSURLSessionDataTask * task, NSDictionary* responseObject) {
        NSDictionary* dic = responseObject;//[NSJSONSerialization JSONObjectWithData:operation.HTTPRequestOperation.responseData options:NSJSONReadingMutableContainers error:nil];
        NSLog(@"%@",dic);
    } failure:^void(NSURLSessionDataTask * task, NSError * error) {
        //NSDictionary* dic = [NSJSONSerialization JSONObjectWithData:operation.HTTPRequestOperation.responseData options:NSJSONReadingMutableContainers error:nil];
        NSLog(@"%@",error.description);
    }];
}

-(void)ResendConfirmationEmail:(NSString*)email
{
    NSMutableDictionary* params = [[NSMutableDictionary alloc] init];
    NSMutableDictionary* user = [[NSMutableDictionary alloc] init];
    [user setObject:email forKey:@"email"];
    [params setObject:user forKey:@"user"];
    [afNetworking POST:@"/users/confirmation" parameters:params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
        NSDictionary* dic = responseObject;
        NSLog(@"%@",dic);
    } failure:^(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error) {
        NSLog(@"%@",error.description);
    }];
}

-(void)Logout
{
    [[DataHandler_new getInstance] ClearUserData];
    
    NSMutableDictionary* params = [[NSMutableDictionary alloc] init];
    [params setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"uuid"] forKey:@"udid"];

    [afNetworking DELETE:@"/users/sign_out.json" parameters:params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
        NSLog(@"%@", @"logged out");
    } failure:^(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error) {
        NSLog(@"%@",error.description);
    }];
}
-(void)ClearUserData
{
    NSUserDefaults * defs = [NSUserDefaults standardUserDefaults];
    NSDictionary * dict = [defs dictionaryRepresentation];
    for (id key in dict) {
        if ([key isEqualToString:@"uuid"])
            continue;
        if ([key isEqualToString:profile_uidArray])
            continue;
        if([key isEqualToString:show_beta_features_boolean])
            continue;
        if([key isEqualToString:server_url])
            continue;
        if([key isEqualToString:profile_email])
            continue;
        
        [defs removeObjectForKey:key];
    }
    [defs synchronize];
    
    [self SetRequestHeaders];
    
    [Measurement MR_truncateAllInContext:[NSManagedObjectContext MR_defaultContext]];
    [Alert MR_truncateAllInContext:[NSManagedObjectContext MR_defaultContext]];
    [MediaType MR_truncateAllInContext:[NSManagedObjectContext MR_defaultContext]];
    [AlertType MR_truncateAllInContext:[NSManagedObjectContext MR_defaultContext]];
    [Fact MR_truncateAllInContext:[NSManagedObjectContext MR_defaultContext]];
    [Friend MR_truncateAllInContext:[NSManagedObjectContext MR_defaultContext]];
    [Treatment MR_truncateAllInContext:[NSManagedObjectContext MR_defaultContext]];
    [TreatmentDiary MR_truncateAllInContext:[NSManagedObjectContext MR_defaultContext]];
    
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
    
    [self SetDefaultData];
}

-(void)SetDefaultData
{
    NSUserDefaults* d = [NSUserDefaults standardUserDefaults];
    
    if([d objectForKey:profile_strips] == nil)
        [[NSUserDefaults standardUserDefaults] setObject:@(default_profile_strips) forKey:profile_strips];
    
    if([d objectForKey:profile_upper_limit] == nil)
        [[NSUserDefaults standardUserDefaults] setObject:@(default_profile_upper_limit) forKey:profile_upper_limit];
    
    if([d objectForKey:profile_lower_limit] == nil)
        [[NSUserDefaults standardUserDefaults] setObject:@(default_profile_lower_limit) forKey:profile_lower_limit];
    
    if([d objectForKey:profile_pre_meal_target] == nil)
        [[NSUserDefaults standardUserDefaults] setObject:@(default_profile_pre_meal_target) forKey:profile_pre_meal_target];
    
    if([d objectForKey:profile_post_meal_target] == nil)
        [[NSUserDefaults standardUserDefaults] setObject:@(default_profile_post_meal_target) forKey:profile_post_meal_target];
    
    if([d objectForKey:profile_hypo_threshold] == nil)
        [[NSUserDefaults standardUserDefaults] setObject:@(default_profile_hypo_threshold) forKey:profile_hypo_threshold];
    
    if([d objectForKey:profile_suspected_hypo_threshold] == nil)
        [[NSUserDefaults standardUserDefaults] setObject:@(default_profile_suspected_hypo_threshold) forKey:profile_suspected_hypo_threshold];
    
    if([d objectForKey:profile_sever_hypo_threshold] == nil)
        [[NSUserDefaults standardUserDefaults] setObject:@(default_profile_sever_hypo_threshold) forKey:profile_sever_hypo_threshold];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}


#pragma mark Social - Friends

-(void)FindFriendIdByEmail:(NSString*)email withCompletionBlock:(void (^)(NSDictionary*))completionBlock
{
    if(DLG.isConnectedVersion == NO) return;
    
    NSString* url = [NSString stringWithFormat:@"/patients/query/%@",email];
    
    NSMutableDictionary* params = [[NSMutableDictionary alloc] init];
    
    [afNetworking GET:url parameters:params success:^void(NSURLSessionDataTask * task, NSDictionary* responseObject) {
        if(completionBlock) completionBlock(responseObject);
    } failure:^void(NSURLSessionDataTask * task, NSError * error) {
        NSLog(@"%@",error.description);
    }];
    
}

-(void)sendFriendToServer:(Friend*)f withCompletionBlock:(void (^)(NSDictionary*))completionBlock
{
    if(DLG.isConnectedVersion == NO) return;
    
    NSString* url = [NSString stringWithFormat:@"/friends.json"];
    
    NSMutableDictionary* params = [[NSMutableDictionary alloc] init];
    
    [params setObject:[self getPatientId] forKey:@"patient_id"];
    [params setObject:[NSString stringWithFormat:@"%@",f.friendId] forKey:@"allowed_patient_id"];
    
    [afNetworking POST:url parameters:params success:^void(NSURLSessionDataTask * task, NSDictionary* responseObject) {
        NSDictionary* dic = responseObject;
        if(completionBlock) completionBlock(dic);
    } failure:^void(NSURLSessionDataTask * task, NSError * error) {
        NSLog(@"%@",error.description);
        NSString* msg = @"";//operation.HTTPRequestOperation.responseString;
        msg = [[NSString alloc] initWithData:error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] encoding:NSUTF8StringEncoding];
        NSLog(@"%@",msg);
    }];
}

//deletes a friend i added
-(void)DeleteFriend:(long)recordId
{
    if(DLG.isConnectedVersion == NO) return;

    NSString* url = [NSString stringWithFormat:@"/friends/%ld.json",recordId];
    
    NSMutableDictionary* params = [[NSMutableDictionary alloc] init];
    
    [afNetworking DELETE:url parameters:params success:^void(NSURLSessionDataTask * task, NSDictionary* responseObject) {
        //NSDictionary* dic = responseObject;
    } failure:^void(NSURLSessionDataTask * task, NSError * error) {
        NSLog(@"%@",error.description);
    }];
}

//removing friends i dont want to see
-(void)FilterFriend:(long)recordId isFiltered:(BOOL)isFiltered
{
    if(DLG.isConnectedVersion == NO) return;
    
    NSString* url = [NSString stringWithFormat:@"/friends/%ld.json",recordId];
    
    NSMutableDictionary* params = [[NSMutableDictionary alloc] init];
    [params setObject:@(isFiltered) forKey:@"is_filtered"];
    
    [afNetworking PUT:url parameters:params success:^void(NSURLSessionDataTask * task, NSDictionary* responseObject) {
        
    } failure:^void(NSURLSessionDataTask * task, NSError * error) {
        NSLog(@"%@",error.description);
        NSString* msg = @"";//operation.HTTPRequestOperation.responseString;
        msg = [[NSString alloc] initWithData:error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] encoding:NSUTF8StringEncoding];
        NSLog(@"%@",msg);
    }];
}

-(void)DisconnectFromClinic:(UIViewController*)vc
{
    if(DLG.isConnectedVersion == NO) return;
    UIAlertController * alert=   [UIAlertController
                                  alertControllerWithTitle:[[NSUserDefaults standardUserDefaults] objectForKey:profile_clinic_name]
                                  message:loc(@"Are_you_sure_you_want_to_disconnect_from_this_clinic")
                                  preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* ok = [UIAlertAction
                         actionWithTitle:loc(@"Disconnect")
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction * action)
                         {
                             [alert dismissViewControllerAnimated:YES completion:nil];
                             
                             NSString* url = [NSString stringWithFormat:@"/patients/%@/disconnect_from_clinic",[self getPatientId]];
                             
                             NSMutableDictionary* params = [[NSMutableDictionary alloc] init];
                             
                             [afNetworking POST:url parameters:params success:^void(NSURLSessionDataTask * task, NSDictionary* responseObject) {
                                 NSDictionary* dic = responseObject;
                                 NSLog(@"%@",dic);
                                 [self SaveProfile:dic];
                                 
                                 [[NSUserDefaults standardUserDefaults] setObject:@"https://ddc.glucome.com" forKey:server_url];
                                 [[NSUserDefaults standardUserDefaults] synchronize];
                                 [DataHandler_new InitializeNetwork];
                                 
                             } failure:^void(NSURLSessionDataTask * task, NSError * error) {
                                 //NSLog(@"%@",error.description);
                                 NSString* msg = @"";//operation.HTTPRequestOperation.responseString;
                                 msg = [[NSString alloc] initWithData:error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] encoding:NSUTF8StringEncoding];
                                 NSLog(@"%@",msg);
                             }];
                         }];
    UIAlertAction* cancel = [UIAlertAction
                             actionWithTitle:loc(@"Cancel")
                             style:UIAlertActionStyleCancel
                             handler:^(UIAlertAction * action)
                             {
                                 [alert dismissViewControllerAnimated:YES completion:nil];
                                 
                             }];
    
    [alert addAction:ok];
    [alert addAction:cancel];
    
    [vc presentViewController:alert animated:YES completion:nil];
}
-(void)ConnectMeToClinicWithQR_result:(NSString*)QR_result viewController:(UIViewController*)vc
{
    if(DLG.isConnectedVersion == NO) return;
    
    //parse QR
    if (![QR_result hasPrefix:@"GlucoMe#v"]) {
        //not a glucome QR
        UIAlertController * alert=   [UIAlertController
                                      alertControllerWithTitle:loc(@"not_a_glucome_qr")
                                      message:@""
                                      preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* ok = [UIAlertAction
                             actionWithTitle:loc(@"OK")
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action)
                             {
                                 [alert dismissViewControllerAnimated:YES completion:nil];
                             }];
        [alert addAction:ok];
        [vc presentViewController:alert animated:YES completion:nil];

        return;
    }
    
    NSArray* parts = [QR_result componentsSeparatedByString:@"#"];
    if([parts[1] isEqualToString:@"v1"])
    {
        NSString* clinicId = parts[2];
        NSString* clinicName = parts[3];
        NSString* clinicUrl = parts[4];
        NSString* doctorId = nil;
        NSString* doctorName = nil;
        if(parts.count > 6)
        {
            doctorId = parts[5];
            doctorName = parts[6];
        }
        NSString* andDoctorMessage = @"";
        if(doctorName != nil)
        {
            andDoctorMessage = [NSString stringWithFormat:@" %@ %@",loc(@"and"), doctorName];
        }
        UIAlertController * alert=   [UIAlertController
                                      alertControllerWithTitle:clinicName
                                      message:[NSString stringWithFormat:@"%@ %@?",loc(@"Are_you_sure_you_want_to_join_this_clinic"),andDoctorMessage]
                                      preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* ok = [UIAlertAction
                             actionWithTitle:loc(@"Join")
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action)
                             {
                                 [alert dismissViewControllerAnimated:YES completion:nil];
                                 
                                 NSString* url = [NSString stringWithFormat:@"/patients/%@/add_to_clinic",[self getPatientId]];
                                 
                                 NSMutableDictionary* params = [[NSMutableDictionary alloc] init];
                                 
                                 [params setObject:clinicId forKey:@"clinic_id"];
                                 if(doctorId != nil)
                                     [params setObject:doctorId forKey:@"doctor_id"];
                                 
                                 [afNetworking POST:url parameters:params success:^void(NSURLSessionDataTask * task, NSDictionary* responseObject) {
                                     NSDictionary* dic = responseObject;
                                     NSLog(@"%@",dic);
                                     [self SaveProfile:dic];
                                     
                                     [[NSUserDefaults standardUserDefaults] setObject:clinicUrl forKey:server_url];
                                     [[NSUserDefaults standardUserDefaults] synchronize];
                                     [DataHandler_new InitializeNetwork];
                                     
                                 } failure:^void(NSURLSessionDataTask * task, NSError * error) {
                                     //NSLog(@"%@",error.description);
                                     NSString* msg = @"";//operation.HTTPRequestOperation.responseString;
                                     msg = [[NSString alloc] initWithData:error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] encoding:NSUTF8StringEncoding];
                                     NSLog(@"%@",msg);
                                 }];
                             }];
        UIAlertAction* cancel = [UIAlertAction
                                 actionWithTitle:loc(@"No")
                                 style:UIAlertActionStyleCancel
                                 handler:^(UIAlertAction * action)
                                 {
                                     [alert dismissViewControllerAnimated:YES completion:nil];
                                     
                                 }];
        
        [alert addAction:ok];
        [alert addAction:cancel];
        
        [vc presentViewController:alert animated:YES completion:nil];
    }
    
    
}


-(void)sendTreatmentDiaryEntryToServer:(TreatmentDiary*)t withCompletionBlock:(void (^)(NSDictionary*))completionBlock
{
    if(DLG.isConnectedVersion == NO) return;
    
    NSString* url = [NSString stringWithFormat:@"/treatment_diaries.json"];
    
    NSMutableDictionary* params = [[NSMutableDictionary alloc] init];
    
    [params setObject:[self getPatientId] forKey:@"patient_id"];
    [params setObject:[NSString stringWithFormat:@"%@",t.dosage] forKey:@"dosage"];
    [params setObject:[NSString stringWithFormat:@"%@",t.name] forKey:@"name"];
    [params setObject:[NSString stringWithFormat:@"%@",t.treatmentTypeId] forKey:@"treatment_type_id"];
    [params setObject:[NSString stringWithFormat:@"%@",t.dueDate] forKey:@"due_date"];
    [params setObject:[NSString stringWithFormat:@"%@",t.sampleId] forKey:@"sample_id"];
    [params setObject:[NSString stringWithFormat:@"%@",t.isDueDateEstimated] forKey:@"is_due_date_estimated"];
    
    [afNetworking POST:url parameters:params success:^void(NSURLSessionDataTask * task, NSDictionary* responseObject) {
        NSDictionary* dic = responseObject;
        if(completionBlock) completionBlock(dic);
    } failure:^void(NSURLSessionDataTask * task, NSError * error) {
        NSLog(@"%@",error.description);
        NSString* msg = @"";//operation.HTTPRequestOperation.responseString;
        msg = [[NSString alloc] initWithData:error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] encoding:NSUTF8StringEncoding];
        NSLog(@"%@",msg);
    }];
}

-(void)UpdateTreatmentDiaryEntryInServer:(TreatmentDiary*)t withCompletionBlock:(void (^)(NSDictionary*))completionBlock
{
    if(DLG.isConnectedVersion == NO) return;
    
    NSString* url = [NSString stringWithFormat:@"/treatment_diaries/%@.json", t.recordId];
    
    NSMutableDictionary* params = [[NSMutableDictionary alloc] init];
    
    [params setObject:[NSString stringWithFormat:@"%@",t.dosage] forKey:@"dosage"];
    [params setObject:[NSString stringWithFormat:@"%@",t.name] forKey:@"name"];
    [params setObject:[NSString stringWithFormat:@"%@",t.treatmentTypeId] forKey:@"treatment_type_id"];
    [params setObject:[NSString stringWithFormat:@"%@",t.dueDate] forKey:@"due_date"];
    [params setObject:[NSString stringWithFormat:@"%@",t.sampleId] forKey:@"sample_id"];
    [params setObject:[NSString stringWithFormat:@"%@",t.isDueDateEstimated] forKey:@"is_due_date_estimated"];
    
    [afNetworking PUT:url parameters:params success:^void(NSURLSessionDataTask * task, NSDictionary* responseObject) {
        //NSDictionary* dic = responseObject;//[NSJSONSerialization JSONObjectWithData:operation.HTTPRequestOperation.responseData options:NSJSONReadingMutableContainers error:nil];
        //NSLog(@"Measurement %@ updated", m.record_id);
        if(((NSHTTPURLResponse*)task.response).statusCode == 204)
        {
            if(completionBlock) completionBlock(responseObject);
        }
        else if(((NSHTTPURLResponse*)task.response).statusCode == 200)
        {
            if(completionBlock) completionBlock(responseObject);
        }
    } failure:^void(NSURLSessionDataTask * task, NSError * error) {
        NSLog(@"%@",error.description);
    }];
    
}
@end
