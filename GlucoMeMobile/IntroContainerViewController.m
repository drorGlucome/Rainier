//
//  IntroContainerViewController.m
//  GlucoMe - Mobile
//
//  Created by dovi winberger on 5/7/15.
//  Copyright (c) 2015 Yiftah Ben Aharon. All rights reserved.
//

#import "IntroContainerViewController.h"
#import "IntroPageViewController.h"
@interface IntroContainerViewController ()

@end

@implementation IntroContainerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ShowErrorMessageOnTutorial:) name:@"ShowErrorMessageOnTutorial" object:nil];
    
    [self.doneButton setTitle:loc(@"Finish") forState:UIControlStateNormal];
    [self.prevButton setTitle:loc(@"prev") forState:UIControlStateNormal];
    [self.nextButton setTitle:loc(@"next") forState:UIControlStateNormal];
}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (IBAction)onDone:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSString * segueName = segue.identifier;
    if ([segueName isEqualToString: @"embededSegue"]) {
        IntroPageViewController * dest = (IntroPageViewController*) [segue destinationViewController];
        dest.doneButton = self.doneButton;
        dest.nextButton = self.nextButton;
        dest.prevButton = self.prevButton;
        dest.containerVC = self;
    }
}
- (IBAction)onNext:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"NextTutorialPage" object:nil];
}

- (IBAction)onPrev:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"PrevTutorialPage" object:nil];
}

-(void)ShowErrorMessageOnTutorial:(NSNotification*)note
{
    NSDictionary* dic = note.userInfo;
    
    [[HelpDialogManager getInstance] SetWithError:[[dic objectForKey:@"Error_code"] intValue]];
    [[HelpDialogManager getInstance] ShowOnView:self.view];
}
@end
