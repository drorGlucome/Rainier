//
//  InfoViewController.m
//  GlucoMe - Mobile
//
//  Created by Yiftah Ben Aharon on 7/1/14.
//  Copyright (c) 2014 Yiftah Ben Aharon. All rights reserved.
//

#import "InfoViewController.h"
#import "general.h"

@interface InfoViewController ()

@end

@implementation InfoViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    

     
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSString * appVersionString = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    self.versionLabel.text = appVersionString;
    [self.versionLabel setTextAlignment:NSTextAlignmentLeft];
    self.sdkVersionLabel.text = [[NSUserDefaults standardUserDefaults] objectForKey:SDKVersionKey];
    [self.sdkVersionLabel setTextAlignment:NSTextAlignmentLeft];
    // Do any additional setup after loading the view.
    
    UITapGestureRecognizer* gs = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(TapGetureRecognizerAction)];
    gs.numberOfTapsRequired = 5;
    gs.numberOfTouchesRequired = 2;
    [self.view addGestureRecognizer:gs];
    
    
    [self.closeButton setTitle:loc(@"Close") forState:UIControlStateNormal];
    if ([UIApplication sharedApplication].userInterfaceLayoutDirection == UIUserInterfaceLayoutDirectionRightToLeft) {
        [self.closeButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
    }
    
    self.appVersionLabel.text = loc(@"Application_version");
    [self.appVersionLabel setTextAlignment:NSTextAlignmentNatural];
    self.SDKVersionLabel.text = loc(@"SDK_version");
    [self.SDKVersionLabel setTextAlignment:NSTextAlignmentNatural];
    self.privacyStatementLabel.text = loc(@"privacy_statement");
    [self.privacyStatementLabel setTextAlignment:NSTextAlignmentNatural];
    self.eulaLabel.text = loc(@"end_user_license_agreement");
    [self.eulaLabel setTextAlignment:NSTextAlignmentNatural];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.screenName = @"InfoViewController";
    
    
}

-(void)TapGetureRecognizerAction
{
    [self performSegueWithIdentifier:@"hiddenFeaturesSegue" sender:nil];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)dismiss:(id)sender {
    [self dismissViewControllerAnimated:YES  completion:nil];
}
@end
