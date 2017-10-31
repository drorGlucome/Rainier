//
//  AddReminderViewController.m
//  GlucoMe
//
//  Created by Yiftah Ben Aharon on 11/28/13.
//
//

#import "AddReminderViewController.h"
#import "general.h"

@interface AddReminderViewController ()<UITextFieldDelegate>



@end

@implementation AddReminderViewController
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.screenName = @"AddReminderViewController";
    
    [self UnselectAllRecurring];
    [self SelectRecurringAtIndex:0];//default
    
    self.nameLabel.text = loc(@"Name");
    self.repeatLabel.text = loc(@"Repeat");
    self.timerLabel.text = loc(@"Timer");
    
    [self.nameLabel setTextAlignment:NSTextAlignmentNatural];
    [self.repeatLabel setTextAlignment:NSTextAlignmentNatural];
    [self.timerLabel setTextAlignment:NSTextAlignmentNatural];
    
    
    self.reminderName.placeholder = loc(@"e_g_Morning_reminder");
    [self.reminderName setTextAlignment:NSTextAlignmentNatural];
    
    [self.saveButton setTitle:loc(@"Save") forState:UIControlStateNormal];
    [self.cancelButton setTitle:loc(@"Cancel") forState:UIControlStateNormal];
    
    ((UILabel*)self.recurringLabels[0]).text = loc(@"Recurring_daily");
    ((UILabel*)self.recurringLabels[1]).text = loc(@"One_time");

    [((UILabel*)self.recurringLabels[0]) setTextAlignment:NSTextAlignmentNatural];
    [((UILabel*)self.recurringLabels[1]) setTextAlignment:NSTextAlignmentNatural];

    self.title = loc(@"Reminders");
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.reminderName.delegate = self;

    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)done:(id)sender {

    if(self.reminderName.text.length == 0) {
        NSString* msg = @"Reminder name cannot be empty";
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Sorry"
                                                        message:msg
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        return;
    }

    EKEventStore* store = [self.delegate getEKEventStore];
    EKReminder *reminder = [EKReminder
                            reminderWithEventStore:store];

    reminder.title = self.reminderName.text;
    reminder.calendar = [store defaultCalendarForNewReminders];
    NSDate *date = [[NSDate alloc] initWithTimeInterval:0 sinceDate:[self.reminderDate date]];

    EKAlarm *alarm = [EKAlarm alarmWithAbsoluteDate:date];
    [reminder addAlarm:alarm];
    
    if([self GetSelectedRecurringIndex] == 0)
    {
        //unsigned hourAndMinuteFlags = NSHourCalendarUnit | NSMinuteCalendarUnit;
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSDateComponents* components = [[NSDateComponents alloc] init];
        [components setHour:[calendar components:NSCalendarUnitHour  fromDate:date].hour];
        [components setMinute:[calendar components:NSCalendarUnitMinute  fromDate:date].minute];
        [components setDay:[calendar components:NSCalendarUnitDay  fromDate:date].day];
        [components setMonth:[calendar components:NSCalendarUnitMonth  fromDate:date].month];
        [components setYear:[calendar components:NSCalendarUnitYear  fromDate:date].year];
        [reminder setDueDateComponents:components];
        
        EKRecurrenceRule *rule = [[EKRecurrenceRule alloc]
                                  initRecurrenceWithFrequency:EKRecurrenceFrequencyDaily
                                  interval:1
                                  end:nil];
        [reminder addRecurrenceRule:rule];
    }


    NSError *error = nil;
    [store saveReminder:reminder commit:YES error:&error];

    [self.delegate refreshData];
    [self dismissViewControllerAnimated:YES completion:nil];

    [[NSNotificationCenter defaultCenter] postNotificationName:@"DataChanged" object:nil];

//    [[NSNotificationCenter defaultCenter] postNotificationName:@"DismissAddReminderViewController" object:nil];
    
    
    
//
  //  }];




    
    

    
}

- (IBAction)cancel:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)reminderTypeValueChanged:(id)sender
{
    if([self.recurringButtons indexOfObject:sender] == 0)
    {
        self.reminderDate.datePickerMode = UIDatePickerModeTime;
    }
    else
    {
        self.reminderDate.datePickerMode = UIDatePickerModeDateAndTime;
    }
    
    [self UnselectAllRecurring];
    [self SelectRecurringAtIndex:(int)[self.recurringButtons indexOfObject:sender]];
}

-(void)UnselectAllRecurring
{
    for(UIImageView* im in self.recurringCheckMarks)
    {
        im.hidden = YES;
    }
}

-(void)SelectRecurringAtIndex:(int)i
{
    UIImageView* im = self.recurringCheckMarks[i];
    im.hidden = NO;
}

-(int)GetSelectedRecurringIndex
{
    for(UIImageView* im in self.recurringCheckMarks)
    {
        if(im.hidden == NO)
        {
            return (int)[self.recurringCheckMarks indexOfObject:im];
        }
    }
    return 0;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    return YES;
}

@end
