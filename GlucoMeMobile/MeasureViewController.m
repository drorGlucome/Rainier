//
//  FirstViewController.m
//  GlucoMe - Mobile
//
//  Created by Yiftah Ben Aharon on 1/9/14.
//  Copyright (c) 2014 Yiftah Ben Aharon. All rights reserved.
//

#import "MeasureViewController.h"
#import "MeViewController.h"
#import "ProfileViewController.h"
#import "Measurement_helper.h"
#import "DataHandler_new.h"
#import <QuartzCore/QuartzCore.h>
#import "PairingManager.h"
#import "YALContextMenuTableView.h"
#import "ContextMenuCell.h"
#import "UIImage+FontAwesome.h"
#import "HelpDialogView.h"
#define ManualInput_UID 9999

static NSString *const menuCellIdentifier = @"rotationCell";

@interface MeasureViewController ()
<
GlucoMeSDKDelegateProtocol,
UITableViewDelegate,
UITableViewDataSource,
YALContextMenuTableViewDelegate
>

@property (nonatomic, strong) YALContextMenuTableView* contextMenuTableView;

@property (nonatomic, strong) NSArray *menuTitles;
@property (nonatomic, strong) NSArray *menuIcons;
@end

@implementation MeasureViewController
@synthesize baseView;
@synthesize topView;
@synthesize protocol;


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initScanAnimation];
    inScan = false;
    protocol =  [[GlucoMeSDK alloc] init];
    [[NSUserDefaults standardUserDefaults] setObject:[protocol SDKVersion] forKey:SDKVersionKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [protocol setDelegate:self];


    [self initiateMenuOptions];
    
    UISwipeGestureRecognizer* swipeleft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(SwipeLeftGestureRecognizer)];
    swipeleft.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.view addGestureRecognizer:swipeleft];
    [self showTutorial:nil];
}

-(void)SwipeLeftGestureRecognizer
{
    self.tabBarController.selectedIndex++;
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(becomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ProfileChanged) name:@"ProfileChanged" object:nil];
    
    isOnTutorial = NO;
    
    [self.startButton setHidden:YES];
    
    self.screenName = @"MeasureViewController";

    self.waitingForMeasurementLabel.text = loc(@"place_blood_drop");
    
    [self SetName];
    
}

- (void)initiateMenuOptions {
    self.menuTitles = @[loc(@"Glucose"),
                        loc(@"Medicine"),
                        loc(@"Food"),
                        loc(@"Activity"),
                        loc(@"Weight")
                        ];
    
    self.menuIcons = @[[UIImage imageNamed:@"glucose"],
                       [UIImage imageNamed:@"medicine"],
                       [UIImage imageNamed:@"food"],
                       [UIImage imageNamed:@"activity"],
                       [UIImage imageNamed:@"weight"],
                       ];
}

-(void)AnimateTutorialImageView
{
    [self.tutorialImageView startAnimating];
}


-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if(isOnTutorial == NO)
        [self stop:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil];
    singleMeasurementNavigationController = [storyboard instantiateViewControllerWithIdentifier:@"SingleMeasurementID"];
    singleMeasurementViewController = singleMeasurementNavigationController.viewControllers[0];
    
    [self start:self.startButton];
    
    //if had not seen tutorial: show it
//    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//
//    if ([defaults boolForKey:@"didSeeTutorial"] == NO)
//    {
//        [self showTutorial:nil];
//
//        [defaults setBool:YES forKey:@"didSeeTutorial"];
//        [defaults synchronize];
//    }
}
//
//-(void)NewMeasurementWasCreated
//{
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [self.tabBarController setSelectedIndex:1];
//    });
//}
-(void)ProfileChanged
{
    [self SetName];
}

-(void)SetName
{
    NSString* userName = [[NSUserDefaults standardUserDefaults] stringForKey:profile_first_name];
    if(userName == nil) userName = @"";
    self.titleLabel.text = [NSString stringWithFormat:@"%@ %@", loc(@"Welcome"), userName];

}
- (IBAction)showTutorial:(id)sender
{
    isOnTutorial = YES;
    UIViewController* vc =  [[UIStoryboard storyboardWithName:@"IntroStoryboard" bundle:nil] instantiateInitialViewController];
    [self presentViewController:vc animated:NO completion:nil];
}


- (IBAction)radarClicked:(id)sender {
    if(inScan) {
        [self stop:sender];
    }
    else {
        [self start:sender];
    }
    
}

- (IBAction)stop:(id)sender {
    //UIButton* button = (UIButton*)sender;
//    [button setTitle:loc(@"Tap to Start") forState:UIControlStateNormal];
    [self.topView.layer removeAllAnimations];
    [self.baseView stopAnimating];
    //[self.topView removeFromSuperview];
    inScan = false;
    
#if !TARGET_IPHONE_SIMULATOR
    [protocol stop];
#endif
    
}

- (void)start:(id)sender
{
    [self.topView.layer removeAllAnimations];

    UIButton* button = (UIButton*)sender;

    //    [button setTitle:loc(@"Tap to Stop") forState:UIControlStateNormal];
    [self.view bringSubviewToFront:button];
    
    [self.baseView startAnimating];
    
    [self rotateImageView];
    
    inScan = true;
    
#if !TARGET_IPHONE_SIMULATOR
    [protocol startWithAudioPermissionDenidedBlock:^{
        
            UIAlertController *alertController = [UIAlertController
                                                  alertControllerWithTitle:loc(@"Microphone_permission_denied")
                                                  message:@"The_app_must_have_microphone_permission_to_communicate_with_the_BGM"
                                                  preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *okAction = [UIAlertAction
                                       actionWithTitle:loc(@"Grant_permission")
                                       style:UIAlertActionStyleDefault
                                       handler:^(UIAlertAction *action)
                                       {
                                           [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
                                       }];
            UIAlertAction *exitAction = [UIAlertAction
                                         actionWithTitle:loc(@"Exit_app")
                                         style:UIAlertActionStyleDefault
                                         handler:^(UIAlertAction *action)
                                         {
                                             exit(0);
                                         }];
            [alertController addAction:okAction];
            [alertController addAction:exitAction];
            [self presentViewController:alertController animated:YES completion:nil];
        
    }];
    
    
#endif
    
}

- (void)rotateImageView
{
    CGFloat direction = 1.0f;  // -1.0f to rotate other way
    self.topView.transform = CGAffineTransformIdentity;
    [UIView animateKeyframesWithDuration:4 delay:0.0
                                 options:UIViewKeyframeAnimationOptionCalculationModeLinear | UIViewAnimationOptionRepeat | UIViewAnimationOptionCurveLinear
                              animations:^{
                                  [UIView addKeyframeWithRelativeStartTime:0 relativeDuration:0.33 animations:^{
                                      self.topView.transform = CGAffineTransformMakeRotation(M_PI * 2.0f / 3.0f * direction);
                                  }];
                                  [UIView addKeyframeWithRelativeStartTime:0.33 relativeDuration:0.33 animations:^{
                                      self.topView.transform = CGAffineTransformMakeRotation(M_PI * 4.0f / 3.0f * direction);
                                  }];
                                  [UIView addKeyframeWithRelativeStartTime:0.66 relativeDuration:0.33 animations:^{
                                      self.topView.transform = CGAffineTransformIdentity;
                                  }];
                              }
                              completion:^(BOOL finished) {}];
}

- (void) initScanAnimation {
    NSMutableArray* images = [[NSMutableArray alloc] init];
    for(int i=1;i<=5;i++) {
        NSString* tmp = [[NSString alloc] initWithFormat:@"radar_%d.png", i ];
        [images addObject:[UIImage imageNamed:tmp]];
    }
    self.baseView.animationImages = images;
    self.baseView.animationRepeatCount = 10000;
    self.baseView.animationDuration = 3;
    
    [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(WaitingForMeasurementAnimation) userInfo:nil repeats:YES];
}

-(void)WaitingForMeasurementAnimation
{
    static int numberOfDots = 2;

    NSString* t = [NSString stringWithFormat:@"%@...",loc(@"place_blood_drop")];
    
    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:t];
    [text addAttribute:NSForegroundColorAttributeName
                 value:[UIColor clearColor]
                 range:NSMakeRange(t.length-numberOfDots, numberOfDots)];
    
    [self.waitingForMeasurementLabel setAttributedText:text];
    
    numberOfDots = (numberOfDots - 1) % 3;
    numberOfDots = (numberOfDots < 0) ? 3 + numberOfDots : numberOfDots;
}


-(void)ShowManualInputWithType:(MeasurementType)type
{
    [singleMeasurementViewController SetType:type source:@"manual"];
    singleMeasurementViewController.allowCancel = YES;
    [singleMeasurementViewController wobbleValueLabel];
    UIViewController *topVC = self.tabBarController;
    [topVC presentViewController:singleMeasurementNavigationController animated:YES completion:nil];
}
- (IBAction)manualInput:(id)sender {
    // init YALContextMenuTableView tableView
    if (!self.contextMenuTableView) {
        self.contextMenuTableView = [[YALContextMenuTableView alloc]initWithTableViewDelegateDataSource:self];
        self.contextMenuTableView.animationDuration = 0.15;
        //optional - implement custom YALContextMenuTableView custom protocol
        self.contextMenuTableView.yalDelegate = self;
        //optional - implement menu items layout
        self.contextMenuTableView.menuItemsSide = Right;
        self.contextMenuTableView.menuItemsAppearanceDirection = FromTopToBottom;
        
        //register nib
        UINib *cellNib = [UINib nibWithNibName:@"ContextMenuCell" bundle:nil];
        [self.contextMenuTableView registerNib:cellNib forCellReuseIdentifier:menuCellIdentifier];
    }
    
    // it is better to use this method only for proper animation
    if (self.contextMenuTableView.superview == NULL)
        [self.contextMenuTableView showInView:self.view withEdgeInsets:UIEdgeInsetsMake(0, self.view.frame.size.width/2.5, 0, 0) animated:YES];
    else
        [self.contextMenuTableView dismisWithIndexPath:NULL];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(alertView.alertViewStyle != UIAlertViewStylePlainTextInput) { // Error message
        return;
    }
    else if(alertView.tag == 999) {  //Manual input
        
        if(buttonIndex == 1) //done
        {
            [self.view endEditing:YES];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                NSString* value = [[alertView textFieldAtIndex:0] text];
                if([value isEqualToString:@""]) return;
                float glucoseFloat = [value floatValue];
                int glucose = 0;
                if ([[UnitsManager getInstance] GetGlucoseUnits] == mgdl) {
                    glucose = (int)glucoseFloat;
                }
                else
                {
                    glucose = (int)(glucoseFloat * 18);
                }
                [self GlucoMeSDKFinishedWith_uid:ManualInput_UID firmewareVersion:0 error:0 battery:0 glucose:glucose];
            });
        }
    }
}


-(void)GlucoMeSDKFinishedWith_uid:(int)uid
                   firmewareVersion:(int)firmwareVersion
                              error:(int)error
                            battery:(int)battery
                            glucose:(int)glucose
{
    if([NSThread isMainThread])
        [self ProtocolDecoderFinishedMainWith_uid:uid firmwareVersion:firmwareVersion error:error battery:battery glucose:glucose];
    else
        dispatch_async(dispatch_get_main_queue(), ^{
            [self ProtocolDecoderFinishedMainWith_uid:uid firmwareVersion:firmwareVersion error:error battery:battery glucose:glucose];
        });
    
}
NSDate* lastMeasurementDate = nil;
- (void) ProtocolDecoderFinishedMainWith_uid:(int)uid firmwareVersion:(int)firmwareVersion error:(int)error battery:(int)battery glucose:(int)glucose
{
    if(firmwareVersion != 15) //type != medicine
    {
        NSNumber* correctionFactor = @([[[NSUserDefaults standardUserDefaults] objectForKey:profile_correction_factor] doubleValue]);
        if(correctionFactor == nil) {
            correctionFactor = @(1.0);
        }
        glucose *= [correctionFactor doubleValue];
    }

    if(glucose > 700)
    {
        glucose = 7; //assuming strip is damaged
        error = 1;
    }
    
    last_uid = uid;
    last_firmware_version = firmwareVersion;
    last_error = error;
    last_battery = battery;
    last_glucose = glucose;
    
    if(!inScan)
        return;

    NSLog(@"Done ! UID %d Glucose: %d, Battery: %d, error %d", uid, glucose, battery, error);

    if(uid != ManualInput_UID && [self handlePairing:uid] == false)
    {
        NSLog(@"Measurement IGNORED because of UID");
        return;
    }
    
    NSDate* currentDate = [NSDate date];
    long secondsFromPastMeasurement = 100;
    if (lastMeasurementDate != nil)
        secondsFromPastMeasurement = fabs(([currentDate timeIntervalSinceDate:lastMeasurementDate]));
    if(secondsFromPastMeasurement > 15)
    {
        //if prev measurement was within 15 seconds then it must be the same strip (device repeats the transmission every 10 seconds)
        //if ERR_INVALID_STRIP then it is a used strip.. dont deduct
        if(error == 0 || (error != 0 && glucose != ERR_INVALID_STRIP))
            [[DataHandler_new getInstance] DeductOneStrip];//updating strips count
    }
    lastMeasurementDate = currentDate;
    
    
    
    if(error != 0)
    {
        int error_code = glucose;
        if(isOnTutorial)
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"ShowErrorMessageOnTutorial" object:nil userInfo:@{@"Error_code" : @(error_code)}];
            return;
        }
        
        [[HelpDialogManager getInstance] SetWithError:error_code];
        [[HelpDialogManager getInstance] ShowOnView:self.view];

        
    }
    else
    {
        if(battery != 0 )
        {
            NSString* msg = loc(@"Battery_level_is_low_Please_replace_battery");
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:loc(@"Warning")
                                                            message:msg
                                                           delegate:self
                                                  cancelButtonTitle:loc(@"Replace_device_battery")
                                                  otherButtonTitles:nil];
            [alert show];
        }
        
        if(isOnTutorial)
        {
            //closing tutorial only in a successfull measurement
            [self dismissViewControllerAnimated:NO completion:^{
                [self ProtocolDecoderFinishedMainWith_uid:uid firmwareVersion:firmwareVersion error:error battery:battery glucose:glucose];
            }];
            return;
        }
        [[HelpDialogManager getInstance] Close];
        
        int type = 0; //BGM
        //firmwareVersion == 1 - BGM
        //firmwareVersion == 15 - IPM
        if(firmwareVersion == 15) type = 1;
        [Measurement SaveMeasurementAndSendToServer:glucose type:type source:@"glucome" completionBlock:^(Measurement *m)
         {
             [singleMeasurementViewController SetMeasurement:m];
             
             UIViewController *topVC = self.tabBarController;
             [topVC presentViewController:singleMeasurementNavigationController animated:YES completion:nil];
             [singleMeasurementViewController wobbleValueLabel];
           
             [[NSNotificationCenter defaultCenter] postNotificationName:@"NewMeasurement" object:nil];
        }];
        
        
        
    }
}

- (NSTimeInterval)timeDifferenceSinceLastOpen {
    
    if (!self.previousTime) self.previousTime = [NSDate date];
    NSDate *currentTime = [NSDate date];
    NSTimeInterval timeDifference =  [currentTime timeIntervalSinceDate:self.previousTime];
    self.previousTime = currentTime;
    return timeDifference;
}


- (bool) handlePairing:(int)uid
{
    NSNumber* uid_number = [NSNumber numberWithInt:uid];

    NSArray* pairedDevices = [PairingManager getPairedDevices];
//    if(pairedDevices == nil)
//    {
//        [PairingManager addPairedDevice:uid];
//        return true;
//    }
//    if ([[PairingManager getCandidatesDevices] containsObject:uid_number])
//    {
//            NSString* msg = loc(@"A_new_GlucoMe_device_was_found_Would_you_like_to_register_it");
//            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:loc(@"Register_new_device") message:msg delegate:self cancelButtonTitle:loc(@"No") otherButtonTitles:loc(@"Register"), nil];
//            alert.tag = 100;
//            [alert show];
//            return false;
//    }
//    
//    if ([pairedDevices containsObject:uid_number] == false)
//    {
//        [PairingManager AddUidToCandidates:uid_number];
//        return false;
//    }
    return [pairedDevices containsObject:uid_number];
}


- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if(alertView.tag == 100 && buttonIndex == 1) // "Yes"
    {
        [PairingManager addPairedDevice:last_uid];
        [self ProtocolDecoderFinishedMainWith_uid:last_uid firmwareVersion:last_firmware_version error:last_error battery:last_battery glucose:last_glucose];
    }
}




-(void)becomeActive:(NSNotification *)notification {
    [self start:self.startButton];
}




#pragma mark - YALContextMenuTableViewDelegate

- (void)contextMenuTableView:(YALContextMenuTableView *)contextMenuTableView didDismissWithIndexPath:(NSIndexPath *)indexPath{
    //NSLog(@"Menu dismissed with indexpath = %@", indexPath);
    if(indexPath == nil) return;
    switch (indexPath.row) {
        case 0:
            [self ShowManualInputWithType:glucoseMeasurementType];
            break;
        case 1:
            [self ShowManualInputWithType:medicineMeasurementType];
            break;
        case 2:
            [self ShowManualInputWithType:foodMeasurementType];
            break;
        case 3:
            [self ShowManualInputWithType:activityMeasurementType];
            break;
        case 4:
            [self ShowManualInputWithType:weightMeasurementType];
            break;
        default:
            break;
    }
}

#pragma mark - UITableViewDataSource, UITableViewDelegate

- (void)tableView:(YALContextMenuTableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView dismisWithIndexPath:indexPath];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.menuTitles.count;
}

- (UITableViewCell *)tableView:(YALContextMenuTableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    ContextMenuCell *cell = [tableView dequeueReusableCellWithIdentifier:menuCellIdentifier forIndexPath:indexPath];
    
    if (cell) {
        cell.backgroundColor = [UIColor clearColor];
        cell.menuTitleLabel.text = [self.menuTitles objectAtIndex:indexPath.row];
        cell.menuImageView.image = [self.menuIcons objectAtIndex:indexPath.row];
    }
    
    return cell;
}

@end
