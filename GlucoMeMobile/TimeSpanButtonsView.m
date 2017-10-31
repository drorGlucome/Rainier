//
//  TimeSpanButtonsView.m
//  GlucoMe - Mobile
//
//  Created by dovi winberger on 15/02/2016.
//  Copyright © 2016 Yiftah Ben Aharon. All rights reserved.
//

#import "TimeSpanButtonsView.h"

@implementation TimeSpanButtonsView

-(void)awakeFromNib
{
    [super awakeFromNib];
    [self setup];
}

-(void)setup
{
    UIImage* selectedImage = [UIImage imageNamed:@"tagButtonBackgroundActive"];
    for(UIButton* b in self.selectionButtons)
    {
        [b setBackgroundImage:selectedImage forState:UIControlStateSelected]; ;
    }
}

- (IBAction)TimeSpanButtonClicked:(id)sender {
    UIButton* senderButton = (UIButton*)sender;
    
    for(int i = 0; i < self.selectionButtons.count; i++) {
        UIButton* b = [self.selectionButtons objectAtIndex:i];
        b.selected = (b.tag == senderButton.tag);
    }
    [self.delegate TimeSpanChanged:(int)senderButton.tag];
}
-(void)SetSelectedDaysAgo:(int)daysAgo
{
    for(int i = 0; i < self.selectionButtons.count; i++) {
        UIButton* b = [self.selectionButtons objectAtIndex:i];
        if(b.tag == daysAgo)
        {
            [self TimeSpanButtonClicked:b];
            return;
        }
    }
    [self TimeSpanButtonClicked:[self.selectionButtons objectAtIndex:1]];//select default 1w 
}
-(int)GetSelectedDaysAgo
{
    int daysAgo = 7;
    for(int i = 0; i < self.selectionButtons.count; i++)
    {
        UIButton* b = (UIButton*)[self.selectionButtons objectAtIndex:i];
        if(b.selected) {
            daysAgo = (int)b.tag;
            break;
        }
    }
    return daysAgo;
}
@end
