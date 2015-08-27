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
@property (nonatomic, retain) NSString * massageName;

/**
 *  使用时间
 */
@property (nonatomic, retain) NSNumber * useTime;

/**
 *  开始时间
 */
@property (nonatomic, retain) NSDate * startTime;

/**
 *  结束时间
 */
@property (nonatomic, retain) NSDate * endTime;

/**
 *  开始时间的字符串格式
 */
@property (nonatomic, retain) NSString * date;

@end
