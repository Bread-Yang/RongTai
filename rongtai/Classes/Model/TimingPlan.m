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
    NSDate* date = [NSDate date];
    NSCalendar* calendar = [NSCalendar autoupdatingCurrentCalendar];
    NSDateComponents* dateComponents = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitHour|NSCalendarUnitMinute|NSCalendarUnitSecond|NSCalendarUnitWeekday fromDate:date];
    NSUInteger dWeek = dateComponents.weekday;
    NSInteger value = dWeek - week -7;
    NSDate* result = [NSDate dateWithTimeInterval:value*24*60*60 sinceDate:date];
    NSLog(@"计算后的时间:%@",result);
    
    UILocalNotification* local = [[UILocalNotification alloc]init];
    local.timeZone = [NSTimeZone defaultTimeZone];
    local.fireDate = result;
    NSLog(@"%@",local.fireDate);
    local.userInfo = [NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"时间线:%@",result] forKey:@"time"];
    local.repeatInterval = NSCalendarUnitWeekday;
    local.soundName = UILocalNotificationDefaultSoundName;
    local.alertBody = [NSString stringWithFormat:@"时间:%@",result];
    NSInteger cout = local.applicationIconBadgeNumber;
    cout++;
    local.applicationIconBadgeNumber = cout;
    [[UIApplication sharedApplication] scheduleLocalNotification:local];
}

-(void)didSave
{
    NSLog(@"定时计划保存到数据库");
}


@end
