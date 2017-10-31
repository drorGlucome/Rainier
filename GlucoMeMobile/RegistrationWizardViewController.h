//
//  RegistrationWizardViewController.h
//  GlucoMe - Mobile
//
//  Created by Yiftah Ben Aharon on 3/26/14.
//  Copyright (c) 2014 Yiftah Ben Aharon. All rights reserved.
//
// first page of rgistration process (enter email/pass)

#import <UIKit/UIKit.h>
#import "general.h"
#import "ApprovePrivacyPolicyViewController.h"

@interface RegistrationWizardViewController : UIViewController 
{
    ApprovePrivacyPolicyViewController* vc;
    UIAlertView* av;
}
- (IBAction)done:(id)sender;
- (bool) isRegister;
@property (weak, nonatomic) IBOutlet UITextField *email;
@property (weak, nonatomic) IBOutlet UITextField *password;
- (IBAction)resetPassword:(id)sender;
@property (weak, nonatomic) IBOutlet UITextField *password2;

- (IBAction)alreadyRegistered:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *OKButton;
@property (weak, nonatomic) IBOutlet UIButton *alreadyRegisteredButton;
@property (weak, nonatomic) IBOutlet UIButton *forgotYourPasswordButton;
@property (weak, nonatomic) IBOutlet UIButton *resendConfirmationButton;
@property (weak, nonatomic) IBOutlet UILabel *welcomeToGlucoMeLabel;

@end
