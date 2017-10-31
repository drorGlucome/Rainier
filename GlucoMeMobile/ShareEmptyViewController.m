//
//  ShareEmptyViewController.m
//  GlucoMe - Mobile
//
//  Created by dovi winberger on 28/05/2017.
//  Copyright © 2017 Yiftah Ben Aharon. All rights reserved.
//

#import "ShareEmptyViewController.h"

@interface ShareEmptyViewController ()

@end

@implementation ShareEmptyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.explanationTextView.text = loc(@"empty_share_text");
    [self.explanationTextView sizeToFit];
    [self.startSharingButton setTitle:loc(@"Start_sharing") forState:UIControlStateNormal];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
