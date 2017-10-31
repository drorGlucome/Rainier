//
//  Fact.h
//  
//
//  Created by dovi winberger on 5/20/15.
//
//
//this class is the local DB facts table
#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Fact : NSManagedObject

@property (nonatomic, retain) NSString * data;
@property (nonatomic, retain) NSDate * date;

@end
