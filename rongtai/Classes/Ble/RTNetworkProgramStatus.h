//
//  RTNetworkProgramStatus.h
//  rongtai
//
//  Created by yoghourt on 8/11/15.
//  Copyright (c) 2015 William-zhang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RTNetworkProgramStatus : NSObject

@property (nonatomic, retain) NSArray *networkProgramStatusArray;

/**
 *	用于安装网络程序,四个位,如果是0,就返回该index,如果四个位都满了,就默认返回1
 */
- (NSInteger)getEmptyPositionIndex;

/**
 *	用于删除网络程序
 */
- (NSInteger)getIndexByMassageId:(NSInteger)massageId;

/**
 *	网络程序是否已经安装过
 */
- (BOOL)isAlreadyIntall:(NSInteger)massageId;

@end
