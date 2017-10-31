//
//  contactTableViewCell.m
//  GlucoMe - Mobile
//
//  Created by dovi winberger on 08/03/2016.
//  Copyright © 2016 Yiftah Ben Aharon. All rights reserved.
//

#import "ContactTableViewCell.h"

@implementation ContactTableViewCell


- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
-(void)SetDataFromContactName:(NSString*)_contactName
{
    contactName = _contactName;
    NSString* relationship = @"";
    NSArray* alerts = [Alert AlertsForContact:contactName];
    if(alerts.count > 0) relationship = ((Alert*)[alerts objectAtIndex:0]).relationship;
    self.titleLabel.text = contactName;
    if(relationship != nil && ![relationship isEqualToString:@""])
        self.titleLabel.text = [NSString stringWithFormat:@"%@ (%@)", contactName, relationship];

}
- (IBAction)AddAlertToContact:(id)sender {
    [self.delegate AddAlertToContact:contactName];
}

@end
