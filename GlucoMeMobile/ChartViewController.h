//
//  ChartViewController.h
//  GlucoMe - Mobile
//
//  Created by dovi winberger on 5/21/15.
//  Copyright (c) 2015 Yiftah Ben Aharon. All rights reserved.
//
// this is a chart view, where you have a chart and filtering options

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "TagsView.h"
#import "TimeSpanButtonsView.h"

@interface ChartViewController : BaseViewController <TimeSpanButtonsViewDelegateProtocol>
{
    UIView* chart;
    TagsView *tagsView;
}

typedef enum ChartType {TrendType, PieType, GaugeType} ChartType;

@property (nonatomic) ChartType chartType;
@property (strong, nonatomic) NSNumber* patient_id;
@property (weak, nonatomic) IBOutlet UIScrollView *tagsContainerScrollview;
@property (weak, nonatomic) IBOutlet UIButton *selectAllNoneTagsButton;
@property (weak, nonatomic) IBOutlet TimeSpanButtonsView *timeSpanButtonsView;

@property (retain, nonatomic) IBOutlet UIView *chartView;

@property (weak, nonatomic) IBOutlet UIButton *closeButton;
@property (weak, nonatomic) IBOutlet UILabel *filterByTagsLabel;
@property (weak, nonatomic) IBOutlet UILabel *noDataLabel;


- (IBAction)close:(id)sender;


@end
