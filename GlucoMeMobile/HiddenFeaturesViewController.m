//
//  HiddenFeaturesViewController.m
//  GlucoMe - Mobile
//
//  Created by dovi winberger on 09/02/2016.
//  Copyright © 2016 Yiftah Ben Aharon. All rights reserved.
//

#import "HiddenFeaturesViewController.h"
#import "general.h"
#import "ProfileViewController.h"

@implementation HiddenFeaturesViewController

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    
    [self.betaFeaturesSwitch setOn:[[NSUserDefaults standardUserDefaults] boolForKey:show_beta_features_boolean]];
    
    NSString* serverURL = [[NSUserDefaults standardUserDefaults] objectForKey:server_url];
    if([serverURL isEqualToString:@"https://app.glucome.com"] || [serverURL isEqualToString:@"https://ddc.glucome.com"])
    {
        self.URLSegmentedControl.selectedSegmentIndex = 0;
    }
    if([serverURL isEqualToString:@"https://beta.glucome.com"] || [serverURL isEqualToString:@"https://staging.glucome.com"])
    {
        self.URLSegmentedControl.selectedSegmentIndex = 1;
    }
    if([serverURL isEqualToString:@"https://dev.glucome.com"])
    {
        self.URLSegmentedControl.selectedSegmentIndex = 2;
    }
    if([serverURL isEqualToString:@"http://localhost:3000"] || [serverURL hasPrefix:@"http://192.168.0."])
    {
        self.URLSegmentedControl.selectedSegmentIndex = 3;
    }
    
    
}

- (IBAction)URLSegmentedControlValueChanged:(id)sender
{
    if(self.URLSegmentedControl.selectedSegmentIndex == 0)
    {
        [[NSUserDefaults standardUserDefaults] setObject:@"https://ddc.glucome.com" forKey:server_url];
    }
    if(self.URLSegmentedControl.selectedSegmentIndex == 1)
    {
        [[NSUserDefaults standardUserDefaults] setObject:@"https://beta.glucome.com" forKey:server_url];
    }
    if(self.URLSegmentedControl.selectedSegmentIndex == 2)
    {
        [[NSUserDefaults standardUserDefaults] setObject:@"https://dev.glucome.com" forKey:server_url];
    }
    if(self.URLSegmentedControl.selectedSegmentIndex == 3)
    {
        if([self.localhostLastIPComponentTextField.text isEqualToString:@""])
            [[NSUserDefaults standardUserDefaults] setObject:@"http://localhost:3000" forKey:server_url];
        else
            [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"http://192.168.0.%@:3000",self.localhostLastIPComponentTextField.text] forKey:server_url];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
    [ProfileViewController Logout];
    exit(0);
    
}

- (IBAction)BetaFeaturesSwitchValueChanged:(id)sender
{
    [[NSUserDefaults standardUserDefaults] setBool:self.betaFeaturesSwitch.isOn forKey:show_beta_features_boolean];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ShowBetaFeaturesChanged" object:nil];
}

- (IBAction)Close:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
