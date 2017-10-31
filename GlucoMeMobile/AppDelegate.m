//
//  AppDelegate.m
//  GlucoMe - Mobile
//
//  Created by Yiftah Ben Aharon on 1/9/14.
//  Copyright (c) 2014 Yiftah Ben Aharon. All rights reserved.
//

#import "AppDelegate.h"
#import "AFNetworking.h"
#import "general.h"
#import "RegistrationWizardViewController.h"
#import "ProfileViewController.h"
#import "GAI.h"
#import "GAIFields.h"
#import "DataHandler_new.h"
#import "Tag_helper.h"
#import "Treatment_helper.h"
#import "SingleMeasurementViewController.h"
#import "TreatmentDiary.h"
#import <HockeySDK/HockeySDK.h>
NSString * const NotificationTreatmentCategory  = @"TREATMENT";
NSString * const NotificationTreatmentActionView = @"VIEW";
NSString * const NotificationMeasureReminderAfter2Hours = @"MeasureReminderAfter2Hours";
NSString * const NotificationMeasureReminderAfterNonactiveLongTime = @"MeasureReminderAfterNonactiveLongTime";
NSString * const NotificationAddAlertReminder = @"AddAlertReminder";
NSString * const NotificationTreatmentDiaryEntry = @"TreatmentDiaryEntry";

@interface AppDelegate() <UIAlertViewDelegate, BITHockeyManagerDelegate>

@end

@implementation AppDelegate
@synthesize isConnectedVersion;


int const ViewTreatmentAlertTag = 5;


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    isConnectedVersion = YES;
    
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    
    [[BITHockeyManager sharedHockeyManager] configureWithIdentifier:@"f23ff6d719e94b94b383bba191d9d5a0"]; // Do some additional configuration if needed here
    [[BITHockeyManager sharedHockeyManager].crashManager setCrashManagerStatus: BITCrashManagerStatusAutoSend];
    [BITHockeyManager sharedHockeyManager].delegate = self;
    [[BITHockeyManager sharedHockeyManager] startManager];

    [TreatmentDiary RegisterForMeasurementsChanges];

    if([[NSUserDefaults standardUserDefaults] stringForKey:@"uuid"] == nil)
    {
        NSString* uuid = [[NSUUID alloc] init].UUIDString;
        [[NSUserDefaults standardUserDefaults] setObject:uuid forKey:@"uuid"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"firstRunDate"] == nil)
    {
        [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:@"firstRunDate"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"numberOfRuns"] == nil)
    {
        [[NSUserDefaults standardUserDefaults] setObject:@(0) forKey:@"numberOfRuns"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    else
    {
        NSNumber* numberOfRuns = (NSNumber*)[[NSUserDefaults standardUserDefaults] objectForKey:@"numberOfRuns"];
        [[NSUserDefaults standardUserDefaults] setObject:@([numberOfRuns integerValue]+1) forKey:@"numberOfRuns"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    //[Crittercism enableWithAppID:@"53a7207db573f14665000002"];
    
    [MagicalRecord setupCoreDataStackWithAutoMigratingSqliteStoreNamed:@"GlucoMeModel"];
    [MagicalRecord setLoggingLevel:MagicalRecordLoggingLevelOff];
    
    [self InitTagsDB];
    
    //[Crittercism setUsername:[[DataHandler_new getInstance] getEmail]];
    [[DataHandler_new getInstance] SendLocaleToServer];
   
    
    [self initAnalytics];
    
    // Let the device know we want to receive push notifications
    [self registerForNotifications];
    
    [TreatmentDiary UpdateTreatmentDiary];
    
    //force old versions to register
    NSPredicate* p = [NSPredicate predicateWithFormat:@"patient_id = 0"];
    if([Measurement MR_findFirstWithPredicate:p inContext:[NSManagedObjectContext MR_defaultContext]])
    {
        [ProfileViewController Logout];
    }
    
    [self HandleNonactiveNotification];
    
    [self CreateActionsForTreatmentDiaryNotifications];
    
    return YES;
}

- (NSString *)userEmailForHockeyManager:(BITHockeyManager *)hockeyManager componentManager:(BITHockeyBaseManager *)componentManager
{
    return [[NSUserDefaults standardUserDefaults] stringForKey:profile_email];
}
- (NSString *)userIDForHockeyManager:(BITHockeyManager *)hockeyManager componentManager:(BITHockeyBaseManager *)componentManager
{
    return [[NSUserDefaults standardUserDefaults] stringForKey:profile_id];
}
-(void)CreateActionsForTreatmentDiaryNotifications
{
    UIMutableUserNotificationAction* showAction = [[UIMutableUserNotificationAction alloc] init];
    showAction.identifier = @"SHOW_ACTION";
    showAction.title = @"Show";
    showAction.activationMode = UIUserNotificationActivationModeForeground;
    showAction.destructive = NO;
    
    UIMutableUserNotificationAction* dismissAction = [[UIMutableUserNotificationAction alloc] init];
    dismissAction.identifier = @"DISMISS_ACTION";
    dismissAction.title = loc(@"Dismiss");
    dismissAction.activationMode = UIUserNotificationActivationModeBackground;
    dismissAction.authenticationRequired = NO;
    dismissAction.destructive = NO;
    
    UIMutableUserNotificationAction* postponeAction = [[UIMutableUserNotificationAction alloc] init];
    postponeAction.identifier = @"POSTPONE_ACTION";
    postponeAction.title = @"Postpone +1h";
    postponeAction.activationMode = UIUserNotificationActivationModeBackground;
    postponeAction.authenticationRequired = NO;
    postponeAction.destructive = NO;
    
    // Category
    UIMutableUserNotificationCategory* counterCategory = [[UIMutableUserNotificationCategory alloc] init];
    counterCategory.identifier = NotificationTreatmentDiaryEntry;
    
    // A. Set actions for the default context
    [counterCategory setActions:@[showAction, postponeAction, dismissAction]
                                forContext: UIUserNotificationActionContextDefault];
    
    // B. Set actions for the minimal context
    [counterCategory setActions:@[showAction, postponeAction]
                     forContext: UIUserNotificationActionContextMinimal];
    
    UIUserNotificationSettings* settings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert | UIUserNotificationTypeSound categories:[NSSet setWithObject:counterCategory]];
    [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
}
-(void)HandleNonactiveNotification
{
    UIApplication *app = [UIApplication sharedApplication];
    NSArray *eventArray = [app scheduledLocalNotifications];
    for (int i = 0; i < [eventArray count]; i++)
    {
        UILocalNotification* oneEvent = [eventArray objectAtIndex:i];
        NSString *category = oneEvent.category;
        if ([category isEqualToString:NotificationMeasureReminderAfterNonactiveLongTime])
        {
            //Cancelling local notification
            [app cancelLocalNotification:oneEvent];
            break;
        }
    }
    
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    notification.repeatInterval = 0;
    [notification setAlertBody:[NSString stringWithFormat:@"%@ %@",loc(@"A_reminder_to"), loc(@"Measure_glucose_level")]];
    [notification setCategory:NotificationMeasureReminderAfterNonactiveLongTime];
    [notification setFireDate:[NSDate dateWithTimeIntervalSinceNow:60*60*24*7]]; //1W
    [notification setTimeZone:[NSTimeZone  defaultTimeZone]];
    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
}


-(void)InitTagsDB
{
    //if (![[NSUserDefaults standardUserDefaults] boolForKey:@"didInitTagsDB"])
    {
        [Tag InitTags];
        
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"didInitTagsDB"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}
- (void) registerForNotifications {
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
    {
        //https://nrj.io/simple-interactive-notifications-in-ios-8/
        UIMutableUserNotificationAction *action1;
        action1 = [[UIMutableUserNotificationAction alloc] init];
        [action1 setActivationMode:UIUserNotificationActivationModeForeground];
        [action1 setTitle:loc(@"View")];
        [action1 setIdentifier:NotificationTreatmentActionView];
        [action1 setDestructive:NO];
        [action1 setAuthenticationRequired:NO];
        
        UIMutableUserNotificationCategory *actionCategory;
        actionCategory = [[UIMutableUserNotificationCategory alloc] init];
        [actionCategory setIdentifier:NotificationTreatmentCategory];
        [actionCategory setActions:@[action1]
                        forContext:UIUserNotificationActionContextDefault];
        
        NSSet *categories = [NSSet setWithObject:actionCategory];
        
        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:categories]];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    }
    else
    {
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
         (UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert)];
#pragma GCC diagnostic pop
    }

}
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    [[DataHandler_new getInstance] GetProfileFromServerWithCompletionBlock:nil];

}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [MagicalRecord cleanUp];
}

- (void) initAnalytics {
    // Optional: automatically send uncaught exceptions to Google Analytics.
    //[GAI sharedInstance].trackUncaughtExceptions = YES;
    
    // Optional: set Google Analytics dispatch interval to e.g. 20 seconds.
    [GAI sharedInstance].dispatchInterval = 20;
    
    // Initialize tracker. Replace with your tracking ID.
    [[GAI sharedInstance] trackerWithTrackingId:@"UA-51337142-1"];
    
    id tracker = [[GAI sharedInstance] defaultTracker];

    [tracker set:[GAIFields customDimensionForIndex:1] value:[[DataHandler_new getInstance] getEmail]];
}


- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{
    NSLog(@"My token is: %@", deviceToken);
    NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
    const unsigned *tokenBytes = [deviceToken bytes];
    NSString *hexToken = [NSString stringWithFormat:@"%08x%08x%08x%08x%08x%08x%08x%08x",
                          ntohl(tokenBytes[0]), ntohl(tokenBytes[1]), ntohl(tokenBytes[2]),
                          ntohl(tokenBytes[3]), ntohl(tokenBytes[4]), ntohl(tokenBytes[5]),
                          ntohl(tokenBytes[6]), ntohl(tokenBytes[7])];
    [dict setObject:hexToken forKey:@"notifications_token"];
    
    [[NSUserDefaults standardUserDefaults] setObject:hexToken forKey:profile_last_push_notifications_token];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [[DataHandler_new getInstance] PostDevice];
}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
    NSLog(@"Failed to get token, error: %@", error);
}


-(void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    UIApplicationState state = [application applicationState];
    if (state == UIApplicationStateInactive) {
        // Application was in the background when notification was delivered.
    } else {
        if([notification.category isEqualToString:NotificationMeasureReminderAfter2Hours] ||
           [notification.category isEqualToString:NotificationMeasureReminderAfterNonactiveLongTime])
        {
            UIAlertController* alert =[UIAlertController
                                       alertControllerWithTitle:loc(@"Reminder")
                                       message:notification.alertBody
                                       preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction* ok = [UIAlertAction
                                 actionWithTitle:loc(@"OK")
                                 style:UIAlertActionStyleDefault
                                 handler:^(UIAlertAction * action)
                                 {
                                     [alert dismissViewControllerAnimated:YES completion:nil];
                                 }];
            [alert addAction:ok];
            
            UIViewController *parentViewController = [self window].rootViewController;
            
            while (parentViewController.presentedViewController != nil){
                parentViewController = parentViewController.presentedViewController;
            }
            UIViewController *vc = parentViewController;
            [vc presentViewController:alert animated:YES completion:nil];
        }
    }
}

-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    if ([userInfo[@"aps"][@"category"] isEqualToString:NotificationTreatmentCategory]) {
        
        //pull new treatment from server:
        [[DataHandler_new getInstance] GetProfileFromServerWithCompletionBlock:^{
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:userInfo[@"aps"][@"alert"] message:@"" delegate:self cancelButtonTitle:loc(@"Not_now") otherButtonTitles:loc(@"View"), nil];
            alert.tag = ViewTreatmentAlertTag;
            [alert show];
        }];
        
    }
    
    completionHandler(UIBackgroundFetchResultNewData);
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView.tag == ViewTreatmentAlertTag)
    {
        if (buttonIndex == 1) {
            [self ShowTreatmentPage];
        }
    }
}

-(void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forLocalNotification:(UILocalNotification *)notification completionHandler:(void (^)())completionHandler
{

    if([notification.category isEqualToString:NotificationTreatmentDiaryEntry])
    {
        if([identifier isEqualToString:@"SHOW_ACTION"])
        {
            [self ShowTreatmentPage];
        }
        
        if([identifier isEqualToString:@"POSTPONE_ACTION"])
        {
            [notification setFireDate:[NSDate dateWithTimeIntervalSinceNow:60*60]];
            [[UIApplication sharedApplication] scheduleLocalNotification:notification];
        }
    }
    
    if (completionHandler) completionHandler();
}


- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo completionHandler:(void (^)())completionHandler
{
    if ([identifier isEqualToString:NotificationTreatmentActionView]) {
        [self ShowTreatmentPage];
    }

    if (completionHandler) completionHandler();
}

-(void)ShowTreatmentPage
{
    UINavigationController *nav = [[UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil] instantiateViewControllerWithIdentifier:@"TreatmentNavigationControllerID"];
    [self ShowViewControllerOnTopOfEverything:nav];
}

-(UIViewController*)GetTopViewController
{
    UIViewController *parentViewController = [self window].rootViewController;
    while (parentViewController.presentedViewController != nil){
        parentViewController = parentViewController.presentedViewController;
    }
    return parentViewController;
}
-(void)ShowViewControllerOnTopOfEverything:(UIViewController*)vc
{
    UIViewController *currentViewController = [self GetTopViewController];
    
    [currentViewController presentViewController:vc animated:YES completion:nil];
}
@end
