//
//  TimingPlanRequest.h
//  rongtai
//
//  Created by William-zhang on 15/8/20.
//  Copyright (c) 2015年 William-zhang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TimingPlan.h"
#import <AFNetworking.h>

@class TimingPlanRequest;

@protocol TimingPlanDelegate <NSObject>

@optional
/**
 *  请求超时调用该方法
 */
-(void)timingPlanRequestTimeOut:(TimingPlanRequest*)request;

@end

@interface TimingPlanRequest : NSObject

/**
 *  超时设置，若设置时间小于等于0，则不启用超时检测，默认为0
 */
@property(nonatomic)NSTimeInterval overTime;

/**
 *  代理
 */
@property(nonatomic, weak)id<TimingPlanDelegate> delegate;


/**
 *  获取定时计划列表
 */
-(void)getTimingPlanListSuccess:(void (^)(NSArray* timingPlanList))success fail:(void (^)(NSDictionary* dic))fail;;

/**
 *  添加定时计划
 */
-(void)addTimingPlan:(TimingPlan*)timingPlan success:(void (^)(NSUInteger timingPlanId))success fail:(void (^)(NSDictionary* dic))fail;

/**
 *  修改定时计划
 */
-(void)updateTimingPlan:(TimingPlan*)timingPlan success:(void (^)(NSDictionary *dic))success fail:(void (^)(NSDictionary* dic))fail;;

/**
 *  删除定时计划
 */
-(void)deleteTimingPlanId:(NSUInteger)timingPlanId success:(void (^)())success fail:(void (^)(NSDictionary* dic))fail;;

@end
