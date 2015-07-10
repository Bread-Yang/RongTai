//
//  Member.h
//  rongtai
//
//  Created by yoghourt on 6/17/15.
//  Copyright (c) 2015 William-zhang. All rights reserved.


//  家庭成员

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Member : NSManagedObject

/**
 *  生日
 */
@property (nonatomic, retain) NSDate * birthday;

/**
 *  身高
 */
@property (nonatomic, retain) NSNumber * height;

/**
 *  身高单位
 */
@property (nonatomic, retain) NSString * heightUnit;

/**
 *  头像链接
 */
@property (nonatomic, retain) NSString * imageURL;

/**
 *  名称
 */
@property (nonatomic, retain) NSString * name;

/**
 *  性别
 */
@property (nonatomic, retain) NSNumber * sex;

/**
 *  数据状态（0是无操作，1是添加，2是编辑，3是删除）
 */
@property (nonatomic, retain) NSNumber * status;

/**
 *  用户id
 */
@property (nonatomic, retain) NSNumber * userId;

@end
