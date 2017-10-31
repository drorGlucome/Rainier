//
//  SingleTreatmentDiaryCell.h
//  GlucoMe - Mobile
//
//  Created by dovi winberger on 26/06/2016.
//  Copyright © 2016 Yiftah Ben Aharon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TreatmentDiary.h"

@interface SingleTreatmentDiaryCell : UITableViewCell
{
    TreatmentDiary* mTreatment;
}
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *detailsLabel;
@property (weak, nonatomic) IBOutlet UILabel *doneLabel;
@property (weak, nonatomic) IBOutlet UISwitch *doneSwitch;
-(void)SetData:(TreatmentDiary*)t;
@end
