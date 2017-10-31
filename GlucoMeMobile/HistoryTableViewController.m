//
//  HistoryTableViewController.m
//  GlucoMe - Mobile
//
//  Created by dovi winberger on 5/5/15.
//  Copyright (c) 2015 Yiftah Ben Aharon. All rights reserved.
//

#import "HistoryTableViewController.h"
#import "FullTableViewControllerNew.h"
#import "SingleMeasurementViewController.h"

#import "general.h"
#import "HistoryCell.h"
#import "FilterHistoryTableViewCell.h"
#import "ShowFiltersTableViewCell.h"

#import "Measurement.h"

#import <MessageUI/MessageUI.h>
@interface HistoryTableViewController() <HistoryCellDelegateProtocol, MFMailComposeViewControllerDelegate>
@end

@implementation HistoryTableViewController
@synthesize patient_id;

BOOL sortAsc = YES;
Measurement* selectedMeasurement;

-(void)viewDidLoad
{
    [super viewDidLoad];
   
    [self.actionButton setTitle:loc(@"Export") forState:UIControlStateNormal];
    self.actionButton.hidden = NO;
    
    [self.h1Button setTitle:loc(@"Date") forState:UIControlStateNormal];
    [self.h2Button setTitle:loc(@"Value") forState:UIControlStateNormal];
    [self.h3Button setTitle:loc(@"Tags") forState:UIControlStateNormal];
    
    self.navigationItem.title = loc(@"History");
    
    [self h1Click];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(DataChanged) name:@"DataChanged" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(DataChanged) name:@"FriendDataChanged" object:nil];
    
    
    
    NSString *CellIdentifier = @"FilterHistoryCellID";
    filterCell = (FilterHistoryTableViewCell*)[self.tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];    
    if (filterCell == nil) {
        filterCell = (FilterHistoryTableViewCell*)[[FilterHistoryTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    filterCell.HistoryTableVC = self;
    
    
    CellIdentifier = @"ShowFiltersCellID";
    showFiltersCell = (ShowFiltersTableViewCell*)[self.tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    if (showFiltersCell == nil) {
        showFiltersCell = (ShowFiltersTableViewCell*)[[ShowFiltersTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    showFiltersCell.HistoryTableVC = self;
    
    self.showFilters = NO;
    
    //self.tableView.tableHeaderView.frame = CGRectMake(0, 0, self.tableView.tableHeaderView.frame.size.width, 0);
    
}
-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    id tracker = [[GAI sharedInstance] defaultTracker];
    
    // This screen name value will remain set on the tracker and sent with
    // hits until it is set to a new value or to nil.
    [tracker set:kGAIScreenName value:@"HistoryPage"];
    
    // manual screen tracking
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
    
    if(filterCell == nil)
    {
        if(measurementTypesFilter == nil)
            measurementTypesFilter = @[@(0),@(1),@(2),@(3),@(4)];
        
        if(glucoseTypesFilter == nil)
            glucoseTypesFilter = @[@(0),@(1),@(2),@(3)];
        
        if(daysAgoFilter == nil)
            daysAgoFilter = @(10000);
        
        [self DataChanged];
        return;
    }
    
    if(daysAgoFilter == nil)
        [filterCell.timeSpanButtonsView SetSelectedDaysAgo:10000];
    else
        [filterCell.timeSpanButtonsView SetSelectedDaysAgo:daysAgoFilter.intValue];
    
    if(measurementTypesFilter == nil)
        [filterCell.measurementTypesTagsView ActivateAllTags];
    else
        [filterCell.measurementTypesTagsView SetActiveTags:[measurementTypesFilter valueForKey:@"stringValue"]];
    
    if(glucoseTypesFilter == nil)
        [filterCell.glucoseFilterTagsView ActivateAllTags];
    else
        [filterCell.glucoseFilterTagsView SetActiveTags:[glucoseTypesFilter valueForKey:@"stringValue"]];

}

-(void)DataChanged
{
    tableData = [Measurement GetAllMeasurementsFromDate:[[NSDate dateWithDaysBeforeNow:daysAgoFilter.intValue] dateAtStartOfDay] forPatient_id:patient_id];

    NSPredicate* p = [NSPredicate predicateWithBlock:^BOOL(Measurement* evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
            if([measurementTypesFilter containsObject:evaluatedObject.type] && evaluatedObject.type.intValue == 0)
            {
                if([glucoseTypesFilter containsObject:[NSNumber numberWithInt:glucoseToType(evaluatedObject.value.intValue, [evaluatedObject GetFirstTagID])]])
                    return YES;
                else
                    return NO;
            }
            else if([measurementTypesFilter containsObject:evaluatedObject.type])
                return YES;
            else
                return NO;
    }];
    //NSPredicate* typesPredicate = [NSPredicate predicateWithFormat:@"type in %@ AND (type = 0 AND glucoseToType([value intValue]) in %@)",measurementTypesFilter, glucoseTypesFilter];
    tableData = [tableData filteredArrayUsingPredicate:p];
    
    [self.tableView reloadData];
}
-(void)SetMeasurementTypesFilter:(NSArray*)measurementTypes
{
    measurementTypesFilter = [measurementTypes valueForKey:@"intValue"];
    if(measurementTypes.count == 0) measurementTypesFilter = nil;
   
    [self DataChanged];
}

-(void)SetGlucoseTypesFilter:(NSArray*)glucoseTypes
{
    glucoseTypesFilter = [glucoseTypes valueForKey:@"intValue"];
    if(glucoseTypes.count == 0) glucoseTypesFilter = nil;
    
    [self DataChanged];
}
-(void)SetDaysAgoFilter:(int)daysAgo
{
    daysAgoFilter = @(daysAgo);
    [self DataChanged];
}


-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
    //return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section == 0) return 1;
    return tableData.count;
}


-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0)
    {
        if(self.showFilters)
            return filterCell;
        else
            return showFiltersCell;
    }
    
    NSString *CellIdentifier = @"glucoseCellID";
    
    HistoryCell *cell = (HistoryCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    if (cell == nil) {
        cell = (HistoryCell*)[[HistoryCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    if(![patient_id isEqualToNumber:[[DataHandler_new getInstance] getPatientIdAsNumber]])
    {
        cell.disclosureIndicator.hidden = YES;
    }
    
    Measurement* m = (Measurement*)[tableData objectAtIndex:indexPath.row];
    [cell setRowDataWithMeasurement:m];

    cell.delegate = self;
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0)
        if(self.showFilters)
            return [filterCell Height];
        else
            return [showFiltersCell Height];
    else
        return [super tableView:tableView estimatedHeightForRowAtIndexPath:indexPath];
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0)
        if(self.showFilters)
            return [filterCell Height];
        else
            return [showFiltersCell Height];
    else
        return [super tableView:tableView heightForRowAtIndexPath:indexPath];
}


-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 1)
    {
        UIView* v = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 35)];
        self.tableHeaderView.frame = v.frame;
        [v addSubview:self.tableHeaderView];
        return v;
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 1)
    {
        return 35;
    }
    return 0;
}




-(void)ShowDetails:(Measurement*)m
{
    selectedMeasurement = m;
    if([self shouldPerformSegueWithIdentifier:@"singleMeasurementSegue" sender:self])
        [self performSegueWithIdentifier:@"singleMeasurementSegue" sender:self];
/*    SingleMeasurementViewController* vc = [[SingleMeasurementViewController alloc] initWithNibName:@"SingleMeasurementViewController" bundle:nil];
    [vc SetMeasurement:m];
    [self presentViewController:vc animated:YES completion:nil];
  */  
    
}

-(BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    if([identifier isEqualToString:@"singleMeasurementSegue"])
    {
        if(DLG.isConnectedVersion == NO || [patient_id isEqualToNumber:[[DataHandler_new getInstance] getPatientIdAsNumber]])
            return YES;
        else
            return NO;
    }
    return YES;
}
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"singleMeasurementSegue"])
    {
        SingleMeasurementViewController* vc = (SingleMeasurementViewController*)segue.destinationViewController;
        [vc SetMeasurement:selectedMeasurement];
    }
}

- (void) sort:(NSString*)field   {
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:field
                                                                   ascending:sortAsc] ;
    NSArray *res = [tableData sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    tableData = res;
    //tableData = [[tableData reverseObjectEnumerator] allObjects];

    [self.tableView reloadData];
}

- (void)h1Click
{
    [self updateHeader:self.h1Button];
    sortAsc = !sortAsc;
    [self sort:@"date"];
}

- (void)h2Click
{
    [self updateHeader:self.h2Button];
    sortAsc = !sortAsc;
    [self sort:@"value"];
}

- (void)h3Click
{
    [self updateHeader:self.h3Button];
    sortAsc = !sortAsc;
    [self sort:@"tags"];
}



- (void) updateHeader:(id)sender
{
    NSString* UP = @"\u25B2";
    NSString* DOWN = @"\u25BC";
    
    NSArray* buttons = [NSArray arrayWithObjects:self.h1Button, self.h2Button, self.h3Button, nil];
    
    UIButton* pressed = (UIButton*)sender;
    
    for(int i = 0; i < buttons.count; i++)
    {
        UIButton* b = [buttons objectAtIndex:i];
        NSString* currentLabel = b.titleLabel.text;
        NSString* lastChar = [currentLabel substringFromIndex:(currentLabel.length-1)];
        if([lastChar isEqualToString:UP] || [lastChar isEqualToString:DOWN]) {
            currentLabel = [currentLabel substringToIndex:currentLabel.length-1];
        }
        NSString *arrow = @"";
        NSString *backgroundImage = @"1_light.png";
        if(pressed == b) {
            arrow = (sortAsc) ? DOWN : UP;
            backgroundImage = @"1_dark.png";
        }
        
        [b setBackgroundImage:[UIImage imageNamed:backgroundImage] forState:UIControlStateNormal];
        NSString* newLabel = [[NSString alloc] initWithFormat:@"%@%@", loc(currentLabel), arrow ];
        [b setTitle:newLabel forState:UIControlStateNormal];
        
    }
    
}


- (IBAction)onActionButtonClicked:(id)sender
{
    if([MFMailComposeViewController canSendMail] == NO)
    {
        UIAlertController * alert=   [UIAlertController
                                      alertControllerWithTitle:@""
                                      message:loc(@"No_email_is_defined_or_there_is_a_problem_sending_emails")
                                      preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* ok = [UIAlertAction
                             actionWithTitle:loc(@"OK")
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action)
                             {
                                 [alert dismissViewControllerAnimated:YES completion:nil];
                             }];
        
        [alert addAction:ok];
        
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    
    NSDate* date = [NSDate date];
    
    NSDateFormatter* dfdate = [[NSDateFormatter alloc] init];
    dfdate.dateStyle = NSDateFormatterShortStyle;
    NSString* dateString = [dfdate stringFromDate:date];

    NSDateFormatter* dftime = [[NSDateFormatter alloc] init];
    dftime.timeStyle = NSDateFormatterShortStyle;
    NSString* timeString = [dftime stringFromDate:date];
    
    NSString *emailTitle = [NSString stringWithFormat:@"GlucoMe history - %@ %@",dateString, timeString];
    
    MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
    mc.mailComposeDelegate = self;
    [mc setSubject:emailTitle];
    [mc setMessageBody:@"" isHTML:NO];
    [mc setToRecipients:@[]];
    
    NSMutableString *csv = [NSMutableString stringWithString:@""];
    
    //add your content to the csv
    [csv appendFormat:@"date, value, tags"];
    
    for(Measurement* m in tableData)
    {
        NSString* dateString = [dfdate stringFromDate:m.date];
        NSString* timeString = [dftime stringFromDate:m.date];
        
        
        
        NSString* value = @"";
        switch ([m.type intValue]) {
            case glucoseMeasurementType:
                value = [NSString stringWithFormat:@"%@ [%@]",[[UnitsManager getInstance] GetGlucoseStringValueForCurrentUnit:[m.value intValue]], [[UnitsManager getInstance] GetGlucoseUnitsLocalizedString]];
                break;
            case medicineMeasurementType:
                value = [NSString stringWithFormat:@"%d [units]",[m.value intValue]];
                break;
            case foodMeasurementType:
                if([m.value intValue] == 1)
                    value = loc(@"Small_meal");
                if([m.value intValue] == 2)
                    value = loc(@"Medium_meal");
                if ([m.value intValue] == 3)
                    value = loc(@"large_meal");
                break;
            case activityMeasurementType:
                if([m.value intValue] == 1)
                    value = loc(@"Easy_physical_activity");
                if([m.value intValue] == 2)
                    value = loc(@"Medium_physical_activity");
                if ([m.value intValue] == 3)
                    value = loc(@"Hard_physical_activity");
                break;
            case weightMeasurementType:
                value = [NSString stringWithFormat:@"%@ weight" , m.value];
                break;
            default:
                break;
        }
        
        [csv appendFormat:@"\n%@ %@, %@, %@",dateString, timeString, value, [m GetTagsAsString]];
    }

    NSString* filePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString* fileName = [NSString stringWithFormat:@"GlucoMe.csv"];
    NSString* fileAtPath = [filePath stringByAppendingPathComponent:fileName];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:fileAtPath]) {
        [[NSFileManager defaultManager] createFileAtPath:fileAtPath contents:nil attributes:nil];
    }
    
    BOOL res = [[csv dataUsingEncoding:NSUTF8StringEncoding] writeToFile:fileAtPath atomically:NO];
    
    if (!res) {
        [[[UIAlertView alloc] initWithTitle:@"Error Creating CSV" message:@"Check your permissions to make sure this app can create files so you may email the app data" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil] show];
    }else{
        NSLog(@"Data saved! File path = %@", fileName);
        [mc addAttachmentData:[NSData dataWithContentsOfFile:fileAtPath]
                     mimeType:@"text/csv"
                     fileName:@"GlucoMe.csv"];
        [self presentViewController:mc animated:YES completion:nil];
    }
}
-(void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
