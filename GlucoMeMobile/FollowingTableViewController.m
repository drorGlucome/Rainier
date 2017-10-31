//
//  FriendsTableViewController.m
//  GlucoMe - Mobile
//
//  Created by dovi winberger on 7/22/15.
//  Copyright (c) 2015 Yiftah Ben Aharon. All rights reserved.
//

#import "FollowingTableViewController.h"
#import "GAI.h"
#import "GAIFields.h"
#import "GAIDictionaryBuilder.h"
#import "DataHandler_new.h"
#import "Friend_helper.h"
#import "FriendCell.h"
#import "general.h"

#import "SingleFriendViewController.h"

@interface FollowingTableViewController ()

@end

@implementation FollowingTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(DataChanged) name:@"FriendsChanged" object:nil];
    
    id tracker = [[GAI sharedInstance] defaultTracker];
    
    // This screen name value will remain set on the tracker and sent with
    // hits until it is set to a new value or to nil.
    [tracker set:kGAIScreenName value:@"FriendsPage"];
    
    // manual screen tracking
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
    
    
    self.title = @"Following";
    
    [self DataChanged];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)DataChanged
{
    tableData = [NSMutableArray arrayWithArray:[Friend GetFriendsWhomIFollow:NO]];

    //inserting myself
    int position = [Friend GetSocialPosition];//1 based
    Friend* f = [Friend MR_createEntity];
    f.firstName = @"Me";
    f.score = [[NSUserDefaults standardUserDefaults] valueForKey:profile_score];
    [tableData insertObject:f atIndex:position-1];//0 based
    selfRowIndex = position-1;
    
    tableDataFiltered = [Friend GetFriendsWhomIFollow:YES];
    
    [self.tableView reloadData];
}

- (IBAction)onBackButtonClicked:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}




#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if(section == 0)
        return tableData.count;
    else
        return tableDataFiltered.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FriendCell *cell = nil;
    if(indexPath.section == 0)
    {
        cell = (FriendCell*)[tableView dequeueReusableCellWithIdentifier:@"friendCellID" forIndexPath:indexPath];
        if(indexPath.row == selfRowIndex)
        {
            cell.userInteractionEnabled = NO;
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
    }
    else
        cell = (FriendCell*)[tableView dequeueReusableCellWithIdentifier:@"filteredFriendCellID" forIndexPath:indexPath];
 
    Friend* f = nil;
    if(indexPath.section == 0)
        f = [tableData objectAtIndex:indexPath.row];
    else
        f = [tableDataFiltered objectAtIndex:indexPath.row];
    
    [cell SetFriend:f];
    cell.indexLabel.text = [NSString stringWithFormat:@"%ld.", (long)indexPath.row];
    
    return cell;
}


-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return @"Friends";
    }
    else return @"Filtered";
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0 && indexPath.row == selfRowIndex)
        return NO;
    else
        return YES;
}
-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if(editingStyle == UITableViewCellEditingStyleDelete)
    {
        [self FilterFollowing:indexPath];
    }
}

-(NSArray*)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0 && indexPath.row == selfRowIndex)
        return @[];
    
    if(indexPath.section == 0)
    {
        UITableViewRowAction* filter = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:loc(@"Filter") handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
            [self FilterFollowing:indexPath];
        }];
        
        return @[filter];
    }
    else
    {
        UITableViewRowAction* unfilter = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:loc(@"Unfilter") handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
            [self FilterFollowing:indexPath];
        }];
        
        unfilter.backgroundColor = [UIColor colorWithRed:0.3 green:0.85 blue:0.4 alpha:1];
        
        return @[unfilter];
    }
}

-(void)FilterFollowing:(NSIndexPath*)indexPath
{
    if(indexPath.section == 0)
    {
        Friend* f = [tableData objectAtIndex:indexPath.row];
        [f FilterFriend:YES];
    }
    else
    {
        Friend* f = [tableDataFiltered objectAtIndex:indexPath.row];
        [f FilterFriend:NO];
    }
}

-(BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    if([identifier isEqualToString:@"singleFriendSegue"])
    {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        if(indexPath.row == selfRowIndex)
            return NO;
        else
            return YES;
        
    }
    else
        return YES;
}

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if([segue.identifier isEqualToString:@"singleFriendSegue"])
    {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        SingleFriendViewController* vc = (SingleFriendViewController*)segue.destinationViewController;
        vc.mFriend = [tableData objectAtIndex:indexPath.row];
    }
}

@end
