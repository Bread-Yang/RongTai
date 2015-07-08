//
//  UserDownload.h
//  rongtai
//
//  Created by William-zhang on 15/6/29.
//  Copyright (c) 2015年 William-zhang. All rights reserved.

//  用户下载程序

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface UserDownload : NSManagedObject

/**
 *  id
 */
@property (nonatomic, retain) NSNumber * massageId;

/**
 *  名称
 */
@property (nonatomic, retain) NSString * name;

/**
 *  描述
 */
@property (nonatomic, retain) NSString * mDescription;

/**
 *  图标链接
 */
@property (nonatomic, retain) NSString * imageUrl;

/**
 *  速度
 */
@property (nonatomic, retain) NSNumber * speed;

/**
 *  气压
 */
@property (nonatomic, retain) NSNumber * pressure;

/**
 *  力度
 */
@property (nonatomic, retain) NSNumber * power;

/**
 *  宽度
 */
@property (nonatomic, retain) NSNumber * width;

/**
 *  是否下载
 */
@property (nonatomic, retain) NSNumber * isDownload;

/**
 *  用户id
 */
@property (nonatomic, retain) NSNumber * userId;


@end
