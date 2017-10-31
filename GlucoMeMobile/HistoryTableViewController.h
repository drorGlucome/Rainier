//
//  HistoryTableViewController.h
//  GlucoMe - Mobile
//
//  Created by dovi winberger on 5/5/15.
//  Copyright (c) 2015 Yiftah Ben Aharon. All rights reserved.
//
// this is the history view

#import <Foundation/Foundation.h>
#import "FullTableViewControllerNew.h"


@class FilterHistoryTableViewCell;
@class ShowFiltersTableViewCell;
@interface HistoryTableViewController : FullTableViewControllerNew
{
    NSArray *tableData;
    NSArray *measurementTypesFilter;
    NSArray *glucoseTypesFilter;
    NSNumber* daysAgoFilter;
    FilterHistoryTableViewCell* filterCell;
    ShowFiltersTableViewCell*   showFiltersCell;
}
@property (nonatomic) BOOL showFilters;
@property (strong, nonatomic) NSNumber* patient_id;
@property (weak, nonatomic) IBOutlet UIView *tableHeaderView;

//measurementTypes
//0 glucose
//1 medicine
//2 food
//3 activity
//4 weight
//glucose types
//0 low
//1 normal
//2 high
//3 very hige
-(void)SetMeasurementTypesFilter:(NSArray*)measurementTypes;
-(void)SetGlucoseTypesFilter:(NSArray*)glucoseTypes;
-(void)SetDaysAgoFilter:(int)daysAgo;
@end
