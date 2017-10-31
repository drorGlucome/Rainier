//
//  TreatmentDiaryTableViewController.m
//  GlucoMe - Mobile
//
//  Created by dovi winberger on 26/06/2016.
//  Copyright © 2016 Yiftah Ben Aharon. All rights reserved.
//

#import "TreatmentDiaryTableViewController.h"
#import "general.h"
#import "SingleTreatmentDiaryCell.h"
#import "Treatmentdiary.h"
@interface TreatmentDiaryTableViewController ()

@end

@implementation TreatmentDiaryTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.tabBarController.title = loc(@"Treatment_diary");
    
    [self UpdateData];
        
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(UpdateData) name:@"TreatmentDiaryChanged" object:nil];
}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)UpdateData
{
    NSPredicate* p =  [NSPredicate predicateWithFormat:@"dueDate <= %@", [NSDate date]];
    pastEvents = [TreatmentDiary MR_findAllSortedBy:@"dueDate" ascending:NO withPredicate:p inContext:[NSManagedObjectContext MR_defaultContext]];
    
    p =  [NSPredicate predicateWithFormat:@"dueDate > %@ && dueDate <= %@", [NSDate date], [[[NSDate date] dateByAddingDays:1] dateAtEndOfDay]];
    futureEvents = [TreatmentDiary MR_findAllSortedBy:@"dueDate" ascending:YES withPredicate:p inContext:[NSManagedObjectContext MR_defaultContext]];
    
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section == 0)
        return futureEvents.count;
    return pastEvents.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SingleTreatmentDiaryCell *cell = [tableView dequeueReusableCellWithIdentifier:@"treatmentDiaryCell" forIndexPath:indexPath];
    if(cell == nil)
    {
        cell = [[SingleTreatmentDiaryCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"treatmentDiaryCell"];
    }
    
    TreatmentDiary *t;
    if(indexPath.section == 0)
        t = futureEvents[indexPath.row];
    else
        t = pastEvents[indexPath.row];
    
    [cell SetData:t];
    
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if(section == 0)
        return @"Next events";
    else
        return @"Previous events";
}

@end
