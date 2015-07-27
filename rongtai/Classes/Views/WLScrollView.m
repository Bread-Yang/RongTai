//
//  WLScrollView.m
//  rongtai
//
//  Created by William-zhang on 15/7/27.
//  Copyright (c) 2015年 William-zhang. All rights reserved.
//

#import "WLScrollView.h"

@implementation WLScrollView

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSLog(@"start");
    [super touchesBegan:touches withEvent:event];
}

-(BOOL)touchesShouldBegin:(NSSet *)touches withEvent:(UIEvent *)event inContentView:(UIView *)view
{
    BOOL r = [super touchesShouldBegin:touches withEvent:event inContentView:view];
    NSLog(@"ddddddd:%d",r);
    return r;
}


-(BOOL)touchesShouldCancelInContentView:(UIView *)view
{
    BOOL r = [super touchesShouldCancelInContentView:view];
    NSLog(@"touchesShouldCancelInContentView:%@,BOOL:%d",view,r);
    return r;
}

@end
