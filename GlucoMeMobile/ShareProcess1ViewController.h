//
//  ShareProcess1ViewController.h
//  GlucoMe - Mobile
//
//  Created by dovi winberger on 08/03/2016.
//  Copyright © 2016 Yiftah Ben Aharon. All rights reserved.
//
// first stage of sharing: choose how and contant

#import <UIKit/UIKit.h>
#import "MediaType_helper.h"

@interface ShareProcess1ViewController : UIViewController
{
    NSString* initialContactName;
    NSString* initialContactDetails;
    NSString* initialRelationship;
    MediaTypesEnum initialMediaType;
    
    MediaTypesEnum selectedMediaType;
}
@property (weak, nonatomic) IBOutlet UIButton *shareWithSmsButton;
@property (weak, nonatomic) IBOutlet UIButton *shareWithEmailButton;
@property (weak, nonatomic) IBOutlet UIButton *shareWithPhoneButton;
@property (weak, nonatomic) IBOutlet UITextField *contactNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *contactDetailsTextField;
@property (weak, nonatomic) IBOutlet UILabel *relationshipLabel;
@property (weak, nonatomic) IBOutlet UIButton *continueButton;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UIButton *chooseContact;

@property (weak, nonatomic) IBOutlet UILabel *howToShareLabel;
@property (weak, nonatomic) IBOutlet UILabel *shareWithWhomLabel;
@property (weak, nonatomic) IBOutlet UILabel *chooseRelationshipLabel;

-(void)SetContactDetails:(NSString*)contactDetails;
-(void)SetContactName:(NSString*)contactName;
-(void)SetMediaType:(MediaTypesEnum)mediaType;
-(void)SetRelationship:(NSString*)relationship;
@end
