//
//  MediaType_helper.m
//  GlucoMe - Mobile
//
//  Created by dovi winberger on 5/20/15.
//  Copyright (c) 2015 Yiftah Ben Aharon. All rights reserved.
//

#import "MediaType_helper.h"

@implementation MediaType(helper)


+(void)MergeMediaTypesWithServer:(NSDictionary*)dic
{
    [MediaType MR_truncateAllInContext:[NSManagedObjectContext MR_defaultContext]];
    
    NSArray* mediaType = [dic objectForKey:@"media_types"];
    for(NSDictionary* mDic in mediaType)
    {
        MediaType* m = [MediaType MR_createEntityInContext:[NSManagedObjectContext MR_defaultContext]];
        m.name  = [mDic objectForKey:@"name"];
        m.id    = [mDic objectForKey:@"id"];
        
        [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreWithCompletion:nil];
    }
}
+(MediaTypesEnum)MediaTypeEnumForMediaTypeID:(int)mediaTypeId
{
    MediaType* m = [MediaType MR_findFirstByAttribute:@"id" withValue:@(mediaTypeId) inContext:[NSManagedObjectContext MR_defaultContext]];
    return [MediaType  MediaTypeEnumForMediaType:m];
}
+(MediaTypesEnum)MediaTypeEnumForMediaType:(MediaType*)m
{
    if ([[m.name lowercaseString] containsString:@"sms"] || [[m.name lowercaseString] containsString:@"text"])
    {
        return SMS;
    }
    if ([[m.name lowercaseString] containsString:@"email"])
    {
        return Email;
    }
    if ([[m.name lowercaseString] containsString:@"phone"])
    {
        return Phone;
    }
    
    
    return SMS;
}
+(MediaType*)MediaTypeForEnum:(MediaTypesEnum)mediaTypesEnum
{
    NSArray* all = [MediaType MR_findAllInContext:[NSManagedObjectContext MR_defaultContext]];
    MediaType* result = nil;

    for (int i = 0; i < all.count; i++) {
        MediaType* m = [all objectAtIndex:i];
        if (mediaTypesEnum == SMS && ([[m.name lowercaseString] containsString:@"sms"] || [[m.name lowercaseString] containsString:@"text"]))
        {
            return m;
        }
        if (mediaTypesEnum == Email && ([[m.name lowercaseString] containsString:@"email"]))
        {
            return m;
        }
        if (mediaTypesEnum == Phone && ([[m.name lowercaseString] containsString:@"phone"]))
        {
            return m;
        }
    }
    
    return result;
}
@end
