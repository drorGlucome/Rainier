//
//  FilterHistoryTableViewCell.m
//  GlucoMe - Mobile
//
//  Created by dovi winberger on 10/02/2016.
//  Copyright © 2016 Yiftah Ben Aharon. All rights reserved.
//

#import "FilterHistoryTableViewCell.h"

@interface FilterHistoryTableViewCell()

@end

@implementation FilterHistoryTableViewCell

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
    self.measurementTypesTagsView.delegate = self;
    self.glucoseFilterTagsView.delegate = self;
    self.timeSpanButtonsView.delegate = self;
    
    [self.titleButton setTitle:loc(@"Close") forState:UIControlStateNormal];
    [self.titleButton.titleLabel setTextAlignment:NSTextAlignmentNatural];
    
    self.glucoseFiltersLabel.text = loc(@"Glucose_filter");
    [self.glucoseFiltersLabel setTextAlignment:NSTextAlignmentNatural];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(CGFloat)Height
{
    return 300;
}


-(void)tagSelectionChanged:(TagsView*)tagsView
{
    if(tagsView == self.measurementTypesTagsView)
        [self.HistoryTableVC SetMeasurementTypesFilter:[self.measurementTypesTagsView GetSelectedTags]];
    
    if(tagsView == self.glucoseFilterTagsView)
        [self.HistoryTableVC SetGlucoseTypesFilter:[self.glucoseFilterTagsView GetSelectedTags]];
}
-(void)TimeSpanChanged:(int)days
{
    [self.HistoryTableVC SetDaysAgoFilter:days];
}

-(NSString*)iconForTag:(long)_id
{
    switch (_id) {
        case 0:
            return @"glucose";
        case 1:
            return @"medicine";
        case 2:
            return @"food";
        case 3:
            return @"activity";
        case 4:
            return @"weight";
        default:
            return @"";
            break;
    }
}
- (IBAction)titleButtonClicked:(id)sender
{
    self.HistoryTableVC.showFilters = NO;
    
    NSRange range = NSMakeRange(0, 1);
    NSIndexSet *section = [NSIndexSet indexSetWithIndexesInRange:range];
    [self.HistoryTableVC.tableView reloadSections:section withRowAnimation:UITableViewRowAnimationFade];
}
@end
