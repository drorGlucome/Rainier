//
//  FullTableViewControllerNew.m
//  GlucoMe - Mobile
//
//  Created by dovi winberger on 5/5/15.
//  Copyright (c) 2015 Yiftah Ben Aharon. All rights reserved.
//

#import "FullTableViewControllerNew.h"
#import "general.h"

@implementation FullTableViewControllerNew
@synthesize h1Button, h2Button, h3Button;


-(void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.backButton setTitle:loc(@"Back") forState:UIControlStateNormal];
    [self.actionButton setTitle:loc(@"Add") forState:UIControlStateNormal];
    if ([UIApplication sharedApplication].userInterfaceLayoutDirection == UIUserInterfaceLayoutDirectionRightToLeft) {
        [self.actionButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
        [self.backButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
    }
    

    self.actionButton.hidden = YES;
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    //[self updateHeader:h1Button];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView
estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 55;
}

- (CGFloat)tableView:(UITableView *)tableView
heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 55;
}


- (IBAction)onActionButtonClicked:(id)sender {
}

- (IBAction)onBackButtonClicked:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)h1Click
{
}
- (IBAction)h2Click
{
}
- (IBAction)h3Click
{
}



@end
