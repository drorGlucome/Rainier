//
//  Units_helper.m
//  GlucoMe - Mobile
//
//  Created by dovi winberger on 8/10/15.
//  Copyright (c) 2015 Yiftah Ben Aharon. All rights reserved.
//

#import "UnitsManager.h"
#import "Utilities.h"
#import "general.h"
@implementation UnitsManager



+(UnitsManager*)getInstance
{
    static UnitsManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[UnitsManager alloc] init];
        // Do any other initialisation stuff here
        
        
        //based on here: http://www.diabetesexplained.com/country-units.html
        sharedInstance->map = @{
                              @"DZ"	:	@"mg/dL",
                              @"AR"	:	@"mg/dL",
                              @"AW"	:	@"mg/dL",
                              @"AU"	:	@"mmol/L",
                              @"AT"	:	@"mg/dL",
                              @"BH"	:	@"mmol/L",
                              @"BS"	:	@"mg/dL",
                              @"BD"	:	@"mg/dL",
                              @"BB"	:	@"mg/dL",
                              @"BY"	:	@"mmol/L",
                              @"BE"	:	@"mg/dL",
                              @"BA"	:  	@"mmol/L",
                              @"BR"	:	@"mg/dL",
                              @"BG"	:	@"mmol/L",
                              @"CA"	:	@"mmol/L",
                              @"KY"	: 	@"mg/dL",
                              @"CL"	:	@"mg/dL",
                              @"CN"	:	@"mmol/L",
                              @"CO"	:	@"mg/dL",
                              @"CW"	:	@"mg/dL",
                              @"HR"	:	@"mmol/L",
                              @"CY"	:	@"mg/dL",
                              @"CZ"	: 	@"mmol/L",
                              @"DK"	:	@"mmol/L",
                              @"CD"	: 	@"mg/dL",
                              @"EC"	:	@"mg/dL",
                              @"EG"	:	@"mg/dL",
                              @"SV"	:	@"mg/dL",
                              @"EE"	:	@"mmol/L",
                              @"FI"	:	@"mmol/L",
                              @"FR"	:	@"mg/dL",
                              @"GE"	:	@"mg/dL",
                              @"DE"	:	@"mg/dL,mmol/L",
                              @"GR"	:	@"mg/dL",
                              @"GT"	:	@"mg/dL",
                              @"HN"	:	@"mg/dL",
                              @"HK"	:	@"mmol/L",
                              @"HU"	:	@"mmol/L",
                              @"IS"	:	@"mmol/L",
                              @"IN"	:	@"mg/dL",
                              @"ID"	:	@"mg/dL",
                              @"IE"	:	@"mmol/L",
                              @"IL"	:	@"mg/dL",
                              @"IT"	:	@"mg/dL",
                              @"CI"	: 	@"mg/dL",
                              @"JM"	:	@"mg/dL",
                              @"JP"	:	@"mg/dL",
                              @"JO"	:	@"mg/dL",
                              @"KZ"	:	@"mmol/L",
                              @"KR"	:	@"mg/dL",
                              @"KW"	:	@"mmol/L",
                              @"LV"	:	@"mmol/L",
                              @"LB"	:	@"mg/dL",
                              @"LT"	:	@"mmol/L",
                              @"LU"	:	@"mmol/L",
                              @"MK"	:	@"mmol/L",
                              @"MT"	:	@"mmol/L",
                              @"MY"	:	@"mmol/L",
                              @"MX"	:	@"mg/dL",
                              @"ME"	:	@"mmol/L",
                              @"MA"	:	@"mg/dL",
                              @"NL"	:	@"mmol/L",
                              @"NZ"	: 	@"mmol/L",
                              @"NO"	:	@"mmol/L",
                              @"OM"	:	@"mmol/L",
                              @"PK"	:	@"mg/dL",
                              @"PE"	:	@"mg/dL",
                              @"PH"	:	@"mg/dL,mmol/L",
                              @"PL"	:	@"mg/dL",
                              @"PT"	:	@"mg/dL",
                              @"PR"	: 	@"mg/dL",
                              @"QA"	:	@"mg/dL",
                              @"RO"	:	@"mg/dL",
                              @"RU"	:	@"mmol/L",
                              @"SA"	: 	@"mg/dL,mmol/L",
                              @"RS"	:	@"mmol/L",
                              @"SG"	:	@"mg/dL,mmol/L",
                              @"SK"	:	@"mmol/L",
                              @"SI"	:	@"mmol/L",
                              @"KR"	: 	@"mg/dL",
                              @"ZA"	: 	@"mmol/L",
                              @"ES"	:	@"mg/dL",
                              @"MF"	:	@"mg/dL",
                              @"SE"	:	@"mmol/L",
                              @"CH"	:	@"mmol/L",
                              @"SY"	:	@"mg/dL",
                              @"TW"	:	@"mg/dL",
                              @"TH"	:	@"mg/dL",
                              @"TT"	:  	@"mg/dL",
                              @"TN"	:	@"mg/dL",
                              @"TR"	:	@"mg/dL",
                              @"AE"	:   @"mg/dL",
                              @"GB"	:	@"mmol/L",
                              @"UA"	:	@"mg/dL,mmol/L",
                              @"UY"	:	@"mg/dL",
                              @"US"	:	@"mg/dL",
                              @"VE"	:	@"mg/dL",
                              @"VN"	:	@"mg/dL",
                              @"YE"	:	@"mg/dL"
                              };
    });
    return sharedInstance;
}


-(Unit)GetGlucoseUnits
{
    if ([[NSUserDefaults standardUserDefaults] stringForKey:profile_glucose_units] != nil)
    {
        NSString* unitString = [[NSUserDefaults standardUserDefaults] stringForKey:profile_glucose_units];
        if([unitString rangeOfString:@"mg/dL"].location != NSNotFound)
            return mgdl;
        else
            return mmolL;
    }
    
    NSString* countryCode = [Utilities GetCountryCode];
    
    NSString* unitString = [map valueForKey:countryCode];
    
    if(unitString != nil)
    {
        if([unitString rangeOfString:@"mg/dL"].location != NSNotFound)
            [self ChangeUnitsTo_mgdl];
        else
            [self ChangeUnitsTo_mmolL];
    }
    else
        [self ChangeUnitsTo_mgdl];
    
    return [self GetGlucoseUnits];
}

-(NSString*)GetGlucoseUnitsLocalizedString
{
    if([self GetGlucoseUnits] == mgdl)
        return loc(@"mg/dL");
    else
        return loc(@"mmol/L");
}

-(NSString*)GetGlucoseStringValueForCurrentUnit:(int)glucose
{
    NSString* result = [NSString stringWithFormat:@"%d",glucose];
    if([self GetGlucoseUnits] == mgdl)
        result = [NSString stringWithFormat:@"%d",glucose];
    else
        result = [NSString stringWithFormat:@"%.1f",glucose/18.0];
    
    return result;
}

-(NSNumber*)GetGlucoseValueForCurrentUnit:(int)glucose
{
    if([self GetGlucoseUnits] == mgdl)
        return @(glucose);
    else
        return @(glucose/18.0);
}

-(void)ChangeUnitsTo_mgdl
{
    [[NSUserDefaults standardUserDefaults] setObject:@"mg/dL" forKey:profile_glucose_units];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ProfileChanged" object:nil];
}

-(void)ChangeUnitsTo_mmolL
{
    [[NSUserDefaults standardUserDefaults] setObject:@"mmol/L" forKey:profile_glucose_units];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ProfileChanged" object:nil];
}

@end
