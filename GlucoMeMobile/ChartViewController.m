//
//  ChartViewController.m
//  GlucoMe - Mobile
//
//  Created by dovi winberger on 5/21/15.
//  Copyright (c) 2015 Yiftah Ben Aharon. All rights reserved.
//

#import "ChartViewController.h"
#import "Measurement_helper.h"
#import "TrendChart.h"
#import "PieChart.h"
#import "GaugeChart.h"
#import "general.h"
#import "HistoryTableViewController.h"
@interface ChartViewController()<TagsViewDelegateProtocol, PieChartDelegateProtocol>
@end

@implementation ChartViewController
@synthesize chartType;
@synthesize patient_id;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.closeButton setTitle:loc(@"Close") forState:UIControlStateNormal];
    if ([UIApplication sharedApplication].userInterfaceLayoutDirection == UIUserInterfaceLayoutDirectionRightToLeft) {
        [self.closeButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
    }
    self.noDataLabel.text = loc(@"No_data_available");
    self.filterByTagsLabel.text = loc(@"Filter_by_tags");
    
    [self.selectAllNoneTagsButton setTitle:loc(@"Select_none") forState:UIControlStateNormal];
    
    
    tagsView = (TagsView*)[[[NSBundle mainBundle] loadNibNamed:@"TagsView" owner:nil options:nil] objectAtIndex:0];
    tagsView.singleSelection = NO;
    tagsView.showNotTagged = YES;
    
    [tagsView setFrame:[UIScreen mainScreen].bounds];
    self.tagsContainerScrollview.autoresizesSubviews = NO;
    [self.tagsContainerScrollview addSubview:tagsView];
    [self.tagsContainerScrollview setContentSize:CGSizeMake(tagsView.frame.size.width, tagsView.frame.size.height+30)];
    
    tagsView.delegate = self;
    
    self.timeSpanButtonsView.delegate = self;
    [self.timeSpanButtonsView SetSelectedDaysAgo:7];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if(chart == nil)
    {
        chart = [[UIView alloc] initWithFrame:CGRectZero];
        switch (chartType)
        {
            case TrendType:
                self.screenName = @"TrendViewController";
                self.navigationItem.title = loc(@"Trends");
                
                chart = [[TrendChart alloc] initWithFrame:self.chartView.bounds andMode:bigTrendChartMode forPatient_id:patient_id];
                break;
            case PieType:
                self.screenName = @"PieViewController";
                self.navigationItem.title = loc(@"Glucose_distribution");
                
                chart = [[PieChart alloc] initWithFrame:self.chartView.bounds forPatient_id:patient_id];
                ((PieChart*)chart).mode = bigPieChartMode;
                ((PieChart*)chart).myDelegate = self;
                break;
            case GaugeType:
                self.screenName = @"EHA1CViewController";
                self.navigationItem.title = loc(@"Estimated_HbA1c");
                
                chart = [[GaugeChart alloc] initWithFrame:self.chartView.bounds withPatient_id:patient_id];
                [self.timeSpanButtonsView SetSelectedDaysAgo:90];
                break;
            default:
                break;
        }
    }
    
    chart.userInteractionEnabled = YES;
    [chart setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.chartView addSubview:chart];
    
    [self.chartView addConstraints:[NSLayoutConstraint
                                    constraintsWithVisualFormat:@"H:|-[chart]-|"
                                    options:NSLayoutFormatDirectionLeadingToTrailing
                                    metrics:nil
                                    views:NSDictionaryOfVariableBindings(chart)]];
    
    [self.chartView addConstraints:[NSLayoutConstraint
                                    constraintsWithVisualFormat:@"V:|-[chart]-|"
                                    options:NSLayoutFormatDirectionLeadingToTrailing
                                    metrics:nil
                                    views:NSDictionaryOfVariableBindings(chart)]];
    
    [self updateChartData];
    
    [tagsView ActivateAllTags];
}

- (IBAction)close:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)tagSelectionChanged:(TagsView*)_tagsView
{
    [self updateChartData];
    if([_tagsView IsAllTagsSelected])
    {
        [self SetAllNoneButtonToNone];
    }
    if([_tagsView IsNoneSelected])
    {
        [self SetAllNoneButtonToAll];
    }
    
}


-(void)TimeSpanChanged:(int)days
{
    [self updateChartData];
}


- (IBAction)SelectAllNoneTags:(UIButton*)sender
{
    if(sender.tag == 0)
    {
        //select none
        [tagsView DeactivateAllTags];
        [self SetAllNoneButtonToAll];
    }
    else if(sender.tag == 1)
    {
        //select all
        [tagsView ActivateAllTags];
        [self SetAllNoneButtonToNone];
    }
    
}
-(void)SetAllNoneButtonToAll
{
    [self.selectAllNoneTagsButton setTitle:loc(@"Select_all") forState:UIControlStateNormal];
    self.selectAllNoneTagsButton.tag = 1;
}
-(void)SetAllNoneButtonToNone
{
    [self.selectAllNoneTagsButton setTitle:loc(@"Select_none") forState:UIControlStateNormal];
    self.selectAllNoneTagsButton.tag = 0;
}

-(void)updateChartData
{
    int daysAgo = [self.timeSpanButtonsView GetSelectedDaysAgo];
    

    NSArray* selectedTags = [tagsView GetSelectedTags];
    
    BOOL anyData = NO;
    switch (chartType)
    {
        case TrendType:
            anyData = [(TrendChart*)chart UpdateChartWithTags:selectedTags andDaysAgo:daysAgo];
            break;
        case PieType:
            anyData = [(PieChart*)chart UpdateChartWithTags:selectedTags andDaysAgo:daysAgo];
            break;
        case GaugeType:
            anyData = [(GaugeChart*)chart UpdateChartWithTags:selectedTags andDaysAgo:daysAgo];
            break;
        default:
            break;
    }
    
    if(anyData)
    {
        self.noDataLabel.hidden = YES;
        chart.hidden = NO;
    }
    else
    {
        self.noDataLabel.hidden = NO;
        chart.hidden = YES;
    }
    
        
}


-(void)SectionSelected:(int)section;//0 low, 1 normal, 2 high, 3 very high
{
    UINavigationController *nav = [[UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil] instantiateViewControllerWithIdentifier:@"HistoryNavigationControllerID"];
    HistoryTableViewController* vc = nav.viewControllers[0];
    vc.patient_id = [[DataHandler_new getInstance] getPatientIdAsNumber];

    [vc SetDaysAgoFilter:[self.timeSpanButtonsView GetSelectedDaysAgo]];
    [vc SetMeasurementTypesFilter:@[@(0)]];
    [vc SetGlucoseTypesFilter:@[@(section)]];
    
    [self presentViewController:nav animated:YES completion:nil];
}
@end
