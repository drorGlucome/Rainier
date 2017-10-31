//
//  Tag_helper.h
//  GlucoMe - Mobile
//
//  Created by dovi winberger on 5/31/15.
//  Copyright (c) 2015 Yiftah Ben Aharon. All rights reserved.
//
//this class is the local DB tags table

#import <Foundation/Foundation.h>
#import "Tag.h"

@interface Tag(helper)

+(void)InitTags;
+(Tag*)GetTagForId:(NSNumber*)tagId;
@end
