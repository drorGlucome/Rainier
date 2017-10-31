//
//  TagsView.h
//  GlucoMe - Mobile
//
//  Created by dovi winberger on 5/31/15.
//  Copyright (c) 2015 Yiftah Ben Aharon. All rights reserved.
//

#import <UIKit/UIKit.h>


@class TagsView;
@protocol TagsViewDelegateProtocol <NSObject>

-(void)tagSelectionChanged:(TagsView*)tagsView;
@optional
-(NSString*)iconForTag:(long)tagId;
-(NSString*)labelForTag:(long)tagId;
@end

@interface TagsView : UIView
{
    NSMutableSet* activeTags;
}
@property (weak, nonatomic) IBOutlet UIView *notTaggesSection;

@property (weak, nonatomic) id<TagsViewDelegateProtocol> delegate;
@property (nonatomic) BOOL singleSelection;

//set before setFrame
@property (nonatomic) BOOL showNotTagged;

@property (strong, nonatomic) IBOutletCollection(UIImageView) NSArray* backgroundImageView;
@property (strong, nonatomic) IBOutletCollection(UIImageView) NSArray* iconImageView;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray* titleLabel;

- (IBAction)TagClicked:(UIButton*)sender;

-(void)SetActiveTags:(NSArray*)tags;
-(void)ActivateAllTags;
-(void)DeactivateAllTags;
-(NSArray*)GetSelectedTags;

-(BOOL)IsAllTagsSelected;
-(BOOL)IsNoneSelected;
@end
