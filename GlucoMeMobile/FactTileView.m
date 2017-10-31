//
//  FactTileView.m
//  GlucoMe - Mobile
//
//  Created by Yiftah Ben Aharon on 4/23/14.
//  Copyright (c) 2014 Yiftah Ben Aharon. All rights reserved.
//

#import "FactTileView.h"
#import "general.h"

@implementation FactTileView


-(void)awakeFromNib
{
    [super awakeFromNib];
    
    UITapGestureRecognizer* gs = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(OnTapGesture)];
    
    [self.textView addGestureRecognizer:gs];
}

-(void)layoutSubviews
{
    [self.headerLabel setFont:[UIFont fontWithName:self.headerLabel.font.fontName size:[UIScreen mainScreen].bounds.size.height/38]];
}
-(void)OnTapGesture
{
    [self.delegate FactWasTapped];
}


@end
