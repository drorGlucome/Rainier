//
//  MYTextAttachment.m
//  GlucoMe - Mobile
//
//  Created by dovi winberger on 10/01/2016.
//  Copyright © 2016 Yiftah Ben Aharon. All rights reserved.
//

#import "MYTextAttachment.h"

@implementation MYTextAttachment
- (CGRect)attachmentBoundsForTextContainer:(NSTextContainer *)textContainer proposedLineFragment:(CGRect)lineFrag glyphPosition:(CGPoint)position characterIndex:(NSUInteger)charIndex {
    CGFloat width = lineFrag.size.width;
    
    // Scale how you want
    float scalingFactor = 0.75;
    CGSize imageSize = [self.image size];
    if (width < imageSize.width)
        scalingFactor = width / imageSize.width;
    CGRect rect = CGRectMake(0, -3, imageSize.width * scalingFactor, imageSize.height * scalingFactor);
    
    return rect;
}
@end
