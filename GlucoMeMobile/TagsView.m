//
//  TagsView.m
//  GlucoMe - Mobile
//
//  Created by dovi winberger on 5/31/15.
//  Copyright (c) 2015 Yiftah Ben Aharon. All rights reserved.
//

#import "TagsView.h"
#import "general.h"
#import "Tag.h"
@implementation TagsView
@synthesize delegate;

-(void)awakeFromNib
{
    [super awakeFromNib];
    [self setup];
}

-(void)setDelegate:(id<TagsViewDelegateProtocol>)_delegate
{
    delegate = _delegate;
    [self setup];
}
-(void)setup
{
    activeTags = [[NSMutableSet alloc] init];
   
    for (UILabel* l in self.titleLabel)
    {
        if(l.textAlignment != NSTextAlignmentCenter)
        {
            if(l.tag != 1000)
                [l setTextAlignment:NSTextAlignmentNatural];
        }
        NSString* label = [self.delegate respondsToSelector:@selector(labelForTag:)] ?
            [self.delegate labelForTag:l.tag] : l.text;
        if(label == nil || [label isEqualToString:@""]) label = l.text;
        
        l.text = loc(label);
    }
    
    
}

-(void)FixFontSize
{
    [self setNeedsLayout];
    [self layoutIfNeeded];
    
    UILabel* maxLengthLabel = nil;
    float maxStringLength = 0;
    for (UILabel* l in self.titleLabel)
    {
        if (l.text.length > maxStringLength) {
            maxStringLength = l.text.length;
            maxLengthLabel = l;
        }
    }
    
    NSInteger maxFontSize = binarySearchForFontSizeForLabel(maxLengthLabel, 10, 30)-1;

    for (UILabel* l in self.titleLabel)
    {
        [l setFont:[UIFont fontWithName:l.font.fontName size:maxFontSize]];
    }
}


-(void)setFrame:(CGRect)frame
{
    CGFloat oldWidth = self.frame.size.width;
    CGFloat oldHeight = self.frame.size.height;
    
    float ar = oldWidth/oldHeight;
    
    CGFloat newWidth = frame.size.width;
    CGFloat newHeight =  newWidth / ar;
    
    
    int numberOfRows = 5;//glucose
    if(self.backgroundImageView.count == 6)
        numberOfRows = 6;//medicine
    if(self.backgroundImageView.count == 0)
        numberOfRows = 0;//weight
    if(self.showNotTagged)
        numberOfRows = numberOfRows + 1;
    UIView* element = self.backgroundImageView[0];
    if(element)
    {
        CGFloat elementHeight = element.frame.size.height;
        CGFloat newElementHeight = elementHeight * newHeight / oldHeight ;
        CGFloat totalHeight = newElementHeight*numberOfRows;
        
        [super setFrame:CGRectMake(frame.origin.x, frame.origin.y,
                                   frame.size.width, totalHeight)];
    }
    else
    {
        if(numberOfRows == 0)
            [super setFrame:CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, 2)];
        else
            [super setFrame:frame];
    }
    [self FixFontSize];
}

-(void)setShowNotTagged:(BOOL)showNotTagged
{
    _showNotTagged = showNotTagged;
    self.notTaggesSection.hidden = !showNotTagged;
}

- (IBAction)TagClicked:(UIButton*)sender
{
    if(self.singleSelection == YES)
    {
        BOOL shouldActivate = NO;
        if(![activeTags containsObject:[NSString stringWithFormat:@"%ld",(long)sender.tag]])
            shouldActivate = YES;

        [self DeactivateAllTags];
        
        if(shouldActivate)
            [self SetTagOn:sender.tag];
    }
    else
    {
        if([activeTags containsObject:[NSString stringWithFormat:@"%ld",(long)sender.tag]])
            [self SetTagOff:sender.tag];
        else
            [self SetTagOn:sender.tag];
    }
    
    [self.delegate tagSelectionChanged:self];
}

-(void)SetTagOn:(NSInteger)tagID
{
    UIImageView* iconImageView;
    UIImageView* backgroundImageView;
    UILabel* titleLabel;
    
    for (int i = 0; i < self.backgroundImageView.count; i++)
    {
        UIImageView *v = self.backgroundImageView[i];
        if ([v tag] == tagID)
        {
            backgroundImageView = v;
            break;
        }
    }
    for (int i = 0; i < self.iconImageView.count; i++)
    {
        UIImageView *v = self.iconImageView[i];
        if ([v tag] == tagID)
        {
            iconImageView = v;
            break;
        }
    }
    for (int i = 0; i < self.titleLabel.count; i++)
    {
        UILabel *v = self.titleLabel[i];
        if ([v tag] == tagID)
        {
            titleLabel = v;
            break;
        }
    }
    
    NSString* icon = @"";
    if([self.delegate respondsToSelector:@selector(iconForTag:)])
    {
        icon = [self.delegate iconForTag:tagID];
    }
    else
    {
        NSPredicate* p = [NSPredicate predicateWithFormat:@"id == %@",@(tagID)];
        NSArray* tags = [Tag MR_findAllWithPredicate:p inContext:[NSManagedObjectContext MR_defaultContext]];
        if(tags.count > 0)
            icon = ((Tag*)tags[0]).icon;
    }
    
    backgroundImageView.image = [UIImage imageNamed:@"tagButtonBackgroundActive.png"];
    iconImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@%@.png",icon, @"Active"]];
    titleLabel.textColor = [UIColor whiteColor];
    
    [activeTags addObject:[NSString stringWithFormat:@"%ld",(long)tagID]];
}
-(void)SetTagOff:(NSInteger)tagID
{
    UIImageView* iconImageView;
    UIImageView* backgroundImageView;
    UILabel* titleLabel;
    
    for (int i = 0; i < self.backgroundImageView.count; i++)
    {
        UIImageView *v = self.backgroundImageView[i];
        if ([v tag] == tagID)
        {
            backgroundImageView = v;
            break;
        }
    }
    for (int i = 0; i < self.iconImageView.count; i++)
    {
        UIImageView *v = self.iconImageView[i];
        if ([v tag] == tagID)
        {
            iconImageView = v;
            break;
        }
    }
    for (int i = 0; i < self.titleLabel.count; i++)
    {
        UILabel *v = self.titleLabel[i];
        if ([v tag] == tagID)
        {
            titleLabel = v;
            break;
        }
    }
    
    NSString* icon = @"";
    if([self.delegate respondsToSelector:@selector(iconForTag:)])
    {
        icon = [self.delegate iconForTag:tagID];
    }
    else
    {
        NSPredicate* p = [NSPredicate predicateWithFormat:@"id == %@",@(tagID)];
        NSArray* tags = [Tag MR_findAllWithPredicate:p inContext:[NSManagedObjectContext MR_defaultContext]];
        if(tags.count > 0)
            icon = ((Tag*)tags[0]).icon;
    }
    backgroundImageView.image = [UIImage imageNamed:@"tagButtonBackgroundNormal.png"];
    iconImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@%@.png",icon, @""]];
    titleLabel.textColor = [UIColor darkGrayColor];
    
    [activeTags removeObject:[NSString stringWithFormat:@"%ld",(long)tagID]];
}

-(void)ActivateAllTags
{
    for (UIView* v in self.backgroundImageView)
    {
        [self SetTagOn:v.tag];
    }
    [self.delegate tagSelectionChanged:self];
}
-(void)DeactivateAllTags
{
    for (UIView* v in self.backgroundImageView)
    {
        [self SetTagOff:v.tag];
    }
    [self.delegate tagSelectionChanged:self];
}

-(void)SetActiveTags:(NSArray*)tags
{
    //assuming tags are string integers
    for (NSString* tag in tags)
    {
        if(![tag isEqualToString:@""])
            [self SetTagOn:[tag integerValue]];
    }
}

-(NSArray*)GetSelectedTags
{
    return [activeTags allObjects];
}
-(BOOL)IsAllTagsSelected
{
    return [activeTags allObjects].count == self.backgroundImageView.count;
}
-(BOOL)IsNoneSelected
{
    return [activeTags allObjects].count == 0;
}
@end
