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

@implementation ViewController {
    
    __weak IBOutlet UIImageView *_imageView;
    
    __weak IBOutlet GraphView *_graphView;
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    CAShapeLayer *arc = [CAShapeLayer layer];
    CGFloat width = CGRectGetWidth(_imageView.frame)/2;
    UIImage *image = [_graphView captureToImage];
    _imageView.image = image;
    CGFloat startRadian = -M_PI_2;
    CGFloat endRadian = 1.5*M_PI*0.9;
    NSString *documentdir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *frameDirectory = [documentdir stringByAppendingPathComponent:@"frames"];
    
    [[NSFileManager defaultManager] removeItemAtPath:frameDirectory error:nil];
    [[NSFileManager defaultManager] createDirectoryAtPath:frameDirectory withIntermediateDirectories:YES attributes:nil error:nil];
    

    
    for (NSInteger idx = 1; idx < 343; idx++) {
        CGFloat end = startRadian+(endRadian-startRadian)*idx/343;
        UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(width, width) radius:width-15 startAngle:startRadian endAngle:end clockwise:YES];
        arc.path = path.CGPath;
        arc.frame = _imageView.bounds;
        arc.fillColor = [UIColor clearColor].CGColor;
        arc.strokeColor = [UIColor purpleColor].CGColor;
        arc.lineWidth = 30.0f;
        arc.cornerRadius = 3.0f;
        arc.lineCap = kCALineCapRound;
        _imageView.layer.mask = arc;
        
        UIImage *image = [_imageView captureToImage];
        
        CGSize drawSize = CGSizeMake(100, 100);
        UIGraphicsBeginImageContextWithOptions(drawSize, NO, [UIScreen mainScreen].scale);
        [image drawInRect:CGRectMake(0, 0, 100, 100)];
        UIImage *captureImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        NSString *imagePath = [frameDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"slowswing%ld@2x.png", (long)idx-1]];
        [UIImagePNGRepresentation(captureImage) writeToFile:imagePath atomically:YES];
        
        if (idx == 342) {
            NSLog(@"imagePath = %@", imagePath);
        }
        
        
    }
    


    
    _graphView.hidden = YES;
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
