//
//  MediaType_helper.h
//  GlucoMe - Mobile
//
//  Created by dovi winberger on 5/20/15.
//  Copyright (c) 2015 Yiftah Ben Aharon. All rights reserved.
//
//this class is the local DB media type table (sms / phone / email)
#import <Foundation/Foundation.h>
#import "MediaType.h"
@interface MediaType(helper)


typedef enum MediaTypesEnum {SMS, Email, Phone} MediaTypesEnum;


+(MediaType*)MediaTypeForEnum:(MediaTypesEnum)mediaTypesEnum;
+(MediaTypesEnum)MediaTypeEnumForMediaType:(MediaType*)m;
+(MediaTypesEnum)MediaTypeEnumForMediaTypeID:(int)mediaTypeId;

+(void)MergeMediaTypesWithServer:(NSDictionary*)dic;
@end
