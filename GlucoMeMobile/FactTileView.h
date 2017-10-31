//
//  FactTileView.h
//  GlucoMe - Mobile
//
//  Created by Yiftah Ben Aharon on 4/23/14.
//  Copyright (c) 2014 Yiftah Ben Aharon. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FactTileViewDelegateProtocol <NSObject>

-(void)FactWasTapped;

@end
@interface FactTileView : UIView

@property (weak, nonatomic) id<FactTileViewDelegateProtocol> delegate;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UILabel *headerLabel;

@end
