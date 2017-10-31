//
//  RemindersTableViewController.m
//  GlucoMe - Mobile
//
//  Created by dovi winberger on 5/5/15.
//  Copyright (c) 2015 Yiftah Ben Aharon. All rights reserved.
//

#import "RemindersTableViewController.h"
#import "FullTableViewControllerNew.h"
#import "general.h"
#import "ReminderCell.h"
#import "AddReminderViewController.h"

@interface RemindersTableViewController() <AddReminderViewControllerDelegateProtocol>


@end

@implementation RemindersTableViewController
@synthesize store;


-(void)viewDidLoad
{
    [super viewDidLoad];
    store = [[EKEventStore alloc] init];
    [store requestAccessToEntityType:EKEntityTypeReminder
                          completion:^(BOOL granted, NSError *error) {
                              [self init_reminders_array];
                              
                              if (!granted)
                                  
                                  NSLog(@"Access to store not granted !!!");
                          }];
    
    [self.h1Button setTitle:loc(@"Date") forState:UIControlStateNormal];
    [self.h2Button setTitle:loc(@"Name") forState:UIControlStateNormal];
    [self.h3Button setTitle:loc(@"Type") forState:UIControlStateNormal];
    
    [self.actionButton setTitle:loc(@"Add") forState:UIControlStateNormal];
    self.actionButton.hidden = NO;
    
    self.navigationItem.title = loc(@"Reminders");
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    id tracker = [[GAI sharedInstance] defaultTracker];
    
    // This screen name value will remain set on the tracker and sent with
    // hits until it is set to a new value or to nil.
    [tracker set:kGAIScreenName value:@"RemindersPage"];
    
    // manual screen tracking
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
    
}

- (void) init_reminders_array {
    
    NSArray* reminders = [self fetchReminders];
    
    [self SetTableDataFromReminders:reminders];
}

-(void)SetTableDataFromReminders:(NSArray*)reminders
{
    tableData = [[NSMutableArray alloc] init];
    for (EKReminder *reminder in reminders) {
        //NSLog(@"Reminder title: %@", reminder.title);
        EKAlarm* alarm = [[reminder alarms] objectAtIndex:0];
        NSDate* d = [alarm absoluteDate];
        if(reminder.title == nil || d == nil) {
            //  NSLog(@"NIL REMINDER %@", reminder.title);
            continue;
        }
        
        
        NSString* time = rails2iosTimeFromDate(d);
        NSString* date = rails2iosDateFromDate(d);
        
        if([reminder.recurrenceRules count] != 0) {
            date = loc(@"Daily");
        }
        NSDate *now = [NSDate date];
        
        if ([now compare:d]!=NSOrderedAscending && ![date isEqualToString:loc(@"Daily")] ) {
            continue;
        }
        
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        [dict setValue:date forKey:@"date"];
        [dict setValue:time forKey:@"time"];
        [dict setValue:reminder.title forKey:@"value"];
        NSString* type = [date isEqualToString:loc(@"Daily")] ? loc(@"Recurring") : loc(@"One time");
        [dict setValue:type forKey:@"type"];
        [dict setValue:reminder forKey:@"ekreminder"];
        [tableData addObject: dict];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });

}

-(void)fetchRemindersWithCompletionBlock:(void (^)(NSArray*))completionBlock
{
    if(store == nil)
    {
        store = [[EKEventStore alloc] init];
    }
    [store requestAccessToEntityType:EKEntityTypeReminder
                          completion:^(BOOL granted, NSError *error) {
                              NSPredicate *predicate = [store predicateForRemindersInCalendars:nil];
                              [store fetchRemindersMatchingPredicate:predicate completion:^(NSArray *ekReminders) {
                                  [self SetTableDataFromReminders:ekReminders];
                                  if(completionBlock) completionBlock(tableData);
                              }];
                              
                              if (!granted)
                                  
                                  NSLog(@"Access to store not granted !!!");
                          }];
    
    
}


-(NSArray*)fetchReminders
{
    __block NSArray *reminders = nil;
    __block BOOL fetching = YES;
    NSPredicate *predicate = [store predicateForRemindersInCalendars:nil];
    [store fetchRemindersMatchingPredicate:predicate completion:^(NSArray *ekReminders) {
        reminders   = ekReminders;
        fetching    = NO;
    }];
    
    while (fetching) {
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.01]];
    }
    return reminders;
}



- (IBAction)onActionButtonClicked:(id)sender
{
    //AddReminderViewController* ar = [[AddReminderViewController alloc] initWithNibName:loc(@"AddReminderViewController") bundle:nil];
    //ar.delegate = self;
    //[self presentViewController:ar animated:NO completion:nil];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"AddReminderSegue"]) {
        AddReminderViewController* ar = (AddReminderViewController*)segue.destinationViewController;
        ar.delegate = self;
    }
}

-(EKEventStore*)getEKEventStore
{
    return store;
}
-(void)refreshData
{
    [self init_reminders_array];
    [self.tableView reloadData];
}



-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return tableData.count;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier = @"reminderCellID";
    
    ReminderCell *cell = (ReminderCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = (ReminderCell*)[[ReminderCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    NSDictionary* dict = (NSDictionary*)[tableData objectAtIndex:indexPath.row];
    
    NSString* time = [[NSString alloc] initWithFormat:@"%@", [dict valueForKey:@"time"]];
    NSString* date =  [[NSString alloc] initWithFormat:@"%@", [dict valueForKey:@"date"]];
    NSString* name = [[NSString alloc] initWithFormat:@"%@", [dict valueForKey:@"value"]];
    NSString* type = [[NSString alloc] initWithFormat:@"%@", [dict valueForKey:@"type"]];
    
    [cell setRowData:date :time :name :type];
    
    return cell;
}



-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(editingStyle == UITableViewCellEditingStyleDelete)
    {
        [self DeleteReminder:indexPath];
    }
}

-(NSArray*)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewRowAction* delete = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:loc(@"Delete") handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
        [self DeleteReminder:indexPath];
    }];
    
    return @[delete];
}

-(void)DeleteReminder:(NSIndexPath*)indexPath
{
    NSDictionary* dict = (NSDictionary*)[tableData objectAtIndex:indexPath.row];

    NSError *err;
    EKReminder* reminder = [dict objectForKey:@"ekreminder"];
    if([store removeReminder:reminder commit:YES error:&err])
    {
        [tableData removeObjectAtIndex:indexPath.row];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"DataChanged" object:nil];
    }
    
    [self.tableView reloadData];
}





@end
