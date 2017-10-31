//
//  MediaType.h
//  
//
//  Created by dovi winberger on 5/20/15.
//
//
//this class is the local DB media type table (sms / phone / email)

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface MediaType : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * id;

@end
