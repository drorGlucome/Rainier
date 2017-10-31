//
//  Friend_helper.h
//  GlucoMe - Mobile
//
//  Created by dovi winberger on 7/26/15.
//  Copyright (c) 2015 Yiftah Ben Aharon. All rights reserved.
//
//this class is the local DB friends table

#import <Foundation/Foundation.h>
#import "Friend.h"
@interface Friend(helper)
+(void)MergeFriendsWithServer:(NSDictionary*)dic;
+(void)SaveFriendAndSendToServer:(long)friendId completionBlock:(void (^)(Friend*))completionBlock;
-(void)UpdateData:(NSDictionary*) dic;
-(void)DeleteFriend;
-(void)FilterFriend:(BOOL)isFiltered;


-(NSString*)DisplayName;
+(NSArray*)GetFriendsWhomIFollow:(BOOL)isFiltered;
+(int)GetSocialPosition;

@end
