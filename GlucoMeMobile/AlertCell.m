//
//  AlertCell.m
//  GlucoMe - Mobile
//
//  Created by dovi winberger on 5/6/15.
//  Copyright (c) 2015 Yiftah Ben Aharon. All rights reserved.
//

#import "AlertCell.h"

@implementation AlertCell

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
}


- (void)setRowData:(NSString*)how :(NSString*)when :(NSString*)who
{
    self.howLabel.text = how;
    self.whenLabel.text = when;
    self.whoLabel.text = who;
    
}

@end
