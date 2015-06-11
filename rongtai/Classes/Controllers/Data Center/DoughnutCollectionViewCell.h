//
//  DoughnutCollectionViewCell.h
//  rongtai
//
//  Created by William-zhang on 15/6/11.
//  Copyright (c) 2015年 William-zhang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DoughnutCollectionViewCell : UICollectionViewCell

/**
 *  按摩名称
 */
@property(nonatomic, strong)NSString* name;

/**
 *  按摩次数
 */
@property(nonatomic)NSUInteger count;

/**
 *  次数比例
 */
@property(nonatomic)CGFloat percent;

-(void)updateFrame;

@end
