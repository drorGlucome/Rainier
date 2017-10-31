//
//  ProfileDataViewController.h
//  GlucoMe - Mobile
//
//  Created by dovi winberger on 21/02/2016.
//  Copyright © 2016 Yiftah Ben Aharon. All rights reserved.
//
//  This is the profile data page, that is meant to be a child of any other view controller

#import <UIKit/UIKit.h>

@interface ProfileDataViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate>
{
    NSMutableArray* PROFILE_GENERAL_LABEL_KEY_ARRAY;
    NSMutableArray* PROFILE_DIABETES_LABEL_KEY_ARRAY;
    NSMutableArray* PROFILE_CLINIC_LABEL_KEY_ARRAY;
}
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@end
