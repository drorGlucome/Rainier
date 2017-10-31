//
//  SecondViewController.m
//  GlucoMe - Mobile
//
//  Created by Yiftah Ben Aharon on 1/9/14.
//  Copyright (c) 2014 Yiftah Ben Aharon. All rights reserved.
//
#import "general.h"
#import "DataHandler_new.h"
#import "MeViewController.h"

#import "BasicTileView.h"
#import "FactTileView.h"
#import "TrendChart.h"
#import "PieChart.h"
#import "FullTableViewControllerNew.h"
#import "HistoryTableViewController.h"
#import "ChartViewController.h"
#import "FactsTableViewController.h"
#import "TreatmentsTableViewController.h"

#import "Measurement.h"
#import "Measurement_helper.h"
#import "Fact.h"
#import "Alert.h"
#import "UnitsManager.h"
#import "Friend_helper.h"
#import "Treatment_helper.h"

#import "RemindersTableViewController.h"

#import "FullStripsViewController.h"
#import "FullScoreViewController.h"
#import "GAIFields.h"
#import "GAI.h"

#import "NSString+FontAwesome.h"

@interface MeViewController () <FactTileViewDelegateProtocol>


@end

@implementation MeViewController
@synthesize tiles;

typedef enum TileNames {historyTile, factTile, HbA1CTile, trendTile,
    distributionTile, remindersTile, stripsTile, alertsTile, friendsTile, prevTreatmentTile, nextTreatmentTile} TileNames;


-(void)loadView
{
    [super loadView];
    tilesDictionary = [[NSMutableDictionary alloc] init];

    [self DataChanged];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(RecreateNextTreatmentTile) name:@"NewTreatmentAvailable" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(RecreateNextTreatmentTile) name:@"TreatmentDiaryChanged" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(DataChanged) name:@"DataChanged" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(DataChanged) name:@"ProfileChanged" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ShowBetaFeaturesChanged) name:@"ShowBetaFeaturesChanged" object:nil];
    
    [self CreateTilesOrder];
    
    UISwipeGestureRecognizer* swipeleft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(SwipeLeftGestureRecognizer)];
    swipeleft.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.view addGestureRecognizer:swipeleft];
    
    UISwipeGestureRecognizer* swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(SwipeRightGestureRecognizer)];
    swipeRight.direction = UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:swipeRight];
}

-(void)CreateTilesOrder
{
    if(DLG.isConnectedVersion)
    {
        NSMutableArray* temp = [[NSMutableArray alloc] initWithObjects:@(historyTile), /*@(factTile),*/ nil];
        if([Treatment IsTreatmentAvailable])
        {
            [temp addObject:@(nextTreatmentTile)];
        }
        
        [temp addObjectsFromArray:@[@(HbA1CTile), @(distributionTile), @(alertsTile),
                                    @(trendTile), @(remindersTile), @(stripsTile)]];
        if([[NSUserDefaults standardUserDefaults] boolForKey:show_beta_features_boolean])
            [temp addObjectsFromArray:@[@(friendsTile)]];
        
        tilesOrder = temp;
        
    }
    else
    {
        tilesOrder = @[ @(historyTile), @(HbA1CTile), @(trendTile),
                        @(distributionTile), @(remindersTile), @(stripsTile)];
    }
}

-(void)SwipeLeftGestureRecognizer
{
    self.tabBarController.selectedIndex++;
}

-(void)SwipeRightGestureRecognizer
{
    self.tabBarController.selectedIndex--;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.screenName = @"MeViewController";
    
    [self HandleAddAlertNorification];
    
    recreateNextTreatmentTileTimer = [NSTimer scheduledTimerWithTimeInterval:60 target:self selector:@selector(RecreateNextTreatmentTile) userInfo:nil repeats:YES];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [recreateNextTreatmentTileTimer invalidate];
}

-(void)HandleAddAlertNorification
{
    NSNumber* numberOfRuns = (NSNumber*)[[NSUserDefaults standardUserDefaults] objectForKey:@"numberOfRuns"];
    NSDate*   firstRunDate = (NSDate*)[[NSUserDefaults standardUserDefaults] objectForKey:@"firstRunDate"];
    
    NSNumber* notNowMultiplier = (NSNumber*)[[NSUserDefaults standardUserDefaults] objectForKey:@"notNowMultiplier"];
    if(notNowMultiplier == nil)
        notNowMultiplier = @(1);
    
    if([[NSDate date] timeIntervalSinceDate:firstRunDate] > 60*60*24*7* [notNowMultiplier integerValue] &&
       [numberOfRuns integerValue] > 4 * [notNowMultiplier integerValue] &&
       [Alert Contacts].count == 0)
    {
        NSString* userName = [[NSUserDefaults standardUserDefaults] stringForKey:profile_first_name];
        if(userName == nil) userName = @"";
        UIAlertController* alert =[UIAlertController
                                   alertControllerWithTitle:[NSString stringWithFormat:@"%@ %@",loc(@"Hi"), userName]
                                   message:loc(@"You_can_share_data_with_others")
                                   preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* ok = [UIAlertAction
                             actionWithTitle:loc(@"Start_sharing")
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action)
                             {
                                 [[NSUserDefaults standardUserDefaults] setObject:@([notNowMultiplier integerValue] * 2) forKey:@"notNowMultiplier"];
                                 [[NSUserDefaults standardUserDefaults] synchronize];
                                 [alert dismissViewControllerAnimated:YES completion:nil];
                                 [self StartSharing];
                             }];
        UIAlertAction* cancel = [UIAlertAction
                             actionWithTitle:loc(@"Not_now")
                             style:UIAlertActionStyleCancel
                             handler:^(UIAlertAction * action)
                             {
                                 [[NSUserDefaults standardUserDefaults] setObject:@([notNowMultiplier integerValue] * 2) forKey:@"notNowMultiplier"];
                                 [[NSUserDefaults standardUserDefaults] synchronize];
                                 [alert dismissViewControllerAnimated:YES completion:nil];
                             }];

        
        [alert addAction:ok];
        [alert addAction:cancel];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"ShouldWobbleGlucose"])
    {
        if([tilesDictionary objectForKey:@(historyTile)])
        {
            //BasicTileView* t = [tilesDictionary objectForKey:@(historyTile)];
            //[t wobbleCenterLabel];
            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"ShouldWobbleGlucose"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    }
}




-(NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section
{
    return tilesOrder.count + 1; //last row is not justified woth flowLayout - so add another item that will be the last row (height 0)
}
-(NSInteger)numberOfSectionsInCollectionView: (UICollectionView *)collectionView
{
    return 1;
}
-(UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [cv dequeueReusableCellWithReuseIdentifier:@"resultTileCell" forIndexPath:indexPath];
    NSString *version = [[UIDevice currentDevice] systemVersion];
    if([version floatValue] < 8.0)
        [cell.contentView setAutoresizesSubviews:NO];
    
    cell.backgroundColor = [UIColor clearColor];
    
    //removing old inner tile if exists
    [[[cell contentView] subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    
    if(indexPath.item >= tilesOrder.count) return cell;
    
    
    if([[tilesOrder objectAtIndex:indexPath.item] integerValue] == historyTile)
    {
        BasicTileView* t = nil;
        
        if([tilesDictionary objectForKey:@(historyTile)])
        {
            t = [tilesDictionary objectForKey:@(historyTile)];
        }
        else
        {
            t = [self CreateHistoryTile];
            
        }
        t.frame = cell.contentView.bounds;
        [cell.contentView addSubview:t];
    }
    else if([[tilesOrder objectAtIndex:indexPath.item] integerValue] == HbA1CTile)
    {
        BasicTileView* t = nil;
        if([tilesDictionary objectForKey:@(HbA1CTile)])
        {
            t = [tilesDictionary objectForKey:@(HbA1CTile)];
        }
        else
        {
            t = [self CreateHbA1cTile];
        }
        
        t.frame = cell.contentView.bounds;
        [cell.contentView addSubview:t];
    }
    else if([[tilesOrder objectAtIndex:indexPath.item] integerValue] == trendTile)
    {
        BasicTileView* t = nil;
        if([tilesDictionary objectForKey:@(trendTile)])
        {
            t = [tilesDictionary objectForKey:@(trendTile)];
        }
        else
        {
            t = [self CreateTrendTile];
        }
        t.frame = cell.contentView.bounds;
        [cell.contentView addSubview:t];
    }
    else if([[tilesOrder objectAtIndex:indexPath.item] integerValue] == distributionTile)
    {
        BasicTileView* t = nil;
        if([tilesDictionary objectForKey:@(distributionTile)])
        {
            t = [tilesDictionary objectForKey:@(distributionTile)];
        }
        else
        {
            t = [self CreateDistributionTile];
        }
        t.frame = cell.contentView.bounds;
        [cell.contentView addSubview:t];
    }
    else if([[tilesOrder objectAtIndex:indexPath.item] integerValue] == remindersTile)
    {
        BasicTileView* t = nil;
        if([tilesDictionary objectForKey:@(remindersTile)])
        {
            t = [tilesDictionary objectForKey:@(remindersTile)];
        }
        else
        {
            t = [self CreateRemindersTile];
        }
        t.frame = cell.contentView.bounds;
        [cell.contentView addSubview:t];
    }
    else if([[tilesOrder objectAtIndex:indexPath.item] integerValue] == stripsTile)
    {
        BasicTileView* t = nil;
        if([tilesDictionary objectForKey:@(stripsTile)])
        {
            t = [tilesDictionary objectForKey:@(stripsTile)];
        }
        else
        {
            t = [self CreateStripsTile];
        }
        t.frame = cell.contentView.bounds;
        [cell.contentView addSubview:t];
    }
    else if([[tilesOrder objectAtIndex:indexPath.item] integerValue] == factTile)
    {
        
        FactTileView* t = nil;
        if([tilesDictionary objectForKey:@(factTile)])
        {
            t = [tilesDictionary objectForKey:@(factTile)];
        }
        else
        {
            t = [self CreateFactTile];
        }
        t.frame = cell.contentView.bounds;
        t.delegate = self;
        [cell.contentView addSubview:t];
    }
    else if([[tilesOrder objectAtIndex:indexPath.item] integerValue] == alertsTile)
    {
        BasicTileView* t = nil;
        if([tilesDictionary objectForKey:@(alertsTile)])
        {
            t = [tilesDictionary objectForKey:@(alertsTile)];
        }
        else
        {
            t = [self CreateAlertTile];
        }
        t.frame = cell.contentView.bounds;
        [cell.contentView addSubview:t];
    }
    else if([[tilesOrder objectAtIndex:indexPath.item] integerValue] == friendsTile)
    {
        BasicTileView* t = nil;
        if([tilesDictionary objectForKey:@(friendsTile)])
        {
            t = [tilesDictionary objectForKey:@(friendsTile)];
        }
        else
        {
            t = [self CreateFriendsTile];
        }
        t.frame = cell.contentView.bounds;
        [cell.contentView addSubview:t];
    }
    else if([[tilesOrder objectAtIndex:indexPath.item] integerValue] == prevTreatmentTile)
    {
        BasicTileView* t = nil;
        if([tilesDictionary objectForKey:@(prevTreatmentTile)])
        {
            t = [tilesDictionary objectForKey:@(prevTreatmentTile)];
        }
        else
        {
            t = [self CreatePrevTreatmentTile];
        }
        t.frame = cell.contentView.bounds;
        [cell.contentView addSubview:t];
    }
    else if([[tilesOrder objectAtIndex:indexPath.item] integerValue] == nextTreatmentTile)
    {
        BasicTileView* t = nil;
        if([tilesDictionary objectForKey:@(nextTreatmentTile)])
        {
            t = [tilesDictionary objectForKey:@(nextTreatmentTile)];
        }
        else
        {
            t = [self CreateNextTreatmentTile];
        }
        t.frame = cell.contentView.bounds;
        [cell.contentView addSubview:t];
    }
    else
    {
        
    }
    return cell;
}


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if(tilesOrder.count <= indexPath.item) return;
    
    // If you need to use the touched cell, you can retrieve it like so
    switch ([[tilesOrder objectAtIndex:indexPath.item] integerValue])
    {
        case historyTile:
        {
            UINavigationController *nav = [[UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil] instantiateViewControllerWithIdentifier:@"HistoryNavigationControllerID"];
            HistoryTableViewController* vc = nav.viewControllers[0];
            vc.patient_id = [[DataHandler_new getInstance] getPatientIdAsNumber];
            
            UIViewController *topVC = self.tabBarController;
            [topVC presentViewController:nav animated:YES completion:nil];
            break;
        }
        case HbA1CTile:
        {
            UINavigationController *nav = [[UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil] instantiateViewControllerWithIdentifier:@"ChartViewControllerID"];
            ChartViewController* vc = nav.viewControllers[0];
            vc.chartType = GaugeType;
            vc.patient_id = [[DataHandler_new getInstance] getPatientIdAsNumber];
            
            UIViewController *topVC = self.tabBarController;
            [topVC presentViewController:nav animated:YES completion:nil];
            break;
        }
        case trendTile:
        {
            UINavigationController *nav = [[UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil] instantiateViewControllerWithIdentifier:@"ChartViewControllerID"];
            ChartViewController* vc = nav.viewControllers[0];
            vc.chartType = TrendType;
            vc.patient_id = [[DataHandler_new getInstance] getPatientIdAsNumber];
            
            UIViewController *topVC = self.tabBarController;
            [topVC presentViewController:nav animated:YES completion:nil];
            break;
        }
        case distributionTile:
        {
            UINavigationController *nav = [[UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil] instantiateViewControllerWithIdentifier:@"ChartViewControllerID"];
            ChartViewController* vc = nav.viewControllers[0];
            vc.chartType = PieType;
            vc.patient_id = [[DataHandler_new getInstance] getPatientIdAsNumber];
            
            UIViewController *topVC = self.tabBarController;
            [topVC presentViewController:nav animated:YES completion:nil];
            break;
        }
        case remindersTile:
        {
            UINavigationController *nav = [[UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil] instantiateViewControllerWithIdentifier:@"RemindersNavigationControllerID"];
            //FullTableViewControllerNew* tvc = nav.viewControllers[0];
            
            UIViewController *topVC = self.tabBarController;
            [topVC presentViewController:nav animated:YES completion:nil];
            break;
        }
        case stripsTile:
        {
            //not showing inner page
            //UIViewController* vc = [[FullStripsViewController alloc] initWithNibName:loc(@"FullStripsViewController")bundle:nil];
            //UIViewController *topVC = self.tabBarController;
            //[topVC presentViewController:vc animated:YES completion:nil];
            
            //instead, update the strips from here
            [FullStripsViewController UpdateStripsAmount:self];
            break;
        }
        case factTile:
        {
            [self FactWasTapped];
            break;
        }
        case alertsTile:
        {
            [self StartSharing];
            break;
        }
        case friendsTile:
        {
            UINavigationController *nav = [[UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil] instantiateViewControllerWithIdentifier:@"FriendsNavigationControllerId"];
            //FullTableViewControllerNew* tvc = nav.viewControllers[0];
            
            UIViewController *topVC = self.tabBarController;
            [topVC presentViewController:nav animated:YES completion:nil];
            break;
        }
        case prevTreatmentTile:
        {
            UINavigationController *nav = [[UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil] instantiateViewControllerWithIdentifier:@"TreatmentNavigationControllerID"];
            
            UIViewController *topVC = self.tabBarController;
            [topVC presentViewController:nav animated:YES completion:nil];
            break;
        }
        case nextTreatmentTile:
        {
            UINavigationController *nav = [[UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil] instantiateViewControllerWithIdentifier:@"TreatmentNavigationControllerID"];
            
            UIViewController *topVC = self.tabBarController;
            [topVC presentViewController:nav animated:YES completion:nil];
            break;
        }
        default:
            break;
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if(DLG.isConnectedVersion)
    {
        int tileName = -1;
        if (indexPath.item < tilesOrder.count)
            tileName = [[tilesOrder objectAtIndex:indexPath.item] intValue];
        
        if(tileName == historyTile || tileName == factTile || tileName == nextTreatmentTile || tileName == friendsTile)
            return CGSizeMake(collectionView.frame.size.width-20, collectionView.frame.size.width/3);
        else if(indexPath.item > -1 && indexPath.item < tilesOrder.count)
            return CGSizeMake(collectionView.frame.size.width/2-15, collectionView.frame.size.width/2-20);
        else
            return CGSizeMake(collectionView.frame.size.width-20, 40);
    }
    else
    {
        if(indexPath.item < tilesOrder.count)
            return CGSizeMake(collectionView.frame.size.width/2-20, collectionView.frame.size.width/2-20);
        else
            return CGSizeMake(collectionView.frame.size.width-20, 40);

    }
}

-(void)FactWasTapped
{
    UINavigationController *nav = [[UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil] instantiateViewControllerWithIdentifier:@"FactsViewControllerID"];
    
    UIViewController *topVC = self.tabBarController;
    [topVC presentViewController:nav animated:YES completion:nil];
}

-(void)StartSharing
{
    UIViewController *vc = [[UIStoryboard storyboardWithName:@"ShareStoryboard" bundle:nil] instantiateInitialViewController];
    //FullTableViewControllerNew* tvc = nav.viewControllers[0];
    
    UIViewController *topVC = self.tabBarController;
    [topVC presentViewController:vc animated:YES completion:nil];
}







-(void)RecreateNextTreatmentTile
{
    [self CreateTilesOrder];
    
    [tilesDictionary removeObjectForKey:@(nextTreatmentTile)];
    [self CreateNextTreatmentTile];
    [self.collectionView reloadData];
}

-(void)ShowBetaFeaturesChanged
{
    [self CreateTilesOrder];
    [self DataChanged];
}


- (void) DataChanged
{
    [self CreateTilesOrder];
    [tilesDictionary removeAllObjects];
    
    [self CreateHistoryTile];
    [self CreateHbA1cTile];
    [self CreateTrendTile];
    [self CreateDistributionTile];
    [self CreateStripsTile];
    [self CreateAlertTile];
    [self CreateFactTile];
    [self CreateRemindersTile];
    [self CreatePrevTreatmentTile];
    [self CreateNextTreatmentTile];
    
    [self.collectionView reloadData];
}

-(BasicTileView*)CreateHistoryTile
{
    
    BasicTileView* t = (BasicTileView*)[[[NSBundle mainBundle] loadNibNamed:@"BasicTileView" owner:nil options:nil] objectAtIndex:0];
    
    NSString* measurementString = @"--";
    NSAttributedString* attributedMeasurementString = [[NSAttributedString alloc] initWithString:@""];

    NSString* subtext = @"";
    NSString* topText = @"";
    UIColor* color = [UIColor darkGrayColor];
    
    NSPredicate* p = [NSPredicate predicateWithFormat:@"patient_id = %@", [[DataHandler_new getInstance] getPatientIdAsNumber]];
    Measurement* lastMeasurement = [Measurement MR_findFirstWithPredicate:p sortedBy:@"date" ascending:false inContext:[NSManagedObjectContext MR_defaultContext]];
    if(lastMeasurement)
    {
        measurementString = @"";
        NSString* units = @"";
        NSString* lastAction = @"";
        switch ([lastMeasurement.type integerValue])
        {
            case glucoseMeasurementType:
                measurementString = [[UnitsManager getInstance] GetGlucoseStringValueForCurrentUnit:[lastMeasurement.value intValue]];
                color = glucoseToColor([lastMeasurement.value intValue], [lastMeasurement GetFirstTagID]);
                units = [[UnitsManager getInstance] GetGlucoseUnitsLocalizedString];
                lastAction = loc(@"Last_Measurement");
                break;
            case medicineMeasurementType:
                measurementString = [NSString stringWithFormat:@"%@",lastMeasurement.value];
                units = loc(@"Units");
                lastAction = loc(@"Last_medicine");
                break;
            case foodMeasurementType:
            {
                NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
                attachment.image = [UIImage imageNamed:@"food"];
                NSAttributedString* attr = [NSAttributedString attributedStringWithAttachment:attachment];
                
                NSMutableAttributedString* tempTitle = [[NSMutableAttributedString alloc] initWithString:@""];
                for (int i = 0; i < lastMeasurement.value.intValue; i++) {
                    [tempTitle appendAttributedString:attr];
                }
                attributedMeasurementString = tempTitle;
                
                color = foodToColor([lastMeasurement.value intValue]);
                units = loc(@"");
                lastAction = loc(@"Last_meal");
                break;
            }
            case activityMeasurementType:
            {
                NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
                attachment.image = [UIImage imageNamed:@"activity"];
                NSAttributedString* attr = [NSAttributedString attributedStringWithAttachment:attachment];
                
                NSMutableAttributedString* tempTitle = [[NSMutableAttributedString alloc] initWithString:@""];
                for (int i = 0; i < lastMeasurement.value.intValue; i++) {
                    [tempTitle appendAttributedString:attr];
                }
                attributedMeasurementString = tempTitle;
                
                color = activityToColor([lastMeasurement.value intValue]);
                units = loc(@"");
                lastAction = loc(@"Last_activity");
                break;
            }
            case weightMeasurementType:
            {
                measurementString = [NSString stringWithFormat:@"%@",lastMeasurement.value];
                color = weightToColor([lastMeasurement.value intValue]);
                units = loc(@"");
                lastAction = loc(@"Last_weight");
                break;
            }
            default:
                break;
        }
        
        NSString* date = [[NSString alloc] initWithFormat:@"%@", rails2iosDateFromDate(lastMeasurement.date)];
        NSString* hour = [[NSString alloc] initWithFormat:@"%@", rails2iosTimeFromDate(lastMeasurement.date)];
        
        subtext= [[NSString alloc] initWithFormat:@"%@ %@ %@", date, loc(@"at"), hour];
        if([units isEqualToString:@""])
            topText = [NSString stringWithFormat:@"%@",loc(lastAction)];
        else
            topText = [NSString stringWithFormat:@"%@ (%@)",loc(lastAction), units];
    }
    
    
    t.topLabel.text = topText;
    t.topLabel.textColor = color;
    
    if(![measurementString isEqualToString:@""])
        t.centerLabel.text = measurementString;
    else if (![attributedMeasurementString isEqualToAttributedString:[[NSAttributedString alloc] initWithString:@""]])
        t.centerLabel.attributedText = attributedMeasurementString;
    
    t.centerLabel.textColor = color;
    t.bottomLabel.text = subtext;
    
    [tilesDictionary setObject:t forKey:@(historyTile)];

    return t;
}

-(BasicTileView*)CreateTrendTile
{
    BasicTileView* t = (BasicTileView*)[[[NSBundle mainBundle] loadNibNamed:@"BasicTileView" owner:nil options:nil] objectAtIndex:0];
    
    t.topLabel.text = loc(@"Glucose_trend");
    t.topLabel.textColor = BLUE;
    t.bottomLabel.text = loc(@"Last_week");
    t.centerLabel.hidden = YES;
    
    NSArray* last7DaysMeasurements = [Measurement GetAllMeasurementsFromDate:[[NSDate dateWithDaysBeforeNow:7] dateAtStartOfDay] andTags:nil measurementType:glucoseMeasurementType forPatient_id:[[DataHandler_new getInstance] getPatientIdAsNumber]];
    if(last7DaysMeasurements.count == 0)
    {
        t.centerLabel.hidden = NO;
        t.centerLabel.text = @"--";
    }
    else
    {
        TrendChart* chart = [[TrendChart alloc] initWithFrame:t.contentView.bounds andMode:smallTrendChartMode forPatient_id:[[DataHandler_new getInstance] getPatientIdAsNumber]];
        [chart UpdateChartWithTags:nil andDaysAgo:7];
        
        chart.userInteractionEnabled = NO;
        [chart setTranslatesAutoresizingMaskIntoConstraints:NO];
        [t.contentView addSubview:chart];
        
        [t.contentView addConstraints:[NSLayoutConstraint
                                       constraintsWithVisualFormat:@"H:|-[chart]-|"
                                       options:NSLayoutFormatDirectionLeadingToTrailing
                                       metrics:nil
                                       views:NSDictionaryOfVariableBindings(chart)]];
        
        [t.contentView addConstraints:[NSLayoutConstraint
                                       constraintsWithVisualFormat:@"V:|-0-[chart]-0-|"
                                       options:NSLayoutFormatDirectionLeadingToTrailing
                                       metrics:nil
                                       views:NSDictionaryOfVariableBindings(chart)]];
    }
    
    [tilesDictionary setObject:t forKey:@(trendTile)];
    return t;
}

-(BasicTileView*)CreateDistributionTile
{
    BasicTileView* t = (BasicTileView*)[[[NSBundle mainBundle] loadNibNamed:@"BasicTileView" owner:nil options:nil] objectAtIndex:0];
    
    t.topLabel.text = loc(@"Glucose_distribution");;
    t.centerLabel.hidden = YES;
    t.bottomLabel.text = loc(@"Last_week");
    t.centerLabel.hidden = YES;
    
    NSArray* last7DaysMeasurements = [Measurement GetAllMeasurementsFromDate:[[NSDate dateWithDaysBeforeNow:7] dateAtStartOfDay] andTags:nil measurementType:glucoseMeasurementType forPatient_id:[[DataHandler_new getInstance] getPatientIdAsNumber]];
    if(last7DaysMeasurements.count == 0)
    {
        t.centerLabel.hidden = NO;
        t.centerLabel.text = @"--";
    }
    else
    {
        PieChart* chart = [[PieChart alloc] initWithFrame:t.contentView.bounds forPatient_id:[[DataHandler_new getInstance] getPatientIdAsNumber]];
        [chart UpdateChartWithTags:nil andDaysAgo:7];
        
        chart.userInteractionEnabled = NO;
        [chart setTranslatesAutoresizingMaskIntoConstraints:NO];
        [t.contentView addSubview:chart];
        
        [t.contentView addConstraints:[NSLayoutConstraint
                                       constraintsWithVisualFormat:@"H:|-[chart]-|"
                                       options:NSLayoutFormatDirectionLeadingToTrailing
                                       metrics:nil
                                       views:NSDictionaryOfVariableBindings(chart)]];
        
        [t.contentView addConstraints:[NSLayoutConstraint
                                       constraintsWithVisualFormat:@"V:|-0-[chart]-0-|"
                                       options:NSLayoutFormatDirectionLeadingToTrailing
                                       metrics:nil
                                       views:NSDictionaryOfVariableBindings(chart)]];
        
        UIColor* color = [chart getLeadingColor];
        t.topLabel.textColor = color;
    }
    
    [tilesDictionary setObject:t forKey:@(distributionTile)];
    return t;
}

-(BasicTileView*)CreateRemindersTile
{
    BasicTileView* t = (BasicTileView*)[[[NSBundle mainBundle] loadNibNamed:@"BasicTileView" owner:nil options:nil] objectAtIndex:0];
    
    //init to 0 until reminders are fetched
    NSString* reminders = @"0";
    UIColor* color = remindersToColor(reminders);
    t.topLabel.text = loc(@"There_are");;
    t.topLabel.textColor = color;
    
    t.centerLabel.text = reminders;
    
    t.centerLabel.textColor = color;
    t.bottomLabel.text = loc(@"Reminders_set");
    //done
    
    RemindersTableViewController* vc = [[RemindersTableViewController alloc] init];
    [vc fetchRemindersWithCompletionBlock:^(NSArray *remindersArray) {
        NSString* reminders = [[NSString alloc] initWithFormat:@"%d", (int)remindersArray.count];//[[vc fetchReminders] count]];
        t.centerLabel.text = reminders;
        UIColor* color = remindersToColor(reminders);
        t.topLabel.text = loc(@"There_are");;
        t.topLabel.textColor = color;
        
        t.centerLabel.textColor = color;
        t.bottomLabel.text = loc(@"Reminders_set");
    }];
    [tilesDictionary setObject:t forKey:@(remindersTile)];
    return t;
}

-(BasicTileView*)CreateHbA1cTile
{
    BasicTileView* t = (BasicTileView*)[[[NSBundle mainBundle] loadNibNamed:@"BasicTileView" owner:nil options:nil] objectAtIndex:0];
    
    float score = [Measurement GetHbA1cFromDate:[[NSDate dateWithDaysBeforeNow:90] dateAtStartOfDay] andTags:NULL forPatient_id:[[DataHandler_new getInstance] getPatientIdAsNumber]];
    NSNumber* tmp = [NSNumber numberWithFloat:score];
    UIColor* color = EHA1CToColor(tmp);
    t.topLabel.text = loc(@"Estimated_HbA1c");;
    t.topLabel.textColor = color;
    if(score == -1) {
        t.centerLabel.text = @"--";
    }
    else {
        t.centerLabel.text = [[NSString alloc] initWithFormat:@"%.1f", score];
    }
    t.centerLabel.textColor = color;
    t.bottomLabel.text = loc(@"Last_3_months");
    
    [tilesDictionary setObject:t forKey:@(HbA1CTile)];
    return t;
}

-(BasicTileView*)CreateStripsTile
{
    BasicTileView* t = (BasicTileView*)[[[NSBundle mainBundle] loadNibNamed:@"BasicTileView" owner:nil options:nil] objectAtIndex:0];
    
    NSString* strips = [NSString stringWithFormat:@"%d",[[DataHandler_new getInstance] GetStrips]];
    
    UIColor* color = stripsToColor(strips);
    t.topLabel.text = loc(@"You_have");;
    t.topLabel.textColor = color;
    t.centerLabel.text = strips;
    t.centerLabel.textColor = color;
    t.bottomLabel.text = loc(@"Test_strips_left");
    
    [tilesDictionary setObject:t forKey:@(stripsTile)];
    return t;
}

-(FactTileView*)CreateFactTile
{
    FactTileView* t = (FactTileView*)[[[NSBundle mainBundle] loadNibNamed:@"FactTileView" owner:nil options:nil] objectAtIndex:0];
    
    if(DLG.isConnectedVersion == NO) return t;
    Fact* lastFact = [Fact MR_findFirstOrderedByAttribute:@"date" ascending:false inContext:[NSManagedObjectContext MR_defaultContext]];
    
    NSPredicate* p = [NSPredicate predicateWithFormat:@"patient_id = %@", [[DataHandler_new getInstance] getPatientIdAsNumber]];
    Measurement* lastMeasurement = [Measurement MR_findFirstWithPredicate:p sortedBy:@"date" ascending:false inContext:[NSManagedObjectContext MR_defaultContext]];
    if(lastMeasurement)
    {
        NSString* glucoseLevelString = [[UnitsManager getInstance] GetGlucoseStringValueForCurrentUnit:[lastMeasurement.value intValue]];
        if([lastFact.data containsString:glucoseLevelString])
            [t.textView setText:lastFact.data];
        else
            [t.textView setText:NumberToFact([[[UnitsManager getInstance] GetGlucoseValueForCurrentUnit:lastMeasurement.value.intValue] intValue])];
        
    }
    else
    {
        [t.textView setText:NSLocalizedString(@"Welcome aboard", @"")];
    }
    
    
    
    
    t.headerLabel.text = loc(@"Did_you_know");
    
    [tilesDictionary setObject:t forKey:@(factTile)];
    return t;
}

-(BasicTileView*)CreateAlertTile
{
    BasicTileView* t = (BasicTileView*)[[[NSBundle mainBundle] loadNibNamed:@"BasicTileView" owner:nil options:nil] objectAtIndex:0];
    
    int alertsCount = (int)[Alert Contacts].count;
    NSString* shares = [[NSString alloc] initWithFormat:@"%d", alertsCount];
    
    UIColor* color = remindersToColor(shares);
    t.topLabel.text = loc(@"You_share_data_with");
    t.topLabel.textColor = color;
    t.centerLabel.text = shares;
    t.centerLabel.textColor = color;
    t.bottomLabel.text = loc(@"People");
    
    [tilesDictionary setObject:t forKey:@(alertsTile)];
    return t;
}

-(BasicTileView*)CreateFriendsTile
{
    BasicTileView* t = (BasicTileView*)[[[NSBundle mainBundle] loadNibNamed:@"BasicTileView" owner:nil options:nil] objectAtIndex:0];
    
    
    NSArray* friends = [Friend GetFriendsWhomIFollow:NO];
    int position = [Friend GetSocialPosition];
    
    UIColor* color = socialPositionToColor(position, (int)friends.count+1);
    t.topLabel.text = loc(@"Last_3_days");
    t.topLabel.textColor = color;
    
    t.centerLabel.text = [NSString stringWithFormat:@"%d", position];
    t.centerLabel.textColor = color;
    t.bottomLabel.text = [NSString stringWithFormat:loc(@"Out of %d friends"),(int)friends.count+1];
    
    [tilesDictionary setObject:t forKey:@(friendsTile)];
    return t;
}

-(BasicTileView*)CreatePrevTreatmentTile
{
    BasicTileView* t = (BasicTileView*)[[[NSBundle mainBundle] loadNibNamed:@"BasicTileView" owner:nil options:nil] objectAtIndex:0];

    NSArray* treatments = [Treatment LastTreatmentsGroup];
    if(treatments.count == 0) return t;
    
    UIColor* color = GRAY;
    t.topLabel.text = loc(@"Next_treatment");
    t.topLabel.textColor = color;

    Treatment* treatment = treatments[0];
    t.centerLabel.text = [NSString stringWithFormat:@"%@ %@", treatment.treatmentTypeName, treatment.dosage];
    t.centerLabel.textColor = color;
    
    NSString* date = [[NSString alloc] initWithFormat:@"%@", rails2iosDateFromDate(treatment.dateGiven)];
    NSString* hour = [[NSString alloc] initWithFormat:@"%@", rails2iosTimeFromDate(treatment.dateGiven)];
    
    t.bottomLabel.text = [[NSString alloc] initWithFormat:@"%@ %@ %@", date, loc(@"at"), hour];
    
    [tilesDictionary setObject:t forKey:@(prevTreatmentTile)];
    
    return t;
}

-(BasicTileView*)CreateNextTreatmentTile
{
    BasicTileView* t = (BasicTileView*)[[[NSBundle mainBundle] loadNibNamed:@"BasicTileView" owner:nil options:nil] objectAtIndex:0];
    
    TreatmentDiary* treatment = [TreatmentDiary NextTreatment];
    if(treatment == nil) return t;
    
    UIColor* color = GRAY;
    t.topLabel.text = loc(@"Next_treatment");
    t.topLabel.textColor = color;
    
    if(treatment.dosage == nil)
        t.centerLabel.text = [NSString stringWithFormat:@"%@", treatment.name];
    else
        t.centerLabel.text = [NSString stringWithFormat:@"%@ %@u", treatment.name, treatment.dosage];
    t.centerLabel.textColor = color;
    
    
    if([treatment.isDueDateEstimated boolValue] == NO)
    {
        NSString* date = [[NSString alloc] initWithFormat:@"%@", rails2iosDateFromDate(treatment.dueDate)];
        NSString* hour = [[NSString alloc] initWithFormat:@"%@", rails2iosTimeFromDate(treatment.dueDate)];
        
        t.bottomLabel.text = [[NSString alloc] initWithFormat:@"%@ %@ %@", date, loc(@"at"), hour];
    }
    else
    {
        NSString* dateComponent = RelativeDate(treatment.dueDate);
        
        NSString* timeComponent = [treatment.dueDate shortTimeString];
        timeComponent = HourAsComponentOfDay((int)treatment.dueDate.hour);
        
        t.bottomLabel.text = [NSString stringWithFormat:@"%@, %@", dateComponent, timeComponent];
    }
    
    [tilesDictionary setObject:t forKey:@(nextTreatmentTile)];
    
    return t;
}
@end
