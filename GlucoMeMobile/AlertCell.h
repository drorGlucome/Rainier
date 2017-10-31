//
//  AlertCell.h
//  GlucoMe - Mobile
//
//  Created by dovi winberger on 5/6/15.
//  Copyright (c) 2015 Yiftah Ben Aharon. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AlertCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *howLabel;
@property (weak, nonatomic) IBOutlet UILabel *whenLabel;
@property (weak, nonatomic) IBOutlet UILabel *whoLabel;


- (void)setRowData:(NSString*)how :(NSString*)when :(NSString*)who;

@end
