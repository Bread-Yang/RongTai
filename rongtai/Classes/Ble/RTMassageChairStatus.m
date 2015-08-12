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
    [dic setValue:[NSNumber numberWithInteger:self.kneadWidth] forKey:@"kneadWidth"];
    NSLog(@"按摩椅状态:%@",dic);
}

//- (NSString *)description {
//
//}

@end
