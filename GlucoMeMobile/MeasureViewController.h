//
//  FirstViewController.h
//  GlucoMe - Mobile
//
//  Created by Yiftah Ben Aharon on 1/9/14.
//  Copyright (c) 2014 Yiftah Ben Aharon. All rights reserved.
//
//  This is the measure page

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "GlucoMeSDK.h"
#import "SingleMeasurementViewController.h"

@interface MeasureViewController : BaseViewController {
    int last_uid, last_firmware_version, last_error, last_battery, last_glucose;
    bool inScan;
    SingleMeasurementViewController* singleMeasurementViewController;
    UINavigationController* singleMeasurementNavigationController;
    BOOL isOnTutorial;
}
@property (retain, nonatomic) IBOutlet UIImageView *baseView;
@property (retain, nonatomic) IBOutlet UIImageView *topView;
@property (retain, nonatomic) GlucoMeSDK *protocol;

@property (weak, nonatomic) IBOutlet UIButton *startButton;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *waitingForMeasurementLabel;
@property (weak, nonatomic) IBOutlet UIButton *showIntroButton;
@property (weak, nonatomic) IBOutlet UIImageView *tutorialImageView;
@property (weak, nonatomic) IBOutlet UIButton *manualInputButton;
@property (weak, nonatomic) IBOutlet UIView *bubbleMenu;

@property(nonatomic, retain) NSDate *previousTime;

- (void)start:(id)sender;
- (void)stop:(id)sender;
- (IBAction)radarClicked:(id)sender;
- (void) initScanAnimation;
- (IBAction)manualInput:(id)sender;
- (bool) handlePairing:(int)uid;
//- (void) scrollToResults;


@end
