//
//  ManualHumanView.h
//  rongtai
//
//  Created by William-zhang on 15/7/21.
//  Copyright (c) 2015年 William-zhang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RongTaiConstant.h"
#import "RTMassageChairStatus.h"

@class ManualHumanView;
@protocol ManualHumanViewDelegate <NSObject>

@optional
-(void)maualHumanViewClicked:(ManualHumanView*)view;

@end

@interface ManualHumanView : UIView

@property(nonatomic)BOOL isSelected;

@property(nonatomic, weak)id<ManualHumanViewDelegate> delegate;

- (void)checkButtonByAirBagProgram:(RTMassageChairAirBagProgram)airBagProgram;

@end
