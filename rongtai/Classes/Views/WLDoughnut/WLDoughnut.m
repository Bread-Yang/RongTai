//
//  WLDoughnut.m
//  WLDoughnut
//
//  Created by William-zhang on 15/6/4.
//  Copyright (c) 2015年 William-zhang. All rights reserved.
//

#import "WLDoughnut.h"

@interface WLDoughnut ()
{
    CAShapeLayer* _finishLayer;
}
@end

@implementation WLDoughnut

-(instancetype)init
{
    if (self = [super init]) {
        [self setUp];
    }
    return self;
}

-(instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self setUp];
        _r = frame.size.width/2;
    }
    return self;
}

#pragma mark - 初始化设置
-(void)setUp
{
    self.backgroundColor = [UIColor clearColor];
    _unFinishColor = [UIColor lightGrayColor];
    _finishColor = [UIColor cyanColor];
    _r = 50;
    _lineWidth = 5;
    _percent = 0.36;
    _animationTime = 1;
}

#pragma mark - set方法
-(void)setR:(CGFloat)r
{
    _r = r;
    [self setNeedsDisplay];
}

-(void)setUnFinishColor:(UIColor *)unFinishColor
{
    _unFinishColor = unFinishColor;
    [self setNeedsDisplay];
}

-(void)setFinishColor:(UIColor *)finishColor
{
    _finishColor = finishColor;
    [self setNeedsDisplay];
}

-(void)setPercent:(CGFloat)percent
{
    _percent = percent;
    [self setNeedsDisplay];
}

-(void)setLineWidth:(CGFloat)lineWidth
{
    _lineWidth = lineWidth;
    [self setNeedsDisplay];
}

#pragma mark - 重写drawRect
- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    CGContextRef context = UIGraphicsGetCurrentContext();
    //中心点，圆心
    CGPoint center = CGPointMake(self.bounds.size.width/2, self.bounds.size.width/2);
    //未完成的比例计算出灰色部分角度大小
    CGFloat pAngle = (1-_percent)*M_PI*2;
    
    //绘制未完成的圆
    [_unFinishColor setStroke];
    CGContextSetLineWidth(context, _lineWidth);
    CGContextAddArc(context, center.x, center.y, _r-_lineWidth/2, M_PI*1.5, M_PI*1.5-0.0001, 0) ;
    CGContextStrokePath(context);
    
    //绘制完成的弧形
    [_finishLayer removeFromSuperlayer];
    UIBezierPath* finishPath = [UIBezierPath bezierPathWithArcCenter:center radius:_r-_lineWidth/2 startAngle:M_PI*1.5 endAngle:M_PI*1.5-0.0001-pAngle clockwise:YES];
    _finishLayer = [CAShapeLayer layer];
    _finishLayer.lineWidth = _lineWidth;
    _finishLayer.fillColor = self.backgroundColor.CGColor;
    _finishLayer.strokeEnd = 0.0;
    _finishLayer.strokeColor = _finishColor.CGColor;
    _finishLayer.lineJoin = kCALineJoinBevel;
    _finishLayer.path = finishPath.CGPath;
    
    CABasicAnimation *pathAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    pathAnimation.duration = _animationTime;
    pathAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    pathAnimation.fromValue = [NSNumber numberWithFloat:0.0f];
    pathAnimation.toValue = [NSNumber numberWithFloat:1.0f];
    pathAnimation.autoreverses = NO;
    [_finishLayer addAnimation:pathAnimation forKey:@"lineLayerAnimation"];
    _finishLayer.strokeEnd = 1.0;
    [self.layer addSublayer:_finishLayer];
}


@end
