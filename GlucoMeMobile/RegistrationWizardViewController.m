//
//  RegistrationWizardViewController.m
//  GlucoMe - Mobile
//
//  Created by Yiftah Ben Aharon on 3/26/14.
//  Copyright (c) 2014 Yiftah Ben Aharon. All rights reserved.
//

#import "RegistrationWizardViewController.h"
#import "ProfileViewController.h"
#import "Registration2ViewController.h"
#import "DataHandler_new.h"
#import "NSString+EmailAddresses.h"

@interface RegistrationWizardViewController ()

@end

@implementation RegistrationWizardViewController
@synthesize email;
@synthesize password;
@synthesize alreadyRegisteredButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad 
{
    [super viewDidLoad];
    [self alreadyRegistered:alreadyRegisteredButton];
    // Do any additional setup after loading the view from its nib.
    
    self.welcomeToGlucoMeLabel.text = loc(@"Welcome_to_glucome");
    self.email.placeholder = loc(@"Email");
    self.password.placeholder = loc(@"Password");
    self.password2.placeholder = loc(@"Password");
    
    [self.forgotYourPasswordButton setTitle:loc(@"Forgot_your_password") forState:UIControlStateNormal];
    [self.resendConfirmationButton setTitle:loc(@"Resend_confirmation") forState:UIControlStateNormal];
    
    NSString* _email = [[NSUserDefaults standardUserDefaults] stringForKey:profile_email];
    if(_email != NULL)
    {
        self.email.text = _email;
    }

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)removeKeyboard:(id)sender
{
    [self.view endEditing:YES];
}

-(IBAction)done:(id)sender
{
    [self.view endEditing:YES];
    self.email.text = [self.email.text stringByCorrectingEmailTypos];
    
    NSString* emailString = [[NSString alloc] initWithString:self.email.text];
    [[NSUserDefaults standardUserDefaults] setObject:emailString forKey:profile_email];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    NSString* passwordString = [[NSString alloc] initWithString:self.password.text];
    NSString* password2String = [[NSString alloc] initWithString:self.password2.text];
    if([self isRegister] && ![passwordString isEqualToString:password2String]) {
        [self alert:loc(@"Passwords_dont_match")];
        return;
    }
    if(passwordString == NULL || [passwordString isEqualToString:@""])
    {
        [self alert:loc(@"Forgot_your_password")];
        return;
    }

    
    
    if(![self isRegister]) // login
    {
        //show privacy dialog
        
        vc = [[ApprovePrivacyPolicyViewController alloc] initWithNibName:@"ApprovePrivacyPolicyViewController" bundle:nil];
        
        vc.DenyBlock = ^{
            [[DataHandler_new getInstance] Logout];
        };
        __weak typeof(self) weakSelf = self;
        __weak typeof(vc) weakVC = vc;
        vc.ApproveBlock = ^{
            [weakSelf DoneAfterInputCheck:emailString password:passwordString password2:password2String];
            [weakVC.view removeFromSuperview];
        };
        
        [vc.view setFrame:self.view.frame];
        [self.view addSubview:vc.view];
    }
    else
    {
        [self DoneAfterInputCheck:emailString password:passwordString password2:password2String];
    }
    
}
-(void)DoneAfterInputCheck:(NSString*)emailString password:(NSString*)passwordString password2:(NSString*)password2String
{
    av=[[UIAlertView alloc] initWithTitle:loc(@"Please_wait") message:@"" delegate:self cancelButtonTitle:nil otherButtonTitles:nil];
    UIActivityIndicatorView* ActInd=[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [ActInd startAnimating];
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    int avSize = 40;
    [ActInd setFrame:CGRectMake((screenRect.size.width-avSize)/2, (screenRect.size.height-avSize)/2, avSize, avSize)];
    [av addSubview:ActInd];
    [av show];
    
    NSMutableDictionary* params = [[NSMutableDictionary alloc] init];
    NSString* url = [self isRegister] ? @"/users.json" : @"/users/sign_in.json";
    //NSString* url = [[NSString alloc] initWithFormat:@"/%@/%@/%@", base, emailString, passwordString];
    
    [params setObject:@{@"email" : emailString, @"password" : passwordString, @"password_confirmation" : password2String} forKey:@"user"];
    [[DataHandler_new getInstance].afNetworking POST:url parameters:params success:^void(NSURLSessionDataTask * task, NSDictionary* responseObject) {
        [av dismissWithClickedButtonIndex:0 animated:YES];
        av=nil;
        
        if([self isRegister])
        {
            [self alreadyRegistered:nil];
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"" message:loc(@"Please_confirm_your_email_and_login") delegate:nil cancelButtonTitle:loc(@"OK") otherButtonTitles:nil];
            [alert show];
            return;
        }
        
        [[DataHandler_new getInstance] setAuthentication_token:[responseObject objectForKey:@"authentication_token"]];
        [[DataHandler_new getInstance] setPatientId:[responseObject objectForKey:@"id"]];
        
        [[DataHandler_new getInstance] sendProfileToServer];
        [[DataHandler_new getInstance] SendLocaleToServer];
        [self dismissViewControllerAnimated:YES completion:nil];
        
    } failure:^void(NSURLSessionDataTask * task, NSError * err) {
        [av dismissWithClickedButtonIndex:0 animated:YES];
        av=nil;
        [self.view endEditing:YES];
        
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:profile_email];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        NSString* msg = @"";//operation.HTTPRequestOperation.responseString;
        msg = [[NSString alloc] initWithData:err.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] encoding:NSUTF8StringEncoding];
        msg = [msg stringByReplacingOccurrencesOfString:@"{" withString:@""];
        msg = [msg stringByReplacingOccurrencesOfString:@"}" withString:@""];
        msg = [msg stringByReplacingOccurrencesOfString:@"\"" withString:@""];
        msg = [msg stringByReplacingOccurrencesOfString:@"errors" withString:@""];
        msg = [msg stringByReplacingOccurrencesOfString:@"error" withString:@""];
        msg = [msg stringByReplacingOccurrencesOfString:@":" withString:@" "];
        msg = [msg stringByReplacingOccurrencesOfString:@"[" withString:@""];
        msg = [msg stringByReplacingOccurrencesOfString:@"]" withString:@""];
        
        if(msg.length == 0 || [msg containsString:@"xml version"]) {
            if(((NSHTTPURLResponse*)[[err userInfo] objectForKey:AFNetworkingOperationFailingURLResponseErrorKey]).statusCode == 401)
            {
                msg = @"Wrong email of password";
            }
            else
            {
                msg = @"A communication problem. Please make sure your are connected to the internet, that email is valid and password length is at least 6 characters";
            }
        }
        [self alert:msg];
    }];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}

- (IBAction)resetPassword:(id)sender
{
    
    NSString* emailString = [[NSString alloc] initWithString:self.email.text];
    if([emailString isEqualToString:@""])
    {
        [[[UIAlertView alloc] initWithTitle:@"" message:@"Please enter an email" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        return;
    }
    if(![emailString isValidEmailAddress])
    {
        [[[UIAlertView alloc] initWithTitle:@"" message:@"Please enter a valid email" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        return;
    }
    [[DataHandler_new getInstance] resetPassword:emailString];
    
    NSString* prompt = @"Password recovery instructions were sent to you";
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Password reset" message:prompt delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    alert.alertViewStyle = UIAlertViewStyleDefault;
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(alertView.alertViewStyle != UIAlertViewStylePlainTextInput) {
        return;
    }
    //NSString* value = [[alertView textFieldAtIndex:0] text];
    if(buttonIndex == 0)
    {
        NSString* value = [[alertView textFieldAtIndex:0] text];
        if([value isEqualToString:@""]) return;
        
    }
}


- (IBAction)alreadyRegistered:(id)sender {
    
    if([self isRegister]) {
        [self.OKButton setTitle:loc(@"Login") forState:UIControlStateNormal];
        self.password2.hidden = YES;
        self.resendConfirmationButton.hidden = NO;
        self.forgotYourPasswordButton.hidden = NO;
        [self.alreadyRegisteredButton setTitle:loc(@"Need_to_register") forState:UIControlStateNormal];
    }
    else {
        [self.OKButton setTitle:loc(@"Register") forState:UIControlStateNormal];
        self.password2.hidden = NO;
        self.resendConfirmationButton.hidden = YES;
        self.forgotYourPasswordButton.hidden = YES;
        [self.alreadyRegisteredButton setTitle:loc(@"Already_registered") forState:UIControlStateNormal];
   
    }
    
}

- (IBAction)ResendConfirmation:(id)sender
{
    NSString* emailString = [[NSString alloc] initWithString:self.email.text];
    if([emailString isEqualToString:@""])
    {
        [[[UIAlertView alloc] initWithTitle:@"" message:@"Please enter an email" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        return;
    }
    if(![emailString isValidEmailAddress])
    {
        [[[UIAlertView alloc] initWithTitle:@"" message:@"Please enter a valid email" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        return;
    }
    [[DataHandler_new getInstance] ResendConfirmationEmail:emailString];
    
    NSString* prompt = loc(@"Confirmation_email_was_sent_to_you");
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:loc(@"Resend_confirmation") message:prompt delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    alert.alertViewStyle = UIAlertViewStyleDefault;
    [alert show];
}

- (void) alert:(NSString*) msg {
    UIAlertView *message = [[UIAlertView alloc] initWithTitle:loc(@"Error") message:msg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [message show];

}

- (bool) isRegister {
    return (self.password2.hidden == NO);
}
@end
