//
//  PieData.h
//  GlucoMe - Mobile
//
//  Created by Yiftah Ben Aharon on 8/14/14.
//  Copyright (c) 2014 Yiftah Ben Aharon. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <ShinobiCharts.h>
//#import <ShinobiCharts/ShinobiChart.h>


@interface PieData : NSObject <SChartDatasource> {
    NSMutableArray *pieData, *pieLabels, *pieColors;
}


- (BOOL) updateChartData:(NSArray*)tags daysBack:(int)daysBack forPatient_id:(NSNumber*)patient_id;
- (UIColor*) getLeadingColor;

@property bool hideLabels;

@end
