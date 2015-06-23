//
//  ProcedureManageTableViewCell.h
//  rongtai
//
//  Created by William-zhang on 15/6/19.
//  Copyright (c) 2015年 William-zhang. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CustomProgram;
@class ProcedureManageTableViewCell;

@protocol ProcedureManageTableViewCellDelegate <NSObject>

@optional
-(void)cellDidFinishedChangeName:(ProcedureManageTableViewCell*)cell;

@end

@interface ProcedureManageTableViewCell : UITableViewCell

/**
 *  编辑状态
 */
@property(nonatomic)BOOL isEdit;

/**
 *  自定义按摩类型
 */
@property(nonatomic, strong)CustomProgram* customProgram;

/**
 *  代理
 */
@property(nonatomic, weak)id<ProcedureManageTableViewCellDelegate> delegate;

@end
