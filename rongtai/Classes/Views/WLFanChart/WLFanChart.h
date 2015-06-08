//
//  WLFanChart.h
//  WLFanChart
//
//  Created by William-zhang on 15/6/5.
//  Copyright (c) 2015年 William-zhang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WLFanChart : UIView

/**
 *  数据源，一个百分比数组，每一个元素的值都必须为0~1，而且值总和应为1
 */
@property(nonatomic, strong)NSArray* dataSource;

/**
 * 颜色数组，每个扇形对应的颜色
 */
@property(nonatomic, strong)NSArray* colors;

/**
 *  显示百分比的字体，默认字体大小为12
 */
@property(nonatomic, strong)UIFont* percentFont;

/**
 *  显示百分比的字体颜色，默认白色
 */
@property(nonatomic, strong)UIColor* percentColor;

/**
 *  扇形半径，默认为View宽度的一半
 */
@property(nonatomic)CGFloat r;

/**
 *  动画时间
 */
@property(nonatomic)CFTimeInterval animationTime;


@end
