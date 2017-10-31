//
//  InfoViewController.h
//  GlucoMe - Mobile
//
//  Created by Yiftah Ben Aharon on 7/1/14.
//  Copyright (c) 2014 Yiftah Ben Aharon. All rights reserved.
//
//  This is the app information page

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
@interface InfoViewController : BaseViewController
- (IBAction)dismiss:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *versionLabel;
@property (weak, nonatomic) IBOutlet UILabel *sdkVersionLabel;
@property (weak, nonatomic) IBOutlet UIButton *closeButton;
@property (weak, nonatomic) IBOutlet UILabel *privacyStatementLabel;
@property (weak, nonatomic) IBOutlet UILabel *eulaLabel;
@property (weak, nonatomic) IBOutlet UILabel *appVersionLabel;
@property (weak, nonatomic) IBOutlet UILabel *SDKVersionLabel;

@end
