//
//  FinishMassageViewController.h
//  rongtai
//
//  Created by William-zhang on 15/6/15.
//  Copyright (c) 2015年 William-zhang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BasicViewController.h"
@class MassageRecord;

@interface FinishMassageViewController : BasicViewController

@property (nonatomic, strong) MassageRecord* massageRecord;

/**
 *  保存模式
 */
-(void)saveMode;

@end
