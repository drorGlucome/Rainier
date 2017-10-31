//
//  IntroGenericViewController.h
//  GlucoMe - Mobile
//
//  Created by dovi winberger on 5/7/15.
//  Copyright (c) 2015 Yiftah Ben Aharon. All rights reserved.
//
//this is a a singe tutorial view

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "IntroContainerViewController.h"

@protocol IntroGenericViewControllerDelegateProtocol <NSObject>

-(void)GoToPageAfter:(UIViewController*)me;
-(void)GoToPageBefore:(UIViewController*)me;
-(NSArray*)ImageForPage:(int)i;
-(int)AnimationDurationForPage:(int)i;

@end
@interface IntroGenericViewController : UIViewController
{
    
}
@property (nonatomic) int pageIndex;

@property (nonatomic, weak) UIButton* doneButton;
@property (weak, nonatomic) UIButton* nextButton;
@property (weak, nonatomic) UIButton* prevButton;

@property (weak, nonatomic) id<IntroGenericViewControllerDelegateProtocol> delegate;
@property (weak, nonatomic) IBOutlet UILabel *mainLabel;
@property (weak, nonatomic) IBOutlet UILabel *secondLabel;
@property (weak, nonatomic) IBOutlet UIImageView *mainImage;
@property (weak, nonatomic) IBOutlet UILabel *secondLabelSecondLine;

@property (weak, nonatomic) IBOutlet UIButton *moreHelpButton;

@end
