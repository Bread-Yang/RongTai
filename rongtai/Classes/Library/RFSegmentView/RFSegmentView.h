//
//  RFSegmentView.h
//  RFSegmentView
//
//  Created by 王若风 on 1/15/15.
//  Copyright (c) 2015 王若风. All rights reserved.
//

#import <UIKit/UIKit.h>
@class RFSegmentView;
@protocol RFSegmentViewDelegate <NSObject>
- (void)segmentView:(RFSegmentView*)segmentView SelectIndex:(NSInteger)index;
@end

@interface RFSegmentView : UIView
/**
 *  设置风格颜色 默认蓝色风格
 */
@property(nonatomic ,strong) UIColor *norFontColor;
@property(nonatomic ,strong) UIColor *selFontColor;
@property(nonatomic ,strong) UIColor *norBgColor;
@property(nonatomic ,strong) UIColor *selBgColor;
@property(nonatomic) id<RFSegmentViewDelegate> delegate;
@property(nonatomic) NSInteger numberOfLines;
@property(nonatomic) NSUInteger selectIndex;
@property(nonatomic) CGFloat cornerRadius;
@property(nonatomic, strong)UIColor* LineColor;
@property(nonatomic)CGFloat lineWidth;
@property(nonatomic, strong)NSArray* items;
@property(nonatomic, strong)UIFont* font;

/**
 *  默认构造函数
 *
 *  @param frame frame
 *  @param items title字符串数组
 *
 *  @return 当前实例
 */
- (id)initWithFrame:(CGRect)frame items:(NSArray *)items;

@end
