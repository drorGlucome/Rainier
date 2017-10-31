//
//  ParingManager.m
//  GlucoMe - Mobile
//
//  Created by dovi winberger on 8/16/15.
//  Copyright (c) 2015 Yiftah Ben Aharon. All rights reserved.
//

#import "PairingManager.h"
#import "general.h"
@implementation PairingManager



+(NSMutableArray*)getCandidatesDevices
{
    static NSMutableArray* candidatesDevices = nil;
    
    if(candidatesDevices == nil) candidatesDevices = [[NSMutableArray alloc] init];
    return candidatesDevices;
}

+(void)AddUidToCandidates:(NSNumber*)uid_number
{
    [[self getCandidatesDevices] addObject:uid_number];
}

+(void)ClearAllPairedDevices
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray* devices = [[NSMutableArray alloc] init];
    
    [defaults setObject:devices forKey:profile_uidArray];
    [defaults synchronize];
}

+ (NSArray*) getPairedDevices
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:profile_uidArray];
}

+ (void) addPairedDevice:(int)uid
{
    NSNumber* uid_number = [NSNumber numberWithInt:uid];
    if([[self getCandidatesDevices] containsObject:uid_number]) [[self getCandidatesDevices] removeObject:uid_number];

    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray* devices = [[defaults arrayForKey:profile_uidArray] mutableCopy];
    if(devices == nil) {
        devices = [[NSMutableArray alloc] init];
    }
    NSNumber* number_uid = [NSNumber numberWithInt:uid];
    if(![devices containsObject:number_uid])
        [devices addObject:number_uid];
    [defaults setObject:devices forKey:profile_uidArray];
    [defaults synchronize];
}

@end
