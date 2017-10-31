//
//  ShareProcees2TableTableViewController.m
//  GlucoMe - Mobile
//
//  Created by dovi winberger on 08/03/2016.
//  Copyright © 2016 Yiftah Ben Aharon. All rights reserved.
//

#import "ShareProcees2TableViewController.h"
#import "AlertType_helper.h"
#import "ShareWhatTableViewCell.h"
#import "ShareWhenTableViewCell.h"
#import "Alert_helper.h"

@interface ShareProcees2TableViewController ()<ShareWhatDelegateProtocol>
@property (nonatomic) NSArray* alertTypes;
@property (nonatomic) NSMutableArray* when_selectedIndex;
@property (nonatomic) NSMutableArray* alert_isOn;

@end

@implementation ShareProcees2TableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.alertTypes = [AlertType AllAlertTypesSorted];
    self.when_selectedIndex  = [NSMutableArray arrayWithCapacity:self.alertTypes.count];
    self.alert_isOn          = [NSMutableArray arrayWithCapacity:self.alertTypes.count];
    
    NSArray* contacts = [Alert Contacts];
    for(int i = 0; i < self.alertTypes.count; i++)
    {
        self.when_selectedIndex[i] = @(0);
        if(contacts.count == 0)
            self.alert_isOn[i] = @([((AlertType*)self.alertTypes[i]).is_on_by_default boolValue]);
        else
            self.alert_isOn[i] = @(NO);
    }
    self.tableView.backgroundView = [[UIImageView alloc] initWithImage:
                                     [UIImage imageNamed:@"bg35"]];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    selectedMediaType = [self.delegate mediaType];
    
    self.navigationItem.title = [self.delegate ContactName];
    
    [self.backButton setTitle:loc(@"Back") forState:UIControlStateNormal];
    [self.saveButton setTitle:loc(@"Save") forState:UIControlStateNormal];
    if ([UIApplication sharedApplication].userInterfaceLayoutDirection == UIUserInterfaceLayoutDirectionRightToLeft) {
        [self.backButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
    }
    if ([UIApplication sharedApplication].userInterfaceLayoutDirection == UIUserInterfaceLayoutDirectionRightToLeft) {
        [self.saveButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return self.alertTypes.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    AlertType* a = [self.alertTypes objectAtIndex:section];
    return [a WhenArray].count+1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    AlertType* a = [self.alertTypes objectAtIndex:indexPath.section];
    if(indexPath.row == 0)
    {
        ShareWhatTableViewCell* cell = (ShareWhatTableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"ShareWhatCellID" forIndexPath:indexPath];
        
        cell.titleLabel.text = [a WhatAsString:a.name];
        
        [cell SetMediaType:selectedMediaType];
        [cell.isOnSwitch setOn:[self.alert_isOn[indexPath.section] boolValue]];
        cell.delegate = self;
        cell.cellID = @(indexPath.section);
        return cell;
    }
    
    long whenIndex = indexPath.row-1;
    ShareWhenTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ShareWhenCellID" forIndexPath:indexPath];
    cell.whenLabel.text = [a WhenAsString:[[a WhenArray] objectAtIndex:whenIndex]];
    [cell SetSelected:[self.when_selectedIndex[indexPath.section] integerValue] == whenIndex];
    return cell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row == 0) return;
    
    self.when_selectedIndex[indexPath.section] = @(indexPath.row-1);
    [tableView reloadData];
}

-(void)selectionChanged:(BOOL)isSelected forCellID:(int)cellID
{
    self.alert_isOn[cellID] = @(isSelected);
    [self.tableView reloadData];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)BackButtonClicked:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)SaveAlert:(id)sender
{
    MediaType* m = [MediaType MediaTypeForEnum:selectedMediaType];
    
    for(int i = 0; i < self.alertTypes.count; i++)
    {
        if([self.alert_isOn[i] boolValue] == YES)
        {
            AlertType* a = self.alertTypes[i];
            
            [Alert SaveAlertAndSendToServerWithContactName:[self.delegate ContactName]
                                            contactDetails:[self.delegate ContactDetails]
                                                   trigger:[a.id intValue]
                                                    params:[[a WhenArray] objectAtIndex:[self.when_selectedIndex[i] integerValue]]
                                                       how:[m.id intValue]
                                              relationship:[self.delegate Relationship]
                                           completionBlock:^(Alert *a)
             {
                 [[NSNotificationCenter defaultCenter] postNotificationName:@"DataChanged" object:nil];
             }];
        }
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
