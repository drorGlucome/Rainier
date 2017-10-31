//
//  IntroGenericViewController.m
//  GlucoMe - Mobile
//
//  Created by dovi winberger on 5/7/15.
//  Copyright (c) 2015 Yiftah Ben Aharon. All rights reserved.
//

#import "IntroGenericViewController.h"
#import "IntroPageViewController.h"

@interface IntroGenericViewController ()

@end

@implementation IntroGenericViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.doneButton setTitle:loc(@"Finish") forState:UIControlStateNormal];
    [self.prevButton setTitle:loc(@"prev") forState:UIControlStateNormal];
    [self.nextButton setTitle:loc(@"next") forState:UIControlStateNormal];
    
    if(self.pageIndex == 0)
    {
        self.prevButton.hidden = YES;
    }
    else
    {
        self.prevButton.hidden = NO;
    }
    if(self.pageIndex == 5)
    {
        //self.doneButton.hidden = NO;
        //[self.nextButton setTitle:loc(@"Finish") forState:UIControlStateNormal];
        self.nextButton.hidden = YES;
    }
    else
    {
        //self.doneButton.hidden = YES;
        self.nextButton.hidden = NO;
        [self.nextButton setTitle:loc(@"next") forState:UIControlStateNormal];
    }
    
    if(self.mainImage.animationImages == nil)
        self.mainImage.animationImages = [self.delegate ImageForPage:self.pageIndex];
    self.mainImage.animationDuration = [self.delegate AnimationDurationForPage:self.pageIndex];
    self.mainImage.animationRepeatCount = 0;
    [self.mainImage startAnimating];
    

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(goToNextPage) name:@"NextTutorialPage" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(goToPrevPage) name:@"PrevTutorialPage" object:nil];
    
    return;
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}



- (void)goToNextPage
{
    [self.delegate GoToPageAfter:self];
}

- (void)goToPrevPage
{
    [self.delegate GoToPageBefore:self];
}

- (IBAction)MoreHelpButtonClicked:(id)sender
{
    if(self.pageIndex == InsertStripPage)
        [[HelpDialogManager getInstance] SetWithInsertTestStripTutorial];
    else if(self.pageIndex == PrickFingerPage)
        [[HelpDialogManager getInstance] SetWithPrickFingerTutorial];
    else if(self.pageIndex == PlaceBloodPage)
        [[HelpDialogManager getInstance] SetWIthPlaceBloodTutorial];
    else if(self.pageIndex == LancetPage)
        [[HelpDialogManager getInstance] SetWithLancetTutorial];
    
    
    [[HelpDialogManager getInstance] ShowOnView:self.view];
}


@end
