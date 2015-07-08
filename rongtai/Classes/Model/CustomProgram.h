//
//  CustomProgram.h
//  rongtai
//
//  Created by yoghourt on 6/17/15.
//  Copyright (c) 2015 William-zhang. All rights reserved.

//  自定义程序表

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface CustomProgram : NSManagedObject

/**
 *  压力
 */
@property (nonatomic, retain) NSNumber * airPressure;

/**
 *  重点部位
 */
@property (nonatomic, retain) NSNumber * keyPart;

/**
 *  技法偏好
 */
@property (nonatomic, retain) NSNumber * massagePreference;

/**
 *  按摩手法
 */
@property (nonatomic, retain) NSNumber * massageType;

/**
 *  名称
 */
@property (nonatomic, retain) NSString * name;

/**
 *  力度
 */
@property (nonatomic, retain) NSNumber * power;

/**
 *   id
 */
@property (nonatomic, retain) NSNumber * programId;

/**
 *  速度
 */
@property (nonatomic, retain) NSNumber * speed;

/**
 *  数据状态（0是无操作，1是添加，2是编辑，3是删除）
 */
@property (nonatomic, retain) NSNumber * status;

/**
 *  使用目的
 */
@property (nonatomic, retain) NSNumber * useAid;

/**
 *  使用时机
 */
@property (nonatomic, retain) NSNumber * useTime;

/**
 *  宽度
 */
@property (nonatomic, retain) NSNumber * width;

@end
