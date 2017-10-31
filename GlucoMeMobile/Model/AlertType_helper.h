//
//  AlertType_herlper.h
//  GlucoMe - Mobile
//
//  Created by dovi winberger on 5/20/15.
//  Copyright (c) 2015 Yiftah Ben Aharon. All rights reserved.
//
//this class is the local DB alerts types table (after test/ after hypo/ no measurements etc.)

#import <Foundation/Foundation.h>
#import "AlertType.h"

@interface AlertType(herlper)

+(void)MergeAlertTypesWithServer:(NSDictionary*)dic;

+(NSArray*)AllAlertTypesSorted;
-(NSArray*)WhenArray;
-(NSString*)WhenAsString:(NSString*)when;
-(NSString*)WhatAsString:(NSString*)what;

@end
