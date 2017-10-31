//
//  FullChartCrosshairTooltip.m
//  GlucoMe - Mobile
//
//  Created by Yiftah Ben Aharon on 7/28/14.
//  Copyright (c) 2014 Yiftah Ben Aharon. All rights reserved.
//

#import "FullChartCrosshairTooltip.h"
#import <ShinobiCharts/SChart.h>
#import <ShinobiCharts/SChartData.h>
#import <ShinobiCharts/SChartAxis.h>
#import "general.h"
#import "Tag_helper.h"
#import "Measurement.h"



@implementation FullChartCrosshairTooltip

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
    }
    return self;
}



- (void)setDataPoint:(id<SChartData>)dataPoint fromSeries:(SChartSeries *)series fromChart:(ShinobiChart *)chart {
//    [datasource setTooltipSeries: series];
//    [tooltipChart reloadData];
    NSString* xVal = [chart.xAxis stringForId: [dataPoint sChartXValue]];
    NSString* yVal = [chart.yAxis stringForId: [dataPoint sChartYValue]];
    NSString* tags = @"";
    
    
    NSArray* allMeasurements = [Measurement MR_findAllInContext:[NSManagedObjectContext MR_defaultContext]];
    
    
    for(Measurement*m in allMeasurements)
    {
        //NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
        //[dateFormatter setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ssZ"];
        NSDate* date = m.date;
        NSDate* chartDate = (NSDate*)[dataPoint sChartXValue];
        if(fabs(date.timeIntervalSince1970 - chartDate.timeIntervalSince1970) < 1) {
            
            NSArray* tempTagsArray = [m.tags componentsSeparatedByCharactersInSet:
                                      [NSCharacterSet characterSetWithCharactersInString:TAGS_SEPARATOR]
                                      ];
            
            NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
            for (NSString* tagString in tempTagsArray)
            {
                NSNumber* tagNumber = [f numberFromString:tagString];
                Tag* tag = [Tag GetTagForId:tagNumber];
                if(tag == nil) continue;
                tags = [NSString stringWithFormat:@"%@ %@",tags, tag.name];
            }
            break;
        }
    }
    
    if(tags.length == 0) {
        self.label.numberOfLines = 2;
        self.label.textAlignment = NSTextAlignmentLeft;
        self.label.text = [[NSString alloc] initWithFormat:@"Date: %@\nValue: %@", xVal, yVal];
    }
    else {
        self.label.numberOfLines = 3;
        self.label.textAlignment = NSTextAlignmentLeft;
        self.label.text = [[NSString alloc] initWithFormat:@"Date: %@\nValue: %@\nTags: %@", xVal, yVal, tags];
    }

}


@end
