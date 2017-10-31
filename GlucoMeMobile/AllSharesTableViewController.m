//
//  AllSharesTableViewController.m
//  GlucoMe - Mobile
//
//  Created by dovi winberger on 08/03/2016.
//  Copyright © 2016 Yiftah Ben Aharon. All rights reserved.
//

#import "AllSharesTableViewController.h"
#import "Alert_helper.h"
#import "ContactTableViewCell.h"
#import "AlertTableViewCell.h"
#import "general.h"
#import "ShareProcess1ViewController.h"
@interface AllSharesTableViewController () <ContactTableViewCellDelegateProtocol>
@property NSArray* contacts;
@end

@implementation AllSharesTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    self.tableView.backgroundView = [[UIImageView alloc] initWithImage:
                                     [UIImage imageNamed:@"bg35"]];

}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self RefreshData];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(RefreshData) name:@"DataChanged" object:nil];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)RefreshData
{
    self.contacts = [Alert Contacts];
    [self.tableView reloadData];
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.contacts.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [Alert AlertsForContact:[self.contacts objectAtIndex:section]].count+1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if(indexPath.row == 0)
    {
        ContactTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"contactCellID" forIndexPath:indexPath];
        [cell SetDataFromContactName:[self.contacts objectAtIndex:indexPath.section]];
        cell.delegate = self;
        return cell;
    }
    else
    {
        AlertTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"alertCellID" forIndexPath:indexPath];
        [cell SetData:((Alert*)[[Alert AlertsForContact:[self.contacts objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row-1])];
        return cell;
    }
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row == 0)
        return 44;
    else
        return 60;
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row == 0)return NO;
    return YES;
}
-(NSArray*)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row == 0) return @[];
    
    UITableViewRowAction* delete = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:loc(@"Delete") handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
        [self DeleteAlert:indexPath];
    }];
    
    return @[delete];
}

-(void)DeleteAlert:(NSIndexPath*)indexPath
{
    Alert* a = ((Alert*)[[Alert AlertsForContact:[self.contacts objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row-1]);
    
    [a DeleteAlert];
}


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"shareSegue"])
    {
        UINavigationController* nav = segue.destinationViewController;
        ShareProcess1ViewController* vc = (ShareProcess1ViewController*)[nav topViewController];
        [vc SetContactName:[self ContactName]];
        [vc SetRelationship:[self Relationship]];
        [vc SetMediaType:[self mediaType]];
        [vc SetContactDetails:[self ContactDetails]];
    }
}
-(NSString*)ContactDetails
{
    NSArray* alerts = [Alert AlertsForContact:[self.contacts objectAtIndex:selectedContactIndex]];
    if(alerts.count > 0) return ((Alert*)alerts[0]).contactDetails;
    return @"";
}
-(NSString*)ContactName
{
    NSArray* alerts = [Alert AlertsForContact:[self.contacts objectAtIndex:selectedContactIndex]];
    if(alerts.count > 0) return ((Alert*)alerts[0]).contactName;
    return @"";
}
-(MediaTypesEnum)mediaType
{
    NSArray* alerts = [Alert AlertsForContact:[self.contacts objectAtIndex:selectedContactIndex]];
    if(alerts.count > 0) return [MediaType MediaTypeEnumForMediaTypeID:[((Alert*)alerts[0]).how_mediaTypeID intValue]];
    return SMS;
}
-(NSString*)Relationship
{
    NSArray* alerts = [Alert AlertsForContact:[self.contacts objectAtIndex:selectedContactIndex]];
    if(alerts.count > 0 && ((Alert*)alerts[0]).relationship != nil)
        return ((Alert*)alerts[0]).relationship;
    return @"";
}
-(BOOL)shouldPopInsteadOfDismiss
{
    return YES;
}
-(void)AddAlertToContact:(NSString*)contactName
{
    selectedContactIndex =  (int)[self.contacts indexOfObject:contactName];
    [self performSegueWithIdentifier:@"shareSegue" sender:self];
}
@end
