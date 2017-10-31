//
//  historyCellTableViewCell.h
//  GlucoMe - Mobile
//
//  Created by dovi winberger on 5/5/15.
//  Copyright (c) 2015 Yiftah Ben Aharon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Measurement.h"

@protocol HistoryCellDelegateProtocol <NSObject>

-(void)ShowDetails:(Measurement*)m;

@end

@interface HistoryCell : UITableViewCell
{
    Measurement* m;
}
@property (weak, nonatomic) id<HistoryCellDelegateProtocol>delegate;

@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *valueLabel;
@property (weak, nonatomic) IBOutlet UIScrollView *tagsScrollView;
@property (weak, nonatomic) IBOutlet UILabel *disclosureIndicator;
@property (weak, nonatomic) IBOutlet UILabel *unitsLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *valueHeightConstraint;


- (void)setRowDataWithMeasurement:(Measurement*)_m;

- (IBAction)showDetails:(id)sender;
@end
