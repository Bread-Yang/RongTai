//
//  WLButtonItem.h
//  rongtai
//
//  Created by William-zhang on 15/9/20.
//  Copyright (c) 2015年 William-zhang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WLButtonItem : UIView

/**
 *  图片
 */
@property(nonatomic, strong)UIImage* image;

/**
 *  选中时图片
 */
@property(nonatomic, strong)UIImage* selectedImage;

/**
 *  标题
 */
@property(nonatomic, strong)NSString* title;

/**
 *  内边距
 */
@property(nonatomic)CGFloat edge;

/**
 *  图片与文字间距
 */
@property(nonatomic)CGFloat dlt;

/**
 *  图片比例，文字比例则为(1-图片比例)
 */
@property(nonatomic)CGFloat ImageScale;

/**
 *  字体
 */
@property(nonatomic, strong)UIFont* font;


-(void)setTitleColor:(UIColor*)color;

-(void)setTitleSelectedColor:(UIColor*)color;

-(void)setSelected:(BOOL)selected;
@end
