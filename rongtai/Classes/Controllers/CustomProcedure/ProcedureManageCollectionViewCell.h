//
//  ProcedureManageCollectionViewCell.h
//  rongtai
//
//  Created by William-zhang on 15/6/14.
//  Copyright (c) 2015年 William-zhang. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MassageMode;

@interface ProcedureManageCollectionViewCell : UICollectionViewCell

/**
 *  按摩模式
 */
@property(nonatomic, strong)MassageMode* massageMode;

@end
