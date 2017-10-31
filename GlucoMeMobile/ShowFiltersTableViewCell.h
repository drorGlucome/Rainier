//
//  ShowFiltersTableViewCell.h
//  GlucoMe - Mobile
//
//  Created by dovi winberger on 11/02/2016.
//  Copyright © 2016 Yiftah Ben Aharon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HistoryTableViewController.h"
@interface ShowFiltersTableViewCell : UITableViewCell

@property (weak, nonatomic) HistoryTableViewController *HistoryTableVC;
@property (weak, nonatomic) IBOutlet UIButton *showFiltersButton;
-(CGFloat)Height;

@end
