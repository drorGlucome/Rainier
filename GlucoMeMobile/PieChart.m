//
//  PieChart.m
//  GlucoMe - Mobile
//
//  Created by dovi winberger on 5/5/15.
//  Copyright (c) 2015 Yiftah Ben Aharon. All rights reserved.
//


#import "PieChart.h"
#import "general.h"

@implementation PieChart

-(id)initWithPatient_id:(NSNumber*)_patient_id
{
    self = [super init];
    if(self)
    {
        patient_id = _patient_id;
        [self setup];
    }
    return self;
}
-(id)initWithFrame:(CGRect)frame forPatient_id:(NSNumber*)_patient_id
{
    self = [super initWithFrame:frame];
    if(self)
    {
        patient_id = _patient_id;
        [self setup];
    }
    return self;
}

-(void)setup
{
    
    self.mode = smallPieChartMode;
    
}
-(void)setMode:(PieChartMode)mode
{
    _mode = mode;
    
    if(mode == smallPieChartMode)
        [self initSmallChart];
    else
        [self initBigChart];
}

-(void)initBigChart
{
    data = [[PieData alloc] init];
    
    SChartNumberAxis *xAxis = [[SChartNumberAxis alloc] init];
    SChartNumberAxis *yAxis = [[SChartNumberAxis alloc] init];
    
    
    self.xAxis = xAxis;
    self.yAxis = yAxis;
    
    self.backgroundColor = [UIColor clearColor];
    self.plotAreaBackgroundColor = [UIColor clearColor];
    self.canvasAreaBackgroundColor = [UIColor clearColor];
    data.hideLabels = YES;
    self.legend.hidden = NO;
    SChartLegendStyle* lStyle = [[SChartLegendStyle alloc] init];
    [lStyle setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:10.0]];
    lStyle.borderWidth = @0;
    lStyle.borderColor = TRANSPARENT;
    lStyle.symbolAlignment = SChartSeriesLegendAlignSymbolsLeft;
    lStyle.marginWidth = @0;
    self.legend.style = lStyle;
    self.legend.placement = SChartLegendPlacementOutsidePlotArea;
    self.legend.position = SChartLegendPositionBottomMiddle;
    self.legend.clipsToBounds = YES;
    self.datasource = data;
    self.delegate = self;
    
    [data updateChartData:nil daysBack:7 forPatient_id:patient_id];
    
    [self reloadData];
    [self redrawChart];
}

-(void)initSmallChart
{
    data = [[PieData alloc] init];
    data.hideLabels = YES;
    
    SChartNumberAxis *xAxis = [[SChartNumberAxis alloc] init];
    SChartNumberAxis *yAxis = [[SChartNumberAxis alloc] init];
    
    self.xAxis = xAxis;
    self.yAxis = yAxis;
    
    self.backgroundColor = [UIColor clearColor];
    self.plotAreaBackgroundColor = [UIColor clearColor];
    self.canvasAreaBackgroundColor = [UIColor clearColor];
    self.legend.hidden = YES;
    self.legend.placement = SChartLegendPlacementOnPlotAreaBorder;
    self.legend.position = SChartLegendPositionTopMiddle;
    
    self.datasource = data;
    //self.delegate = self;
    
    [data updateChartData:nil daysBack:7 forPatient_id:patient_id];
    
    [self reloadData];
    [self redrawChart];
}

- (UIColor*) getLeadingColor {
    return [data getLeadingColor];
}

-(void)ShowLabels:(BOOL)show
{
    data.hideLabels = !show;
}

-(BOOL)UpdateChartWithTags:(NSArray*)tags andDaysAgo:(int)daysAgo
{
    BOOL anyData = [data updateChartData:tags daysBack:daysAgo forPatient_id:patient_id];
    [self reloadData];
    [self redrawChart];
    
    return anyData;    
}


- (void)sChart:(ShinobiChart *)chart toggledSelectionForRadialPoint:(SChartRadialDataPoint *)dataPoint inSeries:(SChartRadialSeries *)series
atPixelCoordinate:(CGPoint)pixelPoint
{
    if([dataPoint.name localizedCaseInsensitiveContainsString:@"low"])
    {
        [self.myDelegate SectionSelected:0];
    }
    else if([dataPoint.name localizedCaseInsensitiveContainsString:@"normal"])
    {
        [self.myDelegate SectionSelected:1];
    }
    else if([dataPoint.name localizedCaseInsensitiveContainsString:@"very high"])
    {
        [self.myDelegate SectionSelected:3];
    }
    else
    {
        //high
        [self.myDelegate SectionSelected:2];
    }
}


@end
