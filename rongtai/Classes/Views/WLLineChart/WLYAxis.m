//
//  WLYAxis.m
//  WLLineChart-2.0
//
//  Created by William-zhang on 15/7/7.
//  Copyright (c) 2015年 William-zhang. All rights reserved.
//

#import "WLYAxis.h"

#if __IPHONE_OS_VERSION_MIN_REQUIRED >= 70000
#define JY_TEXT_SIZE(text, font) [text length] > 0 ? [text sizeWithAttributes : @{ NSFontAttributeName : font }] : CGSizeZero;
#define JY_DRAW_TEXT_IN_RECT(text, rect, font) [text drawInRect : rect withAttributes : @{ NSFontAttributeName:font }];
#else
#define JY_TEXT_SIZE(text, font) [text length] > 0 ? [text sizeWithFont : font] : CGSizeZero;
#define JY_DRAW_TEXT_IN_RECT(text, rect, font) [text drawInRect : rect withFont : font];

#endif

@implementation WLYAxis

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
    }
    return self;
}

#pragma mark - 初始化
-(void)setUp
{
    self.backgroundColor = [UIColor clearColor];
    _yValues = @[@"0",@"2",@"4",@"6",@"8"];
    _yColor = [UIColor blackColor];
    _yAxisHidden = NO;
    _yLineWidth = 1;
    _yUnitFont = [UIFont systemFontOfSize:14];
    _yValueFont = [UIFont systemFontOfSize:12];
    _xHeight = 20;
    _showYRuler = YES;
    _rulerColor = [UIColor lightGrayColor];
    _rulerWidth = 0.5;
}

#pragma mark - drawRect
- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    CGFloat lineDis = 8;
    CGFloat w = self.frame.size.width;
    CGFloat h = self.frame.size.height;
    CGFloat valueWidth = 0.1*w - _yLineWidth;
    CGFloat lineHeight = h - _xHeight;
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //画y轴线
    if (!_yAxisHidden) {
        [_yColor setStroke];
        CGContextSetLineWidth(context, _yLineWidth);
        CGContextMoveToPoint(context, valueWidth, 0);
        CGContextAddLineToPoint(context, valueWidth, lineHeight);
        CGContextStrokePath(context);
    }
    
    //画y轴的值
    if (_yValues.count>0) {
        CGFloat unitHeight = 20;
        
        //画单位
        
        //若单位有设置，则根据字体来预留单位显示位置，若没有设置，预留20
        if (_yUnit.length >0) {
            CGSize unitSize = JY_TEXT_SIZE(_yUnit, _yUnitFont);
            unitHeight = unitSize.height;
            JY_DRAW_TEXT_IN_RECT(_yUnit, CGRectMake((valueWidth-unitSize.width)/2, 0, unitSize.width, unitSize.height), _yUnitFont);
        }
        
        //画数值
        CGFloat dit = (lineHeight-lineDis)/_yValues.count;
        for (int i = 0; i<_yValues.count; i++) {
            NSString* value = _yValues[i];
            CGSize valueSize = JY_TEXT_SIZE(value, _yValueFont);
            JY_DRAW_TEXT_IN_RECT(value, CGRectMake((valueWidth-valueSize.width)/2, lineHeight-valueSize.height/2-i*dit, valueSize.width, valueSize.height), _yValueFont);
//            [[UIColor colorWithRed:0 green:0 blue:1.0 alpha:1-i*0.1] setStroke];
//            CGContextAddRect(context, CGRectMake((valueWidth-valueSize.width)/2, lineHeight-valueSize.height/2-i*dit, valueSize.width, valueSize.height));
        }
//        CGContextStrokePath(context);
        
        //画对齐线
        if (_showYRuler) {
            for (int i = 0; i<_yValues.count+1; i++) {
                CGFloat h = lineHeight- i*dit;
                [_rulerColor setStroke];
                CGContextSetLineWidth(context, _rulerWidth);
                CGContextMoveToPoint(context, valueWidth, h);
                CGContextAddLineToPoint(context, w, h);
                CGContextStrokePath(context);
            }
            
        }
    }
}

#pragma mark - set方法
-(void)setYAxisHidden:(BOOL)yAxisHidden
{
    _yAxisHidden = yAxisHidden;
    [self setNeedsDisplay];
}

-(void)setYColor:(UIColor *)yColor
{
    _yColor = yColor;
    [self setNeedsDisplay];
}

-(void)setYLineWidth:(CGFloat)yLineWidth
{
    _yLineWidth = yLineWidth;
    [self setNeedsDisplay];
}

-(void)setYUnit:(NSString *)yUnit
{
    _yUnit = yUnit;
    [self setNeedsDisplay];
}

-(void)setYUnitFont:(UIFont *)yUnitFont
{
    _yUnitFont = yUnitFont;
    [self setNeedsDisplay];
}

-(void)setYValueFont:(UIFont *)yValueFont
{
    _yValueFont = yValueFont;
    [self setNeedsDisplay];
}

-(void)setYValues:(NSArray *)yValues
{
    _yValues = yValues;
    [self setNeedsDisplay];
}

-(void)setXHeight:(CGFloat)xHeight
{
    _xHeight = xHeight;
    [self setNeedsDisplay];
}

-(void)setRulerWidth:(CGFloat)rulerWidth
{
    _rulerWidth = rulerWidth;
    [self setNeedsDisplay];
}

-(void)setRulerColor:(UIColor *)rulerColor
{
    _rulerColor = rulerColor;
    [self setNeedsDisplay];
}

-(void)setShowYRuler:(BOOL)showYRuler
{
    _showYRuler = showYRuler;
    [self setNeedsDisplay];
}

-(void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    [self setNeedsDisplay];
}










@end
