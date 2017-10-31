//
//  ApprivePrivacyPolicyViewController.m
//  GlucoMe - Mobile
//
//  Created by dovi winberger on 29/05/2017.
//  Copyright © 2017 Yiftah Ben Aharon. All rights reserved.
//

#import "ApprovePrivacyPolicyViewController.h"

@interface ApprovePrivacyPolicyViewController ()

@end

@implementation ApprovePrivacyPolicyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.containerView.layer.cornerRadius = 5;
    self.containerView.layer.masksToBounds = YES;
 
    self.titleLabel.text = loc(@"Privacy_policy");
    self.subtitleLabel.text= loc(@"Please_approve_the_privacy_policy");
    
    self.privacyTitleLabel.text = loc(@"privacy_statement");
    self.eulaTitleLabel.text = loc(@"end_user_license_agreement");
    [self.privacyTitleLabel setTextAlignment:NSTextAlignmentNatural];
    [self.eulaTitleLabel setTextAlignment:NSTextAlignmentNatural];
    
    [self.approveButton setTitle:loc(@"Approve") forState:UIControlStateNormal];
    [self.denyButton setTitle:loc(@"Deny") forState:UIControlStateNormal];
    
}


- (IBAction)Deny:(id)sender {
    if(self.DenyBlock) self.DenyBlock();
    [self.view removeFromSuperview];
}

- (IBAction)Approve:(id)sender {
    if(self.ApproveBlock) self.ApproveBlock();
}
@end
