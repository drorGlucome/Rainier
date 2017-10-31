//
//  ShareWhatTableViewCell.h
//  GlucoMe - Mobile
//
//  Created by dovi winberger on 08/03/2016.
//  Copyright © 2016 Yiftah Ben Aharon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MediaType_helper.h"

@protocol ShareWhatDelegateProtocol <NSObject>

-(void)selectionChanged:(BOOL)isSelected forCellID:(int)cellID;

@end

@interface ShareWhatTableViewCell : UITableViewCell

@property (nonatomic) NSNumber* cellID;
@property (nonatomic, weak) id<ShareWhatDelegateProtocol> delegate;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (weak, nonatomic) IBOutlet UISwitch *isOnSwitch;

-(void)SetMediaType:(MediaTypesEnum)mediaType;
@end
