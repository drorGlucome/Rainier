//
//  ShareInitialViewController.m
//  GlucoMe - Mobile
//
//  Created by dovi winberger on 06/03/2016.
//  Copyright © 2016 Yiftah Ben Aharon. All rights reserved.
//

#import "ShareInitialViewController.h"
#import "Alert_helper.h"
#import "general.h"
@interface ShareInitialViewController ()

@end

@implementation ShareInitialViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self RefreshData];
    
    self.navigationItem.title = loc(@"Share");
    [self.backButton setTitle:loc(@"Back") forState:UIControlStateNormal];
    if ([UIApplication sharedApplication].userInterfaceLayoutDirection == UIUserInterfaceLayoutDirectionRightToLeft) {
        [self.backButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(RefreshData) name:@"DataChanged" object:nil];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)RefreshData
{
    int alertsCount = (int)[Alert Contacts].count;
    if(alertsCount == 0)
    {
        self.containerMultipleShares.alpha = 0;
        self.containerZeroShares.alpha = 1;
        self.topRightButton.hidden = YES;
    }
    else
    {
        self.containerMultipleShares.alpha = 1;
        self.containerZeroShares.alpha = 0;
        self.topRightButton.hidden = NO;
    }
}
- (IBAction)BackButtonClicked:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)unwindToInitialShareView:(UIStoryboardSegue *)unwindSegue
{
}
@end
