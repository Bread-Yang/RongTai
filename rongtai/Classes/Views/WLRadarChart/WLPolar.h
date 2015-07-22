//
//  WLPolar.h
//  JYRadarChartDemo
//
//  Created by William-zhang on 15/6/4.
//  Copyright (c) 2015年 William-zhang. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WLPolar;

@protocol WLPolarDelegate <NSObject>

@optional
-(void)WLPolarMoveFinished:(WLPolar*)polar;

@end

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
*  点是否空心，默认空心
*/
@property(nonatomic)BOOL isPointDashed;

/**
 *  点半径
 */
@property(nonatomic)CGFloat pointR;

/**
 *  线条颜色
 */
@property(nonatomic, strong)UIColor* lineColor;

/**
 *  线条宽度
 */
@property(nonatomic)CGFloat lineWidth;

/**
 *  是否用颜色填充描绘区域
 */
@property (nonatomic, assign) BOOL fillArea;

/**
 *  显示线条
 */
@property(nonatomic, assign)BOOL showLine;

/**
 *  是否显示坐标最大最小值
 */
@property (nonatomic, assign) BOOL showStepText;

/**
 *  坐标轴颜色
 */
@property (nonatomic, strong) UIColor *backgroundLineColorRadial;

/**
 *  数据源
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
 *  填充颜色
 */
@property(nonatomic, strong)UIColor* fillColor;

@end
