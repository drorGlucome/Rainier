//
//  HelpDialogManager.h
//  GlucoMe - Mobile
//
//  Created by dovi winberger on 8/24/15.
//  Copyright (c) 2015 Yiftah Ben Aharon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HelpDialogView.h"

typedef enum {
    ERR_NONE,               // 0 no problem
    ERR_TEMPERATURE,		//1 out of range 10~40 degrees
    ERR_INVALID_STRIP,		//2 reused strip
    ERR_REMOVE_STRIP,		//3 removed strip during measurement
    ERR_MEASUREMENT,		//4 out of range DC 310mV +/- 6mV?
    ERR_SYSTEM,			//5 abnormal temperature & battery voltage
    ERR_LOWEST,			//6 glucose is under 3 3mg/dL
    ERR_STRIIP_ERROR,    //7       Check strip error            damaged check strip
    ERR_INSUFFICIENT_BLOOD,		//8 blood check once, but not detect blood
    ERR_WRONG_BLOOD_DIRECTION,	//9 blood direction error
    ERR_BLOOD_INSERTION_TIMEOUT,	//10   time out 60sec of input blood
    ERR_BATTERY             //11     Battery error                  battery level is out of voltage 2.6V ~ 3.45V
} ErrorCode_t;

@interface HelpDialogManager : NSObject
{
    HelpDialogView* dialogView;
}
+(HelpDialogManager*)getInstance;

-(void)ShowOnView:(UIView*)view;
-(void)Close;

-(void)SetWithTitle:(NSString*)title andMessage:(NSString*)message;
-(void)SetWithError:(int)error_code;

-(void)SetWithLancetTutorial;
-(void)SetWithInsertTestStripTutorial;
-(void)SetWithPrickFingerTutorial;
-(void)SetWIthPlaceBloodTutorial;
@end
