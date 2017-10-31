//
//  TrendChart.m
//  GlucoMe - Mobile
//
//  Created by dovi winberger on 5/5/15.
//  Copyright (c) 2015 Yiftah Ben Aharon. All rights reserved.
//

#import "TrendChart.h"
#import <ShinobiCharts/ShinobiChart.h>
#import <ShinobiCharts/SChartCanvas.h>
#import <ShinobiCharts/SChartCanvasOverlay.h>
#import "general.h"
#import "Measurement_helper.h"
#import "FullChartCrosshairTooltip.h"

@implementation SChartCanvasOverlay (LongPress)

-(void)changeLongPressDelay:(CFTimeInterval)time
{
     [longPressGesture setMinimumPressDuration:time];
}
@end

@implementation TrendChart


-(id)initWithFrame:(CGRect)frame andMode:(TrendChartMode)mode forPatient_id:(NSNumber*)_patient_id
{
    self = [super initWithFrame:frame];
    if(self)
    {
        patient_id = _patient_id;
        _mode = mode;
        
        if(_mode == smallTrendChartMode)
            [self initSmallChart];
        else if(_mode == bigTrendChartMode)
            [self initBigChart];
    }
    return self;
}



- (void) initBigChart
{
    SChartDateTimeAxis *xAxis = [[SChartDateTimeAxis alloc] init];
    
    SChartRange* range = [[SChartRange alloc] initWithMinimum:@(0) andMaximum:[[UnitsManager getInstance] GetGlucoseValueForCurrentUnit:350]];
    SChartNumberAxis *yAxis = [[SChartNumberAxis alloc] initWithRange:(SChartNumberRange*)range];
    yAxis.rangePaddingLow = @(30);
    yAxis.rangePaddingHigh = @(30);
    yAxis.style.majorGridLineStyle.showMajorGridLines = YES;
    yAxis.style.majorGridLineStyle.lineColor = GRAY;
    yAxis.style.majorGridLineStyle.lineWidth = @(1);
    yAxis.anchorPoint = @(0);
    
    // enable gestures
    yAxis.enableGesturePanning = YES;
    yAxis.enableGestureZooming = YES;
    xAxis.enableGesturePanning = YES;
    xAxis.enableGestureZooming = YES;
    xAxis.rangePaddingHigh = [SChartDateFrequency dateFrequencyWithDay:(1)];
    xAxis.rangePaddingLow = [SChartDateFrequency dateFrequencyWithDay:(1)];
    
    self.xAxis = xAxis;
    self.yAxis = yAxis;
    self.gestureDoubleTapResetsZoom = YES;
    [self applyTheme:[SChartLightTheme new]];
    
    [self.canvas.overlay changeLongPressDelay:0.1];
    
    double upperLimit = 130;
    double lowerLimit = 70;
    
    
    NSString* upperStr = [[NSUserDefaults standardUserDefaults] objectForKey:profile_pre_meal_target];
    if(upperStr != nil) {
        upperLimit = [upperStr intValue];
    }
    NSString* lowerStr = [[NSUserDefaults standardUserDefaults] objectForKey:profile_hypo_threshold];
    if(lowerStr != nil) {
        lowerLimit = [lowerStr intValue];
    }
    
    lowerLimit = [[[UnitsManager getInstance] GetGlucoseValueForCurrentUnit:lowerLimit] doubleValue];
    upperLimit = [[[UnitsManager getInstance] GetGlucoseValueForCurrentUnit:upperLimit] doubleValue];
    
    SChartAnnotation* a1 = [SChartAnnotation horizontalBandAtPosition:@0 andMaxY:@(lowerLimit) withXAxis:xAxis andYAxis:yAxis withColor:BLUE];
    a1.position = SChartAnnotationBelowData;
    SChartAnnotation* a2 = [SChartAnnotation horizontalBandAtPosition:@(lowerLimit) andMaxY:@(upperLimit) withXAxis:xAxis andYAxis:yAxis withColor:GREEN];
    a2.position = SChartAnnotationBelowData;
    SChartAnnotation* a3 = [SChartAnnotation horizontalBandAtPosition:@(upperLimit) andMaxY:@(upperLimit*MAX_TOLERANCE) withXAxis:xAxis andYAxis:yAxis withColor:YELLOW];
    a3.position = SChartAnnotationBelowData;
    SChartAnnotation* a4 = [SChartAnnotation horizontalBandAtPosition:@(upperLimit*MAX_TOLERANCE) andMaxY:@2000 withXAxis:xAxis andYAxis:yAxis withColor:RED];
    a4.position = SChartAnnotationBelowData;
    
    
    [self addAnnotation:a1];
    [self addAnnotation:a2];
    [self addAnnotation:a3];
    [self addAnnotation:a4];
    
    SChartCrosshair *mySubclass = [[SChartCrosshair alloc] initWithChart:self];
    mySubclass.interpolatePoints = NO;
//    mySubclass.style =
    mySubclass.tooltip = [[FullChartCrosshairTooltip alloc] init];
    self.crosshair = mySubclass;
    
    
    self.datasource = self;
    [self UpdateChartWithTags:nil andDaysAgo:7];
}

- (void) initSmallChart
{
    self.backgroundColor = TRANSPARENT;
    
    SChartDateTimeAxis *xAxis = [[SChartDateTimeAxis alloc] init];
    self.xAxis = xAxis;
    self.xAxis.style.majorGridLineStyle.showMajorGridLines = NO;
    self.xAxis.style.lineWidth = @0;
    self.xAxis.style.majorTickStyle.showLabels = NO;
    self.xAxis.style.majorTickStyle.showTicks  = NO;
    
    
    
    SChartNumberAxis *yAxis = [[SChartNumberAxis alloc] init];
    self.yAxis = yAxis;
    self.yAxis.style.majorGridLineStyle.showMajorGridLines = NO;
    self.yAxis.style.lineWidth = @0;
    self.yAxis.style.majorTickStyle.showLabels = NO;
    self.yAxis.style.majorTickStyle.showTicks  = NO;
    self.yAxis.style.minorTickStyle.showLabels = NO;
    self.yAxis.style.minorTickStyle.showTicks  = NO;
    
    
    self.datasource = self;
    [self UpdateChartWithTags:nil andDaysAgo:7];
}

-(BOOL)UpdateChartWithTags:(NSArray*)tags andDaysAgo:(int)daysAgo
{
    
    NSArray* allMeasurements = [Measurement GetAllMeasurementsFromDate:[[NSDate dateWithDaysBeforeNow:daysAgo] dateAtStartOfDay] andTags:tags measurementType:glucoseMeasurementType forPatient_id:patient_id];
    chartData = [NSMutableArray arrayWithArray:allMeasurements];
    
    [self reloadData];
    [self redrawChart];
    
    if(chartData.count > 0) return YES;
    else return NO;
}


- (NSInteger)numberOfSeriesInSChart:(ShinobiChart *)chart {
    if (chartData.count == 0) {
        return 0;
    }
    return 1;
}

-(SChartSeries *)sChart:(ShinobiChart *)chart seriesAtIndex:(NSInteger)index
{

    if(self.mode == smallTrendChartMode)
    {
        SChartLineSeries *lineSeries = [[SChartLineSeries alloc] init];
        lineSeries.style.showFill = YES;
        lineSeries.style.areaLineWidth = @3;
        lineSeries.style.areaLineColor = BLUE;
        lineSeries.style.areaColor = [UIColor colorWithRed:(149/255.0) green:(217/255.0) blue:(243/255.0)alpha:1];
        lineSeries.style.areaColorLowGradient = [UIColor colorWithRed:(149/255.0) green:(217/255.0) blue:(243/255.0)alpha:1];
        
        return lineSeries;
    }
    else
    {
        SChartLineSeries *lineSeries = [[SChartLineSeries alloc] init];
        lineSeries.crosshairEnabled = YES;
        SChartLineSeriesStyle* style = (SChartLineSeriesStyle*)lineSeries._style;
        style.lineColor = WHITE;
        style.lineWidth = [NSNumber numberWithInt:3];
        style.pointStyle =  [SChartPointStyle new];
        style.pointStyle.showPoints = YES;
        style.pointStyle.color = GRAY;
        style.pointStyle.radius = @(10);
        style.pointStyle.innerRadius = @(5);
        style.pointStyle.innerColor = WHITE;
        
        return lineSeries;
    }
}

- (NSInteger)sChart:(ShinobiChart *)chart numberOfDataPointsForSeriesAtIndex:(NSInteger)seriesIndex {
    return chartData.count;
}

- (id<SChartData>)sChart:(ShinobiChart *)chart dataPointAtIndex:(NSInteger)dataIndex forSeriesAtIndex:(NSInteger)seriesIndex
{
    SChartDataPoint *datapoint = [[SChartDataPoint alloc] init];
    Measurement* m = [chartData objectAtIndex:dataIndex];
    if(m.date != nil && m.value != nil)
    {
        datapoint.xValue = m.date;
        datapoint.yValue = [[UnitsManager getInstance] GetGlucoseStringValueForCurrentUnit:[m.value intValue]];
    }
    else
    {
        datapoint.xValue = [NSDate date];
        datapoint.yValue = @(0);
        NSLog(@"Wrong dataaaa");
    }
    return datapoint;
}


@end
