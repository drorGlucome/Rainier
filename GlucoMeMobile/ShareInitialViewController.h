//
//  ShareInitialViewController.h
//  GlucoMe - Mobile
//
//  Created by dovi winberger on 06/03/2016.
//  Copyright © 2016 Yiftah Ben Aharon. All rights reserved.
//
// initial view of the share module
#import <UIKit/UIKit.h>

@interface ShareInitialViewController : UIViewController
{
}
@property (weak, nonatomic) IBOutlet UIView *containerMultipleShares;
@property (weak, nonatomic) IBOutlet UIView *containerZeroShares;
@property (weak, nonatomic) IBOutlet UIButton *topRightButton;
@property (weak, nonatomic) IBOutlet UIButton *backButton;

@end
