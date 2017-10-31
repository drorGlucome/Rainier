//
//  PieData.m
//  GlucoMe - Mobile
//
//  Created by Yiftah Ben Aharon on 8/14/14.
//  Copyright (c) 2014 Yiftah Ben Aharon. All rights reserved.
//

#import "PieData.h"
#import "general.h"
#import "Measurement_helper.h"


@implementation PieData
@synthesize hideLabels;



- (NSInteger)sChart:(ShinobiChart *)chart numberOfDataPointsForSeriesAtIndex:(NSInteger)seriesIndex {
    return pieData.count;
}

// Returns the series at the specified index for a given chart
-(SChartSeries *)sChart:(ShinobiChart *)chart seriesAtIndex:(NSInteger)index {
    
    
    SChartPieSeries *series = [[SChartPieSeries alloc] init];
    series.selectedStyle.labelFontColor = [UIColor blackColor];
    series.selectedPosition = [NSNumber numberWithInt: 0];
    series.style.flavourColors = pieColors;
    series.selectedStyle.flavourColors = pieColors;
    series.selectedStyle.showLabels = !hideLabels;
    series.style.labelFont  = [UIFont fontWithName:@"HelveticaNeue-Thin" size:14];
    series.style.showLabels = !hideLabels;
    return series;
}

// Returns the number of series in the specified chart
- (NSInteger)numberOfSeriesInSChart:(ShinobiChart *)chart {
    return 1;
}

// Returns the data point at the specified index for the given series/chart.
- (id<SChartData>)sChart:(ShinobiChart *)chart dataPointAtIndex:(NSInteger)dataIndex forSeriesAtIndex:(NSInteger)seriesIndex {
    
    // Construct a data point to return
    SChartRadialDataPoint *datapoint = [[SChartRadialDataPoint alloc] init];
    
    // Give the data point a name
    
    datapoint.name = [[NSString alloc] initWithFormat:@"%@ (%@)", [pieLabels objectAtIndex:dataIndex], [pieData objectAtIndex:dataIndex] ];
    
    // Give the data point a value
    datapoint.value = (NSNumber*)[pieData objectAtIndex:dataIndex];
    
    return datapoint;
}


/*-(void)sChart:(ShinobiChart *)chart alterLabel:(UILabel *)label forDatapoint:(SChartDataPoint *)datapoint atSliceIndex:(NSInteger)index inRadialSeries:(SChartRadialSeries*)series
 
 {
 SChartRadialDataPoint* point = (SChartRadialDataPoint*)datapoint;
 [label setText:point.name];
 [label setTextColor:[UIColor blackColor]];
 [label sizeToFit];
 [label setHidden:hideLabels];
 
 
 }*/


- (BOOL) updateChartData:(NSArray*)tags daysBack:(int)daysBack forPatient_id:(NSNumber*)patient_id
{
    pieData = [[NSMutableArray alloc] initWithObjects:@(0),@(0),@(0), @(0), nil];
    pieLabels = [[NSMutableArray alloc] initWithObjects:loc(@"Low"), loc(@"Normal"),loc(@"High"), loc(@"Very_high"),nil];
    pieColors = [[NSMutableArray alloc] initWithObjects:BLUE, GREEN, YELLOW, RED, nil];
    
    NSArray* allMeasurements = [Measurement GetAllMeasurementsFromDate:[[NSDate dateWithDaysBeforeNow:daysBack] dateAtStartOfDay] andTags:tags measurementType:glucoseMeasurementType forPatient_id:patient_id];
    for(Measurement* m in allMeasurements)
    {
        NSNumber* value = m.value;
        glucose_type type = glucoseToType([value intValue], [m GetFirstTagID]);
        
        NSNumber* number = (NSNumber*)[pieData objectAtIndex:type];
        number = [NSNumber numberWithInt:[number intValue] + 1];
        [pieData setObject:number atIndexedSubscript:type];

    }
    
    
    for(int i=(int)pieData.count-1; i>=0 ;i--) {
        NSNumber* tmp = (NSNumber*)[pieData objectAtIndex:i];
        if(tmp.intValue == 0) {
            [pieData removeObjectAtIndex:i];
            [pieLabels removeObjectAtIndex:i];
            [pieColors removeObjectAtIndex:i];
        }
    }
    
    if(allMeasurements.count > 0) return YES;
    else return NO;
}


- (UIColor*) getLeadingColor {
    UIColor* res = YELLOW;
    NSNumber* max = @0;
    for(int i=0;i<pieData.count;i++) {
        NSNumber* tmp = [pieData objectAtIndex:i];
        if ( tmp > max) {
            max = tmp;
            res = [pieColors objectAtIndex:i];
        }
    }
    return res;
}


@end
