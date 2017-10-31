//
//  FullScoreViewController.m
//  GlucoMe - Mobile
//
//  Created by Yiftah Ben Aharon on 4/24/14.
//  Copyright (c) 2014 Yiftah Ben Aharon. All rights reserved.
//

#import "FullScoreViewController.h"
#import "general.h"

@interface FullScoreViewController ()

@end

@implementation FullScoreViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.screenName = @"FullScoreViewController";
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
   /* NSDictionary* dict  = DLG.dataHandler.data;
    NSDictionary* profile  = DLG.dataHandler.profile;
    
    NSDictionary* data = [dict objectForKey:@"score"];
    
    self.daysLabel.text = [[NSString alloc] initWithFormat:@"%@", [data objectForKey:@"days"]];
    self.daysLabel.textColor = BLUE;
    
    self.measurementsLabel.text = [[NSString alloc] initWithFormat:@"%@", [data objectForKey:@"measurements"]];
    self.measurementsLabel.textColor = measurementsToColor(self.measurementsLabel.text);
    
    self.inRanhgeLabel.text =[[NSString alloc] initWithFormat:@"%@%%", [data objectForKey:@"in_range"]];

    self.inRanhgeLabel.textColor = rateToColor([data objectForKey:@"in_range_pct"]);
    
    self.ScoreLabel.text = [[NSString alloc] initWithFormat:@"%@%%", [data objectForKey:@"value"]];
    self.ScoreLabel.textColor = rateToColor([data objectForKey:@"value"]);
    
    self.required.text = [[NSString alloc] initWithFormat:@"%@", [profile objectForKey:@"daily_measurements"]];
    */
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)close:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];

}
@end
