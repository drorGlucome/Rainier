//
//  SingleTreatmentCell.m
//  GlucoMe - Mobile
//
//  Created by dovi winberger on 25/01/2016.
//  Copyright © 2016 Yiftah Ben Aharon. All rights reserved.
//

#import "SingleTreatmentCell.h"

@implementation SingleTreatmentCell

-(void)SetWithTreatment:(Treatment*)t
{
    NSString* recurringString = @"";
    int recurringCount = 0;
    
    if([t.recurrenceSunday boolValue])
    {
        recurringString = [NSString stringWithFormat:@"%@ %@",recurringString, loc(@"Sunday")];
        recurringCount++;
    }
    if([t.recurrenceMonday boolValue])
    {
        recurringString = [NSString stringWithFormat:@"%@ %@",recurringString, loc(@"Monday")];
        recurringCount++;
    }
    if([t.recurrenceTuesday boolValue])
    {
        recurringString = [NSString stringWithFormat:@"%@ %@",recurringString, loc(@"Tuesday")];
        recurringCount++;
    }
    if([t.recurrenceWednesday boolValue])
    {
        recurringString = [NSString stringWithFormat:@"%@ %@",recurringString, loc(@"Wednesday")];
        recurringCount++;
    }
    if([t.recurrenceThursday boolValue])
    {
        recurringString = [NSString stringWithFormat:@"%@ %@",recurringString, loc(@"Thursday")];
        recurringCount++;
    }
    if([t.recurrenceFriday boolValue])
    {
        recurringString = [NSString stringWithFormat:@"%@ %@",recurringString, loc(@"Friday")];
        recurringCount++;
    }
    if([t.recurrenceSaturday boolValue])
    {
        recurringString = [NSString stringWithFormat:@"%@ %@",recurringString, loc(@"Saturday")];
        recurringCount++;
    }
    
    recurringString = [NSString stringWithFormat:@"(%@)", recurringString];
    if(recurringCount > 2)  recurringString = @"";
    
    self.dosageLabel.text   = [NSString stringWithFormat:@"%@", t.dosage];
    self.nameLabel.text     = [NSString stringWithFormat:@"%@, %@ %@",t.treatmentTypeName, loc(t.daypart), recurringString];
    [self.nameLabel setTextAlignment:NSTextAlignmentNatural];
    
    
    self.summaryLabel.text  = t.summary;
}

@end
