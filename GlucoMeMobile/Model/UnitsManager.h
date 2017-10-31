//
//  Units_helper.h
//  GlucoMe - Mobile
//
//  Created by dovi winberger on 8/10/15.
//  Copyright (c) 2015 Yiftah Ben Aharon. All rights reserved.
//
//this class is the units manager

#import <Foundation/Foundation.h>

typedef enum Unit {mgdl, mmolL} Unit;


@interface UnitsManager : NSObject
{
    NSDictionary* map;
}

+(UnitsManager*)getInstance;

-(Unit)GetGlucoseUnits;
-(NSString*)GetGlucoseUnitsLocalizedString;
-(NSString*)GetGlucoseStringValueForCurrentUnit:(int)glucose;
-(NSNumber*)GetGlucoseValueForCurrentUnit:(int)glucose;
-(void)ChangeUnitsTo_mgdl;
-(void)ChangeUnitsTo_mmolL;
@end
