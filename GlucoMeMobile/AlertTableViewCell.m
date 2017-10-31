//
//  AlertTableViewCell.m
//  GlucoMe - Mobile
//
//  Created by dovi winberger on 08/03/2016.
//  Copyright © 2016 Yiftah Ben Aharon. All rights reserved.
//

#import "AlertTableViewCell.h"

#import "AlertType_helper.h"
#import "MediaType_helper.h"

@implementation AlertTableViewCell

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)SetData:(Alert*)alert
{
    AlertType* alertType = [AlertType MR_findFirstByAttribute:@"id" withValue:alert.when_alertTypeID inContext:[NSManagedObjectContext MR_defaultContext]];
    self.whatLabel.text = [alertType WhatAsString:alertType.name];;
    self.whenLabel.text = [alertType WhenAsString:alert.params];
    
    MediaType* mediaType = [MediaType MR_findFirstByAttribute:@"id" withValue:alert.how_mediaTypeID inContext:[NSManagedObjectContext MR_defaultContext]];
    MediaTypesEnum mediaTypeEnum = [MediaType MediaTypeEnumForMediaType:mediaType];
    switch (mediaTypeEnum) {
        case SMS:
            self.howImageView.image = [UIImage imageNamed:@"how_sms"];
            break;
        case Email:
            self.howImageView.image = [UIImage imageNamed:@"how_email"];
            break;
        case Phone:
            self.howImageView.image = [UIImage imageNamed:@"how_phone"];
            break;
        default:
            self.howImageView.image = [UIImage imageNamed:@""];
            break;
    }
}
@end
