//
//  ProfileViewController.h
//  GlucoMe - Mobile
//
//  Created by Yiftah Ben Aharon on 3/25/14.
//  Copyright (c) 2014 Yiftah Ben Aharon. All rights reserved.
//
//  This is the profile page

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "general.h"

#define SETTINGS_EMAIL 0
#define SETTINGS_PASSWORD 2
/*
#
#define SETTINGS_NAME 1

#define SETTINGS_HEIGHT 3
#define SETTINGS_WEIGHT 4
#define SETTINGS_LOW 5
#define SETTINGS_HIGH 6
 */

@interface ProfileViewController : BaseViewController 
{
}
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *logoutButton;


- (IBAction)logout:(id)sender;
+(void)Logout;

@end
