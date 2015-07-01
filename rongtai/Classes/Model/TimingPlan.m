//
//  TimingPlan.m
//  rongtai
//
//  Created by William-zhang on 15/7/1.
//  Copyright (c) 2015年 William-zhang. All rights reserved.
//

#import "TimingPlan.h"


@implementation TimingPlan

@dynamic localNotification;
@dynamic date;
@dynamic isOn;
@dynamic week;


-(void)setLocalNotificationByHour:(NSUInteger)hour Minute:(NSUInteger)minute Week:(NSUInteger)week
{
    self.isOn = [NSNumber numberWithBool:YES];
    self.week = [NSNumber numberWithInteger:week];
    NSDate* date = [NSDate date];
    NSCalendar* calendar = [NSCalendar autoupdatingCurrentCalendar];
    NSDateComponents* dateComponents = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitHour|NSCalendarUnitMinute|NSCalendarUnitSecond|NSCalendarUnitWeekday fromDate:date];
    [dateComponents setHour:hour];
    [dateComponents setMinute:minute];
    NSUInteger dWeek = dateComponents.weekday;
    NSInteger value = dWeek - week;
    
    //根据当前这一天来得到最近是星期几（week值）的一天
    NSDate* result = [NSDate dateWithTimeInterval:value*24*60*60 sinceDate:date];
    NSLog(@"计算后的时间:%@",result);
    
    UILocalNotification* local = [[UILocalNotification alloc]init];
    local.timeZone = [NSTimeZone defaultTimeZone];
    local.fireDate = result;
    NSLog(@"设置的时间:%@",local.fireDate);
    
    self.date = local.fireDate;
    
    local.userInfo = [NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"时间线:%@",result] forKey:@"time"];
    local.repeatInterval = NSCalendarUnitWeekday;
    local.soundName = UILocalNotificationDefaultSoundName;
    local.alertBody = [NSString stringWithFormat:@"时间:%@",result];
    NSInteger cout = local.applicationIconBadgeNumber;
    cout++;
    NSLog(@"通知数:%ld",cout);
    local.applicationIconBadgeNumber = cout;
    
}

#pragma mark - 添加通知
-(void)addLocalNotification
{
    UILocalNotification* ln = (UILocalNotification*)self.localNotification;
    [[UIApplication sharedApplication] scheduleLocalNotification:ln];
}

#pragma mark - 取消通知
-(void)cancelLocalNotification
{
    UILocalNotification* ln = (UILocalNotification*)self.localNotification;
    [[UIApplication sharedApplication] cancelLocalNotification:ln];
}

#pragma mark - 重载方法
-(void)didSave
{
    NSLog(@"定时计划保存到数据库");
    if ([self.isOn boolValue]) {
        [self addLocalNotification];
    }
    else
    {
        [self cancelLocalNotification];
    }
}


@end
