//
//  ShareProcess1ViewController.m
//  GlucoMe - Mobile
//
//  Created by dovi winberger on 08/03/2016.
//  Copyright © 2016 Yiftah Ben Aharon. All rights reserved.
//
#import "Utilities.h"
#import "ShareProcess1ViewController.h"
#import "MediaType_helper.h"
#import "ShareProcees2TableViewController.h"
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import "NSString+EmailAddresses.h"
#import "general.h"
#import "NBPhoneNumberUtil.h"
#import "NBPhoneNumber.h"

#import <ContactsUI/ContactsUI.h>

@interface ShareProcess1ViewController () <ShareProcees2DelegateProtocol, UITextFieldDelegate, ABPeoplePickerNavigationControllerDelegate>
@property (nonatomic) NSMutableDictionary* lastContactEmails;
@property (nonatomic) NSMutableDictionary* lastContactPhones;
@end

@implementation ShareProcess1ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.shareWithSmsButton setTitle:loc(@"SMS") forState:UIControlStateNormal];
    [self.shareWithPhoneButton setTitle:loc(@"Phone") forState:UIControlStateNormal];
    [self.shareWithEmailButton setTitle:loc(@"Email") forState:UIControlStateNormal];
    
    self.lastContactEmails = [[NSMutableDictionary alloc] init];
    self.lastContactPhones = [[NSMutableDictionary alloc] init];
    
    [self ShareWithSMSClicked:nil];
    
    if ([MediaType MediaTypeForEnum:SMS] == nil) {
        self.shareWithSmsButton.hidden = YES;
    }
    if ([MediaType MediaTypeForEnum:Email] == nil) {
        self.shareWithEmailButton.hidden = YES;
    }
    if ([MediaType MediaTypeForEnum:Phone] == nil) {
        self.shareWithPhoneButton.hidden = YES;
    }
    
    if(initialContactDetails != nil)
    {
        self.contactNameTextField.text = initialContactName;
        if(initialRelationship == nil || [initialRelationship isEqualToString:@""])
            self.relationshipLabel.text = loc(@"Relationship");
        
        switch (initialMediaType) {
            case SMS:
                [self.lastContactPhones setValue:initialContactDetails forKey:[self randomStringWithLength:8]];
                [self ShareWithSMSClicked:nil];
                break;
            case Email:
                [self.lastContactEmails setValue:initialContactDetails forKey:[self randomStringWithLength:8]];
                [self ShareWithEmailClicked:nil];
                break;
            case Phone:
                [self.lastContactPhones setValue:initialContactDetails forKey:[self randomStringWithLength:8]];
                [self ShareWithPhoneClicked:nil];
            default:
                break;
        };
    }
    
    UITapGestureRecognizer* gs = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTap)];
    [self.view addGestureRecognizer:gs];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
   
    self.navigationItem.title = loc(@"Share");
    
//    [self.shareWithEmailButton sizeToFit];
    if ([UIApplication sharedApplication].userInterfaceLayoutDirection == UIUserInterfaceLayoutDirectionRightToLeft)
    {
        self.shareWithEmailButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        self.shareWithEmailButton.imageEdgeInsets = UIEdgeInsetsMake(0, 20, 0, 10);
        self.shareWithEmailButton.titleEdgeInsets = UIEdgeInsetsMake(0, 20, 0, 20);
        
        self.shareWithSmsButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        self.shareWithSmsButton.imageEdgeInsets = UIEdgeInsetsMake(0, 20, 0, 10);
        self.shareWithSmsButton.titleEdgeInsets = UIEdgeInsetsMake(0, 20, 0, 20);
        
        self.shareWithPhoneButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        self.shareWithPhoneButton.imageEdgeInsets = UIEdgeInsetsMake(0, 20, 0, 10);
        self.shareWithPhoneButton.titleEdgeInsets = UIEdgeInsetsMake(0, 20, 0, 20);
        
        self.chooseContact.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    }
    
    self.shareWithEmailButton.titleLabel.numberOfLines = 1;
    self.shareWithEmailButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    self.shareWithEmailButton.titleLabel.lineBreakMode = NSLineBreakByClipping;
    
    self.shareWithSmsButton.titleLabel.numberOfLines = 1;
    self.shareWithSmsButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    self.shareWithSmsButton.titleLabel.lineBreakMode = NSLineBreakByClipping;
    
    self.shareWithPhoneButton.titleLabel.numberOfLines = 1;
    self.shareWithPhoneButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    self.shareWithPhoneButton.titleLabel.lineBreakMode = NSLineBreakByClipping;

    
    [self.cancelButton setTitle:loc(@"Cancel") forState:UIControlStateNormal];
    if ([UIApplication sharedApplication].userInterfaceLayoutDirection == UIUserInterfaceLayoutDirectionRightToLeft) {
        [self.cancelButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
    }
    [self.continueButton setTitle:loc(@"Continue") forState:UIControlStateNormal];
    if ([UIApplication sharedApplication].userInterfaceLayoutDirection == UIUserInterfaceLayoutDirectionRightToLeft) {
        [self.continueButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    }
    
    self.shareWithWhomLabel.text = loc(@"share_with_whom");
    self.howToShareLabel.text = loc(@"How_to_share");
    
    [self.chooseContact setTitle:loc(@"Choose_contact") forState:UIControlStateNormal];
    [self.chooseContact.titleLabel setTextAlignment:NSTextAlignmentNatural];
    
    self.contactNameTextField.placeholder = loc(@"Name");
    
    self.relationshipLabel.text = loc(@"Relationship");
    self.chooseRelationshipLabel.text = loc(@"Choose_relationship");
    
}
-(void)onTap
{
    [self.contactDetailsTextField resignFirstResponder];
    [self.contactNameTextField resignFirstResponder];
}

/*-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)replacementString
{
    NSString * proposedNewString = [[textField text] stringByReplacingCharactersInRange:range withString:replacementString];
    if([proposedNewString isValidEmailAddress])
    {
        [self ShareWithEmailClicked:nil];
    }
    return YES;
}*/
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    
    return NO;
}

NSString *myletters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";

-(NSString *) randomStringWithLength: (int) len {
    
    NSMutableString *randomString = [NSMutableString stringWithCapacity: len];
    
    for (int i=0; i<len; i++) {
        [randomString appendFormat: @"%C", [myletters characterAtIndex: arc4random_uniform((int)[myletters length])]];
    }
    
    return randomString;
}

- (IBAction)ShareWithSMSClicked:(id)sender {
    [self.contactDetailsTextField resignFirstResponder];
    [self.contactNameTextField resignFirstResponder];
    
    [self.shareWithSmsButton    setBackgroundImage:[UIImage imageNamed:@"tagButtonBackgroundActive"] forState:UIControlStateNormal];
    [self.shareWithEmailButton  setBackgroundImage:[UIImage imageNamed:@"tagButtonBackgroundNormal"] forState:UIControlStateNormal];
    [self.shareWithPhoneButton  setBackgroundImage:[UIImage imageNamed:@"tagButtonBackgroundNormal"] forState:UIControlStateNormal];

    [self.shareWithSmsButton    setImage:[UIImage imageNamed:@"how_sms_big_active"] forState:UIControlStateNormal];
    [self.shareWithEmailButton  setImage:[UIImage imageNamed:@"how_email_big"] forState:UIControlStateNormal];
    [self.shareWithPhoneButton  setImage:[UIImage imageNamed:@"how_phone_big"] forState:UIControlStateNormal];
    
    [self.shareWithSmsButton    setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.shareWithEmailButton  setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.shareWithPhoneButton  setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];

    if(selectedMediaType == Email)
    {
        if(![self.contactDetailsTextField.text isEqualToString:@""] && ![[self.lastContactEmails allValues] containsObject:self.contactDetailsTextField.text])
        {
            [self.lastContactEmails setValue:self.contactDetailsTextField.text forKey:[self randomStringWithLength:8]];
        }
        self.contactDetailsTextField.text = @"";
    }
    selectedMediaType = SMS;
    
    [self SelectFromLastSelectedContactDetails];
    
    self.contactDetailsTextField.placeholder = loc(@"Phone_number");
    [self.contactDetailsTextField setKeyboardType:UIKeyboardTypePhonePad];
}

- (IBAction)ShareWithEmailClicked:(id)sender {
    [self.contactDetailsTextField resignFirstResponder];
    [self.contactNameTextField resignFirstResponder];
    
    [self.shareWithSmsButton    setBackgroundImage:[UIImage imageNamed:@"tagButtonBackgroundNormal"] forState:UIControlStateNormal];
    [self.shareWithEmailButton  setBackgroundImage:[UIImage imageNamed:@"tagButtonBackgroundActive"] forState:UIControlStateNormal];
    [self.shareWithPhoneButton  setBackgroundImage:[UIImage imageNamed:@"tagButtonBackgroundNormal"] forState:UIControlStateNormal];
    
    [self.shareWithSmsButton    setImage:[UIImage imageNamed:@"how_sms_big"] forState:UIControlStateNormal];
    [self.shareWithEmailButton  setImage:[UIImage imageNamed:@"how_email_big_active"] forState:UIControlStateNormal];
    [self.shareWithPhoneButton  setImage:[UIImage imageNamed:@"how_phone_big"] forState:UIControlStateNormal];
    
    [self.shareWithSmsButton    setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.shareWithEmailButton  setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.shareWithPhoneButton  setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    
    if(![self.contactDetailsTextField.text isEqualToString:@""] && ![[self.lastContactPhones allValues] containsObject:self.contactDetailsTextField.text])
    {
        [self.lastContactPhones setValue:self.contactDetailsTextField.text forKey:[self randomStringWithLength:8]];
    }
    self.contactDetailsTextField.text = @"";
    
    selectedMediaType = Email;
    
    [self SelectFromLastSelectedContactDetails];
    
    self.contactDetailsTextField.placeholder = loc(@"Email");
    [self.contactDetailsTextField setKeyboardType:UIKeyboardTypeEmailAddress];
}

- (IBAction)ShareWithPhoneClicked:(id)sender {
    [self.contactDetailsTextField resignFirstResponder];
    [self.contactNameTextField resignFirstResponder];
    
    [self.shareWithSmsButton    setBackgroundImage:[UIImage imageNamed:@"tagButtonBackgroundNormal"] forState:UIControlStateNormal];
    [self.shareWithEmailButton  setBackgroundImage:[UIImage imageNamed:@"tagButtonBackgroundNormal"] forState:UIControlStateNormal];
    [self.shareWithPhoneButton  setBackgroundImage:[UIImage imageNamed:@"tagButtonBackgroundActive"] forState:UIControlStateNormal];
    
    [self.shareWithSmsButton    setImage:[UIImage imageNamed:@"how_sms_big"] forState:UIControlStateNormal];
    [self.shareWithEmailButton  setImage:[UIImage imageNamed:@"how_email_big"] forState:UIControlStateNormal];
    [self.shareWithPhoneButton  setImage:[UIImage imageNamed:@"how_phone_big_active"] forState:UIControlStateNormal];
    
    [self.shareWithSmsButton    setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.shareWithEmailButton  setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.shareWithPhoneButton  setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    if(selectedMediaType == Email)
    {
        if(![self.contactDetailsTextField.text isEqualToString:@""] && ![[self.lastContactEmails allValues] containsObject:self.contactDetailsTextField.text])
        {
            [self.lastContactEmails setValue:self.contactDetailsTextField.text forKey:[self randomStringWithLength:10]];
        }
        self.contactDetailsTextField.text = @"";
    }
    
    selectedMediaType = Phone;
    [self SelectFromLastSelectedContactDetails];
    
    self.contactDetailsTextField.placeholder = loc(@"Phone_number");
    [self.contactDetailsTextField setKeyboardType:UIKeyboardTypePhonePad];
}
- (IBAction)SelectRelationship:(id)sender
{
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:loc(@"Relationship")
                                          message:@""
                                          preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction* parent = [UIAlertAction
                         actionWithTitle:loc(@"Parent")
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction * action)
                         {
                             self.relationshipLabel.text = loc(@"Parent");
                         }];
    UIAlertAction* spouse = [UIAlertAction
                             actionWithTitle:loc(@"Spouse")
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action)
                             {
                                 self.relationshipLabel.text = loc(@"Spouse");
                             }];
    UIAlertAction* caregiver = [UIAlertAction
                             actionWithTitle:loc(@"Caregiver")
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action)
                             {
                                 self.relationshipLabel.text = loc(@"Caregiver");
                             }];
    UIAlertAction* child = [UIAlertAction
                            actionWithTitle:loc(@"Child")
                            style:UIAlertActionStyleDefault
                            handler:^(UIAlertAction * action)
                            {
                                self.relationshipLabel.text = loc(@"Child");
                            }];
    UIAlertAction* physician = [UIAlertAction
                             actionWithTitle:loc(@"Physician")
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action)
                             {
                                 self.relationshipLabel.text = loc(@"Physician");
                             }];
    UIAlertAction* other = [UIAlertAction
                            actionWithTitle:loc(@"Other")
                            style:UIAlertActionStyleDefault
                            handler:^(UIAlertAction * action)
                            {
                                self.relationshipLabel.text = loc(@"Other");
                            }];
    UIAlertAction* cancel = [UIAlertAction
                             actionWithTitle:loc(@"Cancel")
                             style:UIAlertActionStyleCancel
                             handler:^(UIAlertAction * action)
                             {
                                 
                             }];
    
    
    [alertController addAction:parent];
    [alertController addAction:spouse];
    [alertController addAction:caregiver];
    [alertController addAction:child];
    [alertController addAction:physician];
    [alertController addAction:other];
    [alertController addAction:cancel];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

- (IBAction)ChooseContactsClicked:(id)sender
{
    if([[NSProcessInfo processInfo] operatingSystemVersion].majorVersion < 10)
    {
        ABPeoplePickerNavigationController* peoplePickerController = [[ABPeoplePickerNavigationController alloc] init];
        peoplePickerController.peoplePickerDelegate = self;
        [self presentViewController:peoplePickerController animated:YES completion:nil];
    }
    else
    {
        
        CNContactPickerViewController *peoplePicker = [[CNContactPickerViewController alloc] init];
        peoplePicker.delegate = (id<CNContactPickerDelegate>)self;
        NSArray *arrKeys = @[CNContactPhoneNumbersKey, CNContactEmailAddressesKey]; //display only phone numbers
        peoplePicker.displayedPropertyKeys = arrKeys;
        [self presentViewController:peoplePicker animated:YES completion:nil];
    }
}

- (void)contactPickerDidCancel:(CNContactPickerViewController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)contactPicker:(CNContactPickerViewController *)picker didSelectContact:(CNContact *)contact
{
    self.contactNameTextField.text = [CNContactFormatter stringFromContact:contact style:CNContactFormatterStyleFullName];
    
    self.lastContactEmails = [[NSMutableDictionary alloc] initWithDictionary:[self dictionaryRepresentationForCNContact:contact property:CNContactEmailAddressesKey]];
    self.lastContactPhones = [[NSMutableDictionary alloc] initWithDictionary:[self dictionaryRepresentationForCNContact:contact property:CNContactPhoneNumbersKey]];
    
    [picker dismissViewControllerAnimated:YES completion:nil];
    [self SelectFromLastSelectedContactDetails];
}
- (void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker {
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)peoplePickerNavigationController:(ABPeoplePickerNavigationController*)peoplePicker didSelectPerson:(ABRecordRef)person
{
    self.contactNameTextField.text = (__bridge NSString*)ABRecordCopyCompositeName(person);
    
    self.lastContactEmails = [[NSMutableDictionary alloc] initWithDictionary:[self dictionaryRepresentationForABPerson:person property:kABPersonEmailProperty]];
    self.lastContactPhones = [[NSMutableDictionary alloc] initWithDictionary:[self dictionaryRepresentationForABPerson:person property:kABPersonPhoneProperty]];
    [peoplePicker dismissViewControllerAnimated:YES completion:nil];
    [self SelectFromLastSelectedContactDetails];
}
-(void)SelectFromLastSelectedContactDetails
{
    NSDictionary* dict;
    if(selectedMediaType == Email)
        dict = self.lastContactEmails;
    else
        dict = self.lastContactPhones;
    
    if(dict == nil) return;
    
    if([dict allValues].count == 1)
    {
        self.contactDetailsTextField.text = [[dict allValues] objectAtIndex:0];
        return;
    }
    
    
    UIAlertController* popup = [UIAlertController alertControllerWithTitle:@"Select contact details" message:@"" preferredStyle:UIAlertControllerStyleActionSheet];
    
    NSArray* titles = [dict allValues];
    for( NSString *title in titles)  {
        UIAlertAction* action = [UIAlertAction actionWithTitle:title style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            self.contactDetailsTextField.text = title;
        }];
        [popup addAction:action];
    }
    UIAlertAction* action = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }];
    [popup addAction:action];
    
    if(titles.count == 0) {
        /*NSString* msg = @"Contact has no relevant details";
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Sorry"
                                                        message:msg
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];*/
    }
    else {
        [self presentViewController:popup animated:YES completion:nil];
    }
    
}

- (NSDictionary*) dictionaryRepresentationForABPerson:(ABRecordRef)person property:(ABPropertyID)property
{
    NSMutableDictionary* dictionary = [NSMutableDictionary dictionary];
    
    ABMultiValueRef ref = ABRecordCopyValue(person, property);
    for (int i=0; i < ABMultiValueGetCount(ref); i++) {
        NSString* currentLabel = (__bridge NSString*)ABMultiValueCopyLabelAtIndex(ref, i);
        NSString* currentValue = (__bridge NSString*)ABMultiValueCopyValueAtIndex(ref, i);
        if(currentLabel != nil && currentValue != nil) {
            [dictionary setObject:currentValue forKey:currentLabel];
        }
    }
    return dictionary;
}

- (NSDictionary*) dictionaryRepresentationForCNContact:(CNContact*)contact property:(NSString*)property
{
    NSMutableDictionary* dictionary = [NSMutableDictionary dictionary];
    
    NSArray* values = nil;
    if([property isEqualToString:CNContactPhoneNumbersKey])
        values = contact.phoneNumbers;
    else if([property isEqualToString:CNContactEmailAddressesKey])
        values = contact.emailAddresses;
    
    for (int i = 0; i < [values count]; i++)
    {
        NSString* currentLabel = ((CNLabeledValue*)values[i]).label;
        NSString* currentValue = nil;
        if([property isEqualToString:CNContactPhoneNumbersKey])
            currentValue = ((CNPhoneNumber*)((CNLabeledValue*)values[i]).value).stringValue;
        else if([property isEqualToString:CNContactEmailAddressesKey])
            currentValue = ((CNLabeledValue*)values[i]).value;
        
        if(currentLabel != nil && currentValue != nil) {
            [dictionary setObject:currentValue forKey:currentLabel];
        }
    }
    
    return dictionary;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"continueSegue"])
    {
        ShareProcees2TableViewController* vc = segue.destinationViewController;
        vc.delegate = self;
    }
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    if ([identifier isEqualToString:@"continueSegue"])
    {
        //check input
        if([self.contactNameTextField.text isEqualToString:@""] || [self.contactDetailsTextField.text isEqualToString:@""])
            return NO;
        //check email
        if(selectedMediaType == Email)
        {
            self.contactDetailsTextField.text = [self.contactDetailsTextField.text stringByCorrectingEmailTypos];
            if(![self.contactDetailsTextField.text isValidEmailAddress])
            {
                UIAlertController *alertController = [UIAlertController
                                                      alertControllerWithTitle:loc(@"invalid_email")
                                                      message:@""
                                                      preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction* ok = [UIAlertAction
                                         actionWithTitle:@"OK"
                                         style:UIAlertActionStyleDefault
                                         handler:^(UIAlertAction * action)
                                         {
                                         }];
                [alertController addAction:ok];
                [self presentViewController:alertController animated:YES completion:nil];

                return NO;
            }
        }
        else
        {
            NSString* finalPhoneNumber = nil;
            
            NBPhoneNumberUtil *phoneUtil = [[NBPhoneNumberUtil alloc] init];
            NSError *anError = nil;
            NBPhoneNumber *myNumber = [phoneUtil parse:self.contactDetailsTextField.text
                                         defaultRegion:[Utilities GetCountryCode] error:&anError];
            
            if (anError == nil) {
                if([phoneUtil isValidNumber:myNumber] == YES)
                {
                    finalPhoneNumber = [phoneUtil format:myNumber numberFormat:NBEPhoneNumberFormatE164 error:&anError];
                    self.contactDetailsTextField.text = finalPhoneNumber;
                }
            }
            if(finalPhoneNumber == nil)
            {
                UIAlertController *alertController = [UIAlertController
                                                      alertControllerWithTitle:loc(@"Phone_is_invalid")
                                                      message:@""
                                                      preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction* ok = [UIAlertAction
                                     actionWithTitle:loc(@"OK")
                                     style:UIAlertActionStyleDefault
                                     handler:^(UIAlertAction * action)
                                     {
                                     }];
                [alertController addAction:ok];
                [self presentViewController:alertController animated:YES completion:nil];
                
                return NO;
            }
        }
    }
    return YES;
}

- (IBAction)unwindToShareProcess1:(UIStoryboardSegue *)unwindSegue
{
}

-(void)SetContactDetails:(NSString*)contactDetails
{
    initialContactDetails = contactDetails;
}
-(void)SetContactName:(NSString*)contactName
{
    initialContactName = contactName;
}
-(void)SetMediaType:(MediaTypesEnum)mediaType
{
    initialMediaType = mediaType;
}
-(void)SetRelationship:(NSString*)relationship
{
    initialRelationship = relationship;
}

-(NSString*)ContactDetails
{
    return self.contactDetailsTextField.text;
}
-(NSString*)ContactName
{
    return self.contactNameTextField.text;
}
-(MediaTypesEnum)mediaType
{
    return selectedMediaType;
}
-(NSString*)Relationship
{
    if(![self.relationshipLabel.text isEqualToString:loc(@"Relationship")])
        return self.relationshipLabel.text;
    else
        return @"";
}


@end
