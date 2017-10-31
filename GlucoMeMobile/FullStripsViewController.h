//
//  FullStripsViewController.h
//  GlucoMe - Mobile
//
//  Created by Yiftah Ben Aharon on 2/11/14.
//  Copyright (c) 2014 Yiftah Ben Aharon. All rights reserved.
//
//this is the strips view
#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@interface FullStripsViewController : BaseViewController
- (IBAction)numBoxesChanged:(id)sender;
- (IBAction)placeOrder:(id)sender;
- (IBAction)close:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *totalPrice;
- (IBAction)resetStrips:(id)sender;

+(void)UpdateStripsAmount:(UIViewController*)parentVC;
@end
