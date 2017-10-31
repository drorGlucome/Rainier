//
//  ShowFiltersTableViewCell.m
//  GlucoMe - Mobile
//
//  Created by dovi winberger on 11/02/2016.
//  Copyright © 2016 Yiftah Ben Aharon. All rights reserved.
//

#import "ShowFiltersTableViewCell.h"

@implementation ShowFiltersTableViewCell

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
    [self.showFiltersButton setTitle:loc(@"Filter") forState:UIControlStateNormal];
    [self.showFiltersButton.titleLabel setTextAlignment:NSTextAlignmentNatural];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
-(CGFloat)Height
{
    return 30;
}
- (IBAction)ShowFilters:(id)sender
{
    self.HistoryTableVC.showFilters = YES;
    
    NSRange range = NSMakeRange(0, 1);
    NSIndexSet *section = [NSIndexSet indexSetWithIndexesInRange:range];
    [self.HistoryTableVC.tableView reloadSections:section withRowAnimation:UITableViewRowAnimationFade];
}

@end
