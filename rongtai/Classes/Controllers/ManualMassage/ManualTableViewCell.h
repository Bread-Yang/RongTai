//
//  ManualTableViewCell.h
//  rongtai
//
//  Created by William-zhang on 15/7/20.
//  Copyright (c) 2015年 William-zhang. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ManualTableViewCell;
@protocol ManualTableViewCellDelegate <NSObject>

@optional
/**
 *  cell按钮被点击时调用，index是0为左边按钮，index是1为右边按钮
 */
-(void)manualTableViewCell:(ManualTableViewCell*)cell Clicked:(NSInteger)index UIControlEvents:(UIControlEvents)controlEvent;

@end

@interface ManualTableViewCell : UITableViewCell

/**
 *  标题
 */
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

/**
 *  左边按钮
 */
@property (weak, nonatomic) IBOutlet UIButton *leftButton;

/**
 *  右边按钮
 */
@property (weak, nonatomic) IBOutlet UIButton *rightButton;

/**
 *  代理
 */
@property (weak, nonatomic) id<ManualTableViewCellDelegate> delegate;

@end
