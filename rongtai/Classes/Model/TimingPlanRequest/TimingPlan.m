//
//  TimingPlan.m
//  rongtai
//
//  Created by William-zhang on 15/7/1.
//  Copyright (c) 2015年 William-zhang. All rights reserved.
//

#import "TimingPlan.h"

@implementation TimingPlan

@dynamic date;
@dynamic isOn;
@dynamic localNotifications;
@dynamic weekdays;
@dynamic massageId;
@dynamic massageName;

#pragma mark - 设置通知

- (void)setLocalNotificationByHour:(NSUInteger)hour Minute:(NSUInteger)minute Week:(NSOrderedSet *)weekdays Message:(NSString*)message {
    self.isOn = [NSNumber numberWithBool:YES];
    self.weekdays = weekdays;
	
	NSDate *todayDate = [NSDate date];
	
	NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
	
	if ([weekdays count] > 0) {    // 星期几可以循环
		
		for (int i = 0; i < [weekdays count]; i++) {
			
			NSDateComponents *setDateComponents = [calendar components:NSCalendarUnitYear | NSCalendarUnitHour |NSCalendarUnitMinute | NSCalendarUnitSecond | NSCalendarUnitWeekday | NSCalendarUnitWeekOfYear fromDate:todayDate];
			
			[setDateComponents setWeekday:((NSInteger)weekdays[i] + 1)];  // 星期日: 1, 星期一 : 2, ..., 星期六 : 7

			[setDateComponents setHour:hour];
			[setDateComponents setMinute:minute];
			
			NSDate *fireDate = [calendar dateFromComponents:setDateComponents]; // 0时区开始计算
			
			UILocalNotification *localNofication = [[UILocalNotification alloc] init];
			localNofication.fireDate = fireDate;
			
			localNofication.userInfo = [NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"时间:%@",fireDate] forKey:@"time"];
			localNofication.soundName = UILocalNotificationDefaultSoundName;
			localNofication.alertBody = message;
			localNofication.repeatInterval = NSCalendarUnitWeekOfYear;
			
			localNofication.alertLaunchImage = @"image";
			localNofication.alertAction = @"action";
			localNofication.hasAction = YES;
			
			NSLog(@"localNofication.repeatInterval : %zd", localNofication.repeatInterval);
			
			[self addLocalNotification:localNofication];
			[[UIApplication sharedApplication] scheduleLocalNotification:localNofication];
		}
		
	} else {	// 不循环
		
		NSDateComponents *setDateComponents = [calendar components:NSCalendarUnitYear | NSCalendarUnitHour |NSCalendarUnitMinute | NSCalendarUnitSecond | NSCalendarUnitWeekday | NSCalendarUnitWeekOfYear fromDate:todayDate];
		
		NSInteger currentHour = setDateComponents.hour;
		NSInteger currentMinute = setDateComponents.minute;
		if ((currentHour * 60 + currentMinute) > (hour * 60 + minute)) {   // 定时计划时间小于当前时间,加一天再添加
			[setDateComponents setWeekday:(setDateComponents.weekday + 1)];
		}
		[setDateComponents setHour:hour];
		[setDateComponents setMinute:minute];
		
		NSDate *fireDate = [calendar dateFromComponents:setDateComponents]; // 0时区开始计算
		
		UILocalNotification *localNofication = [[UILocalNotification alloc] init];
		localNofication.fireDate = fireDate;
		
		localNofication.userInfo = [NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"时间:%@",fireDate] forKey:@"time"];
		localNofication.soundName = UILocalNotificationDefaultSoundName;
		localNofication.alertBody = message;
		
		localNofication.alertLaunchImage = @"image";
		localNofication.alertAction = @"action";
		localNofication.hasAction = YES;
		
		NSLog(@"localNofication.repeatInterval : %zd", localNofication.repeatInterval);
		
		[self addLocalNotification:localNofication];
		[[UIApplication sharedApplication] scheduleLocalNotification:localNofication];
		
	}
	
	self.date = ((UILocalNotification *)((NSMutableArray *)self.localNotifications)[0]).fireDate;
}

#pragma mark - 计划时间字符串

- (NSString *)planTime {
    NSCalendar *calendar = [NSCalendar autoupdatingCurrentCalendar];
    NSDateComponents *dateComponents = [calendar components:NSCalendarUnitHour|NSCalendarUnitMinute fromDate:self.date];
    NSString *time = [NSString stringWithFormat:@"%02d:%02d",dateComponents.hour,dateComponents.minute];
    return time;
}

#pragma mark - 添加通知

- (void)addLocalNotification:(UILocalNotification *)addNotification {
	if (!self.localNotifications) {
		self.localNotifications = [NSMutableArray new];
	}
	[((NSMutableArray *)self.localNotifications) addObject:addNotification];
}

#pragma mark - 打开通知

- (void)turnOnLocalNotification {
	if (self.localNotifications) {
		NSDate *todayDate = [NSDate date];
		NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
		
		NSMutableArray *localNotifications = self.localNotifications;
		
		for (UILocalNotification *item in localNotifications) {
			if (item.repeatInterval == 0) {
				NSDate *fireDate = item.fireDate;
				
				if ([fireDate earlierDate:todayDate] == fireDate) {
					NSDateComponents *fireDateComponents = [calendar components:NSCalendarUnitYear | NSCalendarUnitHour |NSCalendarUnitMinute | NSCalendarUnitSecond | NSCalendarUnitWeekday | NSCalendarUnitWeekOfYear fromDate:fireDate];
					
					NSDateComponents *setDateComponents = [calendar components:NSCalendarUnitYear | NSCalendarUnitHour |NSCalendarUnitMinute | NSCalendarUnitSecond | NSCalendarUnitWeekday | NSCalendarUnitWeekOfYear fromDate:todayDate];
					[setDateComponents setHour:fireDateComponents.hour];
					[setDateComponents setMinute:fireDateComponents.minute];
					
					[setDateComponents setWeekday:setDateComponents.weekday + 1];
					
					item.fireDate = [calendar dateFromComponents:setDateComponents];
				}
			}
			
			[[UIApplication sharedApplication] scheduleLocalNotification:item];
		}
	}
}


#pragma mark - 关闭通知

- (void)cancelLocalNotification {
    if (self.localNotifications) {
		NSMutableArray *localNotifications = self.localNotifications;
		for (UILocalNotification *item in localNotifications) {
			[[UIApplication sharedApplication] cancelLocalNotification:item];
		}
	} else {
        NSLog(@"通知对象是空的");
    }
}

@end
