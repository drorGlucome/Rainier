//
//  NSString+helpers.m
//  GlucoMe - Mobile
//
//  Created by dovi winberger on 05/06/2017.
//  Copyright © 2017 Yiftah Ben Aharon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSString+helpers.h"

@implementation NSString(helpers)
-(NSTextAlignment)DetectTextAlignment
{
        if (self.length) {
            
            NSArray *rightLeftLanguages = @[@"ar",@"he"];
            
            NSString *lang = CFBridgingRelease(CFStringTokenizerCopyBestStringLanguage((CFStringRef)self,CFRangeMake(0,[self length])));
            
            if ([rightLeftLanguages containsObject:lang]) {
                
                return NSTextAlignmentRight;
                
            }
        }
        
        return NSTextAlignmentLeft;
}

@end
