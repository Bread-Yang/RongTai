//
//  WLDoughnut.h
//  WLDoughnut
//
//  Created by William-zhang on 15/6/4.
//  Copyright (c) 2015年 William-zhang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WLDoughnut : UIView

/**
 *  圆环百分比，值为0到1
 */
@property(nonatomic)CGFloat percent;

/**
 *  完成颜色，默认为cyanColor
 */
@property(nonatomic, strong)UIColor* finishColor;

/**
 *  未完成颜色，默认为lightGray
 */
@property(nonatomic, strong)UIColor* unFinishColor;

/**
 *  圆环半径，不设置默认为这个View的width的一半
 */
@property(nonatomic)CGFloat r;

/**
 *  圆环线宽，默认为5
 */
@property(nonatomic)CGFloat lineWidth;

/**
 *  动画时间
 */
@property(nonatomic)CFTimeInterval animationTime;

@end
