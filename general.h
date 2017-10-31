//
//  general.h
//  audioGraph
//
//  Created by Yiftah Ben Aharon on 9/11/12.
//
//

#ifndef audioGraph_general_h
#define audioGraph_general_h

#import "AppDelegate.h"



#define DLG ((AppDelegate*)[[UIApplication sharedApplication] delegate])

#define GREEN [UIColor colorWithRed:24/255.0 green:182/255.0 blue:61/255.0 alpha:1]
#define BLUE [UIColor colorWithRed:52/255.0 green:127/255.0 blue:174/255.0 alpha:1]
#define RED [UIColor colorWithRed:255/255.0 green:86/255.0 blue:105/255.0 alpha:1]
#define YELLOW [UIColor colorWithRed:246/255.0 green:166/255.0 blue:28/255.0 alpha:1]
#define GRAY [UIColor colorWithRed:113.0/255.0 green:113.0/255.0 blue:113.0/255.0 alpha:1]
#define TRANSPARENT [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0]
#define AZURE [UIColor colorWithRed:204.0/255.0 green:229.0/255.0 blue:238.0/255.0 alpha:1]
#define PURPLE [UIColor colorWithRed:153.0/255.0 green:102.0/255.0 blue:255.0/255.0 alpha:1]
#define BROWN [UIColor colorWithRed:179.0/255.0 green:50.0/255.0 blue:6.0/255.0 alpha:1]
#define LIGHT_GREEN [UIColor colorWithRed:163/255.0 green:211/255.0 blue:123/255.0 alpha:1]
#define WHITE [UIColor whiteColor]

#define RADIANS(degrees) ((degrees * M_PI) / 180.0)
#define TAGS_SEPARATOR @"|"

#define kCatchWidth  60

#define MIN_TOLERANCE  0.8
#define MAX_TOLERANCE  1.2

#define loc(key) [[NSBundle mainBundle] localizedStringForKey:(key) value:@"" table:nil]


#define PENDING @"pending"
#define LAST_DATA @"last"
#define LAST_SAMPLE_DATE @"lastDate"
#define LAST_PROFILE @"lastPorfile"

#define PENDING_REQUEST_METHOD  @"method"
#define PENDING_REQUEST_URL  @"url"
#define PENDING_REQUEST_PARAMS  @"params"
#define PENDING_REQUEST_UID  @"uid"

typedef enum glucose_type {glucose_low, glucose_normal, glucose_high, glucose_very_high} glucose_type;
typedef enum MeasurementType {glucoseMeasurementType, medicineMeasurementType, foodMeasurementType, activityMeasurementType, weightMeasurementType} MeasurementType;

NSString* rails2iosTimeFromDate(NSDate* date);
//NSString* rails2iosTime(NSString* d);
NSString* rails2iosDateFromDate(NSDate* date);
//NSString* rails2iosDate(NSString* d);
NSDate* rails2iosNSDate(NSString* d);
NSString* NSDate2rails(NSDate* date);


NSInteger binarySearchForFontSizeForLabel(UILabel * label, NSInteger minFontSize, NSInteger maxFontSize);

glucose_type glucoseToType(int glucose, int tag);//always mg/dl   //0-low, 1-normal, 2-high, 3-very high
UIColor* glucoseToColor(int glucose, int tag);
UIColor* foodToColor(int value);
UIColor* activityToColor(int value);
UIColor* weightToColor(int value);
UIColor* stripsToColor(NSString* strips);
UIColor* rateToColor(NSNumber* rate);
UIColor* EHA1CToColor(NSNumber* value);
UIColor* remindersToColor(NSString* rate);
UIColor* measurementsToColor(NSString* rate);
UIColor* socialPositionToColor(int position, int numberOfPeople);
void gassert(bool cond, NSString* msg);
void breadcrumb(NSString* msg);

NSString* NumberToFact(int i);

NSString* RelativeDate(NSDate* date);
NSString* HourAsComponentOfDay(int h);

#define profile_email       @"profile_email"
#define profile_id          @"profile_id"
#define profile_authentication_token          @"profile_authentication_token"
#define profile_first_name  @"profile_first_name"
#define profile_last_name   @"profile_last_name"
#define profile_diabetes_type  @"profile_diabetes_type"
#define profile_height      @"profile_height"
#define profile_weight      @"profile_weight"
#define profile_lower_limit @"profile_lower_limit"
#define profile_upper_limit @"profile_upper_limit"
#define profile_daily_measurements @"profile_daily_measurements"
#define profile_strips      @"profile_strips"
#define profile_glucose_units @"profile_glucose_units"
#define profile_uidArray    @"profile_uidArray"
#define profile_score       @"profile_score"
#define profile_pre_meal_target                 @"profile_pre_meal_target"
#define profile_post_meal_target                @"profile_post_meal_target"
#define profile_hypo_threshold                 @"profile_hypo_threshold"
#define profile_suspected_hypo_threshold       @"profile_suspected_hypo_threshold"
#define profile_sever_hypo_threshold           @"profile_sever_hypo_threshold"

#define profile_clinic_name  @"profile_clinic_name"
#define profile_clinic_id  @"profile_clinic_id"

#define profile_doctor_name  @"profile_doctor_name"
#define profile_doctor_id  @"profile_doctor_id"
#define profile_correction_factor @"correction_factor"

#define default_profile_pre_meal_target             130
#define default_profile_post_meal_target            160
#define default_profile_hypo_threshold             60
#define default_profile_suspected_hypo_threshold   90
#define default_profile_sever_hypo_threshold       40
#define default_profile_lower_limit 70
#define default_profile_upper_limit 130
#define default_profile_strips 50

#define usability_test_mode @"usability_test_mode"
#define show_beta_features_boolean @"show_beta_features_boolean"
#define server_url @"server_url"


#define profile_last_push_notifications_token      @"profile_last_push_notifications_token"

#define SDKVersionKey      @"SDKVersionKey"



#define BASAL_TAG_ID            50
#define BOLUS_MORNING_TAG_ID    51
#define BOLUS_NOON_TAG_ID       52
#define BOLUS_EVENING_TAG_ID    53
#define PILLS_TAG_ID            54
#define OPEN_BOLUS_TAG_ID       99
#endif
