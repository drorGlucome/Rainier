//
//  HiddenFeaturesViewController.h
//  GlucoMe - Mobile
//
//  Created by dovi winberger on 09/02/2016.
//  Copyright © 2016 Yiftah Ben Aharon. All rights reserved.
//
//  This is the hidden features settings page

#import <UIKit/UIKit.h>

@interface HiddenFeaturesViewController : UIViewController
@property (weak, nonatomic) IBOutlet UISwitch *betaFeaturesSwitch;
@property (weak, nonatomic) IBOutlet UISegmentedControl *URLSegmentedControl;
@property (weak, nonatomic) IBOutlet UITextField *localhostLastIPComponentTextField;

@end
