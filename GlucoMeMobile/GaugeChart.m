//
//  GaugeChage.m
//  GlucoMe - Mobile
//
//  Created by dovi winberger on 5/21/15.
//  Copyright (c) 2015 Yiftah Ben Aharon. All rights reserved.
//

#import "GaugeChart.h"
#import "general.h"
#import "Measurement_helper.h"
@implementation GaugeChart


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
-(id)initWithFrame:(CGRect)frame withPatient_id:(NSNumber*)_patient_id
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
    int upperLimit = 120;
    int lowerLimit = 70;
    
    
    NSString* upperStr = [[NSUserDefaults standardUserDefaults] objectForKey:profile_upper_limit];
    if(upperStr != nil) {
        upperLimit = [upperStr intValue];
    }
    NSString* lowerStr = [[NSUserDefaults standardUserDefaults] objectForKey:profile_lower_limit];
    if(lowerStr != nil) {
        lowerLimit = [lowerStr intValue];
    }
    
    gauge = [[SGaugeRadial alloc] initWithFrame:self.bounds];
    gauge.maximumValue = @14;
    NSArray* ranges =@[[SGaugeQualitativeRange rangeWithMinimum:nil maximum:@((lowerLimit + 46.7f) / 28.7f) color:BLUE],
                       [SGaugeQualitativeRange rangeWithMinimum:@((lowerLimit + 46.7f) / 28.7f) maximum:@((upperLimit + 46.7f) / 28.7f) color:GREEN],
                       [SGaugeQualitativeRange rangeWithMinimum:@((upperLimit + 46.7f) / 28.7f) maximum:@((upperLimit*1.2 + 46.7f) / 28.7f) color:YELLOW],
                       [SGaugeQualitativeRange rangeWithMinimum:@((upperLimit*1.2 + 46.7f) / 28.7f) maximum:nil color:RED]];
    gauge.qualitativeRanges = ranges;
    gauge.style = [SGaugeLightStyle new];
    gauge.style.innerBackgroundColor = TRANSPARENT;
    gauge.style.outerBackgroundColor = TRANSPARENT;
    gauge.style.tickLabelColor = BLUE;
    gauge.style.majorTickColor = WHITE;
    gauge.style.minorTickColor = WHITE;
    gauge.style.showGlassEffect = NO;
    gauge.style.tickLabelFont = [UIFont fontWithName:@"HelveticaNeue-Light" size:16];
    CGRect r = self.bounds;
    EHA1CLabel = [[UILabel alloc] initWithFrame:CGRectMake(r.origin.x, r.origin.y+r.size.height-40, r.size.width, 40)];
    EHA1CLabel.backgroundColor = TRANSPARENT;
    EHA1CLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:gauge];
    
    [gauge setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self addConstraints:[NSLayoutConstraint
                          constraintsWithVisualFormat:@"H:|-0-[gauge]-0-|"
                          options:NSLayoutFormatDirectionLeadingToTrailing
                          metrics:nil
                          views:NSDictionaryOfVariableBindings(gauge)]];
    
    [self addConstraints:[NSLayoutConstraint
                          constraintsWithVisualFormat:@"V:|-0-[gauge]-0-|"
                          options:NSLayoutFormatDirectionLeadingToTrailing
                          metrics:nil
                          views:NSDictionaryOfVariableBindings(gauge)]];
    
    
    
    [gauge addSubview:EHA1CLabel];
    
    
    [EHA1CLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self addConstraints:[NSLayoutConstraint
                          constraintsWithVisualFormat:@"H:|-[EHA1CLabel]-|"
                          options:NSLayoutFormatDirectionLeadingToTrailing
                          metrics:nil
                          views:NSDictionaryOfVariableBindings(EHA1CLabel)]];
    
    [self addConstraints:[NSLayoutConstraint
                          constraintsWithVisualFormat:@"V:[EHA1CLabel(==50)]-|"
                          options:NSLayoutFormatDirectionLeadingToTrailing
                          metrics:nil
                          views:NSDictionaryOfVariableBindings(EHA1CLabel)]];
}



-(BOOL)UpdateChartWithTags:(NSArray*)tags andDaysAgo:(int)daysAgo
{
    double hba1c = [Measurement GetHbA1cFromDate:[[NSDate dateWithDaysBeforeNow:daysAgo] dateAtStartOfDay] andTags:tags forPatient_id:patient_id];
   
    [gauge setValue:hba1c duration:1];
    
    if(hba1c == -1) {
        EHA1CLabel.text = @"N/A";
        gauge.needle.hidden = YES;
    }
    else {
        gauge.needle.hidden = NO;
        EHA1CLabel.text = [[NSString alloc] initWithFormat:@"%.1f", hba1c];
    }
    EHA1CLabel.textColor = EHA1CToColor([NSNumber numberWithFloat:hba1c]);
    
    if(hba1c == -1)return NO;
    else return YES;
       
}


@end
