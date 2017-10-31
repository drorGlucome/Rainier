//
//  Tag_helper.m
//  GlucoMe - Mobile
//
//  Created by dovi winberger on 5/31/15.
//  Copyright (c) 2015 Yiftah Ben Aharon. All rights reserved.
//

#import "Tag_helper.h"
#import "general.h"
@implementation Tag(helper)

+(void)InitTags
{
    [Tag MR_truncateAllInContext:[NSManagedObjectContext MR_defaultContext]];
    
    Tag* t = [Tag MR_createEntityInContext:[NSManagedObjectContext MR_defaultContext]];
    t.id = @(0);
    t.name = @"Before_breakfast";
    t.icon = @"beforeBreakfast";
    t.didUploadToServer = @(NO);
    t.deletable = @(NO);
    
    
    t = [Tag MR_createEntityInContext:[NSManagedObjectContext MR_defaultContext]];
    t.id = @(1);
    t.name = @"After_breakfast";
    t.icon = @"afterBreakfast";
    t.didUploadToServer = @(NO);
    t.deletable = @(NO);
    
    
    
    t = [Tag MR_createEntityInContext:[NSManagedObjectContext MR_defaultContext]];
    t.id = @(2);
    t.name = @"Before_lunch";
    t.icon = @"beforeLunch";
    t.didUploadToServer = @(NO);
    t.deletable = @(NO);
    
    
    
    t = [Tag MR_createEntityInContext:[NSManagedObjectContext MR_defaultContext]];
    t.id = @(3);
    t.name = @"After_lunch";
    t.icon = @"afterLunch";
    t.didUploadToServer = @(NO);
    t.deletable = @(NO);
    
    
    
    t = [Tag MR_createEntityInContext:[NSManagedObjectContext MR_defaultContext]];
    t.id = @(4);
    t.name = @"Before_dinner";
    t.icon = @"beforeDinner";
    t.didUploadToServer = @(NO);
    t.deletable = @(NO);
    

    
    t = [Tag MR_createEntityInContext:[NSManagedObjectContext MR_defaultContext]];
    t.id = @(5);
    t.name = @"After_dinner";
    t.icon = @"afterDinner";
    t.didUploadToServer = @(NO);
    t.deletable = @(NO);
    
    
    
    t = [Tag MR_createEntityInContext:[NSManagedObjectContext MR_defaultContext]];
    t.id = @(6);
    t.name = @"Before_snack";
    t.icon = @"beforeSnack";
    t.didUploadToServer = @(NO);
    t.deletable = @(NO);
    
    
    
    t = [Tag MR_createEntityInContext:[NSManagedObjectContext MR_defaultContext]];
    t.id = @(7);
    t.name = @"After_snack";
    t.icon = @"afterSnack";
    t.didUploadToServer = @(NO);
    t.deletable = @(NO);
    
    
    
    t = [Tag MR_createEntityInContext:[NSManagedObjectContext MR_defaultContext]];
    t.id = @(8);
    t.name = @"Bedtime";
    t.icon = @"bedtime";
    t.didUploadToServer = @(NO);
    t.deletable = @(NO);
    
    
    
    t = [Tag MR_createEntityInContext:[NSManagedObjectContext MR_defaultContext]];
    t.id = @(9);
    t.name = @"Midnight";
    t.icon = @"midnight";
    t.didUploadToServer = @(NO);
    t.deletable = @(NO);
    
    
    //****************************************************
    //****************************************************
    //medicine
    
    t = [Tag MR_createEntityInContext:[NSManagedObjectContext MR_defaultContext]];
    t.id = @(BASAL_TAG_ID);
    t.name = @"Basal";
    t.icon = @"basal";
    t.didUploadToServer = @(NO);
    t.deletable = @(NO);
    
    t = [Tag MR_createEntityInContext:[NSManagedObjectContext MR_defaultContext]];
    t.id = @(BOLUS_MORNING_TAG_ID);
    t.name = @"Bolus_Morning";
    t.icon = @"bolusMorning";
    t.didUploadToServer = @(NO);
    t.deletable = @(NO);
    
    t = [Tag MR_createEntityInContext:[NSManagedObjectContext MR_defaultContext]];
    t.id = @(BOLUS_NOON_TAG_ID);
    t.name = @"Bolus_Noon";
    t.icon = @"bolusNoon";
    t.didUploadToServer = @(NO);
    t.deletable = @(NO);
    
    t = [Tag MR_createEntityInContext:[NSManagedObjectContext MR_defaultContext]];
    t.id = @(BOLUS_EVENING_TAG_ID);
    t.name = @"Bolus_Evening";
    t.icon = @"bolusNight";
    t.didUploadToServer = @(NO);
    t.deletable = @(NO);
    
    t = [Tag MR_createEntityInContext:[NSManagedObjectContext MR_defaultContext]];
    t.id = @(PILLS_TAG_ID);
    t.name = @"Pills";
    t.icon = @"pills";
    t.didUploadToServer = @(NO);
    t.deletable = @(NO);
    
    t = [Tag MR_createEntityInContext:[NSManagedObjectContext MR_defaultContext]];
    t.id = @(OPEN_BOLUS_TAG_ID);
    t.name = @"Bolus_correction";
    t.icon = @"bolusCorrection";
    t.didUploadToServer = @(NO);
    t.deletable = @(NO);
    
    //****************************************************
    //****************************************************
    //food
    
    t = [Tag MR_createEntityInContext:[NSManagedObjectContext MR_defaultContext]];
    t.id = @(100);
    t.name = @"Breakfast";
    t.icon = @"beforeBreakfast";
    t.didUploadToServer = @(NO);
    t.deletable = @(NO);
    
    t = [Tag MR_createEntityInContext:[NSManagedObjectContext MR_defaultContext]];
    t.id = @(101);
    t.name = @"Lunch";
    t.icon = @"beforeLunch";
    t.didUploadToServer = @(NO);
    t.deletable = @(NO);
    
    t = [Tag MR_createEntityInContext:[NSManagedObjectContext MR_defaultContext]];
    t.id = @(102);
    t.name = @"Dinner";
    t.icon = @"beforeDinner";
    t.didUploadToServer = @(NO);
    t.deletable = @(NO);
    
    t = [Tag MR_createEntityInContext:[NSManagedObjectContext MR_defaultContext]];
    t.id = @(103);
    t.name = @"Night";
    t.icon = @"midnight";
    t.didUploadToServer = @(NO);
    t.deletable = @(NO);
    
    t = [Tag MR_createEntityInContext:[NSManagedObjectContext MR_defaultContext]];
    t.id = @(104);
    t.name = @"Snack";
    t.icon = @"beforeSnack";
    t.didUploadToServer = @(NO);
    t.deletable = @(NO);
    
    
    //****************************************************
    //****************************************************
    //activity
    
    
    t = [Tag MR_createEntityInContext:[NSManagedObjectContext MR_defaultContext]];
    t.id = @(150);
    t.name = @"Before_breakfast";
    t.icon = @"beforeBreakfast";
    t.didUploadToServer = @(NO);
    t.deletable = @(NO);
    
    
    t = [Tag MR_createEntityInContext:[NSManagedObjectContext MR_defaultContext]];
    t.id = @(151);
    t.name = @"After_breakfast";
    t.icon = @"afterBreakfast";
    t.didUploadToServer = @(NO);
    t.deletable = @(NO);
    
    
    
    t = [Tag MR_createEntityInContext:[NSManagedObjectContext MR_defaultContext]];
    t.id = @(152);
    t.name = @"Before_lunch";
    t.icon = @"beforeLunch";
    t.didUploadToServer = @(NO);
    t.deletable = @(NO);
    
    
    
    t = [Tag MR_createEntityInContext:[NSManagedObjectContext MR_defaultContext]];
    t.id = @(153);
    t.name = @"After_lunch";
    t.icon = @"afterLunch";
    t.didUploadToServer = @(NO);
    t.deletable = @(NO);
    
    
    
    t = [Tag MR_createEntityInContext:[NSManagedObjectContext MR_defaultContext]];
    t.id = @(154);
    t.name = @"Before_dinner";
    t.icon = @"beforeDinner";
    t.didUploadToServer = @(NO);
    t.deletable = @(NO);
    
    
    
    t = [Tag MR_createEntityInContext:[NSManagedObjectContext MR_defaultContext]];
    t.id = @(155);
    t.name = @"After_dinner";
    t.icon = @"afterDinner";
    t.didUploadToServer = @(NO);
    t.deletable = @(NO);
    
    
    
    t = [Tag MR_createEntityInContext:[NSManagedObjectContext MR_defaultContext]];
    t.id = @(156);
    t.name = @"Before_snack";
    t.icon = @"beforeSnack";
    t.didUploadToServer = @(NO);
    t.deletable = @(NO);
    
    
    
    t = [Tag MR_createEntityInContext:[NSManagedObjectContext MR_defaultContext]];
    t.id = @(157);
    t.name = @"After_snack";
    t.icon = @"afterSnack";
    t.didUploadToServer = @(NO);
    t.deletable = @(NO);
    
    
    
    t = [Tag MR_createEntityInContext:[NSManagedObjectContext MR_defaultContext]];
    t.id = @(158);
    t.name = @"Bedtime";
    t.icon = @"bedtime";
    t.didUploadToServer = @(NO);
    t.deletable = @(NO);
    
    
    
    t = [Tag MR_createEntityInContext:[NSManagedObjectContext MR_defaultContext]];
    t.id = @(159);
    t.name = @"Midnight";
    t.icon = @"midnight";
    t.didUploadToServer = @(NO);
    t.deletable = @(NO);
    
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreWithCompletion:nil];
}

+(Tag*)GetTagForId:(NSNumber*)tagId
{
    if(tagId == nil)
    {
        return nil;
    }
    
    NSPredicate* p = [NSPredicate predicateWithFormat:@"id = %@", tagId];
    NSArray* tags = [Tag MR_findAllWithPredicate:p inContext:[NSManagedObjectContext MR_defaultContext]];
    if(tags.count == 0) return nil;
    Tag* tag = tags[0];
    return tag;
}

@end
