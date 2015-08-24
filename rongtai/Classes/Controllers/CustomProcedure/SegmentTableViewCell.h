//
//  SegmentTableViewCell.h
//  rongtai
//
//  Created by William-zhang on 15/7/15.
//  Copyright (c) 2015年 William-zhang. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SegmentTableViewCell;
@protocol SegmentTableViewCellDelegate <NSObject>

@optional
-(void)segmentTableViewCell:(SegmentTableViewCell*)cell Clicked:(NSUInteger)index;

@end


@interface SegmentTableViewCell : UITableViewCell

/**
 *  标题
 */
@property(nonatomic, strong)NSString* title;

/**
 *  各个选项名称
 */
@property(nonatomic, strong)NSArray* names;

/**
 *  标题Label
 */
@property(nonatomic, strong)UILabel* titleLabel;

/**
 *  选项字体
 */
@property(nonatomic, strong)UIFont* itemFont;

/**
 *  SegmentView的宽度比例
 */
@property(nonatomic)CGFloat segmentViewScale;

/**
 *  选中项
 */
@property(nonatomic)NSUInteger selectedIndex;

/**
 *  代理
 */
@property(nonatomic, weak)id<SegmentTableViewCellDelegate> delegate;

@end
