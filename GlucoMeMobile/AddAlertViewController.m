//
//  AddAlertViewController.m
//  audioGraph
//
//  Created by Yiftah Ben Aharon on 9/13/12.
//
//

#import "AddAlertViewController.h"
#import "AlertType.h"
#import "MediaType.h"
#import "Alert_helper.h"

@interface AddAlertViewController () <UIActionSheetDelegate>

@end

@implementation AddAlertViewController

@synthesize selectedAlert;
@synthesize selectedContact;
@synthesize selectedEmail;
@synthesize selectedFax;
@synthesize selectedMobile;
@synthesize alertPicker;
@synthesize selectedManually;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.screenName = @"AddAlertViewController";
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self init_alerts_array];
    [self init_media_selection];
    selectedContact = @"";
    [alertPicker selectRow:alerts.count/2 inComponent:0 animated:NO];
    selectedAlert = [alerts objectAtIndex:alerts.count/2];
    [self mediaSelectionChanged:self.mediaSelection];

}

- (void)viewDidUnload
{
    [self setMediaSelection:nil];
    [self setAlertPicker:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}




- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)thePickerView {
    
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)thePickerView numberOfRowsInComponent:(NSInteger)component {
    
    return [alerts count];
}

- (NSString *)pickerView:(UIPickerView *)thePickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return [alerts objectAtIndex:row];
}

- (void)pickerView:(UIPickerView *)thePickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    
    self.selectedAlert = [alerts objectAtIndex:row];
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view{
    UILabel* tView = (UILabel*)view;
    if (!tView){
        tView = [[UILabel alloc] init];
        // Setup label properties - frame, font, colors etc
    }
    [tView setText:[alerts objectAtIndex:row]];
    return tView;
}

- (IBAction)done:(id)sender
{
    if(selectedAlert != nil)
    {
        NSString* media_type = [self.mediaSelection titleForSegmentAtIndex:self.mediaSelection.selectedSegmentIndex];
        NSString* details = [[NSString alloc] initWithString:self.detailsTextbox.text];
        if(details == nil || details.length == 0)
        {
            NSString* msg = [[NSString alloc] initWithFormat:@"%@ (%@)", @"Couldn't set an alert. Contact is missing", media_type];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Add Alert"
                                                            message:msg
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
            return;
            
        }
        else
        {
            /*NSString* key = [alerts objectAtIndex:[alertPicker selectedRowInComponent:0] ];
            int alertId = [[alertToId objectForKey:key] intValue];
            key = media_type;
            int mediaId = [[mediaToId objectForKey:key] intValue];
            
            [Alert SaveAlertAndSendToServerWithWho:details when:alertId how:mediaId completionBlock:^(Alert *a)
             {
                 [[NSNotificationCenter defaultCenter] postNotificationName:@"DataChanged" object:nil];
            }];*/
            
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }
}

- (IBAction)cancel:(id)sender {
    selectedAlert = nil;
    [self dismissViewControllerAnimated:YES completion:nil];
}

ABPeoplePickerNavigationController *peoplePickerController;
- (IBAction)selectContact:(id)sender {
    peoplePickerController = [[ABPeoplePickerNavigationController alloc] init];

    [self presentViewController:peoplePickerController animated:YES completion:nil];
    peoplePickerController.peoplePickerDelegate = self;
}

- (void)peoplePickerNavigationController:(ABPeoplePickerNavigationController*)peoplePicker didSelectPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier
{
    
}

//ios 9
- (void)peoplePickerNavigationController:(ABPeoplePickerNavigationController*)peoplePicker didSelectPerson:(ABRecordRef)person
{
    int emailIndex = 0;
    for (int i = 0; i < self.mediaSelection.numberOfSegments; i++) {
        if([[((NSString*)[self.mediaSelection titleForSegmentAtIndex:i]) lowercaseString] isEqualToString:@"email"])
        {
            emailIndex = i;
        }
    }
    
    int property = (self.mediaSelection.selectedSegmentIndex == emailIndex) ? kABPersonEmailProperty : kABPersonPhoneProperty;
    NSDictionary* dict = [self dictionaryRepresentationForABPerson:person property:property];
    [peoplePicker dismissViewControllerAnimated:YES completion:nil];
    
    UIActionSheet *popup = [[UIActionSheet alloc] initWithTitle: @"Select contact details"
                                                       delegate: self
                                              cancelButtonTitle: nil
                                         destructiveButtonTitle: nil
                                              otherButtonTitles: nil];
    NSArray* titles = [dict allValues];
    for( NSString *title in titles)  {
        [popup addButtonWithTitle:title];
    }
    
    [popup addButtonWithTitle:@"Cancel"];
    popup.cancelButtonIndex = [titles count];
    
    
    
    popup.tag = 1;
    if(titles.count == 0) {
        NSString* msg = @"Contact has no relevant details";
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Sorry"
                                                        message:msg
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
    else {
        [popup showInView:[UIApplication sharedApplication].keyWindow];
    }
    
    //return NO;
}

//ios 7
-(BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person
{
    
    int emailIndex = 0;
    for (int i = 0; i < self.mediaSelection.numberOfSegments; i++) {
        if([[((NSString*)[self.mediaSelection titleForSegmentAtIndex:i]) lowercaseString] isEqualToString:@"email"])
        {
            emailIndex = i;
        }
    }
    
    int property = (self.mediaSelection.selectedSegmentIndex == emailIndex) ? kABPersonEmailProperty : kABPersonPhoneProperty;
    NSDictionary* dict = [self dictionaryRepresentationForABPerson:person property:property];
    [peoplePicker dismissViewControllerAnimated:YES completion:nil];

    UIActionSheet *popup = [[UIActionSheet alloc] initWithTitle: @"Select contact details"
                                                       delegate: self
                                              cancelButtonTitle: nil
                                         destructiveButtonTitle: nil
                                              otherButtonTitles: nil];
    NSArray* titles = [dict allValues];
    for( NSString *title in titles)  {
        [popup addButtonWithTitle:title];
    }
    
    [popup addButtonWithTitle:@"Cancel"];
    popup.cancelButtonIndex = [titles count];

    
    
    popup.tag = 1;
    if(titles.count == 0) {
            NSString* msg = @"Contact has no relevant details";
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Sorry"
                                                            message:msg
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
    }
    else {
        [popup showInView:[UIApplication sharedApplication].keyWindow];
    }
    
    return NO;
}

- (void)actionSheet:(UIActionSheet *)popup clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSString* title = [popup buttonTitleAtIndex:buttonIndex];
    if([title isEqualToString:@"Cancel"]) {
        return;
    }
    self.detailsTextbox.text = [[NSString alloc] initWithString:title];
}

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier
{
       return NO;
}


- (NSDictionary*) dictionaryRepresentationForABPerson:(ABRecordRef)person property:(ABPropertyID)property
{
    NSMutableDictionary* dictionary = [NSMutableDictionary dictionary];

    ABMultiValueRef ref = ABRecordCopyValue(person, property);
    for (int i=0; i < ABMultiValueGetCount(ref); i++) {
        NSString* currentPhoneLabel = (__bridge NSString*)ABMultiValueCopyLabelAtIndex(ref, i);
        NSString* currentPhoneValue = (__bridge NSString*)ABMultiValueCopyValueAtIndex(ref, i);
        if(currentPhoneLabel != nil && currentPhoneValue != nil) {
            [dictionary setObject:currentPhoneValue forKey:currentPhoneLabel];
        }
    }
    return dictionary;
}

- (void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker {
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (void) init_alerts_array {
    alerts = [[NSMutableArray alloc]   initWithObjects:
              @"After low measurement (Hippo alert)",
              @"After each measurement",
              @"After out of range measurement",
              @"After 3 days without measurement",
              @"After 5 consecutive out of range measurement",
              @"At the end of each day",nil];
    
    
    alerts = [[NSMutableArray alloc] init];
    alertToId = [[NSMutableDictionary alloc] init];
    
    NSArray* alertTypes = [AlertType MR_findAllInContext:[NSManagedObjectContext MR_defaultContext]];
    for(AlertType* alertType in alertTypes)
    {
        NSString* name = alertType.name;
        [alertToId setObject:alertType.id forKey:name];
        NSString* val = [[NSString alloc] initWithFormat:@"%@", name];
        [alerts addObject: val];
    }
    
 
}

- (void) init_media_selection {
    [self.mediaSelection removeAllSegments];
    //NSArray* types = [[NSArray alloc] initWithObjects:@"Phone call", @"SMS", @"Email", @"Fax",@"Notification", nil];
    
    
    mediaToId = [[NSMutableDictionary alloc] init];
    
    NSArray* mediaTypes = [MediaType MR_findAllInContext:[NSManagedObjectContext MR_defaultContext]];
    int i = 0;
    for (MediaType* mediaType in mediaTypes)
    {
        NSString* name  = mediaType.name;
        NSNumber* idd   = mediaType.id;
        [mediaToId setObject:idd forKey:name];
        [self.mediaSelection insertSegmentWithTitle:name atIndex:i animated:false];
        i++;
    }
    
   
    
    UIFont *font = [UIFont boldSystemFontOfSize:12.0f];
    NSDictionary *attributes = [NSDictionary dictionaryWithObject:font
                                                           forKey:NSFontAttributeName];
    [self.mediaSelection setTitleTextAttributes:attributes
                                    forState:UIControlStateNormal];
    [self.mediaSelection setSelectedSegmentIndex:0];
}

- (IBAction)manualContact:(id)sender {
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:loc(@"Manual_input") message:@"Please enter the contact details" delegate:self cancelButtonTitle:@"Done" otherButtonTitles:nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alert show];
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    NSString* value = [[NSString alloc] initWithString:[[alertView textFieldAtIndex:0] text]];
    selectedManually = value;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    
    return NO;
}

-(void)textFieldDidBeginEditing:(UITextField *)sender{
    [self scrollUp:sender];
    
}

-(void)textFieldDidEndEditing:(UITextField *)sender{
    [self scrollDown:sender];
}

- (void)scrollUp:(UITextField*)textfield {
    int offset = 150;
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3]; // if you want to slide up the view
    CGRect rect = self.view.frame;
    rect.origin.y -= offset;
    rect.size.height += offset;
    self.view.frame = rect;
    [UIView commitAnimations];
    
}

- (void)scrollDown:(UITextField*)textfield {
    int offset = 150;
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3]; // if you want to slide up the view
    CGRect rect = self.view.frame;
    rect.origin.y += offset;
    rect.size.height -= offset;
    self.view.frame = rect;
    [UIView commitAnimations];
    
}

- (IBAction)mediaSelectionChanged:(id)sender {
    NSString* media = [self.mediaSelection titleForSegmentAtIndex:self.mediaSelection.selectedSegmentIndex];
    NSString* placeholder = [[NSString alloc] initWithFormat:@"Enter %@ details", media ];
    self.detailsTextbox.placeholder = placeholder;
}

@end
