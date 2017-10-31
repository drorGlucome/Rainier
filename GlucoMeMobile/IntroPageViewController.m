//
//  IntroPageViewController.m
//  GlucoMe - Mobile
//
//  Created by dovi winberger on 5/7/15.
//  Copyright (c) 2015 Yiftah Ben Aharon. All rights reserved.
//

#import "IntroPageViewController.h"
#import "IntroGenericViewController.h"
#import "UIImage+animatedGIF.h"

@interface IntroPageViewController () <IntroGenericViewControllerDelegateProtocol, UIPageViewControllerDelegate,UIPageViewControllerDataSource>

@end

@implementation IntroPageViewController

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    self.delegate = self;
    self.dataSource = self;

    myViewControllers = [[NSMutableArray alloc] init];
    [self.doneButton setTitle:loc(@"Finish") forState:UIControlStateNormal];
    [self.prevButton setTitle:loc(@"prev") forState:UIControlStateNormal];
    [self.nextButton setTitle:loc(@"next") forState:UIControlStateNormal];
    
    IntroGenericViewController* welcome = (IntroGenericViewController*)[[UIStoryboard storyboardWithName:@"IntroStoryboard" bundle:nil] instantiateViewControllerWithIdentifier:@"IntroGenericViewControllerID"];
    welcome.view.backgroundColor = [UIColor whiteColor];
    welcome.pageIndex = WelcomePage;
    welcome.mainLabel.text = loc(@"Welcome_to_glucome");
    welcome.secondLabel.text = loc(@"We_aill_guide_you");
    welcome.secondLabelSecondLine.text = loc(@"how_to_use_the_device");
    welcome.delegate = self;
    welcome.doneButton = self.doneButton;
    welcome.prevButton = self.prevButton;
    welcome.nextButton = self.nextButton;
    welcome.moreHelpButton.hidden = YES;
    [welcome.moreHelpButton setTitle:loc(@"need_more_help") forState:UIControlStateNormal];
    
    
    IntroGenericViewController* lancet = (IntroGenericViewController*)[[UIStoryboard storyboardWithName:@"IntroStoryboard" bundle:nil] instantiateViewControllerWithIdentifier:@"IntroGenericViewControllerID"];
    lancet.view.backgroundColor = [UIColor whiteColor];
    lancet.pageIndex = LancetPage;
    lancet.mainLabel.text = loc(@"Lancing_device");
    lancet.secondLabel.text = loc(@"Press_Next_once");
    lancet.secondLabelSecondLine.text = loc(@"the_lancet_is_assambled");
    lancet.delegate = self;
    lancet.mainImage.animationImages = [self ImageForPage:lancet.pageIndex];
    lancet.doneButton = self.doneButton;
    lancet.prevButton = self.prevButton;
    lancet.nextButton = self.nextButton;
    [lancet.moreHelpButton setTitle:loc(@"need_more_help") forState:UIControlStateNormal];
    
    IntroGenericViewController* takeCapOff = (IntroGenericViewController*)[[UIStoryboard storyboardWithName:@"IntroStoryboard" bundle:nil] instantiateViewControllerWithIdentifier:@"IntroGenericViewControllerID"];
    takeCapOff.view.backgroundColor = [UIColor whiteColor];
    takeCapOff.pageIndex = TakeCapOffPage;
    takeCapOff.mainLabel.text = loc(@"Take_the_cap_off");
    takeCapOff.secondLabel.text = loc(@"Press_Next_once");
    takeCapOff.secondLabelSecondLine.text = loc(@"the_cap_is_off");
    takeCapOff.delegate = self;
    takeCapOff.mainImage.animationImages = [self ImageForPage:takeCapOff.pageIndex];
    takeCapOff.doneButton = self.doneButton;
    takeCapOff.prevButton = self.prevButton;
    takeCapOff.nextButton = self.nextButton;
    takeCapOff.moreHelpButton.hidden = YES;
    [takeCapOff.moreHelpButton setTitle:loc(@"need_more_help") forState:UIControlStateNormal];
    
    IntroGenericViewController* testStrip = (IntroGenericViewController*)[[UIStoryboard storyboardWithName:@"IntroStoryboard" bundle:nil] instantiateViewControllerWithIdentifier:@"IntroGenericViewControllerID"];
    testStrip.view.backgroundColor = [UIColor whiteColor];
    testStrip.pageIndex = InsertStripPage;
    testStrip.mainLabel.text = loc(@"Insert_the_test_strip");
    testStrip.secondLabel.text = loc(@"Press_Next_once");
    testStrip.secondLabelSecondLine.text = loc(@"the_green_light_is_on");
    testStrip.delegate = self;
    testStrip.mainImage.animationImages = [self ImageForPage:testStrip.pageIndex];
    //testStrip.secondImage.image = [UIImage imageNamed:@"insertstrip_zoom.png"];
    testStrip.doneButton = self.doneButton;
    testStrip.prevButton = self.prevButton;
    testStrip.nextButton = self.nextButton;
    [testStrip.moreHelpButton setTitle:loc(@"need_more_help") forState:UIControlStateNormal];
    
    IntroGenericViewController* prickFinger = (IntroGenericViewController*)[[UIStoryboard storyboardWithName:@"IntroStoryboard" bundle:nil] instantiateViewControllerWithIdentifier:@"IntroGenericViewControllerID"];
    prickFinger.view.backgroundColor = [UIColor whiteColor];
    prickFinger.pageIndex = PrickFingerPage;
    prickFinger.mainLabel.text = loc(@"Prick_your_finger");
    prickFinger.secondLabel.text = loc(@"Press_Next_once_you");
    prickFinger.secondLabelSecondLine.text = loc(@"have_a_blood_drop_ready");
    prickFinger.delegate = self;
    prickFinger.mainImage.animationImages = [self ImageForPage:prickFinger.pageIndex];
    prickFinger.doneButton = self.doneButton;
    prickFinger.prevButton = self.prevButton;
    prickFinger.nextButton = self.nextButton;
    [prickFinger.moreHelpButton setTitle:loc(@"need_more_help") forState:UIControlStateNormal];
    
    IntroGenericViewController* placeBlood = (IntroGenericViewController*)[[UIStoryboard storyboardWithName:@"IntroStoryboard" bundle:nil] instantiateViewControllerWithIdentifier:@"IntroGenericViewControllerID"];
    placeBlood.view.backgroundColor = [UIColor whiteColor];
    placeBlood.pageIndex = PlaceBloodPage;
    placeBlood.mainLabel.text = loc(@"Place_a_blood_drop");
    placeBlood.secondLabel.text = loc(@"Apply_to_the_edge_of_the_strip_and");
    placeBlood.secondLabelSecondLine.text = loc(@"wait_for_the_green_light_to_blink");
    placeBlood.delegate = self;
    placeBlood.mainImage.animationImages = [self ImageForPage:placeBlood.pageIndex];
    //placeBlood.secondImage.image = [UIImage imageNamed:@"place_zoom.png"];
    placeBlood.doneButton = self.doneButton;
    placeBlood.prevButton = self.prevButton;
    placeBlood.nextButton = self.nextButton;
    [placeBlood.moreHelpButton setTitle:loc(@"need_more_help") forState:UIControlStateNormal];
    
    [myViewControllers addObjectsFromArray:@[welcome, lancet, takeCapOff, testStrip, prickFinger, placeBlood]];
    
    
    [self setViewControllers:@[welcome] direction:UIPageViewControllerNavigationDirectionForward animated:false completion:nil];
    
    [UIPageControl appearance].pageIndicatorTintColor = [UIColor lightGrayColor];
    [UIPageControl appearance].currentPageIndicatorTintColor = [UIColor darkGrayColor];
}


-(void)GoToPageAfter:(UIViewController *)me
{
    UIViewController* vc = [self pageViewController:self viewControllerAfterViewController:me];
    if(vc != nil)
        [self setViewControllers:@[vc] direction:UIPageViewControllerNavigationDirectionForward animated:true completion:nil];
    else
        [self.containerVC onDone:nil];
    
}
-(void)GoToPageBefore:(UIViewController *)me
{
    UIViewController* vc = [self pageViewController:self viewControllerBeforeViewController:me];
    if(vc != nil)
        [self setViewControllers:@[vc] direction:UIPageViewControllerNavigationDirectionReverse animated:true completion:nil];
    
}

-(int)AnimationDurationForPage:(int)pageIndex
{
    switch (pageIndex) {
        case LancetPage:
            return 20;
            break;
        case TakeCapOffPage:
            return 2;
            break;
        case InsertStripPage:
            return 4;
            break;
        case PrickFingerPage:
            return 8;
            break;
        case PlaceBloodPage:
            return 4;
            break;
        default:
            break;
    }

    return 0;
}

-(NSArray*)ImageForPage:(int)pageIndex
{
    if (pageIndex > 0)
    {
        int count = 0;
        NSString* seq = @"";
        NSString* extension = @""; //not needed for png
        switch (pageIndex) {
            case LancetPage:
                count = 10;
                seq = @"Prepare";
                break;
            case TakeCapOffPage:
                count = 6;
                seq = @"capoff";
                break;
            case InsertStripPage:
                count = 8;
                seq = @"insert_strip";
                break;
            case PrickFingerPage:
                count = 9;
                seq = @"prick_cock";
                break;
            case PlaceBloodPage:
                count = 9;
                seq = @"place";
                extension = @".jpg";
                break;
            default:
                break;
        }
        
        
        
        NSMutableArray* images = [[NSMutableArray alloc] init];
        for (int i = 0; i < count; i++)
        {
            NSString* num = [NSString stringWithFormat:@"%d", i];
            if(num.length == 1)
                num = [NSString stringWithFormat:@"000%@", num];
            else if(num.length == 2)
                num = [NSString stringWithFormat:@"00%@", num];
            else if(num.length == 3)
                num = [NSString stringWithFormat:@"0%@", num];
            
            UIImage* im = [UIImage imageNamed:[NSString stringWithFormat:@"%@%@%@",seq,num,extension]];
            [images addObject:im];
        }
        return images;
    }
    return nil;

    
    /*NSURL *url;
    NSArray* image = nil;
    switch (pageIndex) {
        case 0:
            url  = [[NSBundle mainBundle] URLForResource:@"welcome" withExtension:@"gif"];
            image = [UIImage animatedImageWithAnimatedGIFURL:url];
            break;
        case 1:
            url = [[NSBundle mainBundle] URLForResource:@"place_10fps" withExtension:@"gif"];
            image = [UIImage animatedImageWithAnimatedGIFURL:url];
            break;
        case 2:
            url = [[NSBundle mainBundle] URLForResource:@"place_10fps" withExtension:@"gif"];
            image = [UIImage animatedImageWithAnimatedGIFURL:url];
            break;
        case 3:
            url = [[NSBundle mainBundle] URLForResource:@"place_10fps" withExtension:@"gif"];
            image = [UIImage animatedImageWithAnimatedGIFURL:url];
            break;
        case 4:
            url = [[NSBundle mainBundle] URLForResource:@"place_10fps" withExtension:@"gif"];
            image = [UIImage animatedImageWithAnimatedGIFURL:url];
            break;
        default:
            break;
    }
    return image;*/
}



-(UIViewController*)viewControllerAtIndex:(NSInteger)index
{
    return myViewControllers[index];
}

-(UIViewController*)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    int currentIndex = (int)[myViewControllers indexOfObject:viewController];
    
    --currentIndex;
    if(currentIndex > myViewControllers.count-1) {return nil;}
    if(currentIndex < 0) {return nil;}
    return myViewControllers[currentIndex];
}


-(UIViewController*)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    int currentIndex  = (int)[myViewControllers indexOfObject:viewController];
    
    ++currentIndex;
    //currentIndex = currentIndex % (myViewControllers.count);
    if(currentIndex > myViewControllers.count-1)
    {
        //dismissViewControllerAnimated(true, completion: nil);
        //return UIViewController();
        return nil;
    }
    if(currentIndex < 0) {return nil;}
    return myViewControllers[currentIndex];
}

-(NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController
{
    return myViewControllers.count;
}

-(NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController
{
    return [myViewControllers indexOfObject:self.viewControllers[0]];
}

@end
