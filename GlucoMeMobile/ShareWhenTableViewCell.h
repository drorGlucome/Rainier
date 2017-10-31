//
//  ShareWhenTableViewCell.h
//  GlucoMe - Mobile
//
//  Created by dovi winberger on 08/03/2016.
//  Copyright © 2016 Yiftah Ben Aharon. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ShareWhenTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *whenLabel;
@property (weak, nonatomic) IBOutlet UIImageView *isOnCheckMarkImageView;

- (void)SetSelected:(BOOL)selected;
@end
