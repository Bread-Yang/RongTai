//
//  DoughnutCollectionViewCell.h
//  rongtai
//
//  Created by William-zhang on 15/6/12.
//  Copyright (c) 2015年 William-zhang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WLDoughnut.h"

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
 *  按摩次数Label
 */
@property(nonatomic, strong)UILabel* countLabel;

/**
 *  进度View
 */
@property(nonatomic, strong)WLDoughnut* doughnut;

/**
 *  标题Label
 */
@property(nonatomic, strong)UILabel *nameLabel;

/**
 *  小标题Label
 */
@property(nonatomic, strong)UILabel* detailLabel;

-(void)changeUIFrame;

@end
