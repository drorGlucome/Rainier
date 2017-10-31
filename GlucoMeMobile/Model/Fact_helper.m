//
//  Fact_helper.m
//  GlucoMe - Mobile
//
//  Created by dovi winberger on 5/20/15.
//  Copyright (c) 2015 Yiftah Ben Aharon. All rights reserved.
//

#import "Fact_helper.h"

@implementation Fact(helper)


+(void)MergeFactsWithServer:(NSDictionary*)dic
{
    NSString* newFact = [dic objectForKey:@"fact"];
    Fact* f = [Fact MR_createEntityInContext:[NSManagedObjectContext MR_defaultContext]];
    f.data = newFact;
    f.date = [NSDate date];
    
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreWithCompletion:nil];
    
}
@end
