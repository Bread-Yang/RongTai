//
//  RTNetworkProgramStatus.h
//  rongtai
//
//  Created by yoghourt on 8/11/15.
//  Copyright (c) 2015 William-zhang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MassageProgram.h"

@interface RTNetworkProgramStatus : NSObject

@property (nonatomic, retain) NSArray *networkProgramStatusArray;

/**
 *	用于安装网络程序,四个位,如果是0,就返回该index,如果四个位都满了,就默认返回-1
 */
- (NSInteger)getEmptySlotIndex;

- (NSInteger)getMassageIdBySlotIndex:(NSInteger)index;

/**
 *	用于删除网络程序
 */
- (NSInteger)getSlotIndexByMassageId:(NSInteger)massageId;

/**
 *	网络程序是否已经安装过
 */
- (BOOL)isAlreadyIntall:(NSInteger)massageId;

/**
 *	根据参数是云养程序1, 云养程序2, 云养程序3, 云养程序4,返回该程序的实体
 */
- (MassageProgram *)getNetworkProgramNameBySlotIndex:(NSInteger)slotIndex;

@end
