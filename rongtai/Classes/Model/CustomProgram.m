//
//  CustomProgram.m
//  rongtai
//
//  Created by William-zhang on 15/7/10.
//  Copyright (c) 2015年 William-zhang. All rights reserved.
//

#import "CustomProgram.h"


@implementation CustomProgram

@dynamic airPressure;
@dynamic keyPart;
@dynamic massagePreference;
@dynamic massageType;
@dynamic name;
@dynamic power;
@dynamic programId;
@dynamic speed;
@dynamic status;
@dynamic useAid;
@dynamic useTime;
@dynamic width;

-(NSUInteger)valueByIndex:(NSUInteger)index
{
    NSNumber* value;
    switch (index) {
        case 0:  //使用时机
            value = self.useTime;
            break;
        case 1:  //使用目的
            value = self.useAid;
            break;
        case 2:  //重点部位
            value = self.keyPart;
            break;
        case 3: //按摩手法
            value = self.massageType;
            break;
        case 4: //技术偏好
            value = self.massagePreference;
            break;
        case 5:  //速度
            value = self.speed;
            break;
        case 6:  //气压
            value = self.airPressure;
            break;
        default:
            break;
    }
    return [value integerValue];
}

-(void)setValue:(NSUInteger)value ByIndex:(NSUInteger)index
{
    NSNumber* v = [NSNumber numberWithUnsignedInteger:value];
    switch (index) {
        case 0:  //使用时机
            self.useTime = v;
            break;
        case 1:  //使用目的
            self.useAid = v;
            break;
        case 2:  //重点部位
            self.keyPart = v;
            break;
        case 3: //按摩手法
            self.massageType = v;
            break;
        case 4: //技术偏好
            self.massagePreference = v;
            break;
        case 5:  //速度
            self.speed = v;
            break;
        case 6:  //气压
            self.airPressure = v;
            break;
        default:
            break;
    }
}

@end
