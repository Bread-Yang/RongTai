//
//  localNotificationTransformer.m
//  rongtai
//
//  Created by William-zhang on 15/7/1.
//  Copyright (c) 2015年 William-zhang. All rights reserved.
//

#import "localNotificationTransformer.h"
#import <UIKit/UIKit.h>

@implementation localNotificationTransformer

+ (Class)transformedValueClass
{
    return [NSData class];
}


+ (BOOL)allowsReverseTransformation
{
    return YES;
}

- (id)transformedValue:(id)value
{
    NSMutableData* data = [[NSMutableData alloc]init];
    NSKeyedArchiver* archiver = [[NSKeyedArchiver alloc]initForWritingWithMutableData:data];
    [archiver encodeObject:value forKey:@"ln"];
    [archiver finishEncoding];
    return data;
}


- (id)reverseTransformedValue:(id)value
{
    NSKeyedUnarchiver* unarchiver = [[NSKeyedUnarchiver alloc]initForReadingWithData:value];
    UILocalNotification* ln = [unarchiver decodeObjectForKey:@"ln"];
    [unarchiver finishDecoding];
    return ln;
}


@end
