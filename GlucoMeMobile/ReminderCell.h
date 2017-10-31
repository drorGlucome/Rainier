//
//  ReminderCellTableViewCell.h
//  GlucoMe - Mobile
//
//  Created by dovi winberger on 5/6/15.
//  Copyright (c) 2015 Yiftah Ben Aharon. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ReminderCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *typeLabel;


- (void)setRowData:(NSString*)date :(NSString*)time :(NSString*)name :(NSString*)type;


@end
