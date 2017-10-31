//
//  GaugeChage.h
//  GlucoMe - Mobile
//
//  Created by dovi winberger on 5/21/15.
//  Copyright (c) 2015 Yiftah Ben Aharon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ShinobiGauges.h>
//#import <ShinobiGauges/ShinobiGauges.h>


@interface GaugeChart : UIView
{
    NSNumber* patient_id;
    SGauge* gauge;
    UILabel* EHA1CLabel;
}

-(id)initWithPatient_id:(NSNumber*)_patient_id;
-(id)initWithFrame:(CGRect)frame withPatient_id:(NSNumber*)_patient_id;

    
-(BOOL)UpdateChartWithTags:(NSArray*)tags andDaysAgo:(int)daysAgo;

@end
