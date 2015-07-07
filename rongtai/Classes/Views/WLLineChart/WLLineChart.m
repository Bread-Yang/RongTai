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


#pragma mark - 初始化
-(void)setUp
{
    _xAxis = [[WLXAxis alloc]init];
    _yAxis = [[WLYAxis alloc]init];
    _xWidth = 400;
}

#pragma mark - set方法
#pragma mark x轴
-(void)setXWidth:(CGFloat)xWidth
{
    _xWidth = xWidth;
    CGRect f = _xAxis.frame;
    f.size.width = _xWidth;
    _xAxis.frame = f;
    _scroll.contentSize = CGSizeMake(_xWidth, _scroll.contentSize.height);
}



@end
