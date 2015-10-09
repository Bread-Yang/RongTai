//
//  MainViewController.h
//  rongtai
//
//  Created by William-zhang on 15/6/8.
//  Copyright (c) 2015年 William-zhang. All rights reserved.
//

#import "BasicViewController.h"

@interface MainViewController : BasicViewController

/**
 *	从登陆界面跳过来,则重新请求一次网络程序列表
 */
@property (nonatomic, assign) BOOL isFromLoginViewController;

@end
