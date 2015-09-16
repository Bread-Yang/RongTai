//
//  DataCenterViewController.h
//  rongtai
//
//  Created by William-zhang on 15/6/10.
//  Copyright (c) 2015年 William-zhang. All rights reserved.
//  

#import <UIKit/UIKit.h>
#import "BasicViewController.h"

@interface DataCenterViewController : BasicViewController

#pragma mark - 显示HUD
-(void)showHUD;

#pragma mark - 关闭HUD
-(void)hideHUD;

#pragma mark - 快速提示
-(void)showProgressHUDByString:(NSString*)message;

@end
