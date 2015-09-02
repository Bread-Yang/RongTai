//
//  ProgramCount.h
//  rongtai
//
//  Created by William-zhang on 15/8/25.
//  Copyright (c) 2015年 William-zhang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface ProgramCount : NSManagedObject

/**
 *  按摩程序id
 */
@property (nonatomic, retain) NSNumber* programId;

/**
 *  按摩名称
 */
@property (nonatomic, retain) NSString * name;

/**
 *  按摩次数
 */
@property (nonatomic, retain) NSNumber * useCount;


/**
 *  未更新的次数
 */
@property (nonatomic, retain) NSNumber * unUpdateCount;

/**
 *  用户uid
 */
@property (nonatomic, retain) NSString* uid;


/**
 *  统计次数数据同步
 */
+(void)synchroUseCountDataFormServer:(BOOL)isUploadLoalData Success:(void(^)())success Fail:(void(^)(NSDictionary* dic)) fail;

/**
 *  本地数据同步至服务器
 */
+(void)synchroLocalDataToServerSuccess:(void(^)())success Fail:(void(^)(NSDictionary* dic)) fail;

/**
 *  对象转换为字典
 */
-(NSDictionary*)toDictionary;

@end
