//
//  FriendCell.m
//  GlucoMe - Mobile
//
//  Created by dovi winberger on 7/27/15.
//  Copyright (c) 2015 Yiftah Ben Aharon. All rights reserved.
//

#import "FriendCell.h"
#import "Friend_helper.h"

@implementation FriendCell

-(void)SetFriend:(Friend*)f
{
    self.nameLabel.text = [f DisplayName];
    self.scoreLabel.text = [NSString stringWithFormat:@"%.0f",[f.score doubleValue]];
    
}
@end
