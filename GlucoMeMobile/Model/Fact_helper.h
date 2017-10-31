//
//  Fact_helper.h
//  GlucoMe - Mobile
//
//  Created by dovi winberger on 5/20/15.
//  Copyright (c) 2015 Yiftah Ben Aharon. All rights reserved.
//
//this class is the local DB facts table
#import <Foundation/Foundation.h>
#import "Fact.h"
@interface Fact(helper)


+(void)MergeFactsWithServer:(NSDictionary*)dic;

@end
