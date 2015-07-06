//
//  WLDoughnutStatsView.h
//  WLDoughnutStatsView
//
//  Created by William-zhang on 15/7/6.
//  Copyright (c) 2015年 William-zhang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WLDoughnutStatsView : UIView

/**
 *  各个百分比数据，加起来总数应为1
 */
@property(nonatomic, strong)NSArray* percents;

/**
 *  各个圆弧的颜色
 */
@property(nonatomic, strong)NSArray* colors;

/**
 *  各个圆弧间的距离
 */
@property(nonatomic)CGFloat doughnutDistance;

/**
 *  圆弧宽度
 */
@property(nonatomic)CGFloat doughnutWidth;

/**
 *  圆弧半径
 */
@property(nonatomic)CGFloat r;


@end
