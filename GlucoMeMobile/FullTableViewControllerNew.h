//
//  FullTableViewControllerNew.h
//  GlucoMe - Mobile
//
//  Created by dovi winberger on 5/5/15.
//  Copyright (c) 2015 Yiftah Ben Aharon. All rights reserved.
//
//this is a base class for table view controllers
#import <UIKit/UIKit.h>
#import "GAI.h"
#import "GAIFields.h"
#import "GAIDictionaryBuilder.h"


@interface FullTableViewControllerNew : UITableViewController
{
}

@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UIButton *actionButton;


- (IBAction)onActionButtonClicked:(id)sender;
- (IBAction)onBackButtonClicked:(id)sender;


- (IBAction)h1Click;
- (IBAction)h2Click;
- (IBAction)h3Click;

@property (weak, nonatomic) IBOutlet UIButton *h1Button;
@property (weak, nonatomic) IBOutlet UIButton *h2Button;
@property (weak, nonatomic) IBOutlet UIButton *h3Button;

@end
