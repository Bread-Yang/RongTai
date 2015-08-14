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

@interface ManualHumanView : UIView

@property(nonatomic)BOOL isSelected;

- (void)checkButtonByAirBagProgram:(RTMassageChairAirBagProgram)airBagProgram;

@end
