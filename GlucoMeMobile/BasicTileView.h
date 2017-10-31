//
//  TileViewController.h
//  GlucoMe - Mobile
//
//  Created by Yiftah Ben Aharon on 1/20/14.
//  Copyright (c) 2014 Yiftah Ben Aharon. All rights reserved.
//

#import <UIKit/UIKit.h>


#define LEFT_MARGIN 0
#define TOP_MARGIN -20

@interface BasicTileView : UIView
@property (weak, nonatomic) IBOutlet UIButton *tileButton;
@property (retain, nonatomic) IBOutlet UILabel *topLabel;
@property (retain, nonatomic) IBOutlet UILabel *centerLabel;
@property (retain, nonatomic) IBOutlet UILabel *bottomLabel;
@property (weak, nonatomic) IBOutlet UIView *contentView;

@property (weak, nonatomic) IBOutlet UIImageView *backgourndImageView;

- (void) wobbleCenterLabel;


@end
