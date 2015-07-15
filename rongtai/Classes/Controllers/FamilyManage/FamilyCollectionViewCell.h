//
//  FamilyCollectionViewCell.h
//  rongtai
//
//  Created by William-zhang on 15/6/12.
//  Copyright (c) 2015年 William-zhang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Member.h"

@interface FamilyCollectionViewCell : UICollectionViewCell

/**
 *  用户
 */
@property(nonatomic, strong) Member *member;

/**
 * 用户头像IamgeView
 */
@property(nonatomic, strong) UIImageView* userIconView;

/**
 * 用户名称Label
 */
@property(nonatomic, strong) UILabel* userNameLabel;

@end
