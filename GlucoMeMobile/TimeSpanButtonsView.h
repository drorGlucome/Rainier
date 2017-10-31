//
//  TimeSpanButtonsView.h
//  GlucoMe - Mobile
//
//  Created by dovi winberger on 15/02/2016.
//  Copyright © 2016 Yiftah Ben Aharon. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TimeSpanButtonsViewDelegateProtocol <NSObject>

-(void)TimeSpanChanged:(int)days;
@end

@interface TimeSpanButtonsView : UIView

@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *selectionButtons;
@property (weak, nonatomic) id<TimeSpanButtonsViewDelegateProtocol> delegate;

-(void)SetSelectedDaysAgo:(int)daysAgo;//1 7 30 90 180 10000
-(int)GetSelectedDaysAgo;
@end
