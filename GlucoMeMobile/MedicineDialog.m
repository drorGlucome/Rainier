//
//  FoodActivityView.m
//  GlucoMe - Mobile
//
//  Created by dovi winberger on 28/12/2015.
//  Copyright © 2015 Yiftah Ben Aharon. All rights reserved.
//

#import "MedicineDialog.h"
#import "UIImage+FontAwesome.h"
#import "UIButton+VerticalLayout.h"
#import "NSString+FontAwesome.h"
@implementation MedicineDialog

-(void)awakeFromNib
{
    [super awakeFromNib];
    
    self.titleLabel.text = loc(@"Manual_input");
    self.orLabel.text = loc(@"");
    self.enterSpecificLabel.text = [NSString stringWithFormat:@"%@ [%@]",loc(@"Enter_medicine_amount"), loc(@"Units")];
}

-(void)SetSpecificMedicine:(int)amount tagId:(NSString*)tagId name:(NSString*)name
{
    specificMedicineAmount = amount;
    specificMedicineTagId = tagId;
    
    [self.SpecificMedicineButton setTitle:[NSString stringWithFormat:@"%@: %d [%@]",name, amount, loc(@"Units")] forState:UIControlStateNormal];
}

- (IBAction)SpecificMedicineButtonClicked:(id)sender
{
    if (self.delegate != nil)
        [self.delegate MedicineAmountSelected:specificMedicineAmount tagId:specificMedicineTagId];
}

-(int)GetValue
{
    return [self.amountTextField.text doubleValue];
}
-(void)SetValue:(NSString*)value
{
    self.amountTextField.text = value;
}
@end
