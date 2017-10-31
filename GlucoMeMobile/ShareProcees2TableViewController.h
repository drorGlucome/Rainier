//
//  ShareProcees2TableTableViewController.h
//  GlucoMe - Mobile
//
//  Created by dovi winberger on 08/03/2016.
//  Copyright © 2016 Yiftah Ben Aharon. All rights reserved.
//
// second stage of sharing: choose what to share

#import <UIKit/UIKit.h>
#import "MediaType_helper.h"

@protocol ShareProcees2DelegateProtocol <NSObject>
-(NSString*)ContactDetails;
-(NSString*)ContactName;
-(MediaTypesEnum)mediaType;
-(NSString*)Relationship;

@end


@interface ShareProcees2TableViewController : UITableViewController
{
    MediaTypesEnum selectedMediaType;
}
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UIButton *saveButton;

@property (nonatomic, weak) id<ShareProcees2DelegateProtocol> delegate;


@end
