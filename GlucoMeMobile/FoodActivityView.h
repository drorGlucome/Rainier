//
//  FoodActivityView.h
//  GlucoMe - Mobile
//
//  Created by dovi winberger on 28/12/2015.
//  Copyright © 2015 Yiftah Ben Aharon. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum FoodActivityDialogType {foodType, activityType} FoodActivityDialogType;

@protocol FoodActivityViewDelegateProtocol <NSObject>

-(void)AmountSelected:(int)amount;

@end

@interface FoodActivityView : UIView

@property(nonatomic, weak) id<FoodActivityViewDelegateProtocol> delegate;

-(void)SetType:(FoodActivityDialogType)type;

@property (weak, nonatomic) IBOutlet UIButton *button1;
@property (weak, nonatomic) IBOutlet UIButton *button2;
@property (weak, nonatomic) IBOutlet UIButton *button3;

@end
