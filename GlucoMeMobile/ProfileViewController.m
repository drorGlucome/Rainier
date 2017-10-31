//
//  ProfileViewController.m
//  GlucoMe - Mobile
//
//  Created by Yiftah Ben Aharon on 3/25/14.
//  Copyright (c) 2014 Yiftah Ben Aharon. All rights reserved.
//

#import "ProfileViewController.h"
#import "general.h"
#import "RegistrationWizardViewController.h"
#import "DataHandler_new.h"
#import "PairingManager.h"


#define UNITS_LOGOUT 999
@interface ProfileViewController ()


@end

@implementation ProfileViewController

@synthesize logoutButton;


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
    self.screenName = @"ProfileViewController";
    
    self.navigationItem.title = loc(@"title_section3");
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.titleLabel.text = loc(@"Profile");
    [self.logoutButton setTitle:loc(@"Logout") forState:UIControlStateNormal];
    
    if ([UIApplication sharedApplication].userInterfaceLayoutDirection == UIUserInterfaceLayoutDirectionRightToLeft) {
        [self.logoutButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
    }
    if(!DLG.isConnectedVersion)
    {
        //self.logoutButton.hidden = YES;
        [self.logoutButton setTitle:loc(@"reset") forState:UIControlStateNormal];
        
    }
    
    UISwipeGestureRecognizer* swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(SwipeRightGestureRecognizer)];
    swipeRight.direction = UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:swipeRight];
}


-(void)SwipeRightGestureRecognizer
{
    self.tabBarController.selectedIndex--;
}

/*- (void) dataChanged:(DataHandler *)dataHandler {
    [self updateProfile];
}
*/


+(void)Logout
{
    if(DLG.isConnectedVersion)
    {
        [[DataHandler_new getInstance] Logout];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"Logout" object:nil];
    }
    else //reset
        exit(0);
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if(alertView.tag == UNITS_LOGOUT && buttonIndex == 1) // Logout
    {
        [ProfileViewController Logout];
        
    }
}



- (IBAction)logout:(id)sender
{
    NSString* what = loc(@"Logout");
    if(!DLG.isConnectedVersion)
        what = loc(@"Reset");
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:what
                                                    message:loc(@"Are_you_sure")
                                                   delegate:self
                                          cancelButtonTitle:loc(@"No")
                                          otherButtonTitles:loc(@"Logout"), nil];
    alert.tag = UNITS_LOGOUT;
    [alert show];
}



@end
