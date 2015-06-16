//
//  WLPolar.m
//  JYRadarChartDemo
//
//  Created by William-zhang on 15/6/4.
//  Copyright (c) 2015年 William-zhang. All rights reserved.
//

#import "WLPolar.h"

#define PADDING 13
#define LEGEND_PADDING 3
#define ATTRIBUTE_TEXT_SIZE 10
#define COLOR_HUE_STEP 5
#define MAX_NUM_OF_COLOR 17

#if __IPHONE_OS_VERSION_MIN_REQUIRED >= 70000
#define JY_TEXT_SIZE(text, font) [text length] > 0 ? [text sizeWithAttributes : @{ NSFontAttributeName : font }] : CGSizeZero;
#define JY_DRAW_TEXT_AT_POINT(text, point, font) [text drawAtPoint : point withAttributes : @{ NSFontAttributeName:font }];
#define JY_DRAW_TEXT_IN_RECT(text, rect, font) [text drawInRect : rect withAttributes : @{ NSFontAttributeName:font }];
#else
#define JY_TEXT_SIZE(text, font) [text length] > 0 ? [text sizeWithFont : font] : CGSizeZero;
#define JY_DRAW_TEXT_AT_POINT(text, point, font) [text drawAtPoint : point withFont : font];
#define JY_DRAW_TEXT_IN_RECT(text, rect, font) [text drawInRect : rect withFont : font];

#endif

@interface WLPolar ()
{
    NSUInteger _numOfV;  //坐标轴数量，又赋值的数据源数据决定
    CGPoint _centerPoint;  //中心点
    NSArray* _colorArr; //颜色数组
}

@end

@implementation WLPolar

-(instancetype)init
{
    self = [super init];
    if (self) {
        [self setDefaultValues];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setDefaultValues];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setDefaultValues];
    }
    return self;
}

#pragma mark - 设置默认值，用于初始化
- (void)setDefaultValues {
    self.backgroundColor = [UIColor whiteColor];
    _maxValue = 100.0;
    _centerPoint = CGPointMake(self.bounds.size.width / 2, self.bounds.size.height / 2);
    _r = MIN(self.frame.size.width / 2 - PADDING, self.frame.size.height / 2 - PADDING);
    _steps = 1;
    _drawPoints = NO;
    _showStepText = NO;
    _fillArea = YES;
    _minValue = 0;
    _colorOpacity = 1.0;
    _backgroundLineColorRadial = [UIColor darkGrayColor];
    _backgroundFillColor = [UIColor whiteColor];
    _attributes = @[@"you", @"should", @"set", @"these", @"data", @"titles,",
                    @"this", @"is", @"just", @"a", @"placeholder"];
    _scaleFont = [UIFont systemFontOfSize:ATTRIBUTE_TEXT_SIZE];
}

#pragma mark - 设置颜色
- (void)setColors:(NSArray *)colors {
    _colorArr = colors;
}

#pragma mark - 设置数据源
- (void)setDataSeries:(NSArray *)dataSeries {
    _dataSeries = dataSeries;
    _numOfV = [_dataSeries[0] count];
}


- (void)drawRect:(CGRect)rect {
    NSArray *colors = _colorArr;
    CGFloat radPerV = M_PI * 2 / _numOfV;
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    
    //绘制填充背景颜色
    [_backgroundFillColor setFill];
    CGContextMoveToPoint(context, _centerPoint.x, _centerPoint.y - _r);
    for (int i = 1; i <= _numOfV; ++i) {
        CGContextAddArc(context, _centerPoint.x, _centerPoint.y, rect.size.width/3, 0, M_PI*2, 0);
    }
    CGContextFillPath(context);
    
    //绘制圆形
    [[UIColor lightGrayColor] setStroke];
    CGContextSaveGState(context);
    CGFloat r = _r/_steps;
    for (int step = 1; step <= _steps; step++) {
        CGContextAddArc(context, _centerPoint.x, _centerPoint.y, r*(_steps-step+1), 0, M_PI*2, 0);
        CGContextStrokePath(context);
    }
    CGContextRestoreGState(context);
    
    //绘制坐标轴
    [_backgroundLineColorRadial setStroke];
    for (int i = 0; i < _numOfV; i++) {
        CGContextMoveToPoint(context, _centerPoint.x, _centerPoint.y);
        CGContextAddLineToPoint(context, _centerPoint.x - _r * sin(i * radPerV),
                                _centerPoint.y - _r * cos(i * radPerV));
        CGContextStrokePath(context);
    }
    
    
   
    //根据数据源绘制连线区域
//    CGContextSetLineWidth(context, 2.0);
    CGContextSetAlpha(context, self.colorOpacity);
    for (int serie = 0; serie < [_dataSeries count]; serie++) {
        if (self.fillArea) {
            [colors[serie] setFill];
        }
        else {
            [colors[serie] setStroke];
        }
        for (int i = 0; i < _numOfV; ++i) {
            CGFloat value = [_dataSeries[serie][i] floatValue];
            if (i == 0) {
                CGContextMoveToPoint(context, _centerPoint.x, _centerPoint.y - (value - _minValue) / (_maxValue - _minValue) * _r);
            }
            else {
                CGContextAddLineToPoint(context, _centerPoint.x - (value - _minValue) / (_maxValue - _minValue) * _r * sin(i * radPerV),
                                        _centerPoint.y - (value - _minValue) / (_maxValue - _minValue) * _r * cos(i * radPerV));
            }
        }
        CGFloat value = [_dataSeries[serie][0] floatValue];
        CGContextAddLineToPoint(context, _centerPoint.x, _centerPoint.y - (value - _minValue) / (_maxValue - _minValue) * _r);
        
        if (self.fillArea) {
            CGContextFillPath(context);
        }
        else {
            CGContextStrokePath(context);
        }
        
        
        //绘制交点
        if (_drawPoints) {
            for (int i = 0; i < _numOfV; i++) {
                CGFloat value = [_dataSeries[serie][i] floatValue];
                CGFloat xVal = _centerPoint.x - (value - _minValue) / (_maxValue - _minValue) * _r * sin(i * radPerV);
                CGFloat yVal = _centerPoint.y - (value - _minValue) / (_maxValue - _minValue) * _r * cos(i * radPerV);
                [colors[serie] setFill];
                CGContextFillEllipseInRect(context, CGRectMake(xVal - 3, yVal - 3, 6, 6));
            }
        }
    }
    
    //绘制最大最小值
    if (self.showStepText) {
        [[UIColor blackColor] setFill];
        for (int step = 0; step <= _steps; step++) {
            CGFloat value = _minValue + (_maxValue - _minValue) * step / _steps;
            NSString *currentLabel = [NSString stringWithFormat:@"%.0f", value];
            JY_DRAW_TEXT_IN_RECT(currentLabel,
                                 CGRectMake(_centerPoint.x + 3,
                                            _centerPoint.y - _r * step / _steps - 3,
                                            20,
                                            10),
                                 self.scaleFont);
        }
    }
    
    //绘制坐标轴名称
    CGFloat height = [self.scaleFont lineHeight];
    CGFloat padding = 2.0;
    for (int i = 0; i < _numOfV; i++) {
        NSString *attributeName = _attributes[i];
        CGPoint pointOnEdge = CGPointMake(_centerPoint.x - _r * sin(i * radPerV), _centerPoint.y - _r * cos(i * radPerV));
        
        CGSize attributeTextSize = JY_TEXT_SIZE(attributeName, self.scaleFont);
        NSInteger width = attributeTextSize.width;
        CGFloat xOffset = (-width / 2.0 - padding)*sin(i*radPerV);
        CGFloat yOffset = (-height / 2.0 - padding)*cos(i*radPerV);
        CGPoint legendCenter = CGPointMake(pointOnEdge.x + xOffset, pointOnEdge.y + yOffset);
        
        if (__IPHONE_OS_VERSION_MIN_REQUIRED >= 70000) {
            NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
            [paragraphStyle setLineBreakMode:NSLineBreakByClipping];
            [paragraphStyle setAlignment:NSTextAlignmentCenter];
            
            NSDictionary *attributes = @{ NSFontAttributeName: self.scaleFont,
                                          NSParagraphStyleAttributeName: paragraphStyle };
            
            [attributeName drawInRect:CGRectMake(legendCenter.x - width / 2.0,
                                                 legendCenter.y - height / 2.0,
                                                 width,
                                                 height)
                       withAttributes:attributes];
        }
        else {
            [attributeName drawInRect:CGRectMake(legendCenter.x - width / 2.0,
                                                 legendCenter.y - height / 2.0,
                                                 width,
                                                 height)
                             withFont:self.scaleFont
                        lineBreakMode:NSLineBreakByClipping
                            alignment:NSTextAlignmentCenter];
        }
    }

}


@end
