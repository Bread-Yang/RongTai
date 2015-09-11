//
//  MassageRecord.m
//  rongtai
//
//  Created by William-zhang on 15/8/25.
//  Copyright (c) 2015年 William-zhang. All rights reserved.
//

#import "MassageRecord.h"


@implementation MassageRecord

@dynamic name;
@dynamic useTime;
@dynamic programId;
@dynamic date;
@dynamic state;
@dynamic uid;
@dynamic startTime;
@dynamic endTime;

-(NSDictionary*)toDictionary
{
    NSDictionary* dic = @{@"name":self.name,@"useTime":self.useTime,@"massageId":self.programId,@"useDate":self.date};
    return dic;
}

-(NSDictionary*)allProperty
{
    NSDictionary* dic = @{@"name":self.name,@"useTime":self.useTime,@"programId":self.programId,@"useDate":self.date,@"startTime":self.startTime,@"endTime":self.endTime};
    return dic;
}

@end
