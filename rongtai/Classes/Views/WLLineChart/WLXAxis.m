//
//  WLXAxis.m
//  WLLineChart-2.0
//
//  Created by William-zhang on 15/7/7.
//  Copyright (c) 2015年 William-zhang. All rights reserved.
//

#import "WLXAxis.h"

#if __IPHONE_OS_VERSION_MIN_REQUIRED >= 70000
#define JY_TEXT_SIZE(text, font) [text length] > 0 ? [text sizeWithAttributes : @{ NSFontAttributeName : font }] : CGSizeZero;
#define JY_DRAW_TEXT_IN_RECT(text, rect, font) [text drawInRect : rect withAttributes : @{ NSFontAttributeName:font }];
#else
#define JY_TEXT_SIZE(text, font) [text length] > 0 ? [text sizeWithFont : font] : CGSizeZero;
#define JY_DRAW_TEXT_IN_RECT(text, rect, font) [text drawInRect : rect withFont : font];

#endif

@interface WLXAxis ()
{
    CGFloat _lineLeftDit;
    CGFloat _lineRightDit;
    CGFloat _hScale;
}

@end

@implementation WLXAxis


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
    _lineLeftDit = 15;
    _lineRightDit = 10;
    _hScale = 0.9;
    //-------- x轴
    _xAxisHidden = NO;
    _xColor = [UIColor blackColor];
    _xLineWidth = 1;
    _xUnitFont = [UIFont systemFontOfSize:14];
    _xValueFont = [UIFont systemFontOfSize:12];
    _xValues = @[@"5.1",@"5.2",@"5.3",@"5.4",@"5.5",@"5.6"];
    
    //-------- 对齐线
    _showXRuler = YES;
    _rulerColor = [UIColor lightGrayColor];
    _rulerWidth = 0.5;
    
    //--------- 折线
    _showPiont = YES;
    _isPointDashed = YES;
    _lineColor = [UIColor blueColor];
    _lineWidth = 2;
    NSValue* p1 = [NSValue valueWithCGPoint:CGPointMake(0, 30)];
    NSValue* p2 = [NSValue valueWithCGPoint:CGPointMake(20, 50)];
    NSValue* p3 = [NSValue valueWithCGPoint:CGPointMake(40, 100)];
    NSValue* p4 = [NSValue valueWithCGPoint:CGPointMake(60, 10)];
    NSValue* p5 = [NSValue valueWithCGPoint:CGPointMake(80, 50)];
    NSValue* p6 = [NSValue valueWithCGPoint:CGPointMake(100, 30)];
    _points = @[p1,p2,p3,p4,p5,p6];
    _ySection = CGPointMake(0, 150);
    _xSection = CGPointMake(0, 120);
}

#pragma mark - 点的值转换为坐标
-(CGPoint)postionByPoint:(CGPoint)point
{
    CGFloat xScale = (point.x-_xSection.x)/(_xSection.y-_xSection.x);
    point.x = _lineLeftDit+(self.frame.size.width -_lineLeftDit-_lineRightDit)*xScale;
    CGFloat yScale = (point.y - _ySection.x)/(_ySection.y-_ySection.x);
    point.y = 8+(_hScale*self.frame.size.height-8)*(1-yScale);
    return point;
}

#pragma mark - drawRect
- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    CGFloat w = self.frame.size.width;
    CGFloat h = self.frame.size.height;
    CGContextRef context = UIGraphicsGetCurrentContext();

    
    //x轴
    
    //  x轴线
    if (!_xAxisHidden) {
        [_xColor setStroke];
        CGContextMoveToPoint(context, 0, _hScale*h);
        CGContextAddLineToPoint(context, w, _hScale*h);
        CGContextStrokePath(context);
    }
    
    //  x轴数值
    if (_xValues.count > 0) {
        CGFloat dit = (w-_lineLeftDit-_lineRightDit)/_xValues.count;
        for (int i = 0; i<_xValues.count; i++) {
            NSString* value = _xValues[i];
            CGSize valueSize = JY_TEXT_SIZE(value, _xValueFont);
            JY_DRAW_TEXT_IN_RECT(value, CGRectMake(_lineLeftDit+dit*i-valueSize.width/2, _hScale*h+((1-_hScale)*h-valueSize.height)/2, valueSize.width, valueSize.height), _xValueFont);
        }
        
        //x轴单位
        if (_xUnit.length>0) {
            CGSize unitSize = JY_TEXT_SIZE(_xUnit, _xUnitFont);
            JY_DRAW_TEXT_IN_RECT(_xUnit, CGRectMake(w-unitSize.width-1, _hScale*h+((1-_hScale)*h-unitSize.height)/2, unitSize.width, unitSize.height), _xUnitFont);
        }
        
        //对齐线
        if (_showXRuler) {
            [_rulerColor setStroke];
            CGContextSetLineWidth(context, _rulerWidth);
            for (int i = 0; i<_xValues.count+1; i++) {
                CGFloat x = _lineLeftDit+i*dit;
                CGContextMoveToPoint(context, x, 0);
                CGContextAddLineToPoint(context, x, _hScale*h);
                CGContextStrokePath(context);
            }
        }
        
        //对折线
        if (_points.count>0) {
            [_lineColor setStroke];
            CGContextSetLineWidth(context, _lineWidth);
            for (int i = 0; i<_points.count; i++) {
                NSValue* v = _points[i];
                CGPoint p = [self postionByPoint:[v CGPointValue]];
//                NSLog(@"点%d:%@",i,NSStringFromCGPoint(p));
                if (i+1<_points.count) {
                    CGContextMoveToPoint(context, p.x, p.y);
                    NSValue* v2 = _points[i+1];
                    CGPoint p2 = [self postionByPoint:[v2 CGPointValue]];
                    CGContextAddLineToPoint(context, p2.x, p2.y);
                    CGContextStrokePath(context);
                }
            }
        }
        
        //点
        if (_showPiont) {
            for (int i = 0; i<_points.count; i++) {
                CGContextSetLineWidth(context, _lineWidth);
                [_lineColor set];
                NSValue* v = _points[i];
                CGPoint p = [self postionByPoint:[v CGPointValue]];
                if (_showPiont) {
                    CGFloat r = _lineWidth*1.6+2;
                    CGContextFillEllipseInRect(context, CGRectMake(p.x-r/2, p.y-r/2, r, r));
                    if (_isPointDashed) {
                        [[UIColor whiteColor] setFill];
                        CGContextFillEllipseInRect(context, CGRectMake(p.x-r/4, p.y-r/4, r/2, r/2));
                    }
                }
            }
        }
    }
}



#pragma mark - set方法
-(void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    [self setNeedsDisplay];
}

#pragma mark 折线

-(void)setXSection:(CGPoint)xSection
{
    _xSection = xSection;
    [self setNeedsDisplay];
}

-(void)setYSection:(CGPoint)ySection
{
    _ySection = ySection;
    [self setNeedsDisplay];
}

-(void)setShowPiont:(BOOL)showPiont
{
    _showPiont = showPiont;
    [self setNeedsDisplay];
}

-(void)setIsPointDashed:(BOOL)isPointDashed
{
    _isPointDashed = isPointDashed;
    [self setNeedsDisplay];
}

-(void)setLineColor:(UIColor *)lineColor
{
    _lineColor = lineColor;
    [self setNeedsDisplay];
}

-(void)setLineWidth:(CGFloat)lineWidth
{
    _lineWidth = lineWidth;
    [self setNeedsDisplay];
}

-(void)setPoints:(NSArray *)points
{
    _points = points;
    [self setNeedsDisplay];
}


#pragma mark x轴

-(void)setXAxisHidden:(BOOL)xAxisHidden
{
    _xAxisHidden = xAxisHidden;
    [self setNeedsDisplay];
}

-(void)setXColor:(UIColor *)xColor
{
    _xColor = xColor;
    [self setNeedsDisplay];
}

-(void)setXLineWidth:(CGFloat)xLineWidth
{
    _xLineWidth = xLineWidth;
    [self setNeedsDisplay];
}


-(void)setXUnit:(NSString *)xUnit
{
    _xUnit = xUnit;
    [self setNeedsDisplay];
}

-(void)setXUnitFont:(UIFont *)xUnitFont
{
    _xUnitFont = xUnitFont;
    [self setNeedsDisplay];
}

-(void)setXValueFont:(UIFont *)xValueFont
{
    _xValueFont = xValueFont;
    [self setNeedsDisplay];
}

-(void)setXValues:(NSArray *)xValues
{
    _xValues = xValues;
    [self setNeedsDisplay];
}

#pragma mark 对齐线
-(void)setShowXRuler:(BOOL)showXRuler
{
    _showXRuler = showXRuler;
    [self setNeedsDisplay];
}

-(void)setRulerColor:(UIColor *)rulerColor
{
    _rulerColor = rulerColor;
    [self setNeedsDisplay];
}

-(void)setRulerWidth:(CGFloat)rulerWidth
{
    _rulerWidth = rulerWidth;
    [self setNeedsDisplay];
}














@end
