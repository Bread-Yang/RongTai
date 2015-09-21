//
//  TimingPlan.m
//  rongtai
//
//  Created by William-zhang on 15/7/1.
//  Copyright (c) 2015年 William-zhang. All rights reserved.
//

#import "TimingPlan.h"
#import "CoreData+MagicalRecord.h"
#import "TimingPlanRequest.h"

@implementation TimingPlan

@dynamic planId;
@dynamic isOn;
@dynamic localNotifications;
@dynamic days;
@dynamic massageProgamId;
@dynamic massageName;
@dynamic ptime;
@dynamic state;
@dynamic uid;

- (void)setValueByJson:(NSDictionary *)json {
	self.planId = [NSNumber numberWithInteger:[[json objectForKey:@"planId"] integerValue]];
	self.massageName = [json objectForKey:@"massageName"];
	self.ptime = [json objectForKey:@"ptime"];
	self.days = [json objectForKey:@"days"];
	self.isOn = [NSNumber numberWithBool:[[json objectForKey:@"isOpen"] unsignedIntegerValue] == 1];
	self.massageProgamId = [NSNumber numberWithInteger:[[json objectForKey:@"massageProgramId"] unsignedIntegerValue]];
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
						  @"massageProgramId" : self.massageProgamId
						  };
	return dic;
}

#pragma mark - 设置通知
- (void)setLocalNotificationByHour:(NSUInteger)hour Minute:(NSUInteger)minute Week:(NSOrderedSet *)weekdays Message:(NSString*)message {
//	self.isOn = [NSNumber numberWithBool:YES];
	//    self.days = weekdays ;
	
	NSDate *todayDate = [NSDate date];
	
	NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
	
	if ([weekdays count] > 0) {    // 星期几可以循环
		
		for (int i = 0; i < [weekdays count]; i++) {
			
			NSDateComponents *setDateComponents = [calendar components:NSCalendarUnitYear | NSCalendarUnitHour |NSCalendarUnitMinute | NSCalendarUnitSecond | NSCalendarUnitWeekday | NSCalendarUnitWeekOfYear fromDate:todayDate];
            NSNumber* n = [weekdays objectAtIndex:i];
            NSLog(@"星期：%ld❤️",(long)[n integerValue]);
			[setDateComponents setWeekday:[n integerValue]+1];  // 星期日: 1, 星期一 : 2, ..., 星期六 : 7
			[setDateComponents setHour:hour];
			[setDateComponents setMinute:minute];
            [setDateComponents setSecond:0];
			
			NSDate *fireDate = [calendar dateFromComponents:setDateComponents]; // 0时区开始计算
            NSLog(@"通知时间：%@",fireDate);
			UILocalNotification *localNofication = [[UILocalNotification alloc] init];
			localNofication.fireDate = fireDate;
			
			localNofication.userInfo = [NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"时间:%@",fireDate] forKey:@"time"];
			localNofication.soundName = UILocalNotificationDefaultSoundName;
			localNofication.alertBody = message;
			localNofication.repeatInterval = NSCalendarUnitWeekOfYear;
            localNofication.timeZone = [NSTimeZone defaultTimeZone];
			localNofication.alertLaunchImage = @"image";
			localNofication.alertAction = @"action";
			localNofication.hasAction = YES;
			
//			NSLog(@"localNofication.repeatInterval : %zd", localNofication.repeatInterval);
			
			[self addLocalNotification:localNofication];
			[[UIApplication sharedApplication] scheduleLocalNotification:localNofication];
		}
        NSLog(@"加入通知:%@",self.localNotifications);
		
	}
    else {	// 不循环
		
		NSDateComponents *setDateComponents = [calendar components:NSCalendarUnitYear | NSCalendarUnitHour |NSCalendarUnitMinute | NSCalendarUnitSecond | NSCalendarUnitWeekday | NSCalendarUnitWeekOfYear fromDate:todayDate];
		
		NSInteger currentHour = setDateComponents.hour;
		NSInteger currentMinute = setDateComponents.minute;
		if ((currentHour * 60 + currentMinute) > (hour * 60 + minute)) {   // 定时计划时间小于当前时间,加一天再添加
			[setDateComponents setWeekday:(setDateComponents.weekday + 1)];
		}
		[setDateComponents setHour:hour];
		[setDateComponents setMinute:minute];
        [setDateComponents setSecond:0];
		
		NSDate *fireDate = [calendar dateFromComponents:setDateComponents]; // 0时区开始计算
		
		UILocalNotification *localNofication = [[UILocalNotification alloc] init];
		localNofication.fireDate = fireDate;
		localNofication.userInfo = [NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"时间:%@",fireDate] forKey:@"time"];
		localNofication.soundName = UILocalNotificationDefaultSoundName;
		localNofication.alertBody = message;
		localNofication.timeZone = [NSTimeZone defaultTimeZone];
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


#pragma mark - 同步本地定时计划数据
+(void)synchroTimingPlanLocalData:(BOOL)isContinue ByCount:(NSUInteger)count Uid:(NSString*)uid Success:(void (^)())success Fail:(void (^)())fail
{
    if (isContinue) {
        NSArray* plans = [TimingPlan MR_findAllWithPredicate:[NSPredicate predicateWithFormat:@"(state < 4) AND (state > 0) AND uid == %@",uid]];
        if (plans.count>count) {
            TimingPlan* plan = plans[count];
            NSInteger state = [plan.state integerValue];
            TimingPlanRequest* request = [TimingPlanRequest new];
            if (state == 1)
            {
                //新增数据
                [request addTimingPlan:plan success:^(NSUInteger timingPlanId) {
                    NSLog(@"定时计划 同步新增成功");
                    plan.planId = [NSNumber numberWithUnsignedInteger:timingPlanId];
                    plan.state = [NSNumber numberWithInteger:0];
                    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
                    
                    [TimingPlan synchroTimingPlanLocalData:YES ByCount:count Uid:uid Success:success Fail:fail];
                } fail:^(NSDictionary *dic) {
                    [TimingPlan synchroTimingPlanLocalData:YES ByCount:count+1 Uid:uid Success:success Fail:fail];
                }];
            }
            else if (state == 2)
            {
                //编辑数据
                [request updateTimingPlan:plan success:^(NSDictionary *dic) {
                    NSLog(@"定时计划 同步编辑成功");
                    plan.state = [NSNumber numberWithInteger:0];
                    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
                    
                     [TimingPlan synchroTimingPlanLocalData:YES ByCount:count Uid:uid Success:success Fail:fail];
                } fail:^(NSDictionary *dic) {
                     [TimingPlan synchroTimingPlanLocalData:YES ByCount:count+1 Uid:uid Success:success Fail:fail];
                }];
            }
            else if (state == 3)
            {
                //删除数据
                NSUInteger planId = [plan.planId integerValue];
                [request deleteTimingPlanId:planId success:^{
                    NSLog(@"定时计划 同步删除成功");
                    [plan MR_deleteEntity];
                    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
                    
                   [TimingPlan synchroTimingPlanLocalData:YES ByCount:count Uid:uid Success:success Fail:fail];
                } fail:^(NSDictionary *dic) {
                     [TimingPlan synchroTimingPlanLocalData:YES ByCount:count+1 Uid:uid Success:success Fail:fail];
                }];
            }
        }
        else
        {
            //没有需要的同步数据才去请求列表
            [self getTimingPlanListSuccess:success Fail:fail];
        }
    }
}

#pragma mark - 请求定时计划列表
+(void)getTimingPlanListSuccess:(void(^)())success Fail:(void(^)())fail
{
    //网络请求定时计划列表
    TimingPlanRequest* request = [TimingPlanRequest new];
    [request getTimingPlanListSuccess:^(NSArray *timingPlanList) {
        NSLog(@"定时计划网络请求成功");
        [TimingPlan updateLocalNotificationByNetworkData:timingPlanList Finish:success];
        
    } fail:^(NSDictionary *dic) {
        NSLog(@"定时计划网络请求失败");
        if (fail) {
            fail();
        }
    }];
}

#pragma mark - 根据TimingPlan来更新本地通知
+(void)updateLocalNotificationByNetworkData:(NSArray*)arr Finish:(void(^)())finish
{
    NSString* uid = [[NSUserDefaults standardUserDefaults] objectForKey:@"uid"];
    NSMutableArray* networkData = [NSMutableArray arrayWithArray:arr];
    NSArray* localData = [TimingPlan MR_findAllWithPredicate:[NSPredicate predicateWithFormat:@"uid == %@",uid]];
    for (int i = 0; i < localData.count; i++) {
        TimingPlan* t = localData[i];
        BOOL isExist = NO;
        NSDictionary* dic = [t toDictionary];
        for (int j = 0; j < networkData.count; j++) {
            NSDictionary* networkDic = networkData[j];
            NSNumber* networkPlanId = [networkDic objectForKey:@"planId"];
            if ([t.planId isEqualToNumber:networkPlanId]) {
                isExist = YES;
                NSUInteger state = [t.state integerValue];
                if (state == 0) {
                    if (![dic isEqualToDictionary:networkDic]) {
                        //不一样就需要更新本地数据
                        [t cancelLocalNotification];
                        [t setValueByJson:networkDic];
                        [t updateLocalNotification];
                    }
                }
                else
                {
                    TimingPlanRequest* r = [TimingPlanRequest new];
                    if (state == 1)
                    {
                        //添加
                        [r addTimingPlan:t success:^(NSUInteger timingPlanId) {
                            t.state = [NSNumber numberWithInt:0];
                            [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
                        } fail:^(NSDictionary *dic) {
                            NSLog(@"有定时计划 同步添加失败：%@",[t toDictionary]);
                        }];
                    }
                    else if (state == 2)
                    {
                        //编辑
                        [r updateTimingPlan:t success:^(NSDictionary *dic) {
                            t.state = [NSNumber numberWithInt:0];
                            [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
                        } fail:^(NSDictionary *dic) {
                             NSLog(@"有定时计划 同步编辑失败：%@",[t toDictionary]);
                        }];
                    }
                    else if (state == 3)
                    {
                        //删除
                        [r deleteTimingPlanId:[t.planId integerValue] success:^{
                            t.state = [NSNumber numberWithInt:0];
                            [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
                        } fail:^(NSDictionary *dic) {
                             NSLog(@"有定时计划 同步删除失败：%@",[t toDictionary]);
                        }];
                    }
                }
                [networkData removeObjectAtIndex:j];
                break;
            }
        }
        if (!isExist) {
            //本地数据在网络数据中遍历不到，则该本地数据不应存在，要删除
            [t cancelLocalNotification];
            [t MR_deleteEntity];
            [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
        }
    }
    
    if (networkData.count>0) {
        //便利完成后，若网络数据还不为空，则需要新增数据
        NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
        NSString* uid = [defaults objectForKey:@"uid"];
        for (int i = 0; i<networkData.count; i++) {
            TimingPlan* t = [TimingPlan MR_createEntity];
            [t setValueByJson:networkData[i]];
            t.uid = uid;
            [t updateLocalNotification];
            [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
        }
    }
    
    if (finish) {
        finish();
    }
}

#pragma mark - 根据对象的属性更新通知
-(void)updateLocalNotification
{
    self.localNotifications = nil;
    NSArray* weeks = [self.days componentsSeparatedByString:@","];
    NSMutableOrderedSet* weekSet = [[NSMutableOrderedSet alloc]init];
    for (int i = 0; i<weeks.count; i++) {
        NSString* str = weeks[i];
        NSInteger intWeek = [str integerValue]-1;
        NSNumber* week = [NSNumber numberWithInteger:intWeek];
        [weekSet addObject:week];
    }
    
    NSArray* time = [self.ptime componentsSeparatedByString:@":"];
    if (time.count >= 2) {
        NSString* hourStr = time[0];
        NSUInteger hour = [hourStr integerValue];
        NSString* minStr = time[1];
        NSUInteger min = [minStr integerValue];
        [self setLocalNotificationByHour:hour Minute:min Week:weekSet Message:self.massageName];
        BOOL isOn = [self.isOn boolValue];
        if (!isOn) {
            [self cancelLocalNotification];
        }
    }
    else
    {
        NSLog(@"时间格式错误");
    }
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
