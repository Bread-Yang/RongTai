//
//  TimingPlan.h
//  rongtai
//
//  Created by William-zhang on 15/7/1.
//  Copyright (c) 2015年 William-zhang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface TimingPlan : NSManagedObject

@property (nonatomic, retain) NSDate *date;
@property (nonatomic, retain) NSNumber *isOn;
@property (nonatomic, retain) id localNotifications;
@property (nonatomic, retain) id weekdays;
@property (nonatomic, retain) NSNumber *massageId;
@property (nonatomic, retain) NSString *massageName;

/**
 *  设置通知
 */
- (void)setLocalNotificationByHour:(NSUInteger)hour Minute:(NSUInteger)minute Week:(NSOrderedSet *)weekdays Message:(NSString*)message;

/**
 *  计划时间字符串
 */
- (NSString *)planTime;

/**
 *  添加通知
 */
- (void)addLocalNotification:(UILocalNotification *)addNotification;


/**
 *	打开通知
 */
- (void)turnOnLocalNotification;

/**
 *  关闭通知
 */
- (void)cancelLocalNotification;


@end
