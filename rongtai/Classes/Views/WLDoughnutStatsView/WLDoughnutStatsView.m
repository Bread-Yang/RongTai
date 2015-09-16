//
//  WLDoughnutStatsView.m
//  WLDoughnutStatsView
//
//  Created by William-zhang on 15/7/6.
//  Copyright (c) 2015年 William-zhang. All rights reserved.
//

#import "WLDoughnutStatsView.h"

#if __IPHONE_OS_VERSION_MIN_REQUIRED >= 70000
#define JY_TEXT_SIZE(text, font) [text length] > 0 ? [text sizeWithAttributes : @{ NSFontAttributeName : font }] : CGSizeZero;
#define JY_DRAW_TEXT_IN_RECT(text, rect, font) [text drawInRect : rect withAttributes : @{ NSFontAttributeName:font }];
#else
#define JY_TEXT_SIZE(text, font) [text length] > 0 ? [text sizeWithFont : font] : CGSizeZero;
#define JY_DRAW_TEXT_IN_RECT(text, rect, font) [text drawInRect : rect withFont : font];

#endif

@interface WLDoughnutStatsView ()
{
    NSMutableArray* _centerPoints;
    CGPoint _center;
    NSMutableArray* _makersPoints;
    UIColor* _lineColor;  //线的颜色
    CGFloat _lineWidth;   //线的宽度
}
@end

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
    _isShowPercent = YES;
    _center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
    _centerPoints = [NSMutableArray new];
    _makersPoints = [NSMutableArray new];
    _percentColor = @[[UIColor colorWithRed:1 green:0 blue:0 alpha:0.6],[UIColor colorWithRed:0 green:1 blue:0 alpha:0.6],[UIColor colorWithRed:0 green:0 blue:1 alpha:0.6],[UIColor colorWithRed:0 green:1 blue:1 alpha:0.6]];
    _percentFont = [UIFont fontWithName:@"Helvetica" size:20];
    _markersDesFont = [UIFont fontWithName:@"Helvetica" size:10];
    _markersNameFont = [UIFont systemFontOfSize:10 weight:2];
    _percentCharFont = [UIFont systemFontOfSize:14];
    _lineColor = [UIColor grayColor];
    _lineWidth = 0.5;
    _makersNameColor = [UIColor grayColor];
    _makersDesColor = [UIColor blackColor];
}

#pragma mark - set方法
-(void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    _r = MIN(frame.size.width, frame.size.height)/2;
    _center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
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

-(void)setMakersName:(NSArray *)makersName
{
    _makersName = makersName;
    [self setNeedsDisplay];
}

-(void)setMakersDescription:(NSArray *)makersDescription
{
    _makersDescription = makersDescription;
    [self setNeedsDisplay];
}

-(void)setMakersNameColor:(UIColor *)makersNameColor
{
    _makersNameColor = makersNameColor;
    [self setNeedsDisplay];
}

-(void)setMarkersDesFont:(UIFont *)markersDesFont
{
    _markersDesFont = markersDesFont;
    [self setNeedsDisplay];
}

-(void)setMarkersNameFont:(UIFont *)markersNameFont
{
    _markersNameFont = markersNameFont;
    [self setNeedsDisplay];
}

#pragma mark - drawRect
- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGFloat disAngle = _doughnutDistance/(M_PI*2*_r);
    CGFloat start = M_PI*1.5;
    CGFloat pointStart = 0;
    NSUInteger leftCount = 0;
    NSUInteger rightCount = 0;
    CGFloat w = self.frame.size.width;
    CGFloat h = self.frame.size.height;
    //    CGFloat pScale = 0.5;  //百分比文字的高度比例
    //    CGFloat mNameScale = 0.3;  //标注名字高度比例
    //    CGFloat mDecScale = 0.2;  // 标注描述高度比例
    
    //第一个单独画，避免只有一个数据的时候出现间隔的现象
    UIColor* color = _colors[0];
    [color setStroke];
    CGContextSetLineWidth(context, _doughnutWidth);
    CGFloat percent = [_percents[0] floatValue];
    CGFloat angle = M_PI*2*percent;
    
    NSInteger hasDistance = 0;
    if (_percents.count>1) {
        hasDistance = 1;
    }
    CGContextAddArc(context, _center.x, _center.y, _r-_doughnutWidth/2, start, start+angle-hasDistance*disAngle, 0) ;
    CGContextStrokePath(context);
    
    ///////计算圆弧中心点
    [[UIColor blackColor] setStroke];
    CGFloat _currentAngle = -angle/2 ;
    NSLog(@"弧度：%f",_currentAngle);
    CGPoint p = CGPointMake(_center.x - (_r+3) * sin(_currentAngle), _center.y - (_r+3) * cos(_currentAngle));
    //    CGContextFillEllipseInRect(context, CGRectMake(p.x-1.5, p.y-1.5, 3, 3));
    [_centerPoints setObject:[NSValue valueWithCGPoint:p] atIndexedSubscript:0];
    if (p.x>_center.x) {
        rightCount++;
    }
    else
    {
        leftCount++;
    }
    
    //
    
    start = start+angle;
    pointStart -= angle;
    
    for (int i = 1; i < _percents.count; i++) {
        UIColor* color = _colors[i%4];
        [color setStroke];
        CGContextSetLineWidth(context, _doughnutWidth);
        CGFloat percent = [_percents[i] floatValue];
        CGFloat angle = M_PI*2*percent;
        CGContextAddArc(context, _center.x, _center.y, _r-_doughnutWidth/2, start, start+angle-disAngle, 0) ;
        CGContextStrokePath(context);
        
        //计算圆弧中心，方便标注布局
        [[UIColor blackColor] setStroke];
        CGFloat _currentAngle = -angle/2+pointStart;
        NSLog(@"弧度：%f",_currentAngle);
        CGPoint p = CGPointMake(_center.x - (_r+3) * sin(_currentAngle), _center.y - (_r+3) * cos(_currentAngle));
        //        CGContextFillEllipseInRect(context, CGRectMake(p.x-1.5, p.y-1.5, 3, 3));
        [_centerPoints setObject:[NSValue valueWithCGPoint:p] atIndexedSubscript:i];
        if (p.x>=_center.x) {
            rightCount++;
        }
        else
        {
            leftCount++;
        }
        start = start+angle;
        pointStart -= angle;
    }
    
    //画百分比
    if(_isShowPercent)
    {
        if (_makersDescription.count == _makersName.count && _makersName.count == _percents.count) {
            //右边开始画
            CGFloat s = 0.8;
            CGFloat dltY = 5;
            CGFloat dlt = 2; //文字间的距离
            CGFloat mWidth = (w - _r*2)*s/2;  //view宽度减去圆环半径两倍（即圆环大小），再乘以比例，除以2，得到标注文字宽度
            NSUInteger maxCount = MAX(rightCount, leftCount);  //获取一边标注的最大值
            CGFloat mHeight = (h-dltY*2)/maxCount;  //算出标注的宽度
            
            //画右边标注
            CGFloat makerY = dltY;
            CGFloat makerX = w;
            for (int i = 0; i<rightCount; i++) {
                //百分比的AttributedString和Size
                NSString* percentStr = [NSString stringWithFormat:@"%d%%",(int)([_percents[i] floatValue]*100)];
                NSMutableAttributedString* attributeName = [[NSMutableAttributedString alloc]initWithAttributedString:[self attributedStringByColor:_percentColor[i%4] String:percentStr Font:self.percentFont]];
                [attributeName addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:NSMakeRange(percentStr.length-1, 1)];
                [attributeName addAttribute:NSFontAttributeName value:_percentCharFont range:NSMakeRange(percentStr.length-1, 1)];
                CGSize attributeTextSize = [attributeName size];
                
                //标注名的AttributedString和Size
                NSAttributedString* makersName = [self attributedStringByColor:self.makersNameColor String:_makersName[i] Font:self.markersNameFont];
                CGSize makersNameTextSize = [makersName size];
                
                //标注描述的AttributedString和Size
                NSAttributedString* makersDes = [self attributedStringByColor:self.makersDesColor String:_makersDescription[i] Font:self.markersDesFont];
                CGSize makersDesTextSize = [makersDes size];
                
                //画百分比数
                //计算出百分比文字要画的区域
                CGFloat y = makerY+(mHeight-attributeTextSize.height-makersNameTextSize.height-makersDesTextSize.height)/2;
                CGRect f = CGRectZero;
                f.size = attributeTextSize;
                CGFloat pH = attributeTextSize.height;
                f.origin = CGPointMake(makerX-attributeTextSize.width , y+pH/2);
                [attributeName drawWithRect:f options:NSStringDrawingUsesFontLeading|NSStringDrawingUsesDeviceMetrics context:nil];
                
                //画分割线
                [_lineColor setStroke];
                y += (pH/2+dlt);
                CGPoint startPoint = CGPointMake(makerX-mWidth, y);
                
                //把点存到数组，最后连线需要用到
                [_makersPoints setObject:[NSValue valueWithCGPoint:startPoint] atIndexedSubscript:i];
                CGPoint endPoint = CGPointMake(makerX, y);
                CGContextSetLineWidth(context, _lineWidth);
                CGContextMoveToPoint(context,startPoint.x,startPoint.y);
                CGContextAddLineToPoint(context, endPoint.x, endPoint.y);
                CGContextStrokePath(context);
                
                //画标注名称
                
                //计算出百分比文字要画的区域
                f = CGRectZero;
                f.size = makersNameTextSize;
                pH = makersNameTextSize.height;
                y += (pH/2+dlt*2+_lineWidth);
                f.origin = CGPointMake(makerX-makersNameTextSize.width , y);
                [makersName drawWithRect:f options:NSStringDrawingUsesFontLeading|NSStringDrawingUsesDeviceMetrics context:nil];
                
                //画标注描述
                
                //计算出百分比文字要画的区域
                f = CGRectZero;
                f.size = makersDesTextSize;
                pH = makersDesTextSize.height;
                y += (pH/2+dlt*2);
                f.origin = CGPointMake(makerX-makersDesTextSize.width , y);
                [makersDes drawWithRect:f options:NSStringDrawingUsesFontLeading|NSStringDrawingUsesDeviceMetrics context:nil];
                
                makerY += mHeight;
            }
            
            //画左边标注
            int j = 0;
            makerY = dltY+(leftCount-1)*mHeight;
            makerX = 0;
            for (int i = 0; i<leftCount; i++) {
                j = i+(int)rightCount;
                
                //百分比的AttributedString和Size
                NSString* percentStr = [NSString stringWithFormat:@"%d%%",(int)([_percents[j] floatValue]*100)];
                NSMutableAttributedString* attributeName = [[NSMutableAttributedString alloc]initWithAttributedString:[self attributedStringByColor:_percentColor[j%4] String:percentStr Font:self.percentFont]];
                [attributeName addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:NSMakeRange(percentStr.length-1, 1)];
                [attributeName addAttribute:NSFontAttributeName value:_percentCharFont range:NSMakeRange(percentStr.length-1, 1)];
                CGSize attributeTextSize = [attributeName size];
                
                //标注名的AttributedString和Size
                NSAttributedString* makersName = [self attributedStringByColor:self.makersNameColor String:_makersName[j] Font:self.markersNameFont];
                CGSize makersNameTextSize = [makersName size];
                
                //标注描述的AttributedString和Size
                NSAttributedString* makersDes = [self attributedStringByColor:self.makersDesColor String:_makersDescription[j] Font:self.markersDesFont];
                CGSize makersDesTextSize = [makersDes size];
                
                //画百分比数
                //计算出百分比文字要画的区域
                CGFloat y = makerY+(mHeight-attributeTextSize.height-makersNameTextSize.height-makersDesTextSize.height)/2;
                CGRect f = CGRectZero;
                f.size = attributeTextSize;
                CGFloat pH = attributeTextSize.height;
                f.origin = CGPointMake(makerX, y+pH/2);
                [attributeName drawWithRect:f options:NSStringDrawingUsesFontLeading|NSStringDrawingUsesDeviceMetrics context:nil];
                
                //画分割线
                [_lineColor setStroke];
                y += (pH/2+dlt);
                CGPoint startPoint = CGPointMake(makerX+mWidth, y);
                //把点存到数组，最后连线需要用到
                [_makersPoints setObject:[NSValue valueWithCGPoint:startPoint] atIndexedSubscript:j];
                CGPoint endPoint = CGPointMake(makerX, y);
                CGContextSetLineWidth(context, _lineWidth);
                CGContextMoveToPoint(context,startPoint.x,startPoint.y);
                CGContextAddLineToPoint(context, endPoint.x, endPoint.y);
                CGContextStrokePath(context);
                
                //画标注名称
                
                //计算出百分比文字要画的区域
                f = CGRectZero;
                f.size = makersNameTextSize;
                pH = makersNameTextSize.height;
                y += (pH/2+dlt*2+_lineWidth);
                f.origin = CGPointMake(makerX , y);
                [makersName drawWithRect:f options:NSStringDrawingUsesFontLeading|NSStringDrawingUsesDeviceMetrics context:nil];
                
                //画标注描述
                
                //计算出百分比文字要画的区域
                f = CGRectZero;
                f.size = makersDesTextSize;
                pH = makersDesTextSize.height;
                y += (pH/2+dlt*2);
                f.origin = CGPointMake(makerX , y);
                [makersDes drawWithRect:f options:NSStringDrawingUsesFontLeading|NSStringDrawingUsesDeviceMetrics context:nil];
                
                makerY -= mHeight;
            }
            
            //连线
            [_lineColor setStroke];
            CGContextSetLineWidth(context, _lineWidth);
            for (int i = 0; i<_makersPoints.count; i++) {
                CGPoint start = [_makersPoints[i] CGPointValue];
                CGPoint end = [_centerPoints[i] CGPointValue];
                CGContextMoveToPoint(context, start.x, start.y);
                CGContextAddLineToPoint(context, end.x, end.y);
            }
            CGContextStrokePath(context);
        }
    }
}

-(NSAttributedString*)attributedStringByColor:(UIColor*)color String:(NSString*)string Font:(UIFont*)font
{
    NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    [paragraphStyle setLineBreakMode:NSLineBreakByClipping];
    [paragraphStyle setAlignment:NSTextAlignmentCenter];
    NSMutableDictionary* attributes = [NSMutableDictionary new];
    [attributes setObject:font forKey:NSFontAttributeName];
    [attributes setObject:paragraphStyle forKey:NSParagraphStyleAttributeName];
    [attributes setObject:color forKey:NSForegroundColorAttributeName];
    NSAttributedString* attributeName = [[NSAttributedString alloc]initWithString:string attributes:attributes];
    return attributeName;
}



@end
