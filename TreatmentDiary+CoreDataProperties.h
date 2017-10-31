//
//  TreatmentDiary+CoreDataProperties.h
//  GlucoMe - Mobile
//
//  Created by dovi winberger on 21/06/2016.
//  Copyright © 2016 Yiftah Ben Aharon. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//
//this class is the local DB treatment diary table
#import "TreatmentDiary.h"

NS_ASSUME_NONNULL_BEGIN

@interface TreatmentDiary (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *name;
@property (nullable, nonatomic, retain) NSNumber *id;
@property (nullable, nonatomic, retain) NSNumber *treatmentTypeId;
@property (nullable, nonatomic, retain) NSNumber *dosage;
@property (nullable, nonatomic, retain) NSDate *dueDate;
@property (nullable, nonatomic, retain) NSNumber *isDueDateEstimated;
@property (nullable, nonatomic, retain) NSNumber *sampleId;
@property (nullable, nonatomic, retain) NSDate *markedDate;
@property (nonatomic, retain) NSNumber * didUploadToServer;
@property (nonatomic, retain) NSNumber * recordId;

@end

NS_ASSUME_NONNULL_END
