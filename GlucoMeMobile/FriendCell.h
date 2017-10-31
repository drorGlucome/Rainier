//
//  FriendCell.h
//  GlucoMe - Mobile
//
//  Created by dovi winberger on 7/27/15.
//  Copyright (c) 2015 Yiftah Ben Aharon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Friend.h"
@interface FriendCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *scoreLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *indexLabel;


-(void)SetFriend:(Friend*)f;

@end
