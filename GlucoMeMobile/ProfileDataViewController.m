//
//  ProfileDataViewController.m
//  GlucoMe - Mobile
//
//  Created by dovi winberger on 21/02/2016.
//  Copyright © 2016 Yiftah Ben Aharon. All rights reserved.
//

#import "ProfileDataViewController.h"
#import "general.h"
#import "PairingManager.h"
#import "QRCodeReaderViewController.h"

#define DIABETES_TYPE_TAG 2
#define UNITS_TAG 3

#define UPDATE_VALUE_TAG 5

@interface ProfileDataViewController() <QRCodeReaderDelegate>
@property int selectedRow;
@property int selectedSection;
@end
@implementation ProfileDataViewController
@synthesize tableView;

NSArray* original_diabetes_types;
NSArray* diabetes_types;

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.tableView reloadData];
    
    original_diabetes_types = @[@"1",
                       @"2",
                       @"Gestational",
                       @"Prediabetes",
                       @"LADA (1.5)",
                       @"MODY"
                       ];
    diabetes_types = @[@"1",
                       @"2",
                       loc(@"Gestational"),
                       loc(@"Prediabetes"),
                       @"LADA (1.5)",
                       @"MODY"
                       ];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateProfile) name:@"ProfileChanged" object:nil];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    [self updateProfile];
    
}

- (void) updateProfile
{
    if(!DLG.isConnectedVersion)
    {
        PROFILE_GENERAL_LABEL_KEY_ARRAY =  [[NSMutableArray alloc] initWithArray: @[
                                                                                    @[loc(@"patient_id"), profile_id],
                                                                                    @[loc(@"First_name"), profile_first_name],
                                                                                    @[loc(@"Last_name"), profile_last_name],
                                                                                    @[loc(@"Height"), profile_height],
                                                                                    @[loc(@"Weight"), profile_weight],
                                                                                    ]];
        PROFILE_DIABETES_LABEL_KEY_ARRAY =  [[NSMutableArray alloc] initWithArray: @[
                                                                                     @[loc(@"Diabetes_type"), profile_diabetes_type],
                                                                                     @[loc(@"pre_meal_target"), profile_pre_meal_target],
                                                                                     @[loc(@"post_meal_target"), profile_post_meal_target],
                                                                                     @[loc(@"Hypo"), profile_hypo_threshold],
                                                                                     @[loc(@"Daily_measurements"), profile_daily_measurements],
                                                                                     @[loc(@"Units"), profile_glucose_units]
                                                                                     ]];
        
        PROFILE_CLINIC_LABEL_KEY_ARRAY =  [[NSMutableArray alloc] initWithArray: @[
                                                                                   //empty on purpose
                                                                                   ]];
        
    }
    else
    {
        PROFILE_GENERAL_LABEL_KEY_ARRAY =  [[NSMutableArray alloc] initWithArray: @[
                                                                                    @[loc(@"patient_id"), profile_id],
                                                                                    @[loc(@"Email"), profile_email],
                                                                                    @[loc(@"First_name"), profile_first_name],
                                                                                    @[loc(@"Last_name"), profile_last_name],
                                                                                    @[loc(@"Height"), profile_height],
                                                                                    @[loc(@"Weight"), profile_weight],
                                                                                    ]];
        PROFILE_DIABETES_LABEL_KEY_ARRAY =  [[NSMutableArray alloc] initWithArray: @[
                                                                                     @[loc(@"Diabetes_type"), profile_diabetes_type],
                                                                                     @[loc(@"pre_meal_target"), profile_pre_meal_target],
                                                                                     @[loc(@"post_meal_target"), profile_post_meal_target],
                                                                                     @[loc(@"Hypo"), profile_hypo_threshold],
                                                                                     @[loc(@"Daily_measurements"), profile_daily_measurements],
                                                                                     @[loc(@"Units"), profile_glucose_units]
                                                                                     ]];
        
        PROFILE_CLINIC_LABEL_KEY_ARRAY =  [[NSMutableArray alloc] initWithArray: @[
                                                                                   @[loc(@"clinic"), profile_clinic_name],
                                                                                   ]];
        if([[NSUserDefaults standardUserDefaults] objectForKey:profile_doctor_name] != NULL)
        {
            [PROFILE_CLINIC_LABEL_KEY_ARRAY addObject:@[loc(@"doctor"), profile_doctor_name]];
        }
        
        
    }
//    if([[NSUserDefaults standardUserDefaults] boolForKey:show_beta_features_boolean])
//    {
//        [PROFILE_GENERAL_LABEL_KEY_ARRAY addObject:@[loc(@"pairing"), profile_uidArray]];
//    }
    [PROFILE_GENERAL_LABEL_KEY_ARRAY addObject:@[loc(@"pairing"), profile_uidArray]];
    [self.tableView reloadData];
}

-(NSString*)LabelForIndexPath:(NSIndexPath*)indexPath
{
    if(indexPath.section == 0)
    {
        return [[PROFILE_GENERAL_LABEL_KEY_ARRAY objectAtIndex:indexPath.row] objectAtIndex:0];
    }
    else if(indexPath.section == 1)
    {
        return [[PROFILE_DIABETES_LABEL_KEY_ARRAY objectAtIndex:indexPath.row] objectAtIndex:0];
    }
    else
    {
        return [[PROFILE_CLINIC_LABEL_KEY_ARRAY objectAtIndex:indexPath.row] objectAtIndex:0];
    }
}
-(NSString*)KeyForIndexPath:(NSIndexPath*)indexPath
{
    if(indexPath.section == 0)
    {
        return [[PROFILE_GENERAL_LABEL_KEY_ARRAY objectAtIndex:indexPath.row] objectAtIndex:1];
    }
    else if(indexPath.section == 1)
    {
        return [[PROFILE_DIABETES_LABEL_KEY_ARRAY objectAtIndex:indexPath.row] objectAtIndex:1];
    }
    else
    {
        return [[PROFILE_CLINIC_LABEL_KEY_ARRAY objectAtIndex:indexPath.row] objectAtIndex:1];
    }
}

- (UITableViewCell *)tableView:(UITableView *)_tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString* reuseID = @"cell";
    UITableViewCell* cell = [_tableView dequeueReusableCellWithIdentifier:reuseID];
    if(cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@""];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    cell.backgroundColor = [UIColor whiteColor];
    NSString* label = [self LabelForIndexPath:indexPath];
    NSString* key = [self KeyForIndexPath:indexPath];
    
    cell.textLabel.text = label;
    cell.detailTextLabel.text = [self GetCurrentValueForKey:key];
    
    return cell;
}

-(NSString*)GetCurrentValueForKey:(NSString*)key
{
    NSObject* tmp = [[NSUserDefaults standardUserDefaults] objectForKey:key];
    
    if([key isEqualToString:profile_uidArray])
    {
        tmp = [(NSArray*)tmp componentsJoinedByString:@","];
    }
    else if([key isEqualToString:profile_diabetes_type])
    {
        tmp = loc((NSString*)tmp);
    }
    else if([key isEqualToString:profile_lower_limit] ||
            [key isEqualToString:profile_upper_limit] ||
            [key isEqualToString:profile_pre_meal_target] ||
            [key isEqualToString:profile_post_meal_target] ||
            [key isEqualToString:profile_hypo_threshold])
    {
        tmp = [[UnitsManager getInstance] GetGlucoseStringValueForCurrentUnit:[(NSString*)tmp intValue]];
    }
    
    if([key isEqualToString:profile_clinic_name])
    {
        if([[[NSUserDefaults standardUserDefaults] objectForKey:profile_clinic_id] isEqualToString:@"00000000-0000-4000-a000-000000000000"])
        {
            tmp = nil;
        }
        
    }
    
    if(tmp == nil) {
        if([key isEqualToString:profile_clinic_name])
        {
            tmp =  loc(@"clinic_tap_to_scan");
        }
        else
        {
            tmp =  loc(@"Tap_to_enter");
        }
    }
    NSString* value = [[NSString alloc] initWithFormat:@"%@", tmp ];
    if(value.length == 0) {
        value = loc(@"Tap_to_enter");
    }
    
    return value;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(section == 0)
        return PROFILE_GENERAL_LABEL_KEY_ARRAY.count;
    else if(section == 1)
        return PROFILE_DIABETES_LABEL_KEY_ARRAY.count;
    else
        return PROFILE_CLINIC_LABEL_KEY_ARRAY.count;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.selectedRow = (int)indexPath.row;
    self.selectedSection = (int)indexPath.section;
    
    NSString* label = [self LabelForIndexPath:indexPath];
    NSString* key = [self KeyForIndexPath:indexPath];
    
    if([key isEqualToString:profile_id])
    {
        return; //cannot edit patient id
    }
    
    if([key isEqualToString:profile_doctor_name])
    {
        return; //cannot edit doctor's name
    }
    
    if([key isEqualToString:profile_clinic_name])
    {
        void (^ScanForClinic)(void) = ^{
            // Create the reader object
            QRCodeReader *reader = [QRCodeReader readerWithMetadataObjectTypes:@[AVMetadataObjectTypeQRCode]];
            
            // Instantiate the view controller
            QRCodeReaderViewController *vc = [QRCodeReaderViewController readerWithCancelButtonTitle:loc(@"Cancel") codeReader:reader startScanningAtLoad:YES showSwitchCameraButton:YES showTorchButton:YES];
            
            // Set the presentation style
            vc.modalPresentationStyle = UIModalPresentationFormSheet;
            
            // Define the delegate receiver
            vc.delegate = self;
            
            [self presentViewController:vc animated:YES completion:NULL];
        };
        
        if([[NSUserDefaults standardUserDefaults] objectForKey:profile_clinic_id] != nil && ![[[NSUserDefaults standardUserDefaults] objectForKey:profile_clinic_id] isEqualToString:@"00000000-0000-4000-a000-000000000000"])
        {
            //ask user if he wants to disconnect from the clinic or scan a new one

            UIAlertController * alert=   [UIAlertController
                                          alertControllerWithTitle:loc(@"Would_you_like_to")
                                          message:loc(@"")
                                          preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction* disconnect = [UIAlertAction
                                         actionWithTitle:[NSString stringWithFormat:@"%@ %@",loc(@"disconnect_from_clinic"),[[NSUserDefaults standardUserDefaults] objectForKey:profile_clinic_name]]
                                         style:UIAlertActionStyleDestructive
                                         handler:^(UIAlertAction * action)
                                         {
                                             [[DataHandler_new getInstance] DisconnectFromClinic:self];
                                         }];
            UIAlertAction* connect = [UIAlertAction
                                         actionWithTitle:loc(@"connect_to_a_new_clinic")
                                         style:UIAlertActionStyleDefault
                                         handler:^(UIAlertAction * action)
                                         {
                                             ScanForClinic();
                                         }];
            UIAlertAction* cancel = [UIAlertAction
                                     actionWithTitle:loc(@"Cancel")
                                     style:UIAlertActionStyleCancel
                                     handler:^(UIAlertAction * action)
                                     {
                                         [alert dismissViewControllerAnimated:YES completion:nil];
                                     }];
            
            [alert addAction:disconnect];
            [alert addAction:connect];
            [alert addAction:cancel];
            
            [self presentViewController:alert animated:YES completion:nil];
            return;
        }
        else
        {
            //allow user to scan
            
            ScanForClinic();
            return;
        }
    }
    
    if([key isEqualToString:profile_glucose_units])
    {
        UIActionSheet *popup = [[UIActionSheet alloc] initWithTitle:loc(@"Units") delegate:self cancelButtonTitle:loc(@"Cancel") destructiveButtonTitle:nil otherButtonTitles:
                                loc(@"mg/dl"),
                                loc(@"mmol/L"),
                                nil];
        
        popup.tag = UNITS_TAG;
        [popup showInView:self.view];
        
        return;
    }
    
    if([key isEqualToString:profile_diabetes_type])
    {
        UIActionSheet *popup = [[UIActionSheet alloc] initWithTitle:loc(label) delegate:self cancelButtonTitle:loc(@"Cancel") destructiveButtonTitle:nil otherButtonTitles:nil];
        
        for( NSString *title in diabetes_types)  {
            [popup addButtonWithTitle:title];
        }
        
        popup.tag = DIABETES_TYPE_TAG;
        [popup showInView:self.view];
        
        return;
    }
    
    NSString* prompt = [NSString stringWithFormat:@"%@ %@", loc(@"Please_enter_your"), loc(label)];
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:loc(@"Enter_value") message:prompt delegate:self cancelButtonTitle:loc(@"Cancel") otherButtonTitles:loc(@"update"),nil];
    
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    UITextField* tf = [alert textFieldAtIndex:0];
    
    if(![[self GetCurrentValueForKey:key] isEqualToString:loc(@"Tap_to_enter")])
        tf.text = [self GetCurrentValueForKey:key];
    tf.autocapitalizationType = UITextAutocapitalizationTypeWords;
    
    if([key isEqualToString:profile_email ])
    {
        return;
        //tf.keyboardType = UIKeyboardTypeEmailAddress;
    }
    
    if([key isEqualToString:profile_first_name ] ||
       [key isEqualToString:profile_last_name ])
        tf.keyboardType = UIKeyboardTypeAlphabet;
    
    if([key isEqualToString:profile_weight] ||
       [key isEqualToString:profile_diabetes_type] ||
       [key isEqualToString:profile_daily_measurements])
        tf.keyboardType = UIKeyboardTypeNumberPad;
    
    if([key isEqualToString:profile_height])
        tf.keyboardType = UIKeyboardTypeDecimalPad;
    
    if([key isEqualToString:profile_lower_limit] ||
       [key isEqualToString:profile_upper_limit] ||
       [key isEqualToString:profile_pre_meal_target] ||
       [key isEqualToString:profile_post_meal_target] ||
       [key isEqualToString:profile_hypo_threshold])
    {
        if([[UnitsManager getInstance] GetGlucoseUnits] == mmolL)
            tf.keyboardType = UIKeyboardTypeDecimalPad;
        else
            tf.keyboardType = UIKeyboardTypeNumberPad;
        
    }
    
    
    alert.tag = UPDATE_VALUE_TAG;
    [alert show];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(actionSheet.tag == UNITS_TAG) //units
    {
        if(buttonIndex == 0 || buttonIndex == 1)
        {
            if(buttonIndex == 0)//mg/dl
                [[UnitsManager getInstance] ChangeUnitsTo_mgdl];
            if(buttonIndex == 1)//mmol/L
                [[UnitsManager getInstance] ChangeUnitsTo_mmolL];
            
            [[DataHandler_new getInstance] sendProfileToServer];
            [self.tableView reloadData];
        }
    }
    
    if(actionSheet.tag == DIABETES_TYPE_TAG) //diabetes type
    {
        if(buttonIndex > 0)
        {
            NSString* diabetesType = [original_diabetes_types objectAtIndex:buttonIndex-1];//0 is cancel
            
            [[NSUserDefaults standardUserDefaults] setObject:diabetesType forKey:profile_diabetes_type];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [[DataHandler_new getInstance] sendProfileToServer];
            [self.tableView reloadData];
            
            
        }
        
    }
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (alertView.tag == UPDATE_VALUE_TAG) // update data
    {
        if(buttonIndex == 1)
        {
            NSString* label = @"";
            NSString* key = @"";
            if(self.selectedSection == 0)
            {
                label = [[PROFILE_GENERAL_LABEL_KEY_ARRAY objectAtIndex:self.selectedRow] objectAtIndex:0];
                key = [[PROFILE_GENERAL_LABEL_KEY_ARRAY objectAtIndex:self.selectedRow] objectAtIndex:1];
            }
            else
            {
                label = [[PROFILE_DIABETES_LABEL_KEY_ARRAY objectAtIndex:self.selectedRow] objectAtIndex:0];
                key = [[PROFILE_DIABETES_LABEL_KEY_ARRAY objectAtIndex:self.selectedRow] objectAtIndex:1];
            }

            NSObject* value = [[alertView textFieldAtIndex:0] text];
            
            if([key isEqualToString:profile_uidArray])
            {
                NSString* valueString = (NSString*)value;
                
                NSArray* stringUids = [valueString componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@", "]];
                
                [PairingManager ClearAllPairedDevices];
                
                for (NSString* stringUid in stringUids) {
                    
                    @try {
                        int uid = [stringUid intValue];
                        [PairingManager addPairedDevice:uid];
                    }
                    @catch (NSException * e) {
                        NSLog(@"Exception: %@", e);
                    }
                }
                
                value = [PairingManager getPairedDevices];
                
            }
            if([key isEqualToString:profile_pre_meal_target])
            {
                NSString* valueString = (NSString*)value;
                if(![valueString isEqualToString:@""])
                {
                    double doubleValue = [valueString doubleValue];
                    if([[UnitsManager getInstance] GetGlucoseUnits] == mmolL)
                        doubleValue = doubleValue * 18;
                    
                    //doubleValue now in mg/dl
                    //input check
                    if (doubleValue < 20 || doubleValue > 300) {
                        [self.tableView reloadData];
                        return;
                    }
                    
                    value = @((int)round(doubleValue));
                }
                else
                {
                    value = @(default_profile_pre_meal_target);
                }
                
                //input check
                double hypo_threshold = ((NSNumber*)[[NSUserDefaults standardUserDefaults] objectForKey:profile_hypo_threshold]).doubleValue;
                double pre_meal_target = ((NSNumber*)value).doubleValue;
                double post_meal_target = ((NSNumber*)[[NSUserDefaults standardUserDefaults] objectForKey:profile_post_meal_target]).doubleValue;
                if(pre_meal_target < hypo_threshold) {
                    value = @(hypo_threshold + 1);
                }
                
                if(pre_meal_target > post_meal_target) {
                    value = @(post_meal_target - 1);
                }
            }
            if([key isEqualToString:profile_hypo_threshold])
            {
                NSString* valueString = (NSString*)value;
                if(![valueString isEqualToString:@""])
                {
                    double doubleValue = [valueString doubleValue];
                    if([[UnitsManager getInstance] GetGlucoseUnits] == mmolL)
                        doubleValue = doubleValue * 18;
                    
                    //doubleValue now in mg/dl
                    //input check
                    if (doubleValue < 20 || doubleValue > 300) {
                        [self.tableView reloadData];
                        return;
                    }
                    
                    value = @((int)round(doubleValue));
                }
                else
                {
                    value = @(default_profile_hypo_threshold);
                }

                //input check
                double hypo_threshold = ((NSNumber*)value).doubleValue;
                double pre_meal_target = ((NSNumber*)[[NSUserDefaults standardUserDefaults] objectForKey:profile_pre_meal_target]).doubleValue ;
                if(hypo_threshold > pre_meal_target) {
                    value = @(pre_meal_target - 1);
                }
            }
            if([key isEqualToString:profile_post_meal_target])
            {
                NSString* valueString = (NSString*)value;
                if(![valueString isEqualToString:@""])
                {
                    double doubleValue = [valueString doubleValue];
                    if([[UnitsManager getInstance] GetGlucoseUnits] == mmolL)
                        doubleValue = doubleValue * 18;
                    
                    //doubleValue now in mg/dl
                    //input check
                    if (doubleValue < 20 || doubleValue > 300) {
                        [self.tableView reloadData];
                        return;
                    }
                    
                    value = @((int)round(doubleValue));
                }
                else
                {
                    value = @(default_profile_post_meal_target);
                }
                
                //input check
                double pre_meal_target = ((NSNumber*)[[NSUserDefaults standardUserDefaults] objectForKey:profile_pre_meal_target]).doubleValue;
                double post_meal_target = ((NSNumber*)value).doubleValue;
                if(post_meal_target < pre_meal_target) {
                    value = @(pre_meal_target + 1);
                }
            }
            if([key isEqualToString:profile_lower_limit])
            {
                NSString* valueString = (NSString*)value;
                if(![valueString isEqualToString:@""])
                {
                    double doubleValue = [valueString doubleValue];
                    if([[UnitsManager getInstance] GetGlucoseUnits] == mmolL)
                        doubleValue = doubleValue * 18;
                    
                    if(doubleValue > [[[NSUserDefaults standardUserDefaults] objectForKey:profile_upper_limit] intValue])
                        value = @([[[NSUserDefaults standardUserDefaults] objectForKey:profile_upper_limit] intValue]-1);
                    else
                        value = @((int)round(doubleValue));
                }
                else
                {
                    value = @(default_profile_lower_limit);
                }
            }
            if([key isEqualToString:profile_upper_limit])
            {
                NSString* valueString = (NSString*)value;
                if(![valueString isEqualToString:@""])
                {
                    double doubleValue = [valueString doubleValue];
                    if([[UnitsManager getInstance] GetGlucoseUnits] == mmolL)
                        doubleValue = doubleValue * 18;
                    
                    if(doubleValue < [[[NSUserDefaults standardUserDefaults] objectForKey:profile_lower_limit] integerValue])
                        value = @([[[NSUserDefaults standardUserDefaults] objectForKey:profile_lower_limit] integerValue]+1);
                    else
                        value = @((int)round(doubleValue));
                }
                else
                {
                    value = @(default_profile_upper_limit);
                }
            }
            [[NSUserDefaults standardUserDefaults] setObject:value forKey:key];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [[DataHandler_new getInstance] sendProfileToServer];
            [self.tableView reloadData];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"ProfileChanged" object:nil];
            
        }
    }
}

#pragma mark - QRCodeReader Delegate Methods

- (void)reader:(QRCodeReaderViewController *)reader didScanResult:(NSString *)QR_result
{
    [self dismissViewControllerAnimated:YES completion:^{
        NSLog(@"%@", QR_result);
        [[DataHandler_new getInstance] ConnectMeToClinicWithQR_result:QR_result viewController:self];
    }];
}

- (void)readerDidCancel:(QRCodeReaderViewController *)reader
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

@end
