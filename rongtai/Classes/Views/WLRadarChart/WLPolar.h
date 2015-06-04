//
//  WLPolar.h
//  JYRadarChartDemo
//
//  Created by William-zhang on 15/6/4.
//  Copyright (c) 2015年 William-zhang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WLPolar : UIView

/**
 *  极线图半径
 */
@property (nonatomic, assign) CGFloat r;

/**
 *  坐标最大值
 */
@property (nonatomic, assign) CGFloat maxValue;

/**
 *  坐标最小值
 */
@property (nonatomic, assign) CGFloat minValue;

/**
 *  是否描点（即图形与坐标轴交汇处的点）
 */
@property (nonatomic, assign) BOOL drawPoints;

/**
 *  是否用颜色填充描绘区域，默认为是
 *  否则只是用线连接各个点
 */
@property (nonatomic, assign) BOOL fillArea;

/**
 *  是否显示坐标最大最小值
 */
@property (nonatomic, assign) BOOL showStepText;

/**
 *  绘制区域的透明度
 */
@property (nonatomic, assign) CGFloat colorOpacity;

/**
 *  坐标轴颜色
 */
@property (nonatomic, strong) UIColor *backgroundLineColorRadial;

/**
 *  数据源，存放一个元素为数组的数组，元素数组才是用来存放各个坐标的值
 */
@property (nonatomic, strong) NSArray *dataSeries;

/**
 *  各坐标的名称（排列顺序是从最上面的坐标开始，逆时针方向排列）
 */
@property (nonatomic, strong) NSArray *attributes;

/**
 *  圆的个数
 */
@property (nonatomic, assign) NSUInteger steps;

/**
 *  圆形的背景颜色
 */
@property (nonatomic, strong) UIColor *backgroundFillColor;

/**
 *  坐标轴名称字体
 */
@property (nonatomic, strong) UIFont *scaleFont;


/**
 *  设置颜色数组
 */
- (void)setColors:(NSArray *)colors;

@end
