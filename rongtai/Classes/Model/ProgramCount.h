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
 *  对象转换为字典
 */
-(NSDictionary*)toDictionary;

@end
