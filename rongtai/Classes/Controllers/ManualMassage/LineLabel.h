//
//  LineLabel.h
//  rongtai
//
//  Created by William-zhang on 15/7/21.
//  Copyright (c) 2015年 William-zhang. All rights reserved.
//
//  带横线的Label

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, LineLabelType) {
    LineLeftLabel = 0,  //文字在左
    LineRightLabel,     //文字在右
};


@interface LineLabel : UIView

/**
 *  标题Label
 */
@property(nonatomic, readonly)UILabel* titleLabel;

/**
 *  横线
 */
@property(nonatomic, readonly)UIView* line;

/**
 *  选中时的颜色
 */
@property(nonatomic, strong)UIColor* selectedColor;

/**
 *  未选中的颜色
 */
@property(nonatomic, strong)UIColor* unselectedColor;

/**
 *  标题名称
 */
@property(nonatomic, strong)NSString* title;

/**
 *  默认是文字在左
 */
@property(nonatomic, assign)LineLabelType labelType;

/**
 *  是否被选中
 */
@property(nonatomic)BOOL isSelected;

/**
 *  标题字体
 */
@property(nonatomic, strong)UIFont* font;

@end
