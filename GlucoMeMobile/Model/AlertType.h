//
//  AlertType.h
//  
//
//  Created by dovi winberger on 5/20/15.
//
//
//this class is the local DB alerts types table (after test/ after hypo/ no measurements etc.)

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface AlertType : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSString * when_array;
@property (nonatomic, retain) NSNumber * order;
@property (nonatomic, retain) NSNumber * is_on_by_default;
@end
