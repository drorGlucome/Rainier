//
//  SingleFriendViewController.m
//  GlucoMe - Mobile
//
//  Created by dovi winberger on 7/22/15.
//  Copyright (c) 2015 Yiftah Ben Aharon. All rights reserved.
//

#import "SingleFriendViewController.h"
#import "Friend_helper.h"
#import "BasicTileView.h"
#import "ChartViewController.h"
#import "TrendChart.h"
#import "PieChart.h"
#import "general.h"
#import "HistoryTableViewController.h"
@interface SingleFriendViewController ()

@end

@implementation SingleFriendViewController
@synthesize tiles;
@synthesize mFriend;

typedef enum TileNames {historyTile, HbA1CTile, trendTile,
    distributionTile} TileNames;

BOOL headerVisible = YES;
-(void)loadView
{
    [super loadView];
    tilesDictionary = [[NSMutableDictionary alloc] init];
    
    [self CreateHistoryTile];
    [self CreateHbA1cTile];
    [self CreateTrendTile];
    [self CreateDistributionTile];
}
- (void)viewDidLoad
{
    [super viewDidLoad];

    tilesOrder = @[ @(historyTile), @(HbA1CTile), @(trendTile), @(distributionTile)];
    
    headerVisible = YES;
    [[DataHandler_new getInstance] GetFriendMeasurementsFromServer:mFriend.friendId];
}



- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.screenName = @"SingleFriendViewController";
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(FriendDataChanged) name:@"FriendDataChanged" object:nil];
    
    self.title = [mFriend DisplayName];
}
-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)FriendDataChanged
{
    [tilesDictionary removeAllObjects];
    headerVisible = NO;
    [self.collectionView reloadData];
}

-(NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section
{
    return tilesOrder.count + 1; //last row is not justified woth flowLayout - so add another item that will be the last row (height 0)
}
-(NSInteger)numberOfSectionsInCollectionView: (UICollectionView *)collectionView
{
    return 1;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    if (headerVisible) {
        return CGSizeMake(collectionView.bounds.size.width, 30.0f);
    }
    else {
        return CGSizeZero;
    }
}
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionReusableView *reusableview = nil;
    
    if (kind == UICollectionElementKindSectionHeader) {
        UICollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"friendsCollectionHeader" forIndexPath:indexPath];
        //NSString *title = [[NSString alloc]initWithFormat:@"Recipe Group #%i", indexPath.section + 1];
        //headerView.title.text = title;
        //UIImage *headerImage = [UIImage imageNamed:@"header_banner.png"];
        //headerView.backgroundImage.image = headerImage;
        
        reusableview = headerView;
    }
    
    
    return reusableview;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [cv dequeueReusableCellWithReuseIdentifier:@"friendResultCell" forIndexPath:indexPath];
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
    else
    {
        
    }
    return cell;
}


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    // If you need to use the touched cell, you can retrieve it like so
    switch ([[tilesOrder objectAtIndex:indexPath.item] integerValue])
    {
        case historyTile:
        {
            UINavigationController *nav = [[UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil] instantiateViewControllerWithIdentifier:@"HistoryNavigationControllerID"];
            HistoryTableViewController* vc = nav.viewControllers[0];
            vc.patient_id = mFriend.friendId;
            
            [self presentViewController:nav animated:YES completion:nil];
            break;
        }
        case HbA1CTile:
        {
            UINavigationController *nav = [[UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil] instantiateViewControllerWithIdentifier:@"ChartViewControllerID"];
            ChartViewController* vc = nav.viewControllers[0];
            vc.chartType = GaugeType;
            vc.patient_id = mFriend.friendId;
            
            [self presentViewController:nav animated:YES completion:nil];
            break;
        }
        case trendTile:
        {
            UINavigationController *nav = [[UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil] instantiateViewControllerWithIdentifier:@"ChartViewControllerID"];
            ChartViewController* vc = nav.viewControllers[0];
            vc.chartType = TrendType;
            vc.patient_id = mFriend.friendId;
            
            [self presentViewController:nav animated:YES completion:nil];
            break;
        }
        case distributionTile:
        {
            UINavigationController *nav = [[UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil] instantiateViewControllerWithIdentifier:@"ChartViewControllerID"];
            ChartViewController* vc = nav.viewControllers[0];
            vc.chartType = PieType;
            vc.patient_id = mFriend.friendId;
            
            [self presentViewController:nav animated:YES completion:nil];
            break;
        }
        default:
            break;
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.item == historyTile || indexPath.item == HbA1CTile)
        return CGSizeMake(collectionView.frame.size.width-20, 100);
    else if(indexPath.item > -1 && indexPath.item < tilesOrder.count)
        return CGSizeMake(collectionView.frame.size.width/2-15, collectionView.frame.size.width/2-20);
    else
        return CGSizeMake(collectionView.frame.size.width-20, 40);

}










- (void) DataChanged
{
    [tilesDictionary removeAllObjects];
    
    [self CreateHistoryTile];
    [self CreateHbA1cTile];
    [self CreateTrendTile];
    [self CreateDistributionTile];
    
    [self.collectionView reloadData];
}

-(BasicTileView*)CreateHistoryTile
{
    
    BasicTileView* t = (BasicTileView*)[[[NSBundle mainBundle] loadNibNamed:@"BasicTileView" owner:nil options:nil] objectAtIndex:0];
    
    NSString* glucoseLevel = @"--";
    NSString* subtext = @"";
    UIColor* color = BLUE;
    
    NSPredicate* p = [NSPredicate predicateWithFormat:@"patient_id = %@", self.mFriend.friendId];
    Measurement* lastMeasurement = [Measurement MR_findFirstWithPredicate:p sortedBy:@"date" ascending:false inContext:[NSManagedObjectContext MR_defaultContext]];
    if(lastMeasurement)
    {
        glucoseLevel = [[UnitsManager getInstance] GetGlucoseStringValueForCurrentUnit:[lastMeasurement.value intValue]];
        color = glucoseToColor([lastMeasurement.value intValue], [lastMeasurement GetFirstTagID]);
        
        NSString* date = [[NSString alloc] initWithFormat:@"%@", rails2iosDateFromDate(lastMeasurement.date)];
        NSString* hour = [[NSString alloc] initWithFormat:@"%@", rails2iosTimeFromDate(lastMeasurement.date)];
        
        subtext= [[NSString alloc] initWithFormat:@"%@ %@ %@", date, loc(@"at"), hour];
        
    }
    
    
    t.topLabel.text = [NSString stringWithFormat:@"%@ (%@)",loc(@"Last_result"), [[UnitsManager getInstance] GetGlucoseUnitsLocalizedString]];
    t.topLabel.textColor = color;
    t.centerLabel.text = glucoseLevel;
    t.centerLabel.textColor = color;
    t.bottomLabel.text = subtext;
    
    [tilesDictionary setObject:t forKey:@(historyTile)];
    return t;
}

-(BasicTileView*)CreateTrendTile
{
    BasicTileView* t = (BasicTileView*)[[[NSBundle mainBundle] loadNibNamed:@"BasicTileView" owner:nil options:nil] objectAtIndex:0];
    
    t.topLabel.text = loc(@"Last_week");
    t.topLabel.textColor = BLUE;
    t.bottomLabel.text = loc(@"Glucose_trend");
    t.centerLabel.hidden = YES;
    
    NSArray* last7DaysMeasurements = [Measurement GetAllMeasurementsFromDate:[[NSDate dateWithDaysBeforeNow:7] dateAtStartOfDay] andTags:nil measurementType:glucoseMeasurementType forPatient_id:mFriend.friendId];
    if(last7DaysMeasurements.count == 0)
    {
        t.centerLabel.hidden = NO;
        t.centerLabel.text = @"--";
    }
    else
    {
        TrendChart* chart = [[TrendChart alloc] initWithFrame:t.contentView.bounds andMode:smallTrendChartMode forPatient_id:mFriend.friendId];
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
    
    t.topLabel.text = loc(@"Last_week");;
    t.centerLabel.hidden = YES;
    t.bottomLabel.text = loc(@"Glucose_distribution");
    t.centerLabel.hidden = YES;
    
    NSArray* last7DaysMeasurements = [Measurement GetAllMeasurementsFromDate:[[NSDate dateWithDaysBeforeNow:7] dateAtStartOfDay] andTags:nil measurementType:glucoseMeasurementType forPatient_id:mFriend.friendId];
    if(last7DaysMeasurements.count == 0)
    {
        t.centerLabel.hidden = NO;
        t.centerLabel.text = @"--";
    }
    else
    {
        PieChart* chart = [[PieChart alloc] initWithFrame:t.contentView.bounds forPatient_id:mFriend.friendId];
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



-(BasicTileView*)CreateHbA1cTile
{
    BasicTileView* t = (BasicTileView*)[[[NSBundle mainBundle] loadNibNamed:@"BasicTileView" owner:nil options:nil] objectAtIndex:0];
    
    float score = [Measurement GetHbA1cFromDate:[[NSDate dateWithDaysBeforeNow:7] dateAtStartOfDay] andTags:NULL forPatient_id:self.mFriend.friendId];
    NSNumber* tmp = [NSNumber numberWithFloat:score];
    UIColor* color = EHA1CToColor(tmp);
    t.topLabel.text = loc(@"Last_week");;
    t.topLabel.textColor = color;
    if(score == -1) {
        t.centerLabel.text = @"--";
    }
    else {
        t.centerLabel.text = [[NSString alloc] initWithFormat:@"%.1f", score];
    }
    t.centerLabel.textColor = color;
    t.bottomLabel.text = loc(@"Estimated_HbA1c");
    
    [tilesDictionary setObject:t forKey:@(HbA1CTile)];
    return t;
}


@end
