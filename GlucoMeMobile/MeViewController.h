//
//  SecondViewController.h
//  GlucoMe - Mobile
//
//  Created by Yiftah Ben Aharon on 1/9/14.
//  Copyright (c) 2014 Yiftah Ben Aharon. All rights reserved.
//
//  This is the results page
#import <UIKit/UIKit.h>

#import "BaseViewController.h"



@interface MeViewController : BaseViewController <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
{
    NSTimer* recreateNextTreatmentTileTimer;
    NSMutableDictionary* tilesDictionary;
    NSArray* tilesOrder;
}
//- (void) updateData;
//- (void) updateTiles;
//- (void) wobbleResult;

@property (strong, nonatomic) NSMutableArray *tiles;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;


@end
