//
//  FilterHistoryTableViewCell.h
//  GlucoMe - Mobile
//
//  Created by dovi winberger on 10/02/2016.
//  Copyright © 2016 Yiftah Ben Aharon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TagsView.h"
#import "HistoryTableViewController.h"
#import "TimeSpanButtonsView.h"
@interface FilterHistoryTableViewCell : UITableViewCell <TagsViewDelegateProtocol, TimeSpanButtonsViewDelegateProtocol>

@property (weak, nonatomic) IBOutlet TagsView *measurementTypesTagsView;
@property (weak, nonatomic) IBOutlet TagsView *glucoseFilterTagsView;
@property (weak, nonatomic) HistoryTableViewController *HistoryTableVC;
@property (weak, nonatomic) IBOutlet UIButton *titleButton;
@property (weak, nonatomic) IBOutlet TimeSpanButtonsView *timeSpanButtonsView;
@property (weak, nonatomic) IBOutlet UILabel *glucoseFiltersLabel;

-(CGFloat)Height;
@end
