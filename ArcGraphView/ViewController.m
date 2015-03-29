//
//  ViewController.m
//  ArcGraphView
//
//  Created by ronaldo on 3/28/15.
//  Copyright (c) 2015 ronaldo. All rights reserved.
//

#import "ViewController.h"
#import "UIView+Capture.h"
#import "GraphView.h"
@interface ViewController ()

@end

#define RGBCOLOR(r,g,b)             [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:1]

static UIImage *imageWithSize(CGSize size, UIColor *startColor, UIColor *endColor, NSInteger index) {
    static CGFloat const kThickness = 10;
    static CGFloat const kLineWidth = 0;
    
//    static CGFloat const kShadowWidth = 8;
    
    UIGraphicsBeginImageContextWithOptions(size, NO, 0); {
        CGContextRef gc = UIGraphicsGetCurrentContext();
        CGContextAddArc(gc, size.width / 2, size.height / 2,
                        (size.width - kThickness - kLineWidth) / 2,
                        M_PI, -2*M_PI / 4, YES);
        CGContextSetLineWidth(gc, kThickness);
        CGContextSetLineCap(gc, kCGLineCapRound);
        CGContextReplacePathWithStrokedPath(gc);
        CGPathRef path = CGContextCopyPath(gc);
        
//        CGContextSetShadowWithColor(gc,
//                                    CGSizeMake(0, kShadowWidth / 2), kShadowWidth / 2,
//                                    [UIColor colorWithWhite:0 alpha:0.3].CGColor);
        CGContextBeginTransparencyLayer(gc, 0);
        
        {
            
            CGContextSaveGState(gc); {
                CGColorSpaceRef rgb = CGColorSpaceCreateDeviceRGB();
                CGGradientRef gradient = CGGradientCreateWithColors(rgb, (__bridge CFArrayRef)@[
                                                                                                (__bridge id)startColor.CGColor,
                                                                                                (__bridge id)endColor.CGColor
                                                                                                ], (CGFloat[]){ 0.0f, 1.0f });
                CGColorSpaceRelease(rgb);
                
                CGRect bbox = CGContextGetPathBoundingBox(gc);
                CGPoint start = bbox.origin;
                CGPoint end = CGPointMake(CGRectGetMaxX(bbox), CGRectGetMaxY(bbox));
                if (bbox.size.width > bbox.size.height) {
                    end.y = start.y;
                } else {
                    end.x = start.x;
                }
                
                CGContextClip(gc);
                CGContextDrawLinearGradient(gc, gradient, start, end, 0);
                CGGradientRelease(gradient);
            } CGContextRestoreGState(gc);
            
            CGContextAddPath(gc, path);
            CGPathRelease(path);
            
            CGContextSetLineWidth(gc, kLineWidth);
            CGContextSetLineJoin(gc, kCGLineJoinMiter);
            [[UIColor yellowColor] setStroke];
            CGContextStrokePath(gc);
            
        }
        CGContextEndTransparencyLayer(gc);
    }
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

@implementation ViewController {
    
    __weak IBOutlet UIImageView *_imageView;
    
    __weak IBOutlet GraphView *_graphView;
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];


    UIImage *image = [_graphView captureToImage];
    
    CALayer *superLayer = [CALayer layer];
    superLayer.frame = CGRectMake(200, 100, 100, 100);
    superLayer.contents = (__bridge id)(image.CGImage);
    
    
    UIBezierPath *bezierPath = [UIBezierPath bezierPath];
    [bezierPath addLineToPoint:CGPointMake(50, 50)];
    [bezierPath addArcWithCenter:CGPointMake(50, 50) radius:50 startAngle:0 endAngle:M_PI_2 clockwise:YES];
    
    CAShapeLayer *mask = [CAShapeLayer layer];
    mask.bounds = CGRectMake(0, 0, 100, 100);
//    arc.path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(50, 50) radius:50 startAngle:-M_PI/2 endAngle:M_PI/2 clockwise:YES].CGPath;
    mask.path = bezierPath.CGPath;//[UIBezierPath bezierPathWithRect:arc.bounds].CGPath;
    mask.fillColor = [UIColor blackColor].CGColor;
    mask.lineWidth = 10;
    mask.lineCap = kCALineCapRound;
    superLayer.mask = mask;
    
    [self.view.layer addSublayer:superLayer];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
