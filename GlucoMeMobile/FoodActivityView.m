//
//  FoodActivityView.m
//  GlucoMe - Mobile
//
//  Created by dovi winberger on 28/12/2015.
//  Copyright © 2015 Yiftah Ben Aharon. All rights reserved.
//

#import "FoodActivityView.h"
#import "UIImage+FontAwesome.h"
#import "UIButton+VerticalLayout.h"
#import "NSString+FontAwesome.h"
@implementation FoodActivityView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(void)SetType:(FoodActivityDialogType)type
{

    NSAttributedString* attr;

    if(type == foodType)
    {
        NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
        attachment.image = [UIImage imageNamed:@"food"];
        attr = [NSAttributedString attributedStringWithAttachment:attachment];
    }
    else//activity
    {
        NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
        attachment.image = [UIImage imageNamed:@"activity"];
        attr = [NSAttributedString attributedStringWithAttachment:attachment];
    }
    
    
    NSMutableAttributedString* title1 = [[NSMutableAttributedString alloc] initWithString:@""];
    [title1 appendAttributedString:attr];
    [self.button1 setAttributedTitle:title1 forState:UIControlStateNormal];
    
    NSMutableAttributedString* title2 = [[NSMutableAttributedString alloc] initWithString:@""];
    [title2 appendAttributedString:attr];
    [title2 appendAttributedString:attr];
    [self.button2 setAttributedTitle:title2 forState:UIControlStateNormal];
    
    NSMutableAttributedString* title3 = [[NSMutableAttributedString alloc] initWithString:@""];
    [title3 appendAttributedString:attr];
    [title3 appendAttributedString:attr];
    [title3 appendAttributedString:attr];
    [self.button3 setAttributedTitle:title3 forState:UIControlStateNormal];
    
   
}
- (IBAction)ButtonClicked:(id)sender
{
    if (self.delegate != nil)
        [self.delegate AmountSelected:(int)((UIButton*)sender).tag];
}

@end
