//
//  DataHandler_new.h
//  GlucoMe - Mobile
//
//  Created by dovi winberger on 5/19/15.
//  Copyright (c) 2015 Yiftah Ben Aharon. All rights reserved.
//
//  This class handles communication with the server

#import <Foundation/Foundation.h>
#import "Measurement_helper.h"
#import "Alert_helper.h"
#import "AlertType_helper.h"
#import "MediaType_helper.h"
#import "Fact_helper.h"
#import "Friend_helper.h"
#import "HealthKitHelper.h"
#import "AFNetworking.h"
#import "Treatment_helper.h"
#import "TreatmentDiary.h"
#import "Reachability.h"

typedef void (^DHCompletionBlock)(BOOL success);



@interface DataHandler_new : NSObject
{
    HealthKitHelper* hk;
    AFHTTPSessionManager* afNetworking;
    NetworkStatus lastNetworkStatus;
}

@property (nonatomic) Reachability *hostReachability;

+(DataHandler_new*)getInstance;
@property (nonatomic, readonly) AFHTTPSessionManager* afNetworking;

-(void)setAuthentication_token:(NSString*)authentication_token;
-(void)setPatientId:(NSString*)patientId;
-(NSString*)getPatientId;
-(NSNumber*)getPatientIdAsNumber;

-(void)GetUserMeasurementsFromServer;
-(void)GetFriendMeasurementsFromServer:(NSNumber*)friend_id;
-(void)sendMeasurementToServer:(Measurement*)m withCompletionBlock:(void (^)(NSDictionary*))completionBlock;
-(void)UpdateMeasurementInServer:(Measurement*)m withCompletionBlock:(void (^)(NSDictionary*))completionBlock;


-(void)sendAlertToServer:(Alert*)a withCompletionBlock:(void (^)(NSDictionary*))completionBlock;
-(void)deleteAlert:(int)alertId withCompletionBlock:(void (^)(void))completionBlock;

-(int)GetStrips;
-(void)DeductOneStrip;
-(void)UpdateStrips:(int)number;
-(void)RefreshFact;

-(void)GetProfileFromServerWithCompletionBlock:(void (^)())completionBlock;
-(void)sendProfileToServer;
-(NSString*)getEmail;
-(void)resetPassword:(NSString*)email;
-(void)ResendConfirmationEmail:(NSString*)email;

-(void)Logout;
-(void)ClearUserData;
-(void)SetDefaultData;

-(void)PostDevice;
-(void)SendLocaleToServer;

//friends
-(void)FindFriendIdByEmail:(NSString*)email withCompletionBlock:(void (^)(NSDictionary*))completionBlock;
-(void)sendFriendToServer:(Friend*)f withCompletionBlock:(void (^)(NSDictionary*))completionBlock;
-(void)DeleteFriend:(long)recordId;
-(void)FilterFriend:(long)friendId isFiltered:(BOOL)isFiltered;

//clinics
-(void)ConnectMeToClinicWithQR_result:(NSString*)QR_result viewController:(UIViewController*)vc;
-(void)DisconnectFromClinic:(UIViewController*)vc;

//treatment diary
-(void)sendTreatmentDiaryEntryToServer:(TreatmentDiary*)t withCompletionBlock:(void (^)(NSDictionary*))completionBlock;
-(void)UpdateTreatmentDiaryEntryInServer:(TreatmentDiary*)t withCompletionBlock:(void (^)(NSDictionary*))completionBlock;
@end
