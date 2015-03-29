//
//  UIView+Capture.m
//  ArcGraphView
//
//  Created by ronaldo on 3/29/15.
//  Copyright (c) 2015 ronaldo. All rights reserved.
//

#import "UIView+Capture.h"

@implementation UIView (Capture)
- (UIImage *)captureToImage{
    UIImage *img = nil;
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(self.frame.size.width, self.frame.size.height), NO, 0.0);
    [self drawViewHierarchyInRect:self.bounds afterScreenUpdates:NO];
    img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}

@end
