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
    self.view.backgroundColor = [UIColor redColor];
    CAShapeLayer *arc = [CAShapeLayer layer];
    CGFloat width = CGRectGetWidth(_imageView.frame)/2;
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(width, width) radius:width-15 startAngle:-M_PI_2 endAngle:1.5*M_PI*0.9 clockwise:YES];

    arc.path = path.CGPath;
//    arc.position = CGPointMake(CGRectGetMidX(self.view.frame)-radius, CGRectGetMidY(self.view.frame)-radius);
//    arc.position = CGPointMake(CGRectGetWidth(_imageView.bounds)/2, CGRectGetHeight(_imageView.bounds)/2);
    arc.frame = _imageView.frame;
    arc.fillColor = [UIColor clearColor].CGColor;
    arc.strokeColor = [UIColor purpleColor].CGColor;
    arc.lineWidth = 30.0f;
    arc.cornerRadius = 3.0f;
    arc.lineCap = kCALineCapRound;
    
    
    UIImage *image = [_graphView captureToImage];
//    UIView *testView = [[UIView alloc] initWithFrame:_imageView.frame];
//    _imageView.frame = _imageView.bounds;
//    [testView addSubview:_imageView];
//    [self.view addSubview:testView];
//    testView.layer.mask = arc;
    
//    [self.view addSubview:testView];
    
    
    self.view.layer.mask = arc;
    _imageView.image = image;
//    subView.backgroundColor = [UIColor colorWithPatternImage:image];
//    subView.layer.mask = arc;
//    self.view.layer.mask = arc;
    
//    _imageView.layer.mask = arc;
    _graphView.hidden = YES;
//
    return;
#define degreesToRadians(x) ((x) * M_PI / 180.0)
    

//    _graphView.hidden = YES;


    UIBezierPath *bezierPath = [UIBezierPath bezierPathWithArcCenter:CGPointMake(width, width) radius:width-30 startAngle:-M_PI_2 endAngle:1.5*M_PI*0.9 clockwise:YES];

    {
        CGFloat thicknessRatio = 30.0/CGRectGetWidth(_graphView.bounds)*2;
        CGFloat radius = CGRectGetWidth(_graphView.bounds)/2;
        CGFloat radians = (float)((0.5 * 2.0f * M_PI) - M_PI_2);
        CGFloat xOffset = radius * (1.0f + ((1.0f - (thicknessRatio / 2.0f)) * cosf(radians)));
        CGFloat yOffset = radius * (1.0f + ((1.0f - (thicknessRatio / 2.0f)) * sinf(radians)));
        CGPoint endPoint = CGPointMake(xOffset, yOffset);
        
//        [bezierPath addArcWithCenter:endPoint radius:30 startAngle:0 endAngle:M_2_PI clockwise:YES];
    }
    
    
    [bezierPath closePath];
    
    CAShapeLayer *mask = [CAShapeLayer layer];
    mask.frame = CGRectMake(0, 0, 300, 300);
    mask.path = bezierPath.CGPath;//[UIBezierPath bezierPathWithRect:arc.bounds].CGPath;
//    mask.fillColor = [UIColor blackColor].CGColor;
    mask.lineWidth = 30;
    mask.cornerRadius = 3.0f;
    mask.lineCap = kCALineCapRound;
    
    _imageView.layer.mask = mask;
    _graphView.hidden = YES;
    
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
