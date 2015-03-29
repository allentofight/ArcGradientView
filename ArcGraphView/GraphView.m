//
//  GraphView.m
//  ArcGraphView
//
//  Created by ronaldo on 3/29/15.
//  Copyright (c) 2015 ronaldo. All rights reserved.
//

#import "GraphView.h"

@implementation GraphView {
    CGFloat _thickness;
}

typedef void (^voidBlock)(void);
typedef float (^floatfloatBlock)(float);
typedef UIColor * (^floatColorBlock)(float);

-(CGPoint) pointForTrapezoidWithAngle:(float)a andRadius:(float)r  forCenter:(CGPoint)p{
    return CGPointMake(p.x + r*cos(a), p.y + r*sin(a));
}

-(void)drawGradientInContext:(CGContextRef)ctx  startingAngle:(float)a endingAngle:(float)b intRadius:(floatfloatBlock)intRadiusBlock outRadius:(floatfloatBlock)outRadiusBlock withGradientBlock:(floatColorBlock)colorBlock withSubdiv:(int)subdivCount withCenter:(CGPoint)center withScale:(float)scale withIndex:(NSInteger)idx
{
    CGFloat progress = 1.85/2;
    {
#define RGBCOLOR(r,g,b)             [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:1]
        

        CGContextSetFillColorWithColor(ctx, RGBCOLOR(0, 255, 0).CGColor);
        CGRect startEllipseRect = (CGRect) {
            .origin.x = CGRectGetWidth(self.bounds)/2 - _thickness / 2.0f,
            .origin.y = 0.0f,
            .size.width = _thickness,
            .size.height = _thickness
        };
        CGContextAddEllipseInRect(ctx, startEllipseRect);
        CGContextFillPath(ctx);
        
        CGFloat radius = CGRectGetWidth(self.bounds)/2;

        CGFloat radians = (float)((progress * 2.0f * M_PI) - M_PI_2);
        CGFloat thicknessRatio = _thickness/CGRectGetWidth(self.bounds)*2;
        
        CGFloat xOffset = radius * (1.0f + ((1.0f - (thicknessRatio / 2.0f)) * cosf(radians)));
        CGFloat yOffset = radius * (1.0f + ((1.0f - (thicknessRatio / 2.0f)) * sinf(radians)));
        CGPoint endPoint = CGPointMake(xOffset, yOffset);
        
        CGContextSetFillColorWithColor(ctx, [UIColor redColor].CGColor);
        CGRect endEllipseRect = (CGRect) {
            .origin.x = endPoint.x - _thickness / 2.0f,
            .origin.y = endPoint.y - _thickness / 2.0f,
            .size.width = _thickness,
            .size.height = _thickness
        };
        CGContextAddEllipseInRect(ctx, endEllipseRect);
        CGContextFillPath(ctx);
    }


    float angleDelta = (b-a)/subdivCount;
    float fractionDelta = 1.0/subdivCount;

    CGPoint p0,p1,p2,p3, p4,p5;
    float currentAngle=a;
    p4=p0 = [self pointForTrapezoidWithAngle:currentAngle andRadius:intRadiusBlock(0) forCenter:center];
    p5=p3 = [self pointForTrapezoidWithAngle:currentAngle andRadius:outRadiusBlock(0) forCenter:center];
    CGMutablePathRef innerEnveloppe=CGPathCreateMutable(),
    outerEnveloppe=CGPathCreateMutable();
    
    CGPathMoveToPoint(outerEnveloppe, 0, p3.x, p3.y);
    CGPathMoveToPoint(innerEnveloppe, 0, p0.x, p0.y);
    CGContextSaveGState(ctx);
    
    CGContextSetLineWidth(ctx, 1);
    
    for (int i=0;i<subdivCount;i++)
    {
        float fraction = (float)i/subdivCount;
        currentAngle=a+fraction*(b-a);
        CGMutablePathRef trapezoid = CGPathCreateMutable();
        
        p1 = [self pointForTrapezoidWithAngle:currentAngle+angleDelta andRadius:intRadiusBlock(fraction+fractionDelta) forCenter:center];
        p2 = [self pointForTrapezoidWithAngle:currentAngle+angleDelta andRadius:outRadiusBlock(fraction+fractionDelta) forCenter:center];
        
        CGPathMoveToPoint(trapezoid, 0, p0.x, p0.y);
        CGPathAddLineToPoint(trapezoid, 0, p1.x, p1.y);
        CGPathAddLineToPoint(trapezoid, 0, p2.x, p2.y);
        CGPathAddLineToPoint(trapezoid, 0, p3.x, p3.y);
        CGPathCloseSubpath(trapezoid);
        
        CGPoint centerofTrapezoid = CGPointMake((p0.x+p1.x+p2.x+p3.x)/4, (p0.y+p1.y+p2.y+p3.y)/4);
        CGAffineTransform t = CGAffineTransformMakeTranslation(-centerofTrapezoid.x, -centerofTrapezoid.y);
        CGAffineTransform s = CGAffineTransformMakeScale(scale, scale);
        CGAffineTransform concat = CGAffineTransformConcat(t, CGAffineTransformConcat(s, CGAffineTransformInvert(t)));
        CGPathRef scaledPath = CGPathCreateCopyByTransformingPath(trapezoid, &concat);
        
        CGContextAddPath(ctx, scaledPath);
        CGContextSetFillColorWithColor(ctx,colorBlock(fraction).CGColor);
        CGContextSetStrokeColorWithColor(ctx, colorBlock(fraction).CGColor);
        CGContextSetMiterLimit(ctx, 0);
        
        CGContextDrawPath(ctx, kCGPathFillStroke);
        
        CGPathRelease(trapezoid);
        p0=p1;
        p3=p2;
    }
    CGContextSetLineWidth(ctx, 10);
    CGContextSetLineJoin(ctx, kCGLineJoinRound);
    CGContextSetStrokeColorWithColor(ctx, [UIColor clearColor].CGColor);
    CGContextAddPath(ctx, outerEnveloppe);
    CGContextAddPath(ctx, innerEnveloppe);
    CGContextMoveToPoint(ctx, p0.x, p0.y);
    CGContextAddLineToPoint(ctx, p3.x, p3.y);
    CGContextMoveToPoint(ctx, p4.x, p4.y);
    CGContextAddLineToPoint(ctx, p5.x, p5.y);
    CGContextStrokePath(ctx);
    
}

- (void)awakeFromNib{
    self.backgroundColor = [UIColor clearColor];
    _thickness = 30;
}

-(void)drawRect:(CGRect)rect {
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGRect r = self.bounds;
    if (r.size.width > r.size.height)
        r.size.width=r.size.height;
    else r.size.height=r.size.width;
    float radius=r.size.width/2;
    
//    for (NSInteger idx = 0; idx < 350; idx++) {
    [self drawGradientInContext:ctx  startingAngle:-M_PI/2 endingAngle:1.5*M_PI*0.9 intRadius:^float(float f) {
        return radius-_thickness;
    } outRadius:^float(float f) {
        return radius;
    } withGradientBlock:^UIColor *(float f) {
        float sr = 255, sg = 0, sb = 0;
        float er = 0, eg = 255, eb = 0;
        return [UIColor colorWithRed:(f*sr+(1-f)*er)/255. green:(f*sg+(1-f)*eg)/255. blue:(f*sb+(1-f)*eb)/255. alpha:1];
    } withSubdiv:1024 withCenter:CGPointMake(CGRectGetMidX(r), CGRectGetMidY(r)) withScale:1 withIndex:0];
//    }
    

    
}


@end
