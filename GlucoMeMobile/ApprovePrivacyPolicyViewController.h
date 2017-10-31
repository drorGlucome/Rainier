//
//  ApprivePrivacyPolicyViewController.h
//  GlucoMe - Mobile
//
//  Created by dovi winberger on 29/05/2017.
//  Copyright © 2017 Yiftah Ben Aharon. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ApprovePrivacyPolicyViewController : UIViewController

@property (nonatomic, copy) void (^DenyBlock)(void);
@property (nonatomic, copy) void (^ApproveBlock)(void);

@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *subtitleLabel;

@property (weak, nonatomic) IBOutlet UILabel *eulaTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *privacyTitleLabel;

@property (weak, nonatomic) IBOutlet UIButton *denyButton;
@property (weak, nonatomic) IBOutlet UIButton *approveButton;

- (IBAction)Deny:(id)sender;
- (IBAction)Approve:(id)sender;

@end
