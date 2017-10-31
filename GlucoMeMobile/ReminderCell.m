//
//  ReminderCellTableViewCell.m
//  GlucoMe - Mobile
//
//  Created by dovi winberger on 5/6/15.
//  Copyright (c) 2015 Yiftah Ben Aharon. All rights reserved.
//

#import "ReminderCell.h"

@implementation ReminderCell

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setRowData:(NSString*)date :(NSString*)time :(NSString*)name :(NSString*)type
{
    
    self.dateLabel.text = date;
    self.timeLabel.text = time;
    self.nameLabel.text = name;
    self.typeLabel.text = type;
}
@end
