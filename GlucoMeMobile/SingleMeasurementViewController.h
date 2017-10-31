//
//  LogDetailedViewController.h
//  GlucoMe - Mobile
//
//  Created by Yiftah Ben Aharon on 8/14/14.
//  Copyright (c) 2014 Yiftah Ben Aharon. All rights reserved.
//
// this is the a single measurement view, where you can tag and add comment

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "Measurement_helper.h"
#import "TagsView.h"


@interface SingleMeasurementViewController : BaseViewController
{
    BOOL allowCancel;
    BOOL shouldWobble;
    //NSString* tempComment;
    TagsView* tagsView;
    
    double remindViewHeight;
    
    BOOL newMeasurement;
    NSString* source;
    NSString* uuid;
    int type;
    int value;
    int originalValue;
    NSDate* originalDate;
    NSDate* date;
    NSString* comment;
    NSString* tags;
    
    TreatmentDiary* relatedDiaryEntry;
}


@property(nonatomic, retain) NSDate *previousTime;
@property (weak, nonatomic) IBOutlet UIButton *saveButton;
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UIButton *saveAndInjectButton;
@property (weak, nonatomic) IBOutlet UIButton *saveButtonsSeperator;

@property (weak, nonatomic) IBOutlet UIView *tagsContainer;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tagsContainerHeightConstraint;

@property (weak, nonatomic) IBOutlet UITextView *noteTextView;

@property (weak, nonatomic) IBOutlet UILabel *tagResultTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *notesTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *resultDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *resultTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *resultValueLabel;
@property (weak, nonatomic) IBOutlet UILabel *resultValueUnitsLabel;

@property (weak, nonatomic) IBOutlet UIImageView *resultBackgroundImageView;


@property (weak, nonatomic) IBOutlet UIImageView *editDateIcon;
@property (weak, nonatomic) IBOutlet UIImageView *editValueIcon;
@property (weak, nonatomic) IBOutlet UIButton *editDateButton;
@property (weak, nonatomic) IBOutlet UIButton *editValueButton;

@property (weak, nonatomic) IBOutlet UIView *remindView;
@property (weak, nonatomic) IBOutlet UISwitch *remindSwitch;
@property (weak, nonatomic) IBOutlet UILabel *remindLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *remindViewHeightConstraint;


@property (nonatomic) BOOL allowCancel;

//user either one but not each. one will cancel the other
-(void)SetType:(MeasurementType)type source:(NSString*)source; //use to create new measurement
-(void)SetMeasurement:(Measurement*)m; //use to update an existing measurement
-(void)SetTreatmentDiary:(TreatmentDiary*)t;

-(void)wobbleValueLabel;


@end
