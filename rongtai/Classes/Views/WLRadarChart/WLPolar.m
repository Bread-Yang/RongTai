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
    float _radPerV;      //单位弧度，如果有四个点，那它就等于90°
    //    CGPoint _startPoint; //触摸起始点
    CGPoint _endPoint;   //触摸结束点
    BOOL _isTouchInPoint;   //点击是否在交点范围内
    NSUInteger _touchPointIndex;  //第几个点被触摸
    UIImage* _touchImage;   //触摸点点击后样式图片
    //特别说明：用CGPoint来表示一条直线，则x等于直线的k，y等于直线的b
    CGPoint _touchLine;    //触摸点和中心点连成的直线
    CGPoint _Line2;        //垂直与_touchLine的直线
    NSMutableArray* _values;   //存储点的值
    NSMutableArray* _canMove;  //存储点是否可移动
    NSMutableArray* _maxLimit; //存储点的最大限制值
    NSMutableArray* _minLimit; //存储点的最小限制值
    float _newR;
    CGFloat _dif;   //最大最小值的差
    float _currentAngle;  //当前触摸坐标轴和中心点的角度
    float _sinCurrentAngle;  //_currentAngle的sin值
    float _cosCurrentAngle;  //_currentAngle的cos值
    float _currentMaxLimit;  //当前触摸点的最大限制值
    float _currentMinLimit;  //当前触摸点的最小限制值
    CGPoint _currentRangePoint;  //当前触摸点坐标轴的终点坐标
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
    _dif = _maxValue - _minValue;
    //中心点为View的中心
    _centerPoint = CGPointMake((int)(self.bounds.size.width / 2), (int)(self.bounds.size.height / 2));
    //半径为高或宽两者中的最小值
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
    _FontColors = @[[UIColor colorWithRed:65/255.0 green:170/255.0 blue:196/255.0 alpha:1],[UIColor colorWithRed:128/255.0 green:199/255.0 blue:134/255.0 alpha:1],[UIColor colorWithRed:63/255.0 green:157/255.0 blue:244/255.0 alpha:1],[UIColor colorWithRed:245/255.0 green:122/255.0 blue:72/255.0 alpha:1],[UIColor colorWithRed:128/255.0 green:199/255.0 blue:134/255.0 alpha:1]];
}

#pragma mark - set方法
- (void)setDataSeries:(NSArray *)dataSeries {
    _dataSeries = dataSeries;
    _values = [NSMutableArray arrayWithArray:_dataSeries];
    _numOfV = [_dataSeries count];
    _radPerV = M_PI * 2 / _numOfV;
    //默认都是可拖动
    _canMove = [NSMutableArray arrayWithCapacity:_numOfV];
    for (int i = 0; i<_numOfV; i++) {
        NSNumber* n = [NSNumber numberWithBool:YES];
        [_canMove addObject:n];
    }
    
    if (_maxLimit.count == 0) {
        //默认最大限制值都是取值的最大值，属性maxValue
        _maxLimit = [NSMutableArray arrayWithCapacity:_numOfV];
        for (int i = 0; i<_numOfV; i++) {
            NSNumber* n = [NSNumber numberWithFloat:_maxValue];
            [_maxLimit addObject:n];
        }
    }

    if (_minLimit.count == 0) {
        //默认最小限制值都是取值的最小值，属性minValue
        _minLimit = [NSMutableArray arrayWithCapacity:_numOfV];
        for (int i = 0; i<_numOfV; i++) {
            NSNumber* n = [NSNumber numberWithFloat:_minValue];
            [_minLimit addObject:n];
        }
    }

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
    float tmp = _maxValue;
    _maxValue = maxValue;
    _dif = _maxValue - _minValue;
    for (int i = 0; i<_numOfV; i++) {
        NSNumber* n = _maxLimit[i];
        float old = [n floatValue];
        if (old == tmp) {
            NSNumber* new = [NSNumber numberWithDouble:_maxValue];
            [_maxLimit setObject:new atIndexedSubscript:i];
        }
    }
    [self countPointPosition];
    [self setNeedsDisplay];
}

-(void)setMinValue:(CGFloat)minValue
{
    float tmp = _minValue;
    _minValue = minValue;
    _dif = _maxValue - _minValue;
    for (int i = 0; i<_numOfV; i++) {
        NSNumber* n = _minLimit[i];
        float old = [n floatValue];
        if (old == tmp) {
            NSNumber* new = [NSNumber numberWithDouble:_minValue];
            [_minLimit setObject:new atIndexedSubscript:i];
        }
    }
    [self countPointPosition];
    [self setNeedsDisplay];
}

#pragma mark - 设置第n个点可拖动
-(void)setPoint:(NSUInteger)index ableMove:(BOOL)isAble
{
    if (index<_numOfV) {
        NSNumber* n = [NSNumber numberWithBool:isAble];
        [_canMove setObject:n atIndexedSubscript:index];
    }
}

#pragma mark - 获取第n个点的可拖动性
-(BOOL)pointAbleMove:(NSUInteger)index
{
    if (index<_numOfV) {
        NSNumber* n = _canMove[index];
        BOOL able = [n boolValue];
        return able;
    }
    return NO;
}

#pragma mark - 设置第n个点的值
-(void)setValue:(float)value ByIndex:(NSUInteger)index
{
    if (index<_numOfV) {
        [_values setObject:[NSNumber numberWithFloat:value] atIndexedSubscript:index];
        _dataSeries = [NSArray arrayWithArray:_values];
        [self countPointPosition];
        [self setNeedsDisplay];
    }
}

#pragma mark - 设置第n个点的拖拽范围
-(void)setPoint:(NSUInteger)index MaxLimit:(float)max MinLimit:(float)min
{
    if (min>=max) {
        return;
    }
    if (max>_maxValue) {
        max = _maxValue;
    }
    NSNumber* nMax = [NSNumber numberWithFloat:max];
    [_maxLimit setObject:nMax atIndexedSubscript:index];
    
    if (min<_minValue) {
        min = _minValue;
    }
    NSNumber* nMin = [NSNumber numberWithFloat:min];
    [_minLimit setObject:nMin atIndexedSubscript:index];
}

#pragma mark - 调节坐标
-(void)countPointPosition
{
    for (int i = 0; i<_dataSeries.count; i++) {
        float value = [_dataSeries[i] floatValue];
        if (value<_minValue) {
            value = _minValue;
        }
        else if (value>_maxValue)
        {
            value = _maxValue;
        }
        else
        {
            value = (value - _minValue)/ _dif*_r;
        }
        CGFloat angle = i * _radPerV;
        float x = _centerPoint.x - value * sin(angle);
        float y = _centerPoint.y - value * cos(angle);
        CGPoint p = CGPointMake(x, y);
        [_points setObject:[NSValue valueWithCGPoint:p] atIndexedSubscript:i];
    }
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
	NSLog(@"pointInside:");

	for (int i = 0; i<_points.count; i++) {
        NSNumber* n = _canMove[i];
        if (![n boolValue]) {
            continue;
        }
		NSValue* v = _points[i];
		CGPoint p = [v CGPointValue];
		BOOL xIn = ABS(p.x - point.x)<=30;
		BOOL yIn = ABS(p.y - point.y)<=30;
		if (xIn&&yIn) {
            //确定触摸是在点的范围内，且该点是允许移动的，则计算一些相应的值
            _isTouchInPoint = YES;
            _touchPointIndex = i;
            _currentAngle  = _touchPointIndex* _radPerV;
            _currentRangePoint = CGPointMake(_centerPoint.x - _r * sin(_currentAngle), _centerPoint.x - _r * cos(_currentAngle));
            _sinCurrentAngle = sin(_currentAngle);
            _cosCurrentAngle = cos(_currentAngle);
            
            CGPoint p2 = CGPointZero;
            NSNumber* nMin = _minLimit[_touchPointIndex];
            float min = [nMin floatValue];
            if (min<_minValue) {
                min = _minValue;
            }
            _currentMinLimit = (min-_minValue)/_dif;
            
            NSNumber* nMax = _maxLimit[_touchPointIndex];
            float max = [nMax floatValue];
            if (max>_maxValue) {
                max = _maxValue;
            }
            _currentMaxLimit = (max - _minValue)/_dif;
            
            _newR = (_currentMaxLimit - _currentMinLimit)*_r/2;
            float r = (_newR+_currentMinLimit*_r);
            
            float x = _centerPoint.x - r * _sinCurrentAngle;
            float y = _centerPoint.y - r * _cosCurrentAngle;
            p2.x = x;
            p2.y = y;
            _touchLine = lineFunction(_centerPoint, p2);
            
            _Line2.x = -1 / _touchLine.x;
            if (_Line2.x > CGFLOAT_MAX || _Line2.x < -CGFLOAT_MAX) {
                _Line2.y = p2.x;
            } else {
                _Line2.y = p2.y - _Line2.x * p2.x;
            }
            [self setNeedsDisplay];
			return YES;
		}
	}
	return NO;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    NSLog(@"触摸开始");
    if ([self.delegate respondsToSelector:@selector(WLPolarWillStartTouch:)]) {
        [self.delegate WLPolarWillStartTouch:self];
    }
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    //    NSLog(@"触摸移动");
    if (_isTouchInPoint) {
        UITouch* touch = [touches anyObject];
        _endPoint = [touch locationInView:self];
        BOOL isIn  = YES;
        BOOL isInRange = YES;
        float sinA = ABS(_sinCurrentAngle);
        float range;
        if (sinA<0.01) {
            range = 30;
        }
        else
        {
            range = 30/sinA;
        }
        
        //触摸点是否在_touchLine的范围内
        isIn = inLineRange(_endPoint, _touchLine, range);
        
        float angle  = M_PI_2 - _currentAngle;
        sinA = ABS(sin(angle));
        if (sinA<0.01) {
            range = _newR;
        }
        else
        {
            range = (_newR)/sinA;
        }
        //触摸点是否在_tocuhLine和_Line2的范围内
        isInRange = isIn && inLineRange(_endPoint, _Line2, range);
        
        if (isIn) {
            //            NSLog(@"在移动范围内");
            float dlt = distanceTwoPoint(_centerPoint, _endPoint);
            if (!isInRange) {
                //                NSLog(@"超出范围");
                float dist = distanceTwoPoint(_endPoint, _currentRangePoint);
                if (dist > dlt) {
                    dlt = _r*_currentMinLimit;
                }
                else
                {
                    dlt = _r*_currentMaxLimit;
                }
            }
            
            CGPoint p = CGPointZero;
            int sinA = dlt * _sinCurrentAngle;
            int cosA = dlt * _cosCurrentAngle;
            float x = _centerPoint.x - sinA;
            float y = _centerPoint.y - cosA;
            p.x = x;
            p.y = y;
            [_points setObject:[NSValue valueWithCGPoint:p] atIndexedSubscript:_touchPointIndex];
            dlt = distanceTwoPoint(p, _centerPoint);
            float newNum = (dlt/_r)*_dif+_minValue;
            [_values setObject:[NSNumber numberWithFloat:newNum] atIndexedSubscript:_touchPointIndex];
        }
        else
        {
            _isTouchInPoint = NO;
            
        }
        [self setNeedsDisplay];
        if ([self.delegate respondsToSelector:@selector(WLPolarDidMove:)]) {
            [self.delegate WLPolarDidMove:self];
        }
    }
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSLog(@"触摸结束");
//    [super touchesEnded:touches withEvent:event];
    _dataSeries = [NSArray arrayWithArray:_values];
	NSLog(@"Points:%@",_points);
	NSLog(@"_dataSeries : %@", _dataSeries);
    _isTouchInPoint = NO;
    [self setNeedsDisplay];
    if ([self.delegate respondsToSelector:@selector(WLPolarMoveFinished:index:)]) {
        [self.delegate WLPolarMoveFinished:self index:_touchPointIndex];
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
            CGFloat value = _minValue + _dif * step / _steps;
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
        NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
        [paragraphStyle setLineBreakMode:NSLineBreakByClipping];
        [paragraphStyle setAlignment:NSTextAlignmentCenter];
        NSMutableDictionary* attributes = [NSMutableDictionary new];
        [attributes setObject:self.scaleFont forKey:NSFontAttributeName];
        [attributes setObject:paragraphStyle forKey:NSParagraphStyleAttributeName];
        if (_FontColors[i]) {
            [attributes setObject:_FontColors[i] forKey:NSForegroundColorAttributeName];
        }
        NSAttributedString* attributeName = [[NSAttributedString alloc]initWithString:_attributes[i] attributes:attributes];
        CGPoint pointOnEdge = CGPointMake(_centerPoint.x - _r * sin(i * _radPerV), _centerPoint.y - _r * cos(i * _radPerV));
        CGSize attributeTextSize = [attributeName size];
        NSInteger width = attributeTextSize.width;
        CGFloat xOffset = (-width / 2.0 - padding)*sin(i*_radPerV);
        CGFloat yOffset = (-height / 2.0 - padding)*cos(i*_radPerV);
        CGPoint legendCenter = CGPointMake(pointOnEdge.x + xOffset-width/2.0, pointOnEdge.y + yOffset+padding/2.0);
        CGRect f = CGRectZero;
        f.size = attributeTextSize;
        f.origin = legendCenter;
        [attributeName drawWithRect:f options:NSStringDrawingUsesFontLeading|NSStringDrawingUsesDeviceMetrics context:nil];
    }
}

#pragma mark - 点是否在给定的直线的给定范围内
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

#pragma mark - 根据两个点返回一条直线的函数
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

#pragma mark - 两点间的距离
float distanceTwoPoint(CGPoint p1,CGPoint p2)
{
    return sqrt(pow((p1.x - p2.x), 2)+pow((p1.y - p2.y), 2));
}


@end
