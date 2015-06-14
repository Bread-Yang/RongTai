//
//  WLCheckButon.h
//  UICheckButton
//
//  Created by William-zhang on 15/6/14.
//  Copyright (c) 2015年 William-zhang. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WLCheckButon;

@protocol WLCheckButtonDelegate <NSObject>

@optional
-(void)checkButton:(WLCheckButon*) checkButton Clicked:(NSInteger)index;

@end

@interface WLCheckButon : UIView

/**
 *  选项名称
 */
@property(nonatomic, strong)NSArray* itemNames;

/**
 *  选中颜色，默认白色
 */
@property(nonatomic, strong)UIColor* selectColor;

/**
 *  未选中颜色，默认浅灰色
 */
@property(nonatomic, strong)UIColor* unselectColor;

/**
 *  字体颜色，默认浅蓝色
 */
@property(nonatomic, strong)UIColor* tintColor;

/**
 *  选择情况
 */
@property(nonatomic)BOOL selectState;

/**
 *  代理
 */
@property(nonatomic, weak)id<WLCheckButtonDelegate> delegate;

@end
