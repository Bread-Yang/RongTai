//
//  ProgramCount.m
//  rongtai
//
//  Created by William-zhang on 15/8/25.
//  Copyright (c) 2015年 William-zhang. All rights reserved.
//

#import "ProgramCount.h"


@implementation ProgramCount

@dynamic programId;
@dynamic name;
@dynamic useCount;

#pragma mark - 对象转换为字典
-(NSDictionary*)toDictionary
{
    NSDictionary* dic = @{
                          @"name":self.name,
                          @"count":self.useCount,
                          @"programId":self.programId
                          };
    return dic;
}

@end
