//
//  IntroContainerViewController.h
//  GlucoMe - Mobile
//
//  Created by dovi winberger on 5/7/15.
//  Copyright (c) 2015 Yiftah Ben Aharon. All rights reserved.
//
//this is a container view controller for the tutorial module
#import <UIKit/UIKit.h>

@interface IntroContainerViewController : UIViewController
- (IBAction)onDone:(id)sender;

@property (weak, nonatomic) IBOutlet UIButton *doneButton;
@property (weak, nonatomic) IBOutlet UIButton *prevButton;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;

- (IBAction)onNext:(id)sender;
- (IBAction)onPrev:(id)sender;
@end
