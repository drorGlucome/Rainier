//
//  LaunchViewController.m
//  GlucoMe - Mobile
//
//  Created by dovi winberger on 5/26/15.
//  Copyright (c) 2015 Yiftah Ben Aharon. All rights reserved.
//

#import "LaunchViewController.h"
#import "DataHandler_new.h"
#import "general.h"
#import "RegistrationWizardViewController.h"

@interface LaunchViewController ()

@end

@implementation LaunchViewController

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(DismissViewController) name:@"RegistrationFinishedNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(DismissViewController) name:@"Logout" object:nil];
}

-(void)DismissViewController
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    NSString* pateintID = [[DataHandler_new getInstance] getPatientId];

    if(DLG.isConnectedVersion)
    {
        RegistrationWizardViewController* reg = [[RegistrationWizardViewController alloc] initWithNibName:@"RegistrationWizardViewController" bundle:nil];
        if (pateintID == nil)
        {
            [self presentViewController:reg animated:YES completion:nil];
        }
        else
        {
            UIViewController* vc = [[UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil] instantiateInitialViewController];
            [self presentViewController:vc animated:YES completion:nil];

            [[DataHandler_new getInstance] SetDefaultData];
            if([[NSUserDefaults standardUserDefaults] boolForKey:@"NotFirstRun"] == false)
            {
                //first time
                //do stuff for first time only
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"NotFirstRun"];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
            [[DataHandler_new getInstance] GetUserMeasurementsFromServer];
            [[DataHandler_new getInstance] GetProfileFromServerWithCompletionBlock:nil];
            [[DataHandler_new getInstance] PostDevice];
            
        }
    }
    else
    {
        [[DataHandler_new getInstance] SetDefaultData];
        if([[NSUserDefaults standardUserDefaults] boolForKey:@"NotFirstRun"] == false)
        {
            //first time
            //do stuff for first time only
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"NotFirstRun"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        
        UIViewController* vc = [[UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil] instantiateInitialViewController];
        [self presentViewController:vc animated:YES completion:nil];
    }
    
}


@end
