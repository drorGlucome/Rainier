//
//  SingleFriendViewController.h
//  GlucoMe - Mobile
//
//  Created by dovi winberger on 7/22/15.
//  Copyright (c) 2015 Yiftah Ben Aharon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "Friend.h"
@interface SingleFriendViewController : BaseViewController <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
{
    NSMutableDictionary* tilesDictionary;
    NSArray* tilesOrder;
}

@property (strong, nonatomic) NSMutableArray *tiles;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (nonatomic, weak) Friend* mFriend;

@end
