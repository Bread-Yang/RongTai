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

@property (nonatomic, assign) NSNumber *planId;
@property (nonatomic, retain) NSString *massageName;
@property (nonatomic, retain) NSNumber *isOn;
@property (nonatomic, retain) id localNotifications;
@property (nonatomic, retain) NSString *days;
@property (nonatomic, retain) NSNumber *massageProgamId;
@property (nonatomic, retain) NSString *ptime;

+ (TimingPlan *)updateTimingPlanDB:(NSDictionary *)dic;

- (void)setValueByJson:(NSDictionary *)json;

- (NSDictionary *)toDictionary;

/**
 *  设置通知
 */
- (void)setLocalNotificationByHour:(NSUInteger)hour Minute:(NSUInteger)minute Week:(NSOrderedSet *)weekdays Message:(NSString*)message;

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
