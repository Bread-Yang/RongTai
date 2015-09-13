//
//  MassageRecord.h
//  rongtai
//
//  Created by William-zhang on 15/8/25.
//  Copyright (c) 2015年 William-zhang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface MassageRecord : NSManagedObject

/**
 *  按摩名称
 */
@property (nonatomic, retain) NSString * name;

/**
 *  按摩程序id
 */
@property (nonatomic, retain) NSNumber* programId;

/**
 *  使用时间
 */
@property (nonatomic, retain) NSNumber * useTime;

/**
 *  开始时间的字符串格式
 */
@property (nonatomic, retain) NSString * date;

/**
 *  状态，未同步到服务器的，状态会变成1，默认值为0，代表是同步数据
 */
@property (nonatomic, retain) NSNumber* state;

/**
 *  用户id
 */
@property (nonatomic, retain) NSString* uid;


-(NSDictionary*)toDictionary;

@end
