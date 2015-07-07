//
//  WLYAxis.h
//  WLLineChart-2.0
//
//  Created by William-zhang on 15/7/7.
//  Copyright (c) 2015年 William-zhang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WLYAxis : UIView


/**
 *  y轴数据(字符串格式)
 */
@property(nonatomic, strong)NSArray* yValues;

/**
 *  y轴颜色，默认黑色
 */
@property(nonatomic, strong)UIColor* yColor;

/**
 *  y是否显示，默认显示
 */
@property(nonatomic)BOOL yAxisHidden;

/**
 *  单位，为空时则不显示
 */
@property(nonatomic, strong)NSString* yUnit;

/**
 *  y轴数值字体
 */
@property(nonatomic, strong)UIFont* yValueFont;

/**
 *  单位字体
 */
@property(nonatomic, strong)UIFont* yUnitFont;

/**
 *  y轴线宽，默认1
 */
@property(nonatomic)CGFloat yLineWidth;

/**
 *  x轴高度
 */
@property(nonatomic)CGFloat xHeight;

//-------- 对齐线

/**
 *  显示y轴对齐线，默认不显示
 */
@property(nonatomic)BOOL showYRuler;

/**
 *  对齐线线宽，默认为0.5
 */
@property(nonatomic)CGFloat rulerWidth;

/**
 *  对齐线颜色，默认为浅灰色
 */
@property(nonatomic, strong)UIColor* rulerColor;

@end
