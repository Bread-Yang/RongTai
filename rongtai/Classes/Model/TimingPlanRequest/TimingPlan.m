//
//  TimingPlan.m
//  rongtai
//
//  Created by William-zhang on 15/7/1.
//  Copyright (c) 2015年 William-zhang. All rights reserved.
//

#import "TimingPlan.h"
#import "CoreData+MagicalRecord.h"

@implementation TimingPlan

@dynamic planId;
@dynamic isOn;
@dynamic localNotifications;
@dynamic days;
@dynamic massageProgamId;
@dynamic massageName;
@dynamic ptime;
@dynamic state;

- (void)setValueByJson:(NSDictionary *)json {
	self.planId = [NSNumber numberWithInteger:[[json objectForKey:@"planId"] integerValue]];
	self.massageName = [json objectForKey:@"massageName"];
	self.ptime = [json objectForKey:@"ptime"];
	self.days = [json objectForKey:@"days"];
	self.isOn = [NSNumber numberWithBool:[[json objectForKey:@"isOpen"] unsignedIntegerValue] == 1];
	self.massageProgamId = [NSNumber numberWithInteger:[[json objectForKey:@"massageProgameId"] unsignedIntegerValue]];
}

#pragma mark - 根据一条TimingPlan的Json数据更新数据库

+ (TimingPlan *)updateTimingPlanDB:(NSDictionary *)dic {
	NSInteger planId = [[dic valueForKey:@"planId"] integerValue];
	NSArray *arr = [TimingPlan MR_findByAttribute:@"planId" withValue:[NSNumber numberWithInteger:planId]];
	TimingPlan *m;
	if (arr.count == 0) {
		m = [TimingPlan MR_createEntity];
	} else {
		m = arr[0];
	}
	[m setValueByJson:dic];
	[[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
	return m;
}

#pragma mark - 把TimingPlan转成字典
-(NSDictionary *)toDictionary {
	NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
	
	NSDictionary *dic = @{
						  @"uid" : [defaults objectForKey:@"uid"],
						  @"planId" : self.planId,
						  @"massageName" : self.massageName,
						  @"ptime" : self.ptime,
						  @"days" : self.days,
						  @"isOpen" : self.isOn,
						  @"massageProgameId" : self.massageProgamId
						  };
	return dic;
}

#pragma mark - 设置通知
- (void)setLocalNotificationByHour:(NSUInteger)hour Minute:(NSUInteger)minute Week:(NSOrderedSet *)weekdays Message:(NSString*)message {
	self.isOn = [NSNumber numberWithBool:YES];
	//    self.days = weekdays ;
	
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
}

#pragma mark - 添加通知
- (void)addLocalNotification:(UILocalNotification *)addNotification {
	if (!self.localNotifications) {
		self.localNotifications = [NSMutableArray new];
	}
	[((NSMutableArray *)self.localNotifications) addObject:addNotification];
}

#pragma mark - 根据TimingPlan来更新本地通知
-(void)updateLocalNotification
{
    
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
