//
//  Utilities.m
//  GlucoMe - Mobile
//
//  Created by dovi winberger on 17/05/2016.
//  Copyright © 2016 Yiftah Ben Aharon. All rights reserved.
//

#import "Utilities.h"
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>

@implementation Utilities

+(NSString*)GetCountryCode
{
    NSString* countryCode = @"";
    @try {
        CTTelephonyNetworkInfo *info = [CTTelephonyNetworkInfo new];
        
        CTCarrier *carrier = info.subscriberCellularProvider;
        countryCode = [carrier isoCountryCode];
    } @catch (NSException *exception) {
        
    } @finally {
        
    }
    if(countryCode == nil || [countryCode isEqualToString:@""])
    {
        countryCode = [[NSLocale currentLocale] objectForKey:NSLocaleCountryCode];
    }
       
    return countryCode;
}
@end
