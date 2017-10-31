//
//  TabBarViewController.m
//  GlucoMe - Mobile
//
//  Created by dovi winberger on 5/7/15.
//  Copyright (c) 2015 Yiftah Ben Aharon. All rights reserved.
//

#import "TabBarViewController.h"
#import "general.h"
@interface TabBarViewController ()

@end

@implementation TabBarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.delegate = self;
    
    [self.viewControllers makeObjectsPerformSelector:@selector(view)];
    
    [[self.tabBar.items objectAtIndex:0] setTitle:loc(@"title_section1")];
    [[self.tabBar.items objectAtIndex:1] setTitle:loc(@"title_section2")];
    [[self.tabBar.items objectAtIndex:2] setTitle:loc(@"title_section3")];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(NewMeasurementWasCreated) name:@"NewMeasurement" object:nil];
    
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
-(void)NewMeasurementWasCreated
{
    //dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self setSelectedIndex:1];
    //});
}


-(id<UIViewControllerAnimatedTransitioning>)tabBarController:(UITabBarController *)tabBarController
            animationControllerForTransitionFromViewController:(UIViewController *)fromVC
                                              toViewController:(UIViewController *)toVC

{
    BOOL toTheRight = NO;
    if([tabBarController.viewControllers indexOfObject:toVC] > [tabBarController.viewControllers indexOfObject:fromVC])
        toTheRight = YES;

    TabAnimation *animation = [[TabAnimation alloc] initWithDirection:toTheRight];
    
    return animation;
}





@end


@implementation TabAnimation
bool right = false;
-(id)initWithDirection:(BOOL)_right
{
    self = [super init];
    if(self)
    {
        right = _right;
    }
    return self;
}
- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext
{
    // Get the "from" and "to" views
    UIView* fromView    = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey].view;//[transitionContext viewForKey:UITransitionContextFromViewKey];
    UIView* toView      = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey].view;//[transitionContext viewForKey:UITransitionContextToViewKey];
    
    [[transitionContext containerView] addSubview:fromView];
    [[transitionContext containerView] addSubview:toView];
    
    //The "to" view with start "off screen" and slide left pushing the "from" view "off screen"
    int direction = (right)? 1 : -1;
    
    toView.frame = CGRectMake(direction*toView.frame.size.width, 0, toView.frame.size.width, toView.frame.size.height);
    CGRect fromNewFrame = CGRectMake(direction*-1 * fromView.frame.size.width, 0, fromView.frame.size.width, fromView.frame.size.height);
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext]
                     animations:^{
                         toView.frame = [UIScreen mainScreen].bounds;
                         fromView.frame = fromNewFrame;
                     } completion:^(BOOL finished) {
                         [transitionContext completeTransition:YES];
                     }];
    
}

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext
{
    return 0.5;
}


@end

