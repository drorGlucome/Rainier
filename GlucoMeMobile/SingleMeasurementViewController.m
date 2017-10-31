//
//  LogDetailedViewController.m
//  GlucoMe - Mobile
//
//  Created by Yiftah Ben Aharon on 8/14/14.
//  Copyright (c) 2014 Yiftah Ben Aharon. All rights reserved.
//


#import "SingleMeasurementViewController.h"
#import "general.h"
#import "RMDateSelectionViewController.h"
#import "NSString+FontAwesome.h"
#import "CustomIOSAlertView.h"
#import "FoodActivityView.h"
#import "MedicineDialog.h"
#import "TreatmentDiary.h"
@interface SingleMeasurementViewController () <TagsViewDelegateProtocol, RMDateSelectionViewControllerDelegate, FoodActivityViewDelegateProtocol, MedicineDialogDelegateProtocol>
@property (nonatomic) float resultValueLabelFontSize;
@end


@implementation SingleMeasurementViewController
@synthesize allowCancel;

#define EDIT_VALUE_TAG 500
#define ADD_NOTE_TAG 501
#define ARE_YOU_SURE_TAG 502



- (NSTimeInterval)timeDifferenceSinceLastOpen {
    
    if (!self.previousTime) self.previousTime = [NSDate date];
    NSDate *currentTime = [NSDate date];
    NSTimeInterval timeDifference =  [currentTime timeIntervalSinceDate:self.previousTime];
    self.previousTime = currentTime;
    return timeDifference;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //tempComment = @"";
    remindViewHeight = -1;
    
    [self.saveButton setTitle:loc(@"Save") forState:UIControlStateNormal];
    [self.saveAndInjectButton setTitle:loc(@"save_and_inject") forState:UIControlStateNormal];
    [self.backButton setTitle:loc(@"Back") forState:UIControlStateNormal];
    if ([UIApplication sharedApplication].userInterfaceLayoutDirection == UIUserInterfaceLayoutDirectionRightToLeft) {
        [self.saveButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    }
    
    self.notesTitleLabel.text = [NSString stringWithFormat:@" %@",loc(@"Notes")];
    [self.notesTitleLabel setTextAlignment:NSTextAlignmentNatural];
    
    self.tagResultTitleLabel.text = [NSString stringWithFormat:@" %@",loc(@"Tag_your_results")];
    [self.tagResultTitleLabel setTextAlignment:NSTextAlignmentNatural];
    
    
    self.noteTextView.text = loc(@"add_some_note");
    [self.noteTextView setTextAlignment:NSTextAlignmentNatural];
    
    self.resultValueLabelFontSize = self.resultValueLabel.font.pointSize;
    
    self.remindLabel.text = loc(@"remind_me_in_2_hours");
    [self.remindLabel setTextAlignment:NSTextAlignmentNatural];
    
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.screenName = @"SingleMeasurementViewController";
    
    //if (date != nil) {
    [self UpdateUI];
    
    //}
     
}



-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if(shouldWobble)
    {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self WobbleAnimation];
        });

    }
    [self SetTagsUI];
    
}

-(void)setAllowCancel:(BOOL)_allowCancel
{
    allowCancel = _allowCancel;
    
    if(allowCancel)
    {
        UIBarButtonItem *closeButton = [[UIBarButtonItem alloc]
                                       initWithTitle:loc(@"Cancel")
                                       style:UIBarButtonItemStylePlain
                                       target:self
                                       action:@selector(Close:)];
        self.navigationItem.leftBarButtonItem = closeButton;
    }
    else
    {
        self.navigationItem.leftBarButtonItem = nil;
    }
}
-(void)UpdateUI
{
    
    if(remindViewHeight == -1)
        remindViewHeight = self.remindViewHeightConstraint.constant;
    self.remindViewHeightConstraint.constant = 0;
    self.remindView.hidden = YES;
    
    CGRect saveAndInjectButtonOriginalRect = self.saveAndInjectButton.frame;
    [self.saveAndInjectButton setFrame:CGRectZero];
    self.saveButtonsSeperator.hidden = YES;
    //title
    switch (type) {
        case glucoseMeasurementType:
            //self.navigationItem.title = loc(@"Glucose");
            [self.saveAndInjectButton setFrame:saveAndInjectButtonOriginalRect];
            self.saveButtonsSeperator.hidden = NO;
            
            if(newMeasurement && tagsView.GetSelectedTags.count > 0)
            {
                int selectedTag = [[tagsView.GetSelectedTags objectAtIndex:0] intValue];
                if(selectedTag == 0 || selectedTag == 2 ||selectedTag == 4 || selectedTag == 6)
                {
                    self.remindView.hidden = NO;
                    [UIView animateWithDuration:1
                                     animations:^{
                                         self.remindViewHeightConstraint.constant = remindViewHeight;
                                     }];
                    
                    
                    
                }
            }
            
            break;
        case medicineMeasurementType:
            self.navigationItem.title = loc(@"Medicine");
            break;
        case foodMeasurementType:
            self.navigationItem.title = loc(@"Food");
            break;
        case activityMeasurementType:
            self.navigationItem.title = loc(@"Activity");
            break;
        case weightMeasurementType:
            self.navigationItem.title = loc(@"Weight");
            break;
        default:
            break;
    }
    
    
    //notes
    if(comment != nil && ![comment isEqualToString:@""])
    {
        //tempComment = comment;
        self.noteTextView.text = comment;
        [self.noteTextView setTextAlignment:NSTextAlignmentNatural];
    }
    
    
    
    
    
    //edit
    BOOL isEditable = NO;
    if([source isEqualToString:@"manual"]) isEditable = YES;
    self.editDateIcon.hidden = !isEditable;
    self.editDateButton.hidden = !isEditable;
    
    self.editValueIcon.hidden = !isEditable;
    self.editValueButton.hidden = !isEditable;
    
    
    //save and inject button
    self.saveAndInjectButton.hidden = YES;
    self.saveButtonsSeperator.hidden = YES;
    if(type == glucoseMeasurementType)
    {
        if(newMeasurement == YES)
        {
            self.saveAndInjectButton.hidden = NO;
            self.saveButtonsSeperator.hidden = NO;
        }
    }
    
    
    //value
    self.resultValueLabel.text = @"";
    self.resultValueUnitsLabel.text = @"";
    
    UIColor* color = GREEN;
    
    switch (type) {
        case glucoseMeasurementType:
            self.resultValueUnitsLabel.text = [[UnitsManager getInstance] GetGlucoseUnitsLocalizedString];
            
            if(value > -1)
            {
                self.resultValueLabel.text = [[UnitsManager getInstance] GetGlucoseStringValueForCurrentUnit:value];
                NSArray* tagsArray = [tagsView GetSelectedTags];
                if(tagsArray.count == 0)
                    color = glucoseToColor(value, -1);
                else
                    color = glucoseToColor(value, [tagsArray[0] intValue]);
            }
            else
            {
                self.resultValueLabel.text = loc(@"--");
            }
            break;
        case medicineMeasurementType:
            self.resultValueUnitsLabel.text = loc(@"Units");
            if(value > -1)
            {
                self.resultValueLabel.text = [NSString stringWithFormat:@"%d", value];
            }
            else
            {
                self.resultValueLabel.text = loc(@"--");
            }
            break;
        case foodMeasurementType:
        {
            self.resultValueUnitsLabel.text = loc(@"");
            NSString* valueString = loc(@"--");
            self.resultValueLabel.text = valueString;
            if(value > -1)
            {
                NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
                attachment.image = [UIImage imageNamed:@"food"];
                NSAttributedString* attr = [NSAttributedString attributedStringWithAttachment:attachment];
                
                NSMutableAttributedString* tempTitle = [[NSMutableAttributedString alloc] initWithString:@""];
                for (int i = 0; i < value; i++) {
                    [tempTitle appendAttributedString:attr];
                }
                self.resultValueLabel.attributedText = tempTitle;
                
                color = foodToColor(value);
            }
            
            break;
        }
        case activityMeasurementType:
        {
            self.resultValueUnitsLabel.text = loc(@"");
            NSString* valueString = loc(@"--");
            self.resultValueLabel.text = valueString;
            if(value > -1)
            {
                NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
                attachment.image = [UIImage imageNamed:@"activity"];
                NSAttributedString* attr = [NSAttributedString attributedStringWithAttachment:attachment];
                
                NSMutableAttributedString* tempTitle = [[NSMutableAttributedString alloc] initWithString:@""];
                for (int i = 0; i < value; i++) {
                    [tempTitle appendAttributedString:attr];
                }
                self.resultValueLabel.attributedText = tempTitle;
                
                color = activityToColor(value);
            }
            
            break;
        }
        case weightMeasurementType:
        {
            self.resultValueUnitsLabel.text = loc(@"");
            if(value > -1)
            {
                self.resultValueLabel.text = [NSString stringWithFormat:@"%d", value];
            }
            else
            {
                self.resultValueLabel.text = loc(@"--");
            }
            
            break;
        }
        default:
            break;
    }
    
    if([color isEqual:GRAY])
        self.resultBackgroundImageView.image = [UIImage imageNamed:@"glucoseBackgroundGray"];
    if([color isEqual:GREEN])
        self.resultBackgroundImageView.image = [UIImage imageNamed:@"glucoseBackgroundGreen"];
    if([color isEqual:RED])
        self.resultBackgroundImageView.image = [UIImage imageNamed:@"glucoseBackgroundRed"];
    if([color isEqual:YELLOW])
        self.resultBackgroundImageView.image = [UIImage imageNamed:@"glucoseBackgroundOrange"];
    if([color isEqual:BLUE])
        self.resultBackgroundImageView.image = [UIImage imageNamed:@"glucoseBackgroundBlue"];
    
    
    //date
    if (date == nil)
    {
        date = [[NSDate alloc] init];;
    }
    
    NSDateFormatter* timeFormatter = [[NSDateFormatter alloc] init];
    timeFormatter.timeStyle = NSDateFormatterShortStyle;
    self.resultTimeLabel.text = [timeFormatter stringFromDate:date];
    
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateStyle = NSDateFormatterShortStyle;
    self.resultDateLabel.text = [dateFormatter stringFromDate:date];
    
    
    NSInteger maxFontSize = binarySearchForFontSizeForLabel(self.resultDateLabel, 10, 22)-1;
    [self.resultDateLabel setFont:[UIFont fontWithName:self.resultDateLabel.font.fontName size:maxFontSize]];
    [self.resultTimeLabel setFont:[UIFont fontWithName:self.resultTimeLabel.font.fontName size:maxFontSize]];
    
    
    
    
    
    
}


-(void)SetType:(MeasurementType)_type source:(NSString*)_source
{
    newMeasurement = YES;
    
    uuid = nil;
    value = -1;
    originalValue = -1;
    date = nil;
    originalDate = nil;
    comment = nil;
    tags = nil;
    
    type = _type;
    source = [_source copy];
    
    [self UpdateUI];
    [self SetTagsUI];
    
    NSArray* elements = [TreatmentDiary FindTreatmentDiaryElementNearDate:date type:type];
    if(elements.count == 1)
    {
        relatedDiaryEntry = elements[0];
    }

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self EditValueClicked:nil];
    });
    
}

-(void)SetMeasurement:(Measurement*)_m
{
    relatedDiaryEntry = nil;
    newMeasurement = NO;
    
    uuid = [_m.uuid copy];
    value = [_m.value intValue];
    originalValue = [_m.value intValue];
    originalDate = [_m.date copy];
    date = [_m.date copy];
    comment = [_m.comment copy];
    tags = [_m.tags copy];
    type = _m.type.intValue;
    source = [_m.source copy];
    
    [self UpdateUI];
    [self SetTagsUI];
}

-(void)SetTreatmentDiary:(TreatmentDiary*)t
{
    relatedDiaryEntry = t;
    newMeasurement = YES;
    value = [t.dosage intValue];
    originalValue = [t.dosage intValue];
    originalDate = [t.dueDate copy];
    date = [t.dueDate copy];
    comment = nil;
    tags = [t SuggestedTagId];
    type = [t MeasurementType];
    source = @"manual";
    uuid = nil;
    
    [self UpdateUI];
    [self SetTagsUI];
}

-(void)SetTagsUI
{
    //tags
    if (tagsView) {
        [tagsView removeFromSuperview];
    }
    
    NSString* tagsViewName = @"";
    switch (type) {
        case glucoseMeasurementType:
            tagsViewName = @"TagsView";
            break;
        case medicineMeasurementType:
            tagsViewName = @"TagsView_med";
            break;
        case foodMeasurementType:
            tagsViewName = @"TagsView_food";
            break;
        case activityMeasurementType:
            tagsViewName = @"TagsView_activity";
            break;
        case weightMeasurementType:
            tagsViewName = @"TagsView_weight";
            self.tagResultTitleLabel.hidden = YES;
            break;
        default:
            break;
    }
    if([tagsViewName isEqualToString:@""]) return;
    
    tagsView = (TagsView*)[[[NSBundle mainBundle] loadNibNamed:tagsViewName owner:nil options:nil] objectAtIndex:0];
    tagsView.delegate = self;
    tagsView.singleSelection = YES;
    tagsView.showNotTagged = NO;
    [tagsView setFrame:[UIScreen mainScreen].bounds];
    [self.tagsContainer addSubview:tagsView];
    
    //self.tagsContainer.autoresizesSubviews = NO;
    
    
    [self.view layoutIfNeeded];
    [self.tagsContainer layoutIfNeeded];
    [UIView animateWithDuration:0.3 animations:^{
        self.tagsContainerHeightConstraint.constant = tagsView.frame.size.height;
        [self.view layoutIfNeeded];
        [self.tagsContainer layoutIfNeeded];
    }];
    
//    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.tagsContainer
//                                                          attribute:NSLayoutAttributeHeight
//                                                          relatedBy:NSLayoutRelationEqual
//                                                             toItem:nil
//                                                          attribute:NSLayoutAttributeNotAnAttribute
//                                                         multiplier:1.0
//                                                           constant:400]];
    
    if(tags != nil && ![tags isEqualToString:@""])
        [tagsView SetActiveTags:[tags componentsSeparatedByString:TAGS_SEPARATOR]];


}


- (IBAction)Close:(id)sender
{
    if(value > 0)
    {
        UIAlertController * alert=   [UIAlertController
                                      alertControllerWithTitle:loc(@"Cancel")
                                      message:loc(@"Are_you_sure")
                                      preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* ok = [UIAlertAction
                             actionWithTitle:loc(@"Go_back")
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action)
                             {
                                 [alert dismissViewControllerAnimated:YES completion:nil];
                                 [self closeAfterInputCheck];
                                 
                             }];
        UIAlertAction* cancel = [UIAlertAction
                                 actionWithTitle:loc(@"No")
                                 style:UIAlertActionStyleCancel
                                 handler:^(UIAlertAction * action)
                                 {
                                     [alert dismissViewControllerAnimated:YES completion:nil];
                                     
                                 }];
        
        [alert addAction:ok];
        [alert addAction:cancel];
        
        [self presentViewController:alert animated:YES completion:nil];
    }
    else
    {
        [self closeAfterInputCheck];
    }
    

}
-(void)closeAfterInputCheck
{
    if(self == self.navigationController.viewControllers[0])
    {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    else
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (IBAction)SaveAndInject:(id)sender
{
    [self SaveWithCompletionBlock:^{
        [self SetType:medicineMeasurementType source:@"manual"];
        [self setAllowCancel:YES];
        [self.view setNeedsUpdateConstraints];
        [self.view setNeedsLayout];
        [self.view layoutIfNeeded];
        
    }];
    
    
}
- (IBAction)Save:(id)sender
{
    [self SaveWithCompletionBlock:^{
        [self closeAfterInputCheck];
    }];
    
}

-(void)SaveWithCompletionBlock:(void(^)(void))completionBlock
{
    
    if (value < 0) {
        return;
    }
    
    if(type == glucoseMeasurementType && (value < 30 || value > 500) )
    {
        UIAlertController * alert=   [UIAlertController
                                      alertControllerWithTitle:@""
                                      message:loc(@"This_value_seems_unusual_Are_you_sure_it_is_correct")
                                      preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* ok = [UIAlertAction
                             actionWithTitle:loc(@"Correct")
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action)
                             {
                                 [alert dismissViewControllerAnimated:YES completion:nil];
                                 [self SaveAfterInputCheckWithCompletionBlock:completionBlock];
                                 
                             }];
        UIAlertAction* cancel = [UIAlertAction
                                 actionWithTitle:loc(@"Cancel")
                                 style:UIAlertActionStyleDefault
                                 handler:^(UIAlertAction * action)
                                 {
                                     [alert dismissViewControllerAnimated:YES completion:nil];
                                     
                                 }];
        
        [alert addAction:ok];
        [alert addAction:cancel];
        
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    
    [self SaveAfterInputCheckWithCompletionBlock:completionBlock];
}

-(void)SaveAfterInputCheckWithCompletionBlock:(void(^)(void))completionBlock
{
    NSArray* tagsArray = [tagsView GetSelectedTags];
    tags = @"";
    if(tagsArray.count > 0)
        tags = [tagsArray componentsJoinedByString:TAGS_SEPARATOR];
    
    
    if(newMeasurement)
    {
        //save new measurement
        [Measurement SaveMeasurementAndSendToServer:value type:type date:date tags:tags comments:comment source:source completionBlock:^(Measurement *m) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"NewMeasurement" object:nil];
            [relatedDiaryEntry Done:m.id];
        }];
        
        
        //create reminder if needed
        if(type == glucoseMeasurementType && self.remindView.hidden == NO && self.remindSwitch.isOn)
        {
            NSDate* dueDate = [NSDate dateWithTimeIntervalSinceNow:60*60*2];
            [TreatmentDiary AddEntry:@"Monitor glucose"
                                date:dueDate
                  isDueDateEstimated:NO
                              dosage:nil
                     treatmentTypeId:0
                     isBulkDataEntry:NO];
        }

    }
    else
    {
        //update measurement
        
        Measurement* m = [Measurement MR_findFirstByAttribute:@"uuid" withValue:uuid inContext:[NSManagedObjectContext MR_defaultContext]];
        if(m == nil)
        {
            //should not reach here...
            NSArray *timestamps = [NSArray arrayWithObjects:
                                   [originalDate dateByAddingTimeInterval:-1],
                                   [originalDate dateByAddingTimeInterval:1],
                                   nil
                                   ];
            NSPredicate* p = [NSPredicate predicateWithFormat:@"value = %d AND date >= %@ AND date <= %@",originalValue, timestamps[0], timestamps[1]];
            NSArray* tempArray = [Measurement MR_findAllWithPredicate:p inContext:[NSManagedObjectContext MR_defaultContext]];
            
            if(tempArray.count == 0)
            {
                //measuremnt was not saved for some reason.
            }
            else if(tempArray.count == 1)
            {
                m = ((Measurement*)tempArray[0]);
            }
            else
                gassert(YES, @"More then one measurement with same glucose and time");
        }
        [m UpdateMeasurementAndSaveToServerWithTags:tags andComment:comment value:value date:date];
    }
    
    if(shouldWobble)
    {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"ShouldWobbleGlucose"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"DataChanged" object:nil];
    
    if(completionBlock) completionBlock();
}

-(IBAction)AddNote:(id)sender
{
    NSString* prompt = loc(@"Enter note");
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:prompt message:nil delegate:self cancelButtonTitle:loc(@"Cancel") otherButtonTitles:loc(@"Add_note"),nil];
    alert.tag = ADD_NOTE_TAG;
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    UITextField* tf = [alert textFieldAtIndex:0];
    tf.autocapitalizationType = UITextAutocapitalizationTypeWords;
    tf.text = comment;
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView.tag == ADD_NOTE_TAG)
    {
        if(buttonIndex == 1)
        {
            NSString* s = [[alertView textFieldAtIndex:0] text];
            if([s isEqualToString:@""])
            {
                self.noteTextView.text = loc(@"add_some_note");
            }
            else
            {
                self.noteTextView.text = s;
            }
            comment = s;
        }
    }
    if(alertView.tag == EDIT_VALUE_TAG)
    {
        if(buttonIndex == 1)
        {
            NSString* s = [[alertView textFieldAtIndex:0] text];
            if(![s isEqualToString:@""])
            {
                switch (type) {
                    case glucoseMeasurementType:
                        if ([[ UnitsManager getInstance] GetGlucoseUnits] == mmolL)
                            value = [s doubleValue]*18;
                        else
                            value = [s intValue];
                        break;
                    case medicineMeasurementType:
                        value = [s intValue];
                        break;
                    case weightMeasurementType:
                        value = [s intValue];
                        break;
                    default:
                        value = -1;
                        break;
                }
                
                [self UpdateUI];
            }
        }
        else //cancel
        {
            if(value == -1)
                [self Close:nil];
        }
    }
}

- (void) wobbleValueLabel
{
    shouldWobble = YES;
}
-(void)WobbleAnimation
{
    [self.resultValueLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    CGAffineTransform leftWobble = CGAffineTransformMakeScale(1.1, 1.1);
    CGAffineTransform rightWobble = CGAffineTransformMakeScale(0.9, 0.9);
    self.resultValueLabel.transform = leftWobble;  // starting point
    [UIView animateWithDuration:0.25 delay:0 options:(UIViewAnimationOptionRepeat | UIViewAnimationOptionAutoreverse) animations:^{
        [UIView setAnimationRepeatCount:5];
        self.resultValueLabel.transform = rightWobble;
    }completion:^(BOOL finished){
        self.resultValueLabel.transform =CGAffineTransformIdentity;
    }];
}



CustomIOSAlertView *alertView;
- (IBAction)EditValueClicked:(id)sender
{
    NSString* message = @"";
    switch (type) {
        case glucoseMeasurementType:
            message = [NSString stringWithFormat:@"%@ [%@]",loc(@"Enter_measurement"), [[UnitsManager getInstance] GetGlucoseUnitsLocalizedString]];
            break;
        case medicineMeasurementType:
            message = [NSString stringWithFormat:@"%@ [%@]",loc(@"Enter_medicine_amount"), loc(@"Units")];
            break;
        case foodMeasurementType:
            message = [NSString stringWithFormat:@"%@ [%@]",loc(@"Set_food_amount"), loc(@"Units")];
            break;
        case activityMeasurementType:
            message = [NSString stringWithFormat:@"%@ [%@]",loc(@"Set_activity_amount"), loc(@"Units")];
            break;
        case weightMeasurementType:
            message = [NSString stringWithFormat:@"%@ ",loc(@"Enter_your_weight")];
            break;
        default:
            break;
    }

    
    if(newMeasurement && type == medicineMeasurementType && relatedDiaryEntry != nil)
    {
        alertView = [[CustomIOSAlertView alloc] init];
        MedicineDialog *customView = (MedicineDialog*)[[[NSBundle mainBundle] loadNibNamed:@"MedicineDialog" owner:nil options:nil] objectAtIndex:0];
        [customView setDelegate:self];
        [customView SetSpecificMedicine:[relatedDiaryEntry.dosage intValue] tagId:[relatedDiaryEntry SuggestedTagId] name:[NSString stringWithFormat:@"%@ %@",relatedDiaryEntry.name, HourAsComponentOfDay((int)relatedDiaryEntry.dueDate.hour)]];
        if(value > -1)
            [customView SetValue:[NSString stringWithFormat:@"%d", value]];
        
        [alertView setContainerView:customView];
        [alertView setButtonTitles:[NSMutableArray arrayWithObjects:loc(@"Cancel"), loc(@"Update"), nil]];
        [alertView setOnButtonTouchUpInside:^(CustomIOSAlertView *alertView, int buttonIndex) {
            if(buttonIndex == 0)
            {
                if(value == -1)
                    [self Close:nil];
                [alertView close];
            }
            else
            {
                value = [customView GetValue];
                [self UpdateUI];
                [alertView close];
            }
        }];
        
        [alertView show];
    }
    else if(type == glucoseMeasurementType || type == medicineMeasurementType || type == weightMeasurementType)
    {
        NSString* inputType = @"Glucose";
        if(type == medicineMeasurementType)
            inputType = @"Medicine";
        if(type == weightMeasurementType)
            inputType = @"Weight";
            
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"%@ %@", loc(inputType), loc(@"Manual_input")] message:message delegate:self cancelButtonTitle:loc(@"Cancel") otherButtonTitles:loc(@"Update"), nil];
        
        alert.alertViewStyle = UIAlertViewStylePlainTextInput;
        UITextField* tf = [alert textFieldAtIndex:0];
        tf.keyboardType = UIKeyboardTypeNumberPad;
        alert.tag = EDIT_VALUE_TAG;
        switch (type) {
            case glucoseMeasurementType:
                if(value > -1)
                    tf.text = [[UnitsManager getInstance] GetGlucoseStringValueForCurrentUnit:value];
                if([[UnitsManager getInstance] GetGlucoseUnits] == mmolL)
                    tf.keyboardType = UIKeyboardTypeDecimalPad;
                else
                    tf.keyboardType = UIKeyboardTypeNumberPad;
                break;
            case medicineMeasurementType:
                if(value > -1)
                    tf.text = [NSString stringWithFormat:@"%d", value];
                break;
            case weightMeasurementType:
                if(value > -1)
                    tf.text = [NSString stringWithFormat:@"%d", value];
                break;
            default:
                break;
        }
        
        
        [alert show];
    }
    else
    {
        alertView = [[CustomIOSAlertView alloc] init];
        FoodActivityView *customView = (FoodActivityView*)[[[NSBundle mainBundle] loadNibNamed:@"FoodActivityView" owner:nil options:nil] objectAtIndex:0];
        [customView setDelegate:self];
        
        if(type == foodMeasurementType)
        {
            [customView SetType:foodType];
        }
        else
        {
            [customView SetType:activityType];
        }
        
        [alertView setContainerView:customView];
        
        [alertView setButtonTitles:[NSMutableArray arrayWithObjects:loc(@"Cancel"), nil]];
        
        [alertView setOnButtonTouchUpInside:^(CustomIOSAlertView *alertView, int buttonIndex) {
            if(value == -1)
                [self Close:nil];
            [alertView close];
        }];
        
        [alertView show];
    }
}
-(void)AmountSelected:(int)amount
{
    value = amount;
    [self UpdateUI];
    [alertView close];
}

-(void)MedicineAmountSelected:(int)amount tagId:(NSString*)tagId
{
    value = amount;
    [tagsView SetActiveTags:@[tagId]];
    [self UpdateUI];
    [alertView close];
}

- (IBAction)editDateClicked:(id)sender
{
    RMDateSelectionViewController* picker = [RMDateSelectionViewController dateSelectionController];
    picker.datePicker.maximumDate = [NSDate date];
    picker.disableBlurEffects = true;
    picker.delegate = self;
    picker.view.tag = 0;
    if(originalDate != nil)
        picker.datePicker.date = originalDate;
    [picker show];
}

/**
 tagsview delegate methods*/
-(void)tagSelectionChanged:(TagsView*)tagsView
{
    [self UpdateUI];
}

-(NSString*)labelForTag:(long)tagId
{
    if(tagId >= 50 && tagId < 100) //medication
    {
        if(tagId == 50)
        {
            Treatment* t = [Treatment GetBasal];
            if(t != nil) return t.treatmentTypeName;
        }
        if(tagId == 51)
        {
            Treatment* t = [Treatment GetBolusMorning];
            if(t != nil) return [NSString stringWithFormat:@"%@ %@",t.treatmentTypeName, loc(@"morning")];
        }
        if(tagId == 52)
        {
            Treatment* t = [Treatment GetBolusNoon];
            if(t != nil) return [NSString stringWithFormat:@"%@ %@",t.treatmentTypeName, loc(@"noon")];
        }
        if(tagId == 53)
        {
            Treatment* t = [Treatment GetBolusEvening];
            if(t != nil) return [NSString stringWithFormat:@"%@ %@",t.treatmentTypeName, loc(@"evening")];
        }
    }
    return nil;
}
/**
 This method is called when the user selects a certain date.
 
 @param vc      The date selection view controller that just finished selecting a date.
 @param aDate   The selected date.
 */
- (void)dateSelectionViewController:(RMDateSelectionViewController *)vc didSelectDate:(NSDate *)aDate
{
    date = aDate;
    [self UpdateUI];
}

/**
 This method is called when the user selects the cancel button or taps the darkened background (if the property [backgroundTapsDisabled]([RMDateSelectionViewController backgroundTapsDisabled]) of RMDateSelectionViewController returns NO).
 
 @param vc  The date selection view controller that just canceled.
 */
- (void)dateSelectionViewControllerDidCancel:(RMDateSelectionViewController *)vc
{
    
}
@end
