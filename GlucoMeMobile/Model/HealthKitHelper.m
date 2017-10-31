//
//  HealthKitHelper.m
//  GlucoMe - Mobile
//
//  Created by Yiftah Ben Aharon on 10/28/14.
//  Copyright (c) 2014 Yiftah Ben Aharon. All rights reserved.
//

#import "HealthKitHelper.h"




@implementation HealthKitHelper

- (instancetype)init
{
    self = [super init];
    if (self) {
        if (![HKHealthStore isHealthDataAvailable]) {
            return self;
        }
        self.healthStore = [[HKHealthStore alloc] init];
            NSSet *writeDataTypes = [self dataTypesToWrite];
            NSSet *readDataTypes = [self dataTypesToRead];
            
            [self.healthStore requestAuthorizationToShareTypes:writeDataTypes readTypes:readDataTypes completion:^(BOOL success, NSError *error) {
                if (!success) {
                    NSLog(@"You didn't allow HealthKit to access these read/write data types. In your app, try to handle this error gracefully when a user decides not to provide access. The error was: %@. If you're using a simulator, try it on a device.", error);
                    
                    return;
                }
            }];
    }
    return self;
}

- (void)saveGlucoseIntoHealthStore:(double)quantity {
    if (![HKHealthStore isHealthDataAvailable]) {
        return;
    }
    
    
    // Save the user's height into HealthKit.
    HKUnit *mgPerdL = [HKUnit unitFromString:@"mg/dL"];
    HKQuantity *glucoseQuantity = [HKQuantity quantityWithUnit:mgPerdL doubleValue:quantity];
    HKQuantityType *bloodGlucoseType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierBloodGlucose];
    NSDate *now = [NSDate date];
    HKQuantitySample *glucoseSample = [HKQuantitySample quantitySampleWithType:bloodGlucoseType quantity:glucoseQuantity startDate:now endDate:now metadata:nil];
    

    
    
    [self.healthStore saveObject:glucoseSample withCompletion:^(BOOL success, NSError *error) {
        if (!success) {
            NSLog(@"An error occured saving the height sample %@. In your app, try to handle this gracefully. The error was: %@.", glucoseSample, error);
        }
        
    }];
}

// Returns the types of data that Fit wishes to write to HealthKit.
- (NSSet *)dataTypesToWrite {
    HKQuantityType *bloodGlucoseType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierBloodGlucose];
    return [NSSet setWithObjects:bloodGlucoseType, nil];
}

// Returns the types of data that Fit wishes to read from HealthKit.
- (NSSet *)dataTypesToRead {
    HKQuantityType *bloodGlucoseType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierBloodGlucose];
    return [NSSet setWithObjects:bloodGlucoseType, nil];
}

@end
