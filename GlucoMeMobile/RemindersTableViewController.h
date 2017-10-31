//
//  RemindersTableViewController.h
//  GlucoMe - Mobile
//
//  Created by dovi winberger on 5/5/15.
//  Copyright (c) 2015 Yiftah Ben Aharon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FullTableViewControllerNew.h"
#import <EventKit/EventKit.h>


@interface RemindersTableViewController : FullTableViewControllerNew
{
    NSMutableArray *tableData;
}
@property (retain, nonatomic) EKEventStore *store;

-(void)fetchRemindersWithCompletionBlock:(void (^)(NSArray*))completionBlock;
@end
