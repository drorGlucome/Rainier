//
//  HelpDialogManager.m
//  GlucoMe - Mobile
//
//  Created by dovi winberger on 8/24/15.
//  Copyright (c) 2015 Yiftah Ben Aharon. All rights reserved.
//

#import "HelpDialogManager.h"



@implementation HelpDialogManager

+(HelpDialogManager*)getInstance
{
    static HelpDialogManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[HelpDialogManager alloc] init];
        // Do any other initialisation stuff here
        
        sharedInstance->dialogView = [[[NSBundle mainBundle] loadNibNamed:@"HelpDialogView" owner:self options:nil] objectAtIndex:0];

    });
    return sharedInstance;
}

-(void)ShowOnView:(UIView*)view
{
    [dialogView Close];
    dialogView.frame = view.window.frame;
    [view.window addSubview:dialogView];
}
-(void)Close
{
    [dialogView Close];
}
-(void)SetWithTitle:(NSString*)title andMessage:(NSString*)message
{
    dialogView.titleLabel.text = title;
    dialogView.mainLabel.text = message;
    [dialogView.mainLabel setTextAlignment:NSTextAlignmentNatural];
    dialogView.imageView.image = nil;
}

-(void)SetWithError:(int)error_code
{
    NSString* msg = [self getErrorMessage:error_code];
    if(msg == nil) msg = @"";
    
    NSString* title = loc(@"Error");
    dialogView.titleLabel.text = title;
    
    UIFont *titleFont = [UIFont boldSystemFontOfSize:16];
    NSDictionary *boldAttributes = [NSDictionary dictionaryWithObject: titleFont forKey:NSFontAttributeName];
    
    UIFont *messageFont = [UIFont systemFontOfSize:14];
    NSDictionary *messageAttributes = [NSDictionary dictionaryWithObject:messageFont forKey:NSFontAttributeName];
    
    NSDictionary *boldRedAttributes = @{NSFontAttributeName : titleFont, NSForegroundColorAttributeName : [UIColor redColor]};
    
    
    NSMutableAttributedString *attrMessage = [[NSMutableAttributedString alloc] initWithString:msg attributes: boldAttributes];
    dialogView.imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"error%d",error_code]];
    
    

    switch (error_code) {
        case ERR_TEMPERATURE:		//1 out of range 10~40 degrees
        {
            NSString* text = [NSString stringWithFormat:@"\n\n%@",loc(@"Make_sure_the_device_is_within_the_appropriate_temperature_range_see_manual")];
            [attrMessage appendAttributedString:[[NSMutableAttributedString alloc] initWithString:text attributes:messageAttributes]];
            break;
        }
        case ERR_INVALID_STRIP:		//2 reused strip
        {
            NSString* text = [NSString stringWithFormat:@"\n\n%@", loc(@"Do_not_use_the_same_test_strip_Please_use_a_new_one")];
            [attrMessage appendAttributedString:[[NSMutableAttributedString alloc] initWithString:text attributes:boldRedAttributes]];
            break;
        }
        case ERR_REMOVE_STRIP:		//3 removed strip during measurement
        {
            NSString* text = [NSString stringWithFormat:@"\n\n%@", loc(@"Dont_remove_the_strip_before_the_glucose_has_been_measured")];
            [attrMessage appendAttributedString:[[NSMutableAttributedString alloc] initWithString:text attributes:messageAttributes]];
            
            text = [NSString stringWithFormat:@"\n\n%@", loc(@"Please_measure_again_using_a_new_test_strip_Do_not_use_the_same_test_strip")];
            [attrMessage appendAttributedString:[[NSMutableAttributedString alloc] initWithString:text attributes:boldRedAttributes]];
            break;
        }
        case ERR_MEASUREMENT:		//4 out of range DC 310mV +/- 6mV?
        {
            NSString* text = [NSString stringWithFormat:@"\n\n%@", loc(@"Please_measure_again_using_a_new_test_strip_Do_not_use_the_same_test_strip")];
            [attrMessage appendAttributedString:[[NSMutableAttributedString alloc] initWithString:text attributes:boldRedAttributes]];
            
            break;
        }
        case ERR_SYSTEM:			//5 abnormal temperature & battery voltage
        {
            NSString* text = [NSString stringWithFormat:@"\n\n%@", loc(@"Please_measure_again_using_a_new_test_strip_Do_not_use_the_same_test_strip")];
            [attrMessage appendAttributedString:[[NSMutableAttributedString alloc] initWithString:text attributes:boldRedAttributes]];
            
            text = [NSString stringWithFormat:@"\n\n%@", loc(@"If_the_error_reoccurs_please_replace_the_battery_of_the_device")];
            [attrMessage appendAttributedString:[[NSMutableAttributedString alloc] initWithString:text attributes:messageAttributes]];
            
            break;
        }
        case ERR_LOWEST:			//6 glucose is under 3 3mg/dL
        {
            NSString* text = [NSString stringWithFormat:@"\n\n%@", loc(@"Please_measure_again_using_a_new_test_strip_Do_not_use_the_same_test_strip") ];
            [attrMessage appendAttributedString:[[NSMutableAttributedString alloc] initWithString:text attributes:boldRedAttributes]];
            
            text = [NSString stringWithFormat:@"\n\n%@", loc(@"If_the_error_reoccurs_please_replace_the_battery_of_the_device")];
            [attrMessage appendAttributedString:[[NSMutableAttributedString alloc] initWithString:text attributes:messageAttributes]];
            
            break;
        }
        case ERR_STRIIP_ERROR:    //7       Check strip error            damaged check strip
        {
            NSString* text = [NSString stringWithFormat:@"\n\n%@", loc(@"Please_measure_again_using_a_new_test_strip_Do_not_use_the_same_test_strip") ];
            [attrMessage appendAttributedString:[[NSMutableAttributedString alloc] initWithString:text attributes:boldRedAttributes]];

            break;
        }
        case ERR_INSUFFICIENT_BLOOD:		//8 blood check once, but not detect blood
        {
            NSString* text = [NSString stringWithFormat:@"\n\n%@", loc(@"Please_measure_again_using_a_new_test_strip_Do_not_use_the_same_test_strip") ];
            [attrMessage appendAttributedString:[[NSMutableAttributedString alloc] initWithString:text attributes:boldRedAttributes]];
            
            text = [NSString stringWithFormat:@"\n\n%@ \n\n%@",
                    loc(@"Gently_squeeze_your_fingertip_until_a_round_drop_of_blood_forms_on_your_fingertip"),
                    loc(@"Apply_the_blood_drop_to_the_edge_of_the_strip_and_wait_for_the_green_light_to_blink")];
                    
            
            [attrMessage appendAttributedString:[[NSMutableAttributedString alloc] initWithString:text attributes:messageAttributes]];
            break;
        }
        case ERR_WRONG_BLOOD_DIRECTION:	//9 blood direction error
        {
            NSString* text = [NSString stringWithFormat:@"\n\n%@", loc(@"Please_measure_again_using_a_new_test_strip_Do_not_use_the_same_test_strip")];
            [attrMessage appendAttributedString:[[NSMutableAttributedString alloc] initWithString:text attributes:boldRedAttributes]];
            
            text = [NSString stringWithFormat:@"\n\n%@", loc(@"Make_sure_to_apply_blood_on_the_edge_of_the_half_circle")];
            [attrMessage appendAttributedString:[[NSMutableAttributedString alloc] initWithString:text attributes:messageAttributes]];

            break;
        }
        case ERR_BLOOD_INSERTION_TIMEOUT:	//10   time out 60sec of input blood
        {
            NSString* text = [NSString stringWithFormat:@"\n\n%@", loc(@"Please_measure_again_using_a_new_test_strip_Do_not_use_the_same_test_strip")];
            [attrMessage appendAttributedString:[[NSMutableAttributedString alloc] initWithString:text attributes:boldRedAttributes]];
            
            break;
        }
        case ERR_BATTERY:             //11     Battery error
        {
            
            NSString* text = [NSString stringWithFormat:@"\n\n%@ \n\n%@ \n\n%@ \n\n%@",
                              loc(@"Battery_is_about_to_drain_please_replace_the_battery"),
                              loc(@"Remove_the_battery_cover"),
                              loc(@"Replace_the_battery"),
                              loc(@"Close_the_battery_cover")];
                              
            [attrMessage appendAttributedString:[[NSMutableAttributedString alloc] initWithString:text attributes:messageAttributes]];
         
            break;
        }
            
        default:
            break;
    }
    
    dialogView.mainLabel.attributedText = attrMessage;
    [dialogView.mainLabel setTextAlignment:NSTextAlignmentNatural];
    
}

-(void)SetWithLancetTutorial
{
    dialogView.titleLabel.text = loc(@"Assemble_the_lancing_device");
    dialogView.mainLabel.text =     [NSString stringWithFormat:@"%@ \n\n%@ \n\n%@ \n\n%@",
                                     loc(@"Remove_the_cap_by_rotating_the_cap_counter_clockwise"),
                                     loc(@"Insert_the_lancet_to_the_lancing_holder"),
                                     loc(@"Remove_the_round_blue_tip_to_expose_the_needle"),
                                     loc(@"Replace_the_cap_by_rotating_it_clockwise")];
    [dialogView.mainLabel setTextAlignment:NSTextAlignmentNatural];
    dialogView.imageView.image = [UIImage imageNamed:@"lancet_help.jpg"];
    
}
-(void)SetWithInsertTestStripTutorial
{
    dialogView.titleLabel.text = loc(@"Insert_a_test_strip");
    dialogView.mainLabel.text =    [NSString stringWithFormat:@"%@ \n\n%@ \n\n%@",
                                    loc(@"Note_the_strip_golden_plates_and_the_device_black_arrow_are_on_the_same_side"),
                                    loc(@"Push_until_you_hear_a_beep"),
                                    loc(@"Make_sure_the_green_light_is_on")];
    [dialogView.mainLabel setTextAlignment:NSTextAlignmentNatural];
    dialogView.imageView.image = [UIImage imageNamed:@"insert_strip_help.jpg"];
}

-(void)SetWithPrickFingerTutorial
{
    dialogView.titleLabel.text = loc(@"Prick_your_finger");
    dialogView.mainLabel.text =     [NSString stringWithFormat:@"%@ \n\n%@ \n\n%@ \n\n%@ \n\n%@ \n\n%@",
                                     loc(@"Adjust_the_lancing_device_between_one_to_five"),
                                    loc(@"Cock_the_device_by_pulling_the_bottom_part"),
                                    loc(@"Place_it_carefully_on_the_tip_of_your_finger"),
                                    loc(@"Press_the_trigger_button"),
                                    loc(@"Squeeze_your_finger_for_three_seconds"),
                                     loc(@"Make_sure_you_have_a_sufficient_blood_drop_ready_as_shown_in_the_picture")];
    [dialogView.mainLabel setTextAlignment:NSTextAlignmentNatural];
    dialogView.imageView.image = [UIImage imageNamed:@"prick_help.jpg"];
}

-(void)SetWIthPlaceBloodTutorial
{
    dialogView.titleLabel.text = loc(@"Place_a_blood_drop");
    dialogView.mainLabel.text =  [NSString stringWithFormat:@"%@ \n\n%@",
                                  loc(@"do-not-smear-the-blood-on-the-golden-strip-place-it-close-to-the-edge-of-the-strip-and-let-the-blood"),
                                  loc(@"Make_sure_that_the_blood_flows_and_fills_the_entire_strip")];
    [dialogView.mainLabel setTextAlignment:NSTextAlignmentNatural];
    dialogView.imageView.image = [UIImage imageNamed:@"place_blood_help.jpg"];
}





- (NSString*)getErrorMessage:(int)errorId {
    
    /*
     10     Insertion timeout            blood insertion time is over 60sec
     11     Battery error                  battery level is out of voltage 2.6V ~ 3.45V
     */
    
    
    
    
    
    NSMutableArray* messages = [[NSMutableArray alloc] initWithObjects:
                                loc(@"General_error"), //      0  ERR_NONE,
                                loc(@"The_meter_is_too_hot_or_cold"), // 1 ERR_TEMPERATURE
                                loc(@"Used_test_strip_was_inserted_into_the_test_port"), // 2 ERR_INVALID_STRIP
                                loc(@"Test_strip_is_damaged_or_was_removed_too_soon"), // 3 ERR_REMOVE_STRIP
                                loc(@"The_sample_was_improperly_applied_or_there_was_electronic_interference_during_the_test"), //4 ERR_MEASUREMENT
                                loc(@"Internal_error_cannot_read_test_strip"), // 5 ERR_SYSTEM
                                loc(@"Internal_error_cannot_read_test_strip"), // 6 ERR_LOWEST
                                loc(@"Strip_is_damaged"), // 7 ERR_STRIIP_ERROR
                                loc(@"Inserted_blood_is_less_than_standard"), // 8 ERR_INSUFFICIENT_BLOOD
                                loc(@"Blood_was_applied_to_the_wrong_part_of_the_test_strip"), // 9 ERR_WRONG_BLOOD_DIRECTION
                                loc(@"Blood_was_not_applied_on_the_test_strip"), // 10 ERR_BLOOD_INSERTION_TIMEOUT
                                loc(@"Battery_is_damaged"), //11 ERR_BATTERY
                                nil];
    
    if(errorId < messages.count) {
        return (NSString*)[messages objectAtIndex:errorId];
    }
    return nil;
}
@end
