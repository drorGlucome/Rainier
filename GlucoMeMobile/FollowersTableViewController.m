//
//  FriendsTableViewController.m
//  GlucoMe - Mobile
//
//  Created by dovi winberger on 7/22/15.
//  Copyright (c) 2015 Yiftah Ben Aharon. All rights reserved.
//

#import "FollowersTableViewController.h"
#import "GAI.h"
#import "GAIFields.h"
#import "GAIDictionaryBuilder.h"
#import "DataHandler_new.h"
#import "Friend_helper.h"
#import "FriendCell.h"
#import "general.h"

@interface FollowersTableViewController ()

@end

@implementation FollowersTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(DataChanged) name:@"FriendsChanged" object:nil];

}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    
    id tracker = [[GAI sharedInstance] defaultTracker];
    
    // This screen name value will remain set on the tracker and sent with
    // hits until it is set to a new value or to nil.
    [tracker set:kGAIScreenName value:@"FriendsPage"];
    
    // manual screen tracking
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
    
    self.title = @"Followers";
    
    [self DataChanged];
}

-(void)DataChanged
{
    NSPredicate* p = [NSPredicate predicateWithFormat:@"didFriendAddedMe == NO"];
    tableData = [Friend MR_findAllSortedBy:@"score" ascending:YES withPredicate:p inContext:[NSManagedObjectContext MR_defaultContext]];
    [self.tableView reloadData];
}

- (IBAction)onBackButtonClicked:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(IBAction)onAddButtonClick:(id)sender
{
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Add a follower" message:@"Please enter your friend's Email" delegate:self cancelButtonTitle:@"Continue" otherButtonTitles:@"Cancel", nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 0) //done
    {
        [self.view endEditing:YES];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            NSString* email = [[alertView textFieldAtIndex:0] text];
            if([email isEqualToString:@""]) return;
            
            [[DataHandler_new getInstance] FindFriendIdByEmail:email withCompletionBlock:^(NSDictionary *dic) {
                
                long friendId = [[dic valueForKey:@"id"] integerValue];
                [Friend SaveFriendAndSendToServer:friendId completionBlock:^(Friend *f)
                {
                    [f UpdateData:dic];
                    [self DataChanged];
                }];
            }];
        });
    }
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


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FriendCell *cell = (FriendCell*)[tableView dequeueReusableCellWithIdentifier:@"followerFriendCellID" forIndexPath:indexPath];
    
    Friend* f = [tableData objectAtIndex:indexPath.row];
    [cell SetFriend:f];
    cell.indexLabel.text = [NSString stringWithFormat:@"%ld.", (long)indexPath.row];
    
    return cell;
}

-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"People who can see my data";
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(editingStyle == UITableViewCellEditingStyleDelete)
    {
        [self DeleteFollower:indexPath];
    }
}

-(NSArray*)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewRowAction* delete = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:loc(@"Delete") handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
        [self DeleteFollower:indexPath];
    }];
    
    return @[delete];
}


-(void)DeleteFollower:(NSIndexPath*)indexPath
{
    Friend* f = [tableData objectAtIndex:indexPath.row];
    [f DeleteFriend];
}
/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/





@end
