//
//  TileViewController.m
//  GlucoMe - Mobile
//
//  Created by Yiftah Ben Aharon on 1/20/14.
//  Copyright (c) 2014 Yiftah Ben Aharon. All rights reserved.
//

#import "BasicTileView.h"
#import "FullTableViewControllerNew.h"


@implementation BasicTileView
@synthesize topLabel;
@synthesize centerLabel;
@synthesize bottomLabel;
@synthesize tileButton;



-(void)awakeFromNib
{
    //self.backgourndImageView.image = [[UIImage imageNamed:@"non-flat-tile-bg.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10) resizingMode:UIImageResizingModeStretch];
    [super awakeFromNib];
}

-(void)layoutSubviews
{
    [self.topLabel setFont:[UIFont fontWithName:self.topLabel.font.fontName size:[UIScreen mainScreen].bounds.size.height/38]];
    [self.centerLabel setFont:[UIFont fontWithName:self.centerLabel.font.fontName size:[UIScreen mainScreen].bounds.size.height/13]];
    [self.bottomLabel setFont:[UIFont fontWithName:self.bottomLabel.font.fontName size:[UIScreen mainScreen].bounds.size.height/38]];
  
}


- (void) wobbleCenterLabel {
    CGAffineTransform leftWobble = CGAffineTransformMakeScale(1.1, 1.1);
    CGAffineTransform rightWobble = CGAffineTransformMakeScale(0.9, 0.9);
    centerLabel.transform = leftWobble;  // starting point
    [UIView animateWithDuration:0.25 delay:0 options:(UIViewAnimationOptionRepeat | UIViewAnimationOptionAutoreverse) animations:^{
        [UIView setAnimationRepeatCount:5];
        centerLabel.transform = rightWobble;
    }completion:^(BOOL finished){
        centerLabel.transform =CGAffineTransformIdentity;
    }];
}



@end



