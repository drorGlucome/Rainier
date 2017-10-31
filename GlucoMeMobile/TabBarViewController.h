//
//  TabBarViewController.h
//  GlucoMe - Mobile
//
//  Created by dovi winberger on 5/7/15.
//  Copyright (c) 2015 Yiftah Ben Aharon. All rights reserved.
//
//  This view controller is the main tab controller 

#import <UIKit/UIKit.h>

@interface TabAnimation : NSObject <UIViewControllerAnimatedTransitioning>
-(id)initWithDirection:(BOOL)_right;

@end

@interface TabBarViewController : UITabBarController <UITabBarControllerDelegate>



@end
