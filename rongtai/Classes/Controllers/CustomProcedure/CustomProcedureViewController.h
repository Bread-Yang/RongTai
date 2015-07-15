//
//  CustomProcedureViewController.h
//  rongtai
//
//  Created by William-zhang on 15/6/14.
//  Copyright (c) 2015年 William-zhang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MassageMode.h"
#import "CustomProgram.h"
#import "BasicViewController.h"


@interface CustomProcedureViewController : BasicViewController


/**
 *  编辑模式
 */
-(void)editModeWithCustomProgram:(CustomProgram*)customProgram Index:(NSUInteger)index;


@end
