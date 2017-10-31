//
//  ShareWhatTableViewCell.m
//  GlucoMe - Mobile
//
//  Created by dovi winberger on 08/03/2016.
//  Copyright © 2016 Yiftah Ben Aharon. All rights reserved.
//

#import "ShareWhatTableViewCell.h"

@implementation ShareWhatTableViewCell

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


-(void)SetMediaType:(MediaTypesEnum)mediaType
{
    switch (mediaType) {
        case SMS:
            self.iconImageView.image = [UIImage imageNamed:@"how_sms"];
            break;
        case Email:
            self.iconImageView.image = [UIImage imageNamed:@"how_email"];
            break;
        case Phone:
            self.iconImageView.image = [UIImage imageNamed:@"how_phone"];
            break;
        default:
            self.iconImageView.image = [UIImage imageNamed:@""];
            break;
    }
}
- (IBAction)switchValueChanged:(id)sender
{
    [self.delegate selectionChanged:self.isOnSwitch.isOn forCellID:[self.cellID intValue]];
}
@end
