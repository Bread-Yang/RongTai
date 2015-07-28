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
    NSMutableArray* _points;  //各点坐标
    float _radPerV;
    CGPoint _startPoint;
    CGPoint _endPoint;
    BOOL _isTouchInPoint;
    NSUInteger _touchPointIndex;
    UIImage* _touchImage;
    CGPoint _touchLine;    //特别说明：用CGPoint来表示一条直线，则x等于直线的k，y等于直线的b
    CGPoint _Line2;
}
@end

@implementation WLPolar

-(instancetype)init
{
    if (self = [super init]) {
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
    self.backgroundColor = [UIColor clearColor];
    _maxValue = 100.0;
    _minValue = 0;
    _centerPoint = CGPointMake(self.bounds.size.width / 2, self.bounds.size.height / 2);
    _r = MIN(self.frame.size.width / 2 - PADDING, self.frame.size.height / 2 - PADDING);
    _steps = 1;
    _drawPoints = NO;
    _showStepText = NO;
    _fillArea = NO;
    _lineColor = [UIColor redColor];
    _lineWidth = 2;
    _isPointDashed = YES;
    _backgroundLineColorRadial = [UIColor darkGrayColor];
    _backgroundFillColor = [UIColor clearColor];
    _attributes = @[@"you", @"should", @"set", @"these", @"data", @"titles,",
                    @"this", @"is", @"just", @"a", @"placeholder"];
    _scaleFont = [UIFont systemFontOfSize:ATTRIBUTE_TEXT_SIZE];
    _pointR = 6;
    _fillColor = [UIColor redColor];
    _points = [NSMutableArray new];
    _showLine = YES;
    _isTouchInPoint = NO;
    _touchImage = [UIImage imageNamed:@"piont_2"];
    _touchLine = CGPointZero;
    _Line2 = CGPointZero;
}

#pragma mark - set方法
- (void)setDataSeries:(NSArray *)dataSeries {
    _dataSeries = dataSeries;
    _numOfV = [_dataSeries count];
    _radPerV = M_PI * 2 / _numOfV;
    [self countPointPosition];
    [self setNeedsDisplay];
}

-(void)setR:(CGFloat)r
{
    _r = r;
    [self countPointPosition];
    [self setNeedsDisplay];
}

-(void)setMaxValue:(CGFloat)maxValue
{
    _maxValue = maxValue;
    [self countPointPosition];
    [self setNeedsDisplay];
}

-(void)setMinValue:(CGFloat)minValue
{
    _minValue = minValue;
    [self countPointPosition];
    [self setNeedsDisplay];
}


#pragma mark - 调节坐标
-(void)countPointPosition
{
    for (int i = 0; i<_dataSeries.count; i++) {
        float value = [_dataSeries[i] floatValue];
        value = (value - _minValue)/ (_maxValue - _minValue)*_r;
        CGFloat angle = i * _radPerV;
        float x = _centerPoint.x - value * sin(angle);
        float y = _centerPoint.y - value * cos(angle);
        CGPoint p = CGPointMake(x, y);
        [_points setObject:[NSValue valueWithCGPoint:p] atIndexedSubscript:i];
    }
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
//    NSLog(@"触摸开始");
//    [super touchesBegan:touches withEvent:event];
    if ([self.delegate respondsToSelector:@selector(WLPolarWillStartTouch:)]) {
        [self.delegate WLPolarWillStartTouch:self];
    }
    UITouch* touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    for (int i = 0; i<_points.count; i++) {
        NSValue* v = _points[i];
        CGPoint p = [v CGPointValue];
        BOOL xIn = ABS(p.x - point.x)<=10;
        BOOL yIn = ABS(p.y - point.y)<=10;
        if (xIn&&yIn) {
            _isTouchInPoint = YES;
            _touchPointIndex = i;
            _startPoint = p;
            NSValue* v = _points[_touchPointIndex];
            CGPoint p2 = [v CGPointValue];
            
            _touchLine = lineFunction(_centerPoint, p2);
            float x = _centerPoint.x - _r * sin(_touchPointIndex * _radPerV)/2;
            float y = _centerPoint.y - _r * cos(_touchPointIndex * _radPerV)/2;
            p2.x = x;
            p2.y = y;
            _Line2.x = -1/_touchLine.x;
            if (_Line2.x>CGFLOAT_MAX||_Line2.x<-CGFLOAT_MAX) {
                _Line2.y = p2.x;
            }
            else
            {
                _Line2.y = p2.y - _Line2.x*p2.x;
            }
            [self setNeedsDisplay];
            break;
        }
    }

}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
//    NSLog(@"触摸移动");
//    [super touchesMoved:touches withEvent:event];
    if (_isTouchInPoint) {
        UITouch* touch = [touches anyObject];
        _endPoint = [touch locationInView:self];
        BOOL isIn  = YES;
        float angle = _touchPointIndex * _radPerV;
        float sinA = ABS(sin(angle));
        float range;
        if (sinA<0.01) {
            range = 22;
        }
        else
        {
            range = 22/sinA;
        }
        isIn = inLineRange(_endPoint, _touchLine, range);
        
        angle  = M_PI_2 - angle;
        sinA = ABS(sin(angle));
        if (sinA<0.01) {
            range = _r/2;
        }
        else
        {
            range = (_r/2)/sinA;
        }
        isIn = isIn && inLineRange(_endPoint, _Line2, range);
       
        if (isIn) {
            CGFloat newR = sqrt(pow((_endPoint.x - _centerPoint.x), 2)+pow((_endPoint.y - _centerPoint.y), 2));
            if (newR > _r)
            {
                newR = _r;
            }
            NSValue* v = _points[_touchPointIndex];
            CGPoint p = [v CGPointValue];
            float angle = _touchPointIndex * _radPerV;
            float x = _centerPoint.x - newR * sin(angle);
            float y = _centerPoint.y - newR * cos(angle);
            p.x = x;
            p.y = y;
            [_points setObject:[NSValue valueWithCGPoint:p] atIndexedSubscript:_touchPointIndex];
            [self setNeedsDisplay];
        }
    }
    if ([self.delegate respondsToSelector:@selector(WLPolarDidMove:)]) {
        [self.delegate WLPolarDidMove:self];
    }

}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
//    NSLog(@"触摸结束");
//    [super touchesEnded:touches withEvent:event];
    _isTouchInPoint = NO;
    [self setNeedsDisplay];
    if ([self.delegate respondsToSelector:@selector(WLPolarMoveFinished:)]) {
        [self.delegate WLPolarMoveFinished:self];
    }
}

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    //绘制填充背景颜色
    [_backgroundFillColor setFill];
    CGContextMoveToPoint(context, _centerPoint.x, _centerPoint.y - _r);
    for (int i = 1; i <= _numOfV; ++i) {
        CGContextAddArc(context, _centerPoint.x, _centerPoint.y, _r, 0, M_PI*2, 0);
    }
    CGContextFillPath(context);
    
    //绘制圆形
    [_backgroundLineColorRadial setStroke];
    CGContextSaveGState(context);
    CGFloat r = _r/_steps;
    for (int step = 1; step <= _steps; step++) {
        CGContextAddArc(context, _centerPoint.x, _centerPoint.y, r*(_steps-step+1), 0, M_PI*2, 0);
        CGContextStrokePath(context);
    }
    
    //绘制坐标轴
    [_backgroundLineColorRadial setStroke];
    for (int i = 0; i < _numOfV; i++) {
        CGContextMoveToPoint(context, _centerPoint.x, _centerPoint.y);
        CGContextAddLineToPoint(context, _centerPoint.x - _r * sin(i * _radPerV),
                                _centerPoint.y - _r * cos(i * _radPerV));
        CGContextStrokePath(context);
    }

    //绘制连线
    if (_showLine) {
        [_lineColor setStroke];
        CGContextSetLineWidth(context, _lineWidth);
        NSValue* value = _points[0];
        CGPoint point = [value CGPointValue];
        CGContextMoveToPoint(context, point.x, point.y);
        for (int i = 1; i<_points.count; i++) {
            NSValue* v = _points[i];
            CGPoint p = [v CGPointValue];
            CGContextAddLineToPoint(context, p.x, p.y);
        }
        CGContextAddLineToPoint(context, point.x, point.y);
        CGContextStrokePath(context);
    }
    
    //填充区域
    if (_fillArea) {
        [_fillColor setFill];
        CGContextSetLineWidth(context, _lineWidth);
        NSValue* value = _points[0];
        CGPoint point = [value CGPointValue];
        CGContextMoveToPoint(context, point.x, point.y);
        for (int i = 1; i<_points.count; i++) {
            NSValue* v = _points[i];
            CGPoint p = [v CGPointValue];
            CGContextAddLineToPoint(context, p.x, p.y);
        }
        CGContextAddLineToPoint(context, point.x, point.y);
        CGContextFillPath(context);

    }
    
    //绘制点
    if (_drawPoints)
    {
        for (int i = 0; i < _points.count; i++)
        {
            NSValue* v = _points[i];
            CGPoint p = [v CGPointValue];
            CGFloat xVal = p.x;
            CGFloat yVal = p.y;
            [_lineColor setFill];
            [_lineColor setStroke];
            CGContextSetLineWidth(context, _lineWidth);
            if (_isPointDashed) {
                CGContextClearRect(context, CGRectMake(xVal - _pointR/2, yVal - _pointR/2, _pointR, _pointR));
                 CGContextStrokeEllipseInRect(context, CGRectMake(xVal - _pointR/2, yVal - _pointR/2, _pointR, _pointR));
            }
            else
            {
                 CGContextFillEllipseInRect(context, CGRectMake(xVal - _pointR/2, yVal - _pointR/2, _pointR, _pointR));
            }
        }
    }
  
    //绘制触摸点图片
    if (_isTouchInPoint) {
        NSValue* v = _points[_touchPointIndex];
        CGPoint p = [v CGPointValue];
        p.x -= 12;
        p.y -= 12;
        [_touchImage drawAtPoint:p blendMode:kCGBlendModeNormal alpha:1];
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
    CGFloat padding = 10.0;
    
    for (int i = 0; i < _numOfV; i++) {
        NSString *attributeName = _attributes[i];
        CGPoint pointOnEdge = CGPointMake(_centerPoint.x - _r * sin(i * _radPerV), _centerPoint.y - _r * cos(i * _radPerV));
        
        
        CGSize attributeTextSize = JY_TEXT_SIZE(attributeName, self.scaleFont);
        NSInteger width = attributeTextSize.width;
        CGFloat xOffset = (-width / 2.0 - padding)*sin(i*_radPerV);
        CGFloat yOffset = (-height / 2.0 - padding)*cos(i*_radPerV);
        CGPoint legendCenter = CGPointMake(pointOnEdge.x + xOffset, pointOnEdge.y + yOffset);
        
        if (__IPHONE_OS_VERSION_MIN_REQUIRED >= 70000) {
            NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
            [paragraphStyle setLineBreakMode:NSLineBreakByClipping];
            [paragraphStyle setAlignment:NSTextAlignmentCenter];
            
            NSDictionary *attributes = @{ NSFontAttributeName: self.scaleFont,
                                          NSParagraphStyleAttributeName: paragraphStyle ,NSForegroundColorAttributeName:[UIColor colorWithRed:115/255.0 green:182/255.0 blue:197/255.0 alpha:1]};
            
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

//-(BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
//{
//    NSLog(@"ddd:%d",[super pointInside:point withEvent:event]);
//    return [super pointInside:point withEvent:event];
//}
//
//-(UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
//{
//    NSLog(@"ddd:%@",[super hitTest:point withEvent:event]);
//    return [super hitTest:point withEvent:event];
//}

#pragma mark - 计算函数
bool inLineRange (CGPoint p,CGPoint line,CGFloat range)
{
    CGFloat y;
    bool result;
    if (line.x>CGFLOAT_MAX||line.x<-CGFLOAT_MAX) {
        result = ABS(p.x-line.y) <= range;
    }
    else
    {
        y = p.x*line.x+line.y;
        result = ABS(y - p.y) <= range;
    }
//    printf("{\n line->k:%lf   b:%lf\n point->x:%lf   y:%lf\n",line.x,line.y,p.x,p.y);
//    printf(" range:%lf\n InRange:%d\n}\n",range,result);
    return result;
}

CGPoint lineFunction(CGPoint p1,CGPoint p2)
{
    CGPoint line = CGPointZero;
    CGFloat k = (p1.y - p2.y)/(p1.x - p2.x);
    CGFloat b = p1.y - k*p1.x;
    line.x = k;
    line.y = b;
    if (p1.x - p2.x == 0) {
        line.y = p1.x;
    }
    return line;
}


@end
