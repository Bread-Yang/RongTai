//
//  CustomProcedureViewController.h
//  rongtai
//
//  Created by William-zhang on 15/6/14.
//  Copyright (c) 2015年 William-zhang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MassageMode.h"


@interface CustomProcedureViewController : UIViewController


/**
 *  编辑模式
 */
-(void)editModeWithMassageMode:(MassageMode*)massageMode Index:(NSUInteger)index;


@end
