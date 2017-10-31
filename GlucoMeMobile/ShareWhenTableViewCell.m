//
//  ShareWhenTableViewCell.m
//  GlucoMe - Mobile
//
//  Created by dovi winberger on 08/03/2016.
//  Copyright © 2016 Yiftah Ben Aharon. All rights reserved.
//

#import "ShareWhenTableViewCell.h"

@implementation ShareWhenTableViewCell

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
}

- (void)SetSelected:(BOOL)selected
{
    // Configure the view for the selected state
    if(selected == YES)
        self.isOnCheckMarkImageView.hidden = NO;
    else
        self.isOnCheckMarkImageView.hidden = YES;
}

@end
