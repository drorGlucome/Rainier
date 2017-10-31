//
//  PieChart.h
//  GlucoMe - Mobile
//
//  Created by dovi winberger on 5/5/15.
//  Copyright (c) 2015 Yiftah Ben Aharon. All rights reserved.
//

#import <UIKit/UIKit.h>

//#import <ShinobiCharts/ShinobiChart.h>
#import "PieData.h"

typedef enum PieChartMode {smallPieChartMode, bigPieChartMode} PieChartMode;

@protocol PieChartDelegateProtocol <NSObject>

-(void)SectionSelected:(int)section;//0 low, 1 normal, 2 high, 3 very high

@end

@interface PieChart : ShinobiChart <SChartDelegate>
{
    NSNumber* patient_id;
    PieData* data;
}

@property (weak, nonatomic) id<PieChartDelegateProtocol> myDelegate;

@property (nonatomic) PieChartMode mode;

-(id)initWithPatient_id:(NSNumber*)_patient_id;
-(id)initWithFrame:(CGRect)frame forPatient_id:(NSNumber*)_patient_id;

-(BOOL)UpdateChartWithTags:(NSArray*)tags andDaysAgo:(int)daysAgo;
-(void)ShowLabels:(BOOL)show;
- (UIColor*) getLeadingColor;
@end
