//
//  ParingManager.h
//  GlucoMe - Mobile
//
//  Created by dovi winberger on 8/16/15.
//  Copyright (c) 2015 Yiftah Ben Aharon. All rights reserved.
//
//this class is the BGM pairing manager

#import <Foundation/Foundation.h>

@interface PairingManager : NSObject

+(void)ClearAllPairedDevices;


+(NSMutableArray*)getCandidatesDevices;
+(void)AddUidToCandidates:(NSNumber*)uid_number;


+(NSArray*) getPairedDevices;
+(void) addPairedDevice:(int)uid;


@end
