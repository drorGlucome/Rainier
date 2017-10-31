//
//  historyCellTableViewCell.m
//  GlucoMe - Mobile
//
//  Created by dovi winberger on 5/5/15.
//  Copyright (c) 2015 Yiftah Ben Aharon. All rights reserved.
//

#import "HistoryCell.h"
#import "general.h"
#import "Tag_helper.h"
#import "NSString+FontAwesome.h"
#import "MYTextAttachment.h"
#import "NSString+helpers.h"
@interface HistoryCell ()
@property (nonatomic, strong) UIFont* originalValueFont;
@end

@implementation HistoryCell

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setRowDataWithMeasurement:(Measurement*)_m
{
    if(self.originalValueFont == nil)
    {
        self.originalValueFont = self.valueLabel.font;
    }
    self.valueLabel.font = self.originalValueFont;
    
    m = _m;
    
    if(m.date == nil) return;
    NSString* time = [[NSString alloc] initWithString:rails2iosTimeFromDate(m.date)];
    NSString* date =  [[NSString alloc] initWithString:rails2iosDateFromDate(m.date)];
    NSString* value = @"";
    NSAttributedString* attributedValue = [[NSAttributedString alloc] initWithString:@""];
    NSString* units = @"";
    UIColor* valueColor = GRAY;
    self.valueHeightConstraint.priority = 600;
    switch ([_m.type integerValue]) {
        case glucoseMeasurementType:
            units = [[UnitsManager getInstance] GetGlucoseUnitsLocalizedString];
            valueColor = glucoseToColor([m.value intValue], [_m GetFirstTagID]);
            value = [[UnitsManager getInstance] GetGlucoseStringValueForCurrentUnit:[m.value intValue]];
            break;
        case medicineMeasurementType:
            units = loc(@"Units");
            value = [NSString stringWithFormat:@"%d",[m.value intValue]];
            break;
        case foodMeasurementType:
        {
            self.valueHeightConstraint.priority = 900;
            units = loc(@"");
            valueColor = foodToColor([m.value intValue]);
            
            MYTextAttachment *attachment = [[MYTextAttachment alloc] init];
            attachment.image = [UIImage imageNamed:@"food"];
            NSAttributedString* attr = [NSAttributedString attributedStringWithAttachment:attachment];
            
            NSMutableAttributedString* tempTitle = [[NSMutableAttributedString alloc] initWithString:@""];
            for (int i = 0; i < m.value.intValue; i++) {
                [tempTitle appendAttributedString:attr];
            }
            attributedValue = tempTitle;

            break;
        }
        case activityMeasurementType:
        {
            self.valueHeightConstraint.priority = 900;
            units = loc(@"");

            MYTextAttachment *attachment = [[MYTextAttachment alloc] init];
            attachment.image = [UIImage imageNamed:@"activity"];
            NSAttributedString* attr = [NSAttributedString attributedStringWithAttachment:attachment];
            
            NSMutableAttributedString* tempTitle = [[NSMutableAttributedString alloc] initWithString:@""];
            for (int i = 0; i < m.value.intValue; i++) {
                [tempTitle appendAttributedString:attr];
            }
            attributedValue = tempTitle;
            
            break;
        }
        case weightMeasurementType:
        {
            self.valueHeightConstraint.priority = 900;
            units = loc(@"");
            
            MYTextAttachment *attachment = [[MYTextAttachment alloc] init];
            attachment.image = [UIImage imageNamed:@"weight"];

            NSAttributedString* attr = [NSAttributedString attributedStringWithAttachment:attachment];

            NSMutableAttributedString* tempTitle = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%.0f",[m.value doubleValue]]];
            [tempTitle appendAttributedString:attr];
            attributedValue = tempTitle;
            
            break;
        }
        default:
            break;
    }
    
     
    
    NSMutableArray *tagsNamesArray = [[NSMutableArray alloc] init];
    NSMutableArray *tagsIconsArray = [[NSMutableArray alloc] init];

    if(m.tags && (NSObject*)m.tags != [NSNull null])
    {
        NSArray* tempTagsArray = [m.tags componentsSeparatedByCharactersInSet:
                                  [NSCharacterSet characterSetWithCharactersInString:TAGS_SEPARATOR]
                                  ];
        
        NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
        for (NSString* tagString in tempTagsArray)
        {
            NSNumber* tagNumber = [f numberFromString:tagString];
            Tag* tag = [Tag GetTagForId:tagNumber];
            if(tag == nil) continue;
            [tagsNamesArray addObject:loc(tag.name)];
            [tagsIconsArray addObject:tag.icon];
        }
    }
    
    
    
    [self.timeLabel setText:date];
    
    [self.dateLabel setText:time];
    
    if(![value isEqualToString:@""])
        [self.valueLabel setText:value];
    else if (![attributedValue isEqualToAttributedString:[[NSAttributedString alloc] initWithString:@""]])
        [self.valueLabel setAttributedText:attributedValue];
    
    [self.valueLabel setTextColor:valueColor];
    
    [self.unitsLabel setText:units];
    
    for(UIView* v in [self.tagsScrollView subviews])
    {
        [v removeFromSuperview];
    }
    if(tagsNamesArray.count == 0) return;
    //setting tags section
    
    UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(45,0,self.tagsScrollView.frame.size.width,self.tagsScrollView.frame.size.height)];
    //[label setTextAlignment:NSTextAlignmentNatural];
    label.textColor = GRAY;
    [label setFont:[UIFont fontWithName:@"HelveticaNeue-Thin" size:14]];
    label.backgroundColor=[UIColor clearColor];
    
    NSString* tagTexts = [tagsNamesArray componentsJoinedByString:@" "];
    [label setText:tagTexts];
    [label setTextAlignment:NSTextAlignmentNatural];
    
    
    UIImageView* icon = [[UIImageView alloc] initWithFrame:CGRectMake(0, self.tagsScrollView.frame.size.height/2-15, 30, 30)];
    icon.image = [UIImage imageNamed:tagsIconsArray[0]];

    [self.tagsScrollView addSubview:icon];
    [self.tagsScrollView addSubview:label];
    
    [self.tagsScrollView setContentSize:CGSizeMake(tagTexts.length*10 > self.tagsScrollView.frame.size.width ? tagTexts.length*10 : self.tagsScrollView.frame.size.width, 50)];
    
    if([label.text DetectTextAlignment] == NSTextAlignmentRight ){
        [label setFrame:CGRectMake(0,0,self.tagsScrollView.contentSize.width-45,self.tagsScrollView.frame.size.height)];
        [icon setFrame:CGRectMake(self.tagsScrollView.contentSize.width-30, self.tagsScrollView.frame.size.height/2-15, 30, 30)];
        
//        self.tagsScrollView.contentOffset = CGPointMake(self.tagsScrollView.contentSize.width-10,0);
    }
}




- (IBAction)showDetails:(id)sender
{
    [_delegate ShowDetails:m];
}
@end
