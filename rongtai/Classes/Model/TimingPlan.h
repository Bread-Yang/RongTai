//
//  TimingPlan.h
//  rongtai
//
//  Created by William-zhang on 15/7/1.
//  Copyright (c) 2015年 William-zhang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface TimingPlan : NSManagedObject

@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSNumber * isOn;
@property (nonatomic, retain) id localNotification;
@property (nonatomic, retain) NSNumber * week;
@property (nonatomic, retain) NSNumber * massageId;
@property (nonatomic, retain) NSString * massageName;

/**
 *  设置通知
 */
-(void)setLocalNotificationByHour:(NSUInteger)hour Minute:(NSUInteger)minute Week:(NSUInteger)week Message:(NSString*)message;

/**
 *  计划时间字符串
 */
-(NSString*)planTime;

/**
 *  添加通知
 */
-(void)addLocalNotification;

/**
 *  取消通知
 */
-(void)cancelLocalNotification;

@end
