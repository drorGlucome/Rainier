//
//  AlertsTableViewController.m
//  GlucoMe - Mobile
//
//  Created by dovi winberger on 5/6/15.
//  Copyright (c) 2015 Yiftah Ben Aharon. All rights reserved.
//

#import "AlertsTableViewController.h"
#import "AddAlertViewController.h"
#import "AlertCell.h"
#import "general.h"
#import "Alert_helper.h"
#import "MediaType.h"
#import "AlertType.h"

@interface AlertsTableViewController ()

@end

@implementation AlertsTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationItem.title = loc(@"Data Sharing");
    [self.h1Button setTitle:loc(@"How") forState:UIControlStateNormal];
    [self.h2Button setTitle:loc(@"When") forState:UIControlStateNormal];
    [self.h3Button setTitle:loc(@"Who") forState:UIControlStateNormal];
    self.h1Button.enabled = NO;
    self.h2Button.enabled = NO;
    self.h3Button.enabled = NO;
    [self init_alerts_array];
    
    
    [self.actionButton setTitle:loc(@"Add") forState:UIControlStateNormal];
    self.actionButton.hidden = NO;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(DataChanged) name:@"DataChanged" object:nil];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    id tracker = [[GAI sharedInstance] defaultTracker];
    
    // This screen name value will remain set on the tracker and sent with
    // hits until it is set to a new value or to nil.
    [tracker set:kGAIScreenName value:@"AlertsPage"];
    
    // manual screen tracking
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
    
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (IBAction)onActionButtonClicked:(id)sender
{
    AddAlertViewController* vc = [[AddAlertViewController alloc] initWithNibName:loc(@"AddAlertViewController") bundle:nil];
    [self presentViewController:vc animated:YES completion:nil];
}

-(void)DataChanged
{
    [self init_alerts_array];
    [self.tableView reloadData];
}

- (void) init_alerts_array
{
    tableData = [Alert MR_findAllInContext:[NSManagedObjectContext MR_defaultContext]];
}


-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return tableData.count;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier = @"alertCellID";
    
    AlertCell *cell = (AlertCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = (AlertCell*)[[AlertCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    Alert* a = [tableData objectAtIndex:indexPath.row];
    MediaType* mt = nil;
    AlertType* at = nil;
    if([MediaType MR_findByAttribute:@"id" withValue:a.how_mediaTypeID inContext:[NSManagedObjectContext MR_defaultContext]].count > 0)
        mt = [[MediaType MR_findByAttribute:@"id" withValue:a.how_mediaTypeID inContext:[NSManagedObjectContext MR_defaultContext]] objectAtIndex:0];
    if([AlertType MR_findByAttribute:@"id" withValue:a.when_alertTypeID inContext:[NSManagedObjectContext MR_defaultContext]].count > 0)
        at = [[AlertType MR_findByAttribute:@"id" withValue:a.when_alertTypeID inContext:[NSManagedObjectContext MR_defaultContext]] objectAtIndex:0];
    
    /*NSString* name = at.name;
    NSString* media = mt.name;
    NSString* contact = a.who;
    
    [cell setRowData:media :name :contact];*/
    
    return cell;
}


-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(editingStyle == UITableViewCellEditingStyleDelete)
    {
        [self DeleteAlert:indexPath];
    }
}

-(NSArray*)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewRowAction* delete = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:loc(@"Delete") handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
        [self DeleteAlert:indexPath];
    }];
    
    return @[delete];
}

-(void)DeleteAlert:(NSIndexPath*)indexPath
{
    Alert* a = [tableData objectAtIndex:indexPath.row];

    [a DeleteAlert];

}
@end
