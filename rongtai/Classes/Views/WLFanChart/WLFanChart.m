//
//  WLFanChart.m
//  WLFanChart
//
//  Created by William-zhang on 15/6/5.
//  Copyright (c) 2015年 William-zhang. All rights reserved.
//

#import "WLFanChart.h"
#import <CoreText/CoreText.h>

@interface WLFanChart ()
{
    CGPoint _center;  //圆心坐标
}
@end

@implementation WLFanChart

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
    }
    return self;
}


#pragma mark - 默认初始化
-(void)setUp
{
    self.backgroundColor = [UIColor clearColor];
    _animationTime = 1;
    _r = 100;
    _percentFont = [UIFont systemFontOfSize:12];
    _percentColor = [UIColor whiteColor];
    _dataSource = [[NSArray alloc]initWithObjects:@0.2,@0.35,@0.1,@0.15,@0.2, nil];
    NSMutableArray* arr = [NSMutableArray new];
    for (int i = 0; i<5; i++) {
        [arr addObject:[UIColor colorWithRed:0 green:0.5 blue:1 alpha:0.2+(4-i)*0.2]];
    }
    _colors = arr;
}


#pragma mark - 重写drawRect
- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    _center = CGPointMake(self.bounds.size.width/2, self.bounds.size.width/2);
    _r = self.bounds.size.width/2;
    CGFloat startAngle = M_PI*1.5;
    if (_dataSource.count>0&&_colors.count>0) {
        //扇形
        for (int i = 0; i < _dataSource.count; i++) {
            NSNumber* num = _dataSource[i];
            CGFloat percent = num.floatValue;
            UIColor* color = _colors[i];
            CAShapeLayer* fan = [self fanLayerWith:color percent:percent startAngle:startAngle];
            fan.zPosition = -10+i;
            [self.layer addSublayer:fan];
            startAngle += M_PI*2*percent;
        }
        
        //文字
        CGFloat sAngle = M_PI;
        for (int i = 0; i<_dataSource.count; i++) {
            
            NSNumber* num = _dataSource[i];
            CGFloat percent = num.floatValue;
            NSString *percentLabel = [NSString stringWithFormat:@"%.1f%%", percent*100];
            CAShapeLayer* text = [self textShapeLayerWithText:percentLabel Font:_percentFont Color:_percentColor];
            CGRect textFrame = text.frame;
            CGFloat x = _center.x-sin(sAngle+M_PI*percent)*(_r*0.6)-textFrame.size.width/2;
            CGFloat y = _center.y+cos(sAngle+M_PI*percent)*(_r*0.6)-textFrame.size.height
            /2;
            textFrame.origin.x = x;
            textFrame.origin.y = y;
            text.frame = textFrame;
            [self.layer addSublayer:text];

            sAngle += M_PI*2*percent;
        }
        
    }
}

#pragma mark - 返回一个文字的Layer层
-(CAShapeLayer*)textShapeLayerWithText:(NSString*)text Font:(UIFont*)font Color:(UIColor*)color
{
    CGMutablePathRef textPath = CGPathCreateMutable();   //创建path
    NSDictionary* attribute = [NSDictionary dictionaryWithObjectsAndKeys:
                               font,kCTFontAttributeName,
                               nil];
    NSAttributedString* string = [[NSAttributedString alloc]initWithString:text   attributes:attribute];  //设置字体
    CTLineRef line = CTLineCreateWithAttributedString((CFAttributedStringRef)string);  //创建line
    CFArrayRef runArray = CTLineGetGlyphRuns(line);   //根据line获得一个数组
    
    // 获得每一个 run
    for (CFIndex runIndex = 0; runIndex< CFArrayGetCount(runArray); runIndex++) {
        CTRunRef run = (CTRunRef)CFArrayGetValueAtIndex(runArray, runIndex);
        CTFontRef runFont = CFDictionaryGetValue(CTRunGetAttributes(run), kCTFontAttributeName);
        for (CFIndex runGlyphIndex = 0; runGlyphIndex < CTRunGetGlyphCount(run); runGlyphIndex++)
        {
            // 获得形象字
            CFRange thisGlyphRange = CFRangeMake(runGlyphIndex, 1);
            //获得形象字信息
            CGGlyph glyph;
            CGPoint position;
            CTRunGetGlyphs(run, thisGlyphRange, &glyph);
            CTRunGetPositions(run, thisGlyphRange, &position);
            
            // 获得形象字外线的path
            {
                CGPathRef letter = CTFontCreatePathForGlyph(runFont, glyph, NULL);
                CGAffineTransform t = CGAffineTransformMakeTranslation(position.x, position.y);
                CGPathAddPath(textPath, &t, letter);
                CGPathRelease(letter);
            }
        }
    }
    CFRelease(line);
    
    //根据构造出的 path 构造 bezier 对象
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointZero];
    [path appendPath:[UIBezierPath bezierPathWithCGPath:textPath]];
    CGPathRelease(textPath);
    
    CAShapeLayer* textLayer = [CAShapeLayer layer];
    textLayer.bounds = CGPathGetBoundingBox(path.CGPath);
    textLayer.strokeEnd = 0;
    textLayer.strokeColor = color.CGColor;
    textLayer.geometryFlipped = YES;
    textLayer.lineWidth = 0.1;
    textLayer.lineJoin = kCALineJoinBevel;
    textLayer.fillColor = color.CGColor;
    textLayer.path = path.CGPath;
    textLayer.strokeEnd = 1;
    return textLayer;
}

#pragma mark - 返回一个扇形的Layer层
-(CAShapeLayer*)fanLayerWith:(UIColor*)color percent:(CGFloat)percent startAngle:(CGFloat)startAngle
{
    CGFloat angle = M_PI*2*percent;
    UIBezierPath* path = [UIBezierPath bezierPath];
    [path addArcWithCenter:_center radius:_r/2 startAngle:startAngle  endAngle:startAngle+angle clockwise:YES];
    CAShapeLayer* fanLayer = [CAShapeLayer layer];
    fanLayer.strokeEnd = 0;
    fanLayer.strokeColor = color.CGColor;
    fanLayer.lineWidth = _r;
    fanLayer.lineCap = kCALineCapButt;
    fanLayer.fillColor = nil;
    fanLayer.path = path.CGPath;
    [fanLayer addAnimation:[self defaultBasicAnimation] forKey:@"fanLayerAnimation"];
    fanLayer.strokeEnd = 1;
    return fanLayer;
}

#pragma mark - 返回一个CABasicAnimation
-(CABasicAnimation*)defaultBasicAnimation
{
    CABasicAnimation *pathAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    pathAnimation.duration = _animationTime;
    pathAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    pathAnimation.fromValue = [NSNumber numberWithFloat:0.0f];
    pathAnimation.toValue = [NSNumber numberWithFloat:1.0f];
    pathAnimation.autoreverses = NO;
    return pathAnimation;
}

@end














