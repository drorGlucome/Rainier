//
//  FoodActivityView.h
//  GlucoMe - Mobile
//
//  Created by dovi winberger on 28/12/2015.
//  Copyright © 2015 Yiftah Ben Aharon. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol MedicineDialogDelegateProtocol <NSObject>

-(void)MedicineAmountSelected:(int)amount tagId:(NSString*)tagId;

@end

@interface MedicineDialog : UIView
{
    int specificMedicineAmount;
    NSString* specificMedicineTagId;
}

@property(nonatomic, weak) id<MedicineDialogDelegateProtocol> delegate;

@property (weak, nonatomic) IBOutlet UITextField *amountTextField;
@property (weak, nonatomic) IBOutlet UIButton *SpecificMedicineButton;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *orLabel;
@property (weak, nonatomic) IBOutlet UILabel *enterSpecificLabel;

-(void)SetSpecificMedicine:(int)amount tagId:(NSString*)tagId name:(NSString*)name;
-(int)GetValue;
-(void)SetValue:(NSString*)value;
@end
