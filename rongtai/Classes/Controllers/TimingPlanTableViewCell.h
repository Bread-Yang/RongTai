//
//  TimingPlanTableViewCell.h
//  rongtai
//
//  Created by William-zhang on 15/7/1.
//  Copyright (c) 2015年 William-zhang. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TimingPlan;

@interface TimingPlanTableViewCell : UITableViewCell

@property(nonatomic, strong) TimingPlan *timingPlan;

- (void)setFrame:(CGRect)frame;

@end
