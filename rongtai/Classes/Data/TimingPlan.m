//
//  TimingPlan.m
//  rongtai
//
//  Created by William-zhang on 15/7/1.
//  Copyright (c) 2015年 William-zhang. All rights reserved.
//

#import "TimingPlan.h"
#import <UIKit/UIKit.h>


@implementation TimingPlan

@dynamic date;
@dynamic isOn;
@dynamic localNotification;
@dynamic week;
@dynamic massageId;
@dynamic massageName;

#pragma mark - 设置通知
-(void)setLocalNotificationByHour:(NSUInteger)hour Minute:(NSUInteger)minute Week:(NSUInteger)week Message:(NSString*)message
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
    NSDate* new = [calendar dateFromComponents:dateComponents];
    
    //根据当前这一天来得到最近是星期几（week值）的一天
    NSDate* result = [NSDate dateWithTimeInterval:value*24*60*60 sinceDate:new];
//    NSLog(@"计算后的时间:%@",result);
    UILocalNotification* local = [[UILocalNotification alloc]init];
    local.timeZone = [NSTimeZone defaultTimeZone];
    local.fireDate = result;
//    NSLog(@"设置的时间:%@",local.fireDate);

    self.date = local.fireDate;
    
    local.userInfo = [NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"时间:%@",result] forKey:@"time"];
    local.repeatInterval = NSCalendarUnitWeekday;
    local.soundName = UILocalNotificationDefaultSoundName;
    local.alertBody = message;
    
    local.alertLaunchImage = @"iamge";
    local.alertAction = @"action";
    local.hasAction = YES;
//    local.applicationIconBadgeNumber = [UIApplication sharedApplication].applicationIconBadgeNumber+1;
//    local.alertTitle  = [NSString stringWithFormat:@"通知数量:%ld",[UIApplication sharedApplication].applicationIconBadgeNumber+1];
    self.localNotification = local;
    [self addLocalNotification];
}

#pragma mark - 计划时间字符串
-(NSString*)planTime
{
    NSCalendar* calendar = [NSCalendar autoupdatingCurrentCalendar];
    NSDateComponents* dateComponents = [calendar components:NSCalendarUnitHour|NSCalendarUnitMinute fromDate:self.date];
    NSString* time = [NSString stringWithFormat:@"%02ld:%02ld",dateComponents.hour,dateComponents.minute];
    return time;
}

#pragma mark - 添加通知
-(void)addLocalNotification
{
    UILocalNotification* ln = (UILocalNotification*)self.localNotification;
    NSLog(@"添加通知,时间为:%@",ln.fireDate);
    [[UIApplication sharedApplication] scheduleLocalNotification:ln];
}

#pragma mark - 取消通知
-(void)cancelLocalNotification
{
    if (self.localNotification) {
        UILocalNotification* ln = (UILocalNotification*)self.localNotification;
        NSLog(@"取消通知,时间为:%@",ln.fireDate);
        [[UIApplication sharedApplication] cancelLocalNotification:ln];
    }
    else
    {
        NSLog(@"通知对象是空的");
    }
}

@end
