//
//  FullStripsViewController.m
//  GlucoMe - Mobile
//
//  Created by Yiftah Ben Aharon on 2/11/14.
//  Copyright (c) 2014 Yiftah Ben Aharon. All rights reserved.
//

#import "general.h"
#import "FullStripsViewController.h"
#import "ProfileViewController.h"
#import "DataHandler_new.h"

@interface FullStripsViewController ()

@end

@implementation FullStripsViewController

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
    self.screenName = @"FullStripsViewController";
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)numBoxesChanged:(id)sender {
    UISegmentedControl* seg = (UISegmentedControl*)sender;
    int price = (int)((seg.selectedSegmentIndex+1)*2*10-(seg.selectedSegmentIndex)*2);
    NSString* txt = [[NSString alloc] initWithFormat:@"$%d", price ];
    [self.totalPrice setText:txt];
}

- (IBAction)placeOrder:(id)sender {
    NSString* msg = loc(@"Unfortunatly, this feature is not supported in your country");
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:loc(@"Sorry...")
                                                    message:msg
                                                   delegate:nil
                                          cancelButtonTitle:loc(@"OK")
                                          otherButtonTitles:nil];
    [alert show];
}


- (IBAction)close:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

+(void)UpdateStripsAmount:(UIViewController*)parentVC
{
    UIAlertController* alert =[UIAlertController
                               alertControllerWithTitle:loc(@"Amount_of_strips_left")
                               message:loc(@"Please_enter_updated_strips_count")
                               preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.keyboardType = UIKeyboardTypeNumberPad;
    }];
    UIAlertAction* update = [UIAlertAction
                         actionWithTitle:loc(@"Update")
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction * action)
                         {
                             UITextField *textField = alert.textFields.firstObject;
                             NSString* value = [textField text];
                             
                             @try {
                                 [[DataHandler_new getInstance] UpdateStrips:[value intValue]];
                             } @catch (NSException *exception) {
                                 NSLog(@"Value is not an integer");
                             } @finally {
                                 [alert dismissViewControllerAnimated:YES completion:nil];
                             }
                             
                         }];
    [alert addAction:update];
    
    UIAlertAction* cancel = [UIAlertAction
                             actionWithTitle:loc(@"Cancel")
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action)
                             {
                                 [alert dismissViewControllerAnimated:YES completion:nil];
                             }];
    [alert addAction:cancel];
    
    [parentVC presentViewController:alert animated:YES completion:nil];
}

- (IBAction)resetStrips:(id)sender {
    
    [FullStripsViewController UpdateStripsAmount:self];
    
    /*UIAlertView * alert = [[UIAlertView alloc] initWithTitle:loc(@"Reset Strips Count") message:loc(@"Please enter updated strips count") delegate:self cancelButtonTitle:loc(@"Update") otherButtonTitles:@"Cancel",nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    UITextField* tf = [alert textFieldAtIndex:0];
    tf.keyboardType = UIKeyboardTypeNumberPad;
    [alert show];*/
//    [alert performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:YES];

}
/*- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 0) //done
    {
        NSString* value = [[alertView textFieldAtIndex:0] text];

        [[DataHandler_new getInstance] UpdateStrips:[value intValue]];
        [self close:nil];
       
    }
}
*/
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}
@end
