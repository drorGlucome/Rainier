//
//  AlertTableViewCell.h
//  GlucoMe - Mobile
//
//  Created by dovi winberger on 08/03/2016.
//  Copyright © 2016 Yiftah Ben Aharon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Alert.h"
@interface AlertTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *whatLabel;
@property (weak, nonatomic) IBOutlet UILabel *whenLabel;
@property (weak, nonatomic) IBOutlet UIImageView *howImageView;

-(void)SetData:(Alert*)alert;
@end
