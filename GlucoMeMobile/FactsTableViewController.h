//
//  FactsTableViewController.h
//  GlucoMe - Mobile
//
//  Created by dovi winberger on 5/28/15.
//  Copyright (c) 2015 Yiftah Ben Aharon. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FactsTableViewController : UITableViewController
{
    NSArray* tableData;
}
@property (weak, nonatomic) IBOutlet UIButton *closeButton;

- (IBAction)Close:(id)sender;

@end
