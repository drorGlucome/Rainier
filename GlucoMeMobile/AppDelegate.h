//
//  AppDelegate.h
//  GlucoMe - Mobile
//
//  Created by Yiftah Ben Aharon on 1/9/14.
//  Copyright (c) 2014 Yiftah Ben Aharon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "general.h"
#import "MeViewController.h"
@class FullRemindersViewController;


@interface AppDelegate : UIResponder <UIApplicationDelegate>


@property (readonly) BOOL isConnectedVersion;

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, retain) FullRemindersViewController *remindersView;



- (void) initAnalytics;
-(UIViewController*)GetTopViewController;
-(void)ShowViewControllerOnTopOfEverything:(UIViewController*)vc;

@end
