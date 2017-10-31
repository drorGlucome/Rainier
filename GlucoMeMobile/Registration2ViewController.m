//
//  Registration2ViewController.m
//  GlucoMe - Mobile
//
//  Created by Yiftah Ben Aharon on 6/1/14.
//  Copyright (c) 2014 Yiftah Ben Aharon. All rights reserved.
//

#import "Registration2ViewController.h"
#import "general.h"
#import "DataHandler_new.h"

@interface Registration2ViewController ()

@end

@implementation Registration2ViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if(self.containerView.subviews.count == 0)
    {
        UIViewController *vc = [[UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil] instantiateViewControllerWithIdentifier:@"ProfileDataViewControllerStoryboardID"];
        [self addChildViewController:vc];
        [vc.view setFrame:CGRectMake(0, 0, self.containerView.frame.size.width, self.containerView.frame.size.height)];
        [self.containerView addSubview:vc.view];
        [vc didMoveToParentViewController:self];
    }
}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)Done:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"RegistrationFinishedNotification" object:nil];
    [[DataHandler_new getInstance] sendProfileToServer];
    [[DataHandler_new getInstance] SendLocaleToServer];
}

- (IBAction)Skip:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"RegistrationFinishedNotification" object:nil];
    [[DataHandler_new getInstance] sendProfileToServer];
    [[DataHandler_new getInstance] SendLocaleToServer];
}



@end
