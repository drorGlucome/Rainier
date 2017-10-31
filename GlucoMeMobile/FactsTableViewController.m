//
//  FactsTableViewController.m
//  GlucoMe - Mobile
//
//  Created by dovi winberger on 5/28/15.
//  Copyright (c) 2015 Yiftah Ben Aharon. All rights reserved.
//

#import "FactsTableViewController.h"
#import "Fact.h"
#import "FactViewCell.h"
#import "general.h"
@interface FactsTableViewController ()

@end

@implementation FactsTableViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.navigationItem.title = loc(@"Facts");
    [self.closeButton setTitle:loc(@"Close") forState:UIControlStateNormal];
    if ([UIApplication sharedApplication].userInterfaceLayoutDirection == UIUserInterfaceLayoutDirectionRightToLeft) {
        [self.closeButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
    }
    tableData = [Fact MR_findAllSortedBy:@"date" ascending:NO inContext:[NSManagedObjectContext MR_defaultContext]];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return tableData.count;
}

-(CGFloat)heightForRow:(NSInteger)i
{
    Fact* f = [tableData objectAtIndex:i];
    
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue" size:16.0f]};
    
    
    CGRect rect = [f.data boundingRectWithSize:CGSizeMake(self.tableView.frame.size.width, MAXFLOAT)
                                       options:NSStringDrawingUsesLineFragmentOrigin
                                    attributes:attributes
                                       context:nil];
    // Values are fractional -- you should take the ceilf to get equivalent values
    CGSize adjustedSize = CGSizeMake(ceilf(rect.size.width), ceilf(rect.size.height));
    
    return adjustedSize.height+20;
}
-(CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self heightForRow:indexPath.row];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self heightForRow:indexPath.row];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier = @"FactCellID";
    
    FactViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[FactViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    Fact* f = [tableData objectAtIndex:indexPath.row];
    cell.textView.text = f.data;
    
    return cell;
}






- (IBAction)Close:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
