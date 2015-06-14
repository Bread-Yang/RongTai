//
//  FamilyCollectionViewCell.h
//  rongtai
//
//  Created by William-zhang on 15/6/12.
//  Copyright (c) 2015年 William-zhang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"

@interface FamilyCollectionViewCell : UICollectionViewCell

/**
 *  用户
 */
@property(nonatomic, strong)User* user;

/**
 *  是否显示为添加按钮
 */
@property(nonatomic)BOOL isAdd;

@end
