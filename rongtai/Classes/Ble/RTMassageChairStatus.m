//
//  RTMassageChairStatus.m
//  BLETool
//
//  Created by yoghourt on 5/26/15.
//  Copyright (c) 2015 Jaben. All rights reserved.
//

#import "RTMassageChairStatus.h"

@implementation RTMassageChairStatus

-(void)printStatus
{
    NSMutableDictionary* dic = [NSMutableDictionary new];
    [dic setValue:[NSNumber numberWithInteger:self.massageTechniqueFlag] forKey:@"按摩手法"];
    [dic setValue:[NSNumber numberWithInteger:self.airBagProgram] forKey:@"气囊部位"];
    [dic setValue:[NSNumber numberWithInteger:self.kneadWidthFlag] forKey:@"kneadWidth"];
    NSLog(@"按摩椅状态:%@",dic);
}

-(NSString*)autoMassageNameByIndex:(NSUInteger)index
{
    NSString* name = nil;
    switch (index) {
        case 1:
            name = NSLocalizedString(@"运动恢复", nil);
            break;
        case 2:
            name = NSLocalizedString(@"舒展活络", nil);
            break;
        case 3:
            name = NSLocalizedString(@"休憩促眠", nil);
            break;
        case 4:
            name = NSLocalizedString(@"工作减压", nil);
            break;
        case 5:
            name = NSLocalizedString(@"肩颈重点", nil);
            break;
        case 6:
            name = NSLocalizedString(@"腰椎舒缓", nil);
            break;
        default:
            name = nil;
            break;
    }
    return name;
}

-(NSString *)autoMassageFunctionByIndex:(NSUInteger)index
{
    NSString* function = nil;
    switch (index) {
        case 1:
            function = NSLocalizedString(@"运动恢复功能", nil);
            break;
        case 2:
            function = NSLocalizedString(@"舒展活络功能", nil);
            break;
        case 3:
            function = NSLocalizedString(@"休憩促眠功能", nil);
            break;
        case 4:
            function = NSLocalizedString(@"工作减压功能", nil);
            break;
        case 5:
            function = NSLocalizedString(@"肩颈重点功能", nil);
            break;
        case 6:
            function = NSLocalizedString(@"腰椎舒缓功能", nil);
            break;
        default:
            function = nil;
            break;
    }
    return function;
}

@end
