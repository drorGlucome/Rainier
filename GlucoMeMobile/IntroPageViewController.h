//
//  IntroPageViewController.h
//  GlucoMe - Mobile
//
//  Created by dovi winberger on 5/7/15.
//  Copyright (c) 2015 Yiftah Ben Aharon. All rights reserved.
//
//this is a pagination view of the tutorial module 

#import <UIKit/UIKit.h>
#import "IntroContainerViewController.h"

typedef enum PageIndex {WelcomePage, LancetPage, TakeCapOffPage, InsertStripPage, PrickFingerPage, PlaceBloodPage} PageIndex;

@interface IntroPageViewController : UIPageViewController
{
    NSMutableArray* myViewControllers;
}

@property (nonatomic, weak) UIButton* doneButton;
@property (nonatomic, weak) UIButton* nextButton;
@property (nonatomic, weak) UIButton* prevButton;
@property (nonatomic, weak) IntroContainerViewController* containerVC;
@end
