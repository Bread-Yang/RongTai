//
//  AdjustTableViewCell.h
//  rongtai
//
//  Created by William-zhang on 15/7/20.
//  Copyright (c) 2015年 William-zhang. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AdjustTableViewCell;
@protocol AdjustTableViewCellDelegate <NSObject>

@optional
/**
 *  左边按钮被点击
 */
-(void)adjustTableViewCellLeftButtonClicked:(AdjustTableViewCell*)cell;

/**
 *  右边按钮被点击
 */
-(void)adjustTableViewCellRightButtonClicked:(AdjustTableViewCell*)cell;

@end

@interface AdjustTableViewCell : UITableViewCell

@property(nonatomic, strong)UILabel* titleLable;

@property(nonatomic, strong)UIButton* leftButton;

@property(nonatomic, strong)UIButton* rightButton;

@end
