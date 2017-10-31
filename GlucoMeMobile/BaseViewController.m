//
//  BaseViewController.m
//  GlucoMe - Mobile
//
//  Created by Yiftah Ben Aharon on 6/22/14.
//  Copyright (c) 2014 Yiftah Ben Aharon. All rights reserved.
//

#import "BaseViewController.h"
#import "GAIFields.h"
#import "ProfileViewController.h"

@interface BaseViewController ()

@end

@implementation BaseViewController

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    //NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString* email = [[NSUserDefaults standardUserDefaults] stringForKey:profile_email];
    if(email == nil || [email isEqualToString:@""])
        email = @"test2@email.com";

    id tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:[GAIFields customDimensionForIndex:1] value:email];
}

@end
