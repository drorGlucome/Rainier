//
//  TreatmentTabBarController.m
//  GlucoMe - Mobile
//
//  Created by dovi winberger on 26/06/2016.
//  Copyright © 2016 Yiftah Ben Aharon. All rights reserved.
//

#import "TreatmentTabBarController.h"

@interface TreatmentTabBarController ()

@end

@implementation TreatmentTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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
- (IBAction)Back:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
