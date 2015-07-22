//
//  UIBarButtonItem+goBack.h
//  rongtai
//
//  Created by William-zhang on 15/7/22.
//  Copyright (c) 2015年 William-zhang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIBarButtonItem (goBack)

/**
 *  快速生成一个返回按钮
 */
+(UIBarButtonItem*)goBackItemByTarget:(id)target Action:(SEL)action;

@end
