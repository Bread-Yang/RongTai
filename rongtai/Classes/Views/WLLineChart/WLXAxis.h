//
//  WLXAxis.h
//  WLLineChart-2.0
//
//  Created by William-zhang on 15/7/7.
//  Copyright (c) 2015年 William-zhang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WLXAxis : UIView

//-------- x轴


/**
 *  x轴的值
 */
@property(nonatomic, strong)NSArray* xValues;

/**
 *  x轴的颜色
 */
@property(nonatomic, strong)UIColor* xColor;

/**
 *  x轴的宽度
 */
@property(nonatomic)CGFloat xLineWidth;

/**
 *  x轴的单位
 */
@property(nonatomic, strong)NSString* xUnit;

/**
 *  x轴数值字体
 */
@property(nonatomic, strong)UIFont* xValueFont;

/**
 *  x轴单位字体
 */
@property(nonatomic, strong)UIFont* xUnitFont;

/**
 *  x轴是否显示
 */
@property(nonatomic)BOOL xAxisHidden;


//-------- 对齐线

/**
 *  显示x轴对齐线，默认不显示
 */
@property(nonatomic)BOOL showXRuler;

/**
 *  对齐线线宽，默认为0.5
 */
@property(nonatomic)CGFloat rulerWidth;

/**
 *  对齐线颜色，默认为浅灰色
 */
@property(nonatomic, strong)UIColor* rulerColor;

//--------- 折线

/**
 *  是否显示点，默认显示
 */
@property(nonatomic)BOOL showPiont;

/**
 *  点是否空心，默认空心
 */
@property(nonatomic)BOOL isPointDashed;

/**
 *  线条颜色，默认蓝色
 */
@property(nonatomic, strong)UIColor* lineColor;

/**
 *  线条宽度，默认为2
 */
@property(nonatomic)CGFloat lineWidth;

/**
 *  折线的点集
 */
@property(nonatomic, copy)NSArray* points;

/**
 *  y轴区间值，即y轴端点的最小值与最大值[minY,maxY]
 */
@property(nonatomic)CGPoint ySection;

/**
 *  x轴区间值，即x轴端点的最小值与最大值[minX,maxX]
 */
@property(nonatomic)CGPoint xSection;


@end
