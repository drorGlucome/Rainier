//
//  MediaType_helper.h
//  GlucoMe - Mobile
//
//  Created by dovi winberger on 5/20/15.
//  Copyright (c) 2015 Yiftah Ben Aharon. All rights reserved.
//
//this class is the local DB treatment table
#import <Foundation/Foundation.h>
#import "Treatment.h"
@interface Treatment(helper)

+(NSArray*)LastTreatmentsGroup;
+(BOOL)IsTreatmentAvailable;
+(NSArray*)AllTreatmentsGrouped;


+(void)AddNewTreatment:(NSArray*)treatments;

-(int)daypartToApproximateHour;

+(Treatment*)GetBasal;
+(Treatment*)GetBolusMorning;
+(Treatment*)GetBolusNoon;
+(Treatment*)GetBolusEvening;

@end
