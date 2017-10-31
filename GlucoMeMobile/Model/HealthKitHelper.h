//
//  HealthKitHelper.h
//  GlucoMe - Mobile
//
//  Created by Yiftah Ben Aharon on 10/28/14.
//  Copyright (c) 2014 Yiftah Ben Aharon. All rights reserved.
//

#import <Foundation/Foundation.h>
@import HealthKit;

@interface HealthKitHelper : NSObject

@property (nonatomic) HKHealthStore *healthStore;

- (void)saveGlucoseIntoHealthStore:(double)quantity;

@end
