//
//  FullScoreViewController.h
//  GlucoMe - Mobile
//
//  Created by Yiftah Ben Aharon on 4/24/14.
//  Copyright (c) 2014 Yiftah Ben Aharon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"


@interface FullScoreViewController : BaseViewController
- (IBAction)close:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *daysLabel;
@property (weak, nonatomic) IBOutlet UILabel *measurementsLabel;
@property (weak, nonatomic) IBOutlet UILabel *inRanhgeLabel;
@property (weak, nonatomic) IBOutlet UILabel *ScoreLabel;
@property (weak, nonatomic) IBOutlet UILabel *required;

@end
