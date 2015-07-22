//
//  UIBarButtonItem+goBack.m
//  rongtai
//
//  Created by William-zhang on 15/7/22.
//  Copyright (c) 2015年 William-zhang. All rights reserved.
//

#import "UIBarButtonItem+goBack.h"
#import "SlideNavigationController.h"

@implementation UIBarButtonItem (goBack)

+(UIBarButtonItem*)goBackItemByTarget:(id)target Action:(SEL)action
{
      UIBarButtonItem* item = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"icon_back"] style:UIBarButtonItemStylePlain target:target action:action];
    return item;
}


@end
