//
//  TreatmentsTableViewController.m
//  GlucoMe - Mobile
//
//  Created by dovi winberger on 25/01/2016.
//  Copyright © 2016 Yiftah Ben Aharon. All rights reserved.
//

#import "TreatmentsTableViewController.h"
#import "Treatment_helper.h"
#import "SingleTreatmentCell.h"
#import "general.h"
@interface TreatmentsTableViewController ()

@end

@implementation TreatmentsTableViewController

NSArray* allTreatmets;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    allTreatmets = [Treatment AllTreatmentsGrouped];
    
    [self.backButton setTitle:loc(@"Close") forState:UIControlStateNormal];
    if ([UIApplication sharedApplication].userInterfaceLayoutDirection == UIUserInterfaceLayoutDirectionRightToLeft) {
        [self.backButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
    }
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.tabBarController.title = loc(@"Treatment_plan");
    self.navigationItem.title = loc(@"Treatment_plan");
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    //return allTreatmets.count;
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(allTreatmets == nil || allTreatmets.count == 0) return 0;
    return ((NSArray*)allTreatmets[section]).count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SingleTreatmentCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TreatmentCellID" forIndexPath:indexPath];
    if(cell == nil)
    {
        cell = [[SingleTreatmentCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"TreatmentCellID"];
    }
    [cell SetWithTreatment:[[allTreatmets objectAtIndex:indexPath.section] objectAtIndex:indexPath.row]];
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 44;
}
-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView* header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, [self tableView:tableView heightForHeaderInSection:section])];
    header.backgroundColor = [UIColor whiteColor];
    UILabel* title = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 40)];
    
    if(allTreatmets == nil || allTreatmets.count == 0)
    {
        title.text = loc(@"No_treatment_available");
        
        [title setTextAlignment:NSTextAlignmentNatural];
        
        [header addSubview:title];
        
        return header;
        
    }
    
    NSString* date = rails2iosDateFromDate(((Treatment*)[[allTreatmets objectAtIndex:section] objectAtIndex:0]).dateGiven);
    NSString* time = rails2iosTimeFromDate(((Treatment*)[[allTreatmets objectAtIndex:section] objectAtIndex:0]).dateGiven);
    title.text = [NSString stringWithFormat:@"%@ %@ %@", loc(@"Given_at"), date, time];
    
    [title setTextAlignment:NSTextAlignmentNatural];
    
    [header addSubview:title];
    
    return header;
}

- (IBAction)backButtonClicked:(id)sender {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

@end
