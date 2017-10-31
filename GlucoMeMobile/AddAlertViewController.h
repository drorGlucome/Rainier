//
//  AddAlertViewController.h
//  audioGraph
//
//  Created by Yiftah Ben Aharon on 9/13/12.
//
//

#import <UIKit/UIKit.h>
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import "general.h"
#import "BaseViewController.h"



@interface AddAlertViewController : BaseViewController  <ABPeoplePickerNavigationControllerDelegate>{
    NSMutableArray* alerts;
    NSMutableDictionary* mediaToId;
    NSMutableDictionary* alertToId;
    
}
- (IBAction)done:(id)sender;
- (IBAction)cancel:(id)sender;
- (IBAction)selectContact:(id)sender;
- (void) init_alerts_array;
- (void) init_media_selection;
- (IBAction)manualContact:(id)sender;

- (IBAction)mediaSelectionChanged:(id)sender;

@property  (retain, nonatomic) NSString* selectedAlert;
@property  (retain, nonatomic) NSString* selectedContact;
@property  (retain, nonatomic) NSString* selectedFax;
@property  (retain, nonatomic) NSString* selectedEmail;
@property  (retain, nonatomic) NSString* selectedMobile;
@property  (retain, nonatomic) NSString* selectedManually;
@property (weak, nonatomic) IBOutlet UITextField *detailsTextbox;



@property (retain, nonatomic) IBOutlet UIPickerView *alertPicker;

@property (retain, nonatomic) IBOutlet UISegmentedControl *mediaSelection;

-(BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person;


- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier;

- (void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker;


@end
