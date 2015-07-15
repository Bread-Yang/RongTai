//
//  WLDoughnutStatsView.m
//  WLDoughnutStatsView
//
//  Created by William-zhang on 15/7/6.
//  Copyright (c) 2015年 William-zhang. All rights reserved.
//

#import "WLDoughnutStatsView.h"

@implementation WLDoughnutStatsView

-(instancetype)init
{
    if (self = [super init]) {
        [self setUp];
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        [self setUp];
    }
    return self;
}

-(instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self setUp];
        _r = MIN(frame.size.width, frame.size.height)/2;
    }
    return self;
}

#pragma mark - 初始化
-(void)setUp
{
    self.backgroundColor = [UIColor clearColor];
    _colors = @[[UIColor colorWithRed:1 green:0 blue:0 alpha:0.6],[UIColor colorWithRed:0 green:1 blue:0 alpha:0.6],[UIColor colorWithRed:0 green:0 blue:1 alpha:0.6],[UIColor colorWithRed:0 green:1 blue:1 alpha:0.6]];
    _percents = @[@0.1,@0.2,@0.3,@0.4];
    _doughnutDistance = 20;
    _doughnutWidth = 20;
    _r = 100;
}

#pragma mark - set方法
-(void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    _r = MIN(frame.size.width, frame.size.height)/2;
    [self setNeedsDisplay];
}

-(void)setColors:(NSArray *)colors
{
    _colors = colors;
    [self setNeedsDisplay];
}

-(void)setPercents:(NSArray *)percents
{
    _percents = percents;
    [self setNeedsDisplay];
}

-(void)setDoughnutDistance:(CGFloat)doughnutDistance
{
    _doughnutDistance = doughnutDistance;
    [self setNeedsDisplay];
}

-(void)setDoughnutWidth:(CGFloat)doughnutWidth
{
    _doughnutWidth = doughnutWidth;
    [self setNeedsDisplay];
}

-(void)setR:(CGFloat)r
{
    _r = r;
    [self setNeedsDisplay];
}

#pragma mark - drawRect
- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGPoint center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
    CGFloat disAngle = _doughnutDistance/(M_PI*2*_r);
    CGFloat start = M_PI*1.5;
    for (int i = 0; i < _percents.count; i++) {
        UIColor* color = _colors[i];
        [color setStroke];
        CGContextSetLineWidth(context, _doughnutWidth);
        CGFloat percent = [_percents[i] floatValue];
        CGFloat angle = M_PI*2*percent;
        CGContextAddArc(context, center.x, center.y, _r-_doughnutWidth/2, start, start+angle-disAngle, 0) ;
        CGContextStrokePath(context);
        start = start+angle;
    }
}
























@end
