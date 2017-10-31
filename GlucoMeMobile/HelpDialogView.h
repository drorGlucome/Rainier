//
//  HelpDialogView.h
//  GlucoMe - Mobile
//
//  Created by dovi winberger on 8/24/15.
//  Copyright (c) 2015 Yiftah Ben Aharon. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HelpDialogView : UIView

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *mainLabel;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIButton *closeButton;

-(void)Close;
@end
