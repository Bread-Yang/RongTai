//
//  WLLineChart.m
//  WLLineChart-2.0
//
//  Created by William-zhang on 15/7/7.
//  Copyright (c) 2015年 William-zhang. All rights reserved.
//

#import "WLLineChart.h"
#import "WLXAxis.h"
#import "WLYAxis.h"

@interface WLLineChart ()
{
    WLXAxis* _xAxis;
    WLYAxis* _yAxis;
    UIScrollView* _scroll;
}
@end

@implementation WLLineChart

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
        self.frame = frame;
    }
    return self;
}

#pragma mark - 初始化
-(void)setUp
{
    _scroll = [[UIScrollView alloc]init];
    _xAxis = [[WLXAxis alloc]init];
    _yAxis = [[WLYAxis alloc]init];
    _xWidth = 400;
    [self addSubview:_yAxis];
    [self addSubview:_scroll];
    [_scroll addSubview:_xAxis];
    _scroll.showsHorizontalScrollIndicator = NO;
    _scroll.showsVerticalScrollIndicator = NO;
    _scroll.bounces = NO;
}

#pragma mark - set/get方法
-(void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    CGFloat w = self.frame.size.width;
    CGFloat h = self.frame.size.height;
    _yAxis.frame = CGRectMake(0, 0, w, h);
    _yAxis.xHeight = 0.1*h;
    _xAxis.frame = CGRectMake(0, 0, _xWidth, h);
    _scroll.frame = CGRectMake(0.1*w, 0, 0.9*w, h);
    _scroll.contentSize = CGSizeMake(_xWidth, h);
}

#pragma mark x轴
-(void)setXWidth:(CGFloat)xWidth
{
    _xWidth = xWidth;
    CGRect f = _xAxis.frame;
    f.size.width = _xWidth;
    _xAxis.frame = f;
    _scroll.contentSize = CGSizeMake(_xWidth, _scroll.contentSize.height);
}

-(void)setXColor:(UIColor *)xColor
{
    _xAxis.xColor = xColor;
}

-(UIColor *)xColor
{
    return _xAxis.xColor;
}

-(void)setXLineWidth:(CGFloat)xLineWidth
{
    _xAxis.lineWidth = xLineWidth;
}

-(CGFloat)xLineWidth
{
    return _xAxis.xLineWidth;
}

-(void)setXSection:(CGPoint)xSection
{
    _xAxis.xSection = xSection;
}

-(CGPoint)xSection
{
    return _xAxis.xSection;
}

-(void)setXUnit:(NSString *)xUnit
{
    _xAxis.xUnit = xUnit;
}

-(NSString *)xUnit
{
    return _xAxis.xUnit;
}

-(void)setXUnitFont:(UIFont *)xUnitFont
{
    _xAxis.xUnitFont = xUnitFont;
}

-(UIFont *)xUnitFont
{
    return _xAxis.xUnitFont;
}

-(void)setXValueFont:(UIFont *)xValueFont
{
    _xAxis.xValueFont = xValueFont;
}

-(UIFont *)xValueFont
{
    return _xAxis.xValueFont;
}

-(void)setXValues:(NSArray *)xValues
{
    _xAxis.xValues = xValues;
}

-(NSArray *)xValues
{
    return _xAxis.xValues;
}

-(void)setXAxisHidden:(BOOL)xAxisHidden
{
    _xAxis.xAxisHidden = xAxisHidden;
}

-(BOOL)xAxisHidden
{
    return _xAxis.xAxisHidden;
}

#pragma mark y轴
-(void)setYAxisHidden:(BOOL)yAxisHidden
{
    _yAxis.yAxisHidden = yAxisHidden;
}

-(BOOL)yAxisHidden
{
    return _yAxis.yAxisHidden;
}

-(void)setYColor:(UIColor *)yColor
{
    _yAxis.yColor = yColor;
}

-(UIColor *)yColor
{
    return _yAxis.yColor;
}

-(void)setYLineWidth:(CGFloat)yLineWidth
{
    _yAxis.yLineWidth = yLineWidth;
}

-(CGFloat)yLineWidth
{
    return _yAxis.yLineWidth;
}

-(void)setYSection:(CGPoint)ySection
{
    _xAxis.ySection = ySection;
}

-(CGPoint)ySection
{
    return _xAxis.ySection;
}

-(void)setYUnit:(NSString *)yUnit
{
    _yAxis.yUnit = yUnit;
}

-(NSString *)yUnit
{
    return _yAxis.yUnit;
}

-(void)setYUnitFont:(UIFont *)yUnitFont
{
    _yAxis.yUnitFont = yUnitFont;
}

-(UIFont *)yUnitFont
{
    return _yAxis.yUnitFont;
}

-(void)setYValueFont:(UIFont *)yValueFont
{
    _yAxis.yValueFont = yValueFont;
}

-(UIFont *)yValueFont
{
    return _yAxis.yValueFont;
}

-(void)setYValues:(NSArray *)yValues
{
    _yAxis.yValues = yValues;
}

-(NSArray *)yValues
{
    return _yAxis.yValues;
}

#pragma mark 对齐线
-(void)setShowXRuler:(BOOL)showXRuler
{
    _xAxis.showXRuler = showXRuler;
}

-(BOOL)showXRuler
{
    return _xAxis.showXRuler;
}

-(void)setShowYRuler:(BOOL)showYRuler
{
    _yAxis.showYRuler = showYRuler;
}

-(BOOL)showYRuler
{
    return _yAxis.showYRuler;
}

-(void)setRulerColor:(UIColor *)rulerColor
{
    _yAxis.rulerColor = rulerColor;
    _xAxis.rulerColor = rulerColor;
}

-(UIColor *)rulerColor
{
    return _xAxis.rulerColor;
}

-(void)setRulerWidth:(CGFloat)rulerWidth
{
    _xAxis.rulerWidth = rulerWidth;
    _yAxis.rulerWidth = rulerWidth;
}

-(CGFloat)rulerWidth
{
    return _xAxis.rulerWidth;
}

#pragma mark 折线
-(void)setShowPiont:(BOOL)showPiont
{
    _xAxis.showPiont = showPiont;
}

-(BOOL)showPiont
{
    return _xAxis.showPiont;
}

-(void)setIsPointDashed:(BOOL)isPointDashed
{
    _xAxis.isPointDashed = isPointDashed;
}

-(BOOL)isPointDashed
{
    return _xAxis.isPointDashed;
}

-(void)setLineColor:(UIColor *)lineColor
{
    _xAxis.lineColor = lineColor;
}

-(UIColor *)lineColor
{
   return _xAxis.lineColor;
}

-(void)setLineWidth:(CGFloat)lineWidth
{
    _xAxis.lineWidth = lineWidth;
}

-(CGFloat)lineWidth
{
    return _xAxis.lineWidth;
}

-(void)setPoints:(NSArray *)points
{
    _xAxis.points = points;
}

-(NSArray *)points
{
    return _xAxis.points;
}




@end
