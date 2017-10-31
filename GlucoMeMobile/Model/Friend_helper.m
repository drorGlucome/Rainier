//
//  Friend_helper.m
//  GlucoMe - Mobile
//
//  Created by dovi winberger on 7/26/15.
//  Copyright (c) 2015 Yiftah Ben Aharon. All rights reserved.
//

#import "Friend_helper.h"
#import "DataHandler_new.h"
#import "general.h"
@implementation Friend(helper)

+(void)MergeFriendsWithServer:(NSDictionary*)dic
{

    //friends i added
    NSPredicate* p = [NSPredicate predicateWithFormat:@"didUploadToServer == YES && didFriendAddedMe == NO"];
    [Friend MR_deleteAllMatchingPredicate:p inContext:[NSManagedObjectContext MR_defaultContext]];

    NSArray* friends = [dic objectForKey:@"friends"];
    for(NSDictionary* mDic in friends)
    {
        
        Friend* f = [Friend MR_createEntityInContext:[NSManagedObjectContext MR_defaultContext]];
        f.recordId = [mDic objectForKey:@"id"];
        f.friendId = @([[mDic objectForKey:@"allowed_patient_id"] integerValue]);
        f.didUploadToServer = @(YES);
        f.didFriendAddedMe = @(NO);
        
        if([mDic objectForKey:@"first"] != [NSNull null])
            f.firstName = [mDic objectForKey:@"first"];
        if([mDic objectForKey:@"last"] != [NSNull null])
            f.lastName = [mDic objectForKey:@"last"];
        if([mDic objectForKey:@"email"] != [NSNull null])
            f.email = [mDic objectForKey:@"email"];
        
        f.score = @([[mDic objectForKey:@"score"] doubleValue]);
        
        [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreWithCompletion:nil];
        
    }
    
    //friends who added me
    p = [NSPredicate predicateWithFormat:@"didFriendAddedMe == YES"];
    [Friend MR_deleteAllMatchingPredicate:p inContext:[NSManagedObjectContext MR_defaultContext]];
    
    NSArray* allowed_friends = [dic objectForKey:@"allowed_friends"];
    for(NSDictionary* mDic in allowed_friends)
    {
        Friend* f = [Friend MR_createEntityInContext:[NSManagedObjectContext MR_defaultContext]];
        f.recordId = [mDic objectForKey:@"id"];
        f.friendId = @([[mDic objectForKey:@"patient_id"] integerValue]);
        f.didUploadToServer = @(YES);
        f.didFriendAddedMe = @(YES); // i am the follower
        
        if([mDic objectForKey:@"first"] != [NSNull null])
            f.firstName = [mDic objectForKey:@"first"];
        if([mDic objectForKey:@"last"] != [NSNull null])
            f.lastName = [mDic objectForKey:@"last"];
        if([mDic objectForKey:@"email"] != [NSNull null])
            f.email = [mDic objectForKey:@"email"];
        
        f.isFiltered = @([[mDic objectForKey:@"is_filtered"] boolValue]);
        f.score = @([[mDic objectForKey:@"score"] doubleValue]);
        
        [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreWithCompletion:nil];
        
        
    }
    
    p = [NSPredicate predicateWithFormat:@"friendId = 0"];
    [Friend MR_deleteAllMatchingPredicate:p inContext:[NSManagedObjectContext MR_defaultContext]];
    
    //uploading friends that are local
    p = [NSPredicate predicateWithFormat:@"didUploadToServer = false OR didUploadToServer = nil"];
    NSArray* localFriends = [Friend MR_findAllWithPredicate:p inContext:[NSManagedObjectContext MR_defaultContext]];
    
    for(Friend* f in localFriends)
    {
        [[DataHandler_new getInstance] sendFriendToServer:f withCompletionBlock:^(NSDictionary *dic) {
            f.didUploadToServer = @(YES);
            f.recordId = [dic objectForKey:@"id"];
            [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreWithCompletion:nil];
        }];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"FriendsChanged" object:nil];
}


+(void)SaveFriendAndSendToServer:(long)friendId completionBlock:(void (^)(Friend*))completionBlock
{
    Friend* f = [Friend MR_createEntityInContext:[NSManagedObjectContext MR_defaultContext]];
    f.friendId = @(friendId);
    f.didUploadToServer = @(NO);
    f.didFriendAddedMe = @(NO);
    f.score = @(0);
    
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreWithCompletion:^(BOOL contextDidSave, NSError *error)
     {
         if(completionBlock) completionBlock(f);
         
         [[DataHandler_new getInstance] sendFriendToServer:f withCompletionBlock:^(NSDictionary *dic) {
             f.didUploadToServer = @(YES);
             f.recordId = [dic objectForKey:@"id"];
             [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreWithCompletion:nil];
             
         }];
         
         if(contextDidSave == NO)
         {
             NSLog(@"WHHYYY");
         }
     }];
    
}


-(void)UpdateData:(NSDictionary*) dic
{
    if([dic valueForKey:@"first"] != [NSNull null] && ![[dic valueForKey:@"first"] isEqualToString:@""])
        self.firstName = [dic valueForKey:@"first"];
   
    if([dic valueForKey:@"last"] != [NSNull null] && ![[dic valueForKey:@"last"] isEqualToString:@""])
        self.lastName = [dic valueForKey:@" last"];

    if([dic valueForKey:@"email"] != [NSNull null] && ![[dic valueForKey:@"email"] isEqualToString:@""])
        self.email = [dic valueForKey:@"email"];
    
    if([dic valueForKey:@"score"] != [NSNull null])
        self.score = [dic valueForKey:@"score"];
    
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreWithCompletion:nil];

}

-(void)DeleteFriend
{
    if(self.didUploadToServer)
    {
        [[DataHandler_new getInstance] DeleteFriend:[self.recordId longValue]];
    }
    
    [self MR_deleteEntityInContext:[NSManagedObjectContext MR_defaultContext]];
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreWithCompletion:^(BOOL contextDidSave, NSError *error) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"FriendsChanged" object:nil];
    }];
}

-(void)FilterFriend:(BOOL)isFiltered
{
    if(self.didUploadToServer)
    {
        [[DataHandler_new getInstance] FilterFriend:[self.recordId longValue] isFiltered:isFiltered];
    }
    
    self.isFiltered = @(isFiltered);
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreWithCompletion:^(BOOL contextDidSave, NSError *error) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"FriendsChanged" object:nil];
    }];
}

-(NSString*)DisplayName
{
    if (self.firstName == NULL || [self.firstName isEqualToString:@""])
    {
        return self.email;
    }
    else
    {
        if (self.lastName != NULL)
        {
            return [NSString stringWithFormat:@"%@ %@",self.firstName, self.lastName];
        }
        return self.firstName;
    }
}

+(NSArray*)GetFriendsWhomIFollow:(BOOL)isFiltered
{
    NSString* isFilteredString = @"YES";
    if(isFiltered == NO)
        isFilteredString = @"NO";
    NSPredicate* p = [NSPredicate predicateWithFormat:@"didFriendAddedMe == YES AND isFiltered == %d", isFiltered];
    return [Friend MR_findAllSortedBy:@"score" ascending:NO withPredicate:p inContext:[NSManagedObjectContext MR_defaultContext]];
}

+(int)GetSocialPosition
{
    //friends are sorted by score
    NSArray* friends = [Friend GetFriendsWhomIFollow:NO];
    //finding my position:
    NSNumber* myScore = [[NSUserDefaults standardUserDefaults] valueForKey:profile_score];
    int position = 1;
    for (Friend* f in friends) {
        if([f.score doubleValue] > [myScore doubleValue])
            position++;
        else
            break;
    }
    return position;
}
@end
