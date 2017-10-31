//
//  AddReminderViewController.h
//  GlucoMe
//
//  Created by Yiftah Ben Aharon on 11/28/13.
//
//


#import <UIKit/UIKit.h>
#import <EventKit/EventKit.h>
#import "BaseViewController.h"

@protocol AddReminderViewControllerDelegateProtocol <NSObject>

-(EKEventStore*)getEKEventStore;
-(void)refreshData;

@end

@interface AddReminderViewController : BaseViewController
- (IBAction)done:(id)sender;
- (IBAction)cancel:(id)sender;

@property (weak, nonatomic) IBOutlet UITextField *reminderName;
@property (weak, nonatomic) IBOutlet UIDatePicker *reminderDate;

@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray* recurringButtons;
@property (strong, nonatomic) IBOutletCollection(UIImageView) NSArray* recurringCheckMarks;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray* recurringLabels;


@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *repeatLabel;
@property (weak, nonatomic) IBOutlet UILabel *timerLabel;

@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UIButton *saveButton;


- (IBAction)reminderTypeValueChanged:(id)sender;

@property (retain, nonatomic) id<AddReminderViewControllerDelegateProtocol> delegate;

@end
