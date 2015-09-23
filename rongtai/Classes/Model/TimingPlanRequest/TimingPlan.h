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

/**
 *  id
 */
@property (nonatomic, assign) NSNumber *planId;

/**
 *  按摩名称
 */
@property (nonatomic, retain) NSString *massageName;

/**
 *  是否开启
 */
@property (nonatomic, retain) NSNumber *isOn;

/**
 *  本地通知对象数组
 */
@property (nonatomic, retain) id localNotifications;

/**
 *  重复日期，（比如周一和周三重复，就是“2,3”，不重复则为“0”, 星期日: 1, 星期一 : 2, ..., 星期六 : 7）
 */
@property (nonatomic, retain) NSString *days;

/**
 *  按摩程序id
 */
@property (nonatomic, retain) NSNumber *massageProgamId;

/**
 *  重复时间，（格式为“09：05”）
 */
@property (nonatomic, retain) NSString *ptime;

/**
 *  数据状态
 *  0代表是同步好的数据
 *  1代表是 未同步的 新增 数据
 *  2代表是 未同步的 编辑 数据
 *  3代表是 未同步的 删除 数据
 */
@property (nonatomic, retain) NSNumber *state;

/**
 *  用户uid
 */
@property (nonatomic, retain) NSString* uid;


+ (TimingPlan *)updateTimingPlanDB:(NSDictionary *)dic;

- (void)setValueByJson:(NSDictionary *)json;

- (NSDictionary *)toDictionary;

/**
 *  根据TimingPlan来更新本地通知
 */
//+(void)updateLocalNotificationByNetworkData:(NSArray*)arr;

/**
 * 同步定时计划
 */
+(void)synchroTimingPlanLocalData:(BOOL)isContinue ByCount:(NSUInteger)count Uid:(NSString*)uid Success:(void (^)())success Fail:(void (^)())fail;

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
