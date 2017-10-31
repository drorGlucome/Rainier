//
//  TrendChart.h
//  GlucoMe - Mobile
//
//  Created by dovi winberger on 5/5/15.
//  Copyright (c) 2015 Yiftah Ben Aharon. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <ShinobiCharts.h>
//#import <ShinobiCharts/ShinobiChart.h>

typedef enum TrendChartMode {smallTrendChartMode, bigTrendChartMode} TrendChartMode;

@interface TrendChart : ShinobiChart <SChartDatasource>
{
    NSNumber* patient_id;
    NSMutableArray* chartData;
}

-(id)initWithFrame:(CGRect)frame andMode:(TrendChartMode)mode forPatient_id:(NSNumber*)patient_id;

@property (nonatomic, readonly) TrendChartMode mode;
-(BOOL)UpdateChartWithTags:(NSArray*)tags andDaysAgo:(int)daysAgo;

@end
