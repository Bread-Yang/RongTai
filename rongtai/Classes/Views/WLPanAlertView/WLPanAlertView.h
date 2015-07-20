//
//  WLPanAlertView.h
//  WLPanAlertView
//
//  Created by William-zhang on 15/7/17.
//  Copyright (c) 2015年 William-zhang. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WLPanAlertView;
@protocol WLPanAlertViewDelegate <NSObject>

@optional

/**
 *  即将弹出
 */
-(void)wlPanAlertViewWillAlert:(WLPanAlertView*)panAlertView;

/**
 *  即将弹下
 */
-(void)wlPanAlertViewWillDown:(WLPanAlertView*)panAlertView;

/**
 *  弹出完成
 */
-(void)wlPanAlertViewDidAlert:(WLPanAlertView*)panAlertView;

/**
 *  弹下完成
 */
-(void)wlPanAlertViewDidDown:(WLPanAlertView*)panAlertView;

/**
 *  拖拽中
 */
-(void)wlPanAlertViewDidPan:(WLPanAlertView*)panAlertView ByDirection:(BOOL)isDown;

@end

@interface WLPanAlertView : UIView

/**
 *  弹出的View，包含buttonView和contentView
 */
@property(nonatomic, strong)UIView* alertView;

/**
 *  未弹出时可见部分，点击或拖拽都可以弹出View
 */
@property(nonatomic, strong)UIView* buttonView;

/**
 *  未弹出时不可见部分
 */
@property(nonatomic, strong)UIView* contentView;

/**
 *  背景颜色，默认黑色
 */
@property(nonatomic, strong)UIColor* backgroundColor;

/**
 *  背景透明度，默认0.1
 */
@property(nonatomic, assign)CGFloat backgroundAlpha;

/**
 *  代理
 */
@property(nonatomic, weak)id<WLPanAlertViewDelegate> delegate;

@end
