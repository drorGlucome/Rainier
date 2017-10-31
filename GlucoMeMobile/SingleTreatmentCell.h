//
//  SingleTreatmentCell.h
//  GlucoMe - Mobile
//
//  Created by dovi winberger on 25/01/2016.
//  Copyright © 2016 Yiftah Ben Aharon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Treatment.h"

@interface SingleTreatmentCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *dosageLabel;
@property (weak, nonatomic) IBOutlet UILabel *summaryLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

-(void)SetWithTreatment:(Treatment*)t;
@end
