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

/**
 *  显示百分比
 */
@property(nonatomic)BOOL isShowPercent;

/**
 *  百分比字体
 */
@property(nonatomic, strong)UIFont* percentFont;

/**
 *  百分号字体
 */
@property(nonatomic, strong)UIFont* percentCharFont;

/**
 *  百分比颜色
 */
@property(nonatomic, strong)NSArray* percentColor;

/**
 *  标注名称
 */
@property(nonatomic, strong)NSArray* makersName;

/**
 *  标注名称字体颜色
 */
@property(nonatomic, strong)UIColor* makersNameColor;

/**
 *  标注名称字体
 */
@property(nonatomic, strong)UIFont* markersNameFont;

/**
 *  标注描述
 */
@property(nonatomic, strong)NSArray* makersDescription;

/**
 *  标注描述字体颜色
 */
@property(nonatomic ,strong)UIColor* makersDesColor;

/**
 *  标注描述字体
 */
@property(nonatomic, strong)UIFont* markersDesFont;




@end
