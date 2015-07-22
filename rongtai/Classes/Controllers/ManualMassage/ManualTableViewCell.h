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
-(void)manualTableViewCell:(ManualTableViewCell*)cell Clicked:(NSInteger)index;

@end

@interface ManualTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (weak, nonatomic) IBOutlet UIButton *leftButton;

@property (weak, nonatomic) IBOutlet UIButton *rightButton;

@property (weak, nonatomic) id<ManualTableViewCellDelegate> delegate;

@end
