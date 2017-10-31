//
//  SingleTreatmentDiaryCell.m
//  GlucoMe - Mobile
//
//  Created by dovi winberger on 26/06/2016.
//  Copyright © 2016 Yiftah Ben Aharon. All rights reserved.
//

#import "SingleTreatmentDiaryCell.h"
#import "SingleMeasurementViewController.h"

@implementation SingleTreatmentDiaryCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)SetData:(TreatmentDiary*)t
{
    mTreatment = t;
    
    if(t.dosage != nil)
        self.titleLabel.text = [NSString stringWithFormat:@"%@ %@",t.name, t.dosage ];
    else
        self.titleLabel.text = [NSString stringWithFormat:@"%@",t.name ];
    self.detailsLabel.text = [self GetTimeString:t];
    [self.doneSwitch setOn:[t isDone]];
    self.doneSwitch.hidden = [t isDone];
    self.doneLabel.hidden = [t isDone];
    
    [self SetColor];
}

-(NSString*)GetTimeString:(TreatmentDiary*)t
{
    NSString* dateComponent = RelativeDate(t.dueDate);
    
    NSString* timeComponent = [t.dueDate shortTimeString];
    if([t.isDueDateEstimated boolValue])
    {
        timeComponent = HourAsComponentOfDay((int)t.dueDate.hour);
    }
    
    return [NSString stringWithFormat:@"%@, %@", dateComponent, timeComponent];
    
    
}
- (IBAction)doneSwitchChanged:(id)sender
{
    if(_doneSwitch.isOn)
    {
        UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil];
        UINavigationController* singleMeasurementNavigationController = [storyboard instantiateViewControllerWithIdentifier:@"SingleMeasurementID"];
        SingleMeasurementViewController* singleMeasurementViewController = singleMeasurementNavigationController.viewControllers[0];
        
        [singleMeasurementViewController SetTreatmentDiary:mTreatment];
        singleMeasurementViewController.allowCancel = YES;
        
        [((AppDelegate*)[[UIApplication sharedApplication] delegate]) ShowViewControllerOnTopOfEverything:singleMeasurementNavigationController];
    }
    else
        [mTreatment Undone];
    
    [self SetColor];
}

-(void)SetColor
{
    self.backgroundColor = [UIColor clearColor];
    if([mTreatment isDone])
        self.backgroundColor = GREEN;
    if([[NSDate date] isLaterThanDate:mTreatment.dueDate])
    {
        if(![mTreatment isDone ])
            self.backgroundColor = RED;
    }
}
@end
