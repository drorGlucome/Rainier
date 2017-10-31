//
//  contactTableViewCell.h
//  GlucoMe - Mobile
//
//  Created by dovi winberger on 08/03/2016.
//  Copyright © 2016 Yiftah Ben Aharon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Alert_helper.h"
@protocol ContactTableViewCellDelegateProtocol <NSObject>

-(void)AddAlertToContact:(NSString*)contactName;

@end
@interface ContactTableViewCell : UITableViewCell
{
    NSString* contactName;
}
@property (weak, nonatomic) id<ContactTableViewCellDelegateProtocol> delegate;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

-(void)SetDataFromContactName:(NSString*)contactName;

@end
