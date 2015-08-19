//
//  Massage.m
//  rongtai
//
//  Created by William-zhang on 15/6/26.
//  Copyright (c) 2015年 William-zhang. All rights reserved.
//

#import "MassageProgram.h"

@implementation MassageProgram

- (instancetype)initWithJSON:(NSDictionary *)json {
    if (self = [super init]) {
        _mDescription = [json objectForKey:@"description"];
        _imageUrl = [json objectForKey:@"imageUrl"];
		_binUrl = [json objectForKey:@"binUrl"];
        _commandId = [[json objectForKey:@"commandId"] unsignedIntegerValue];
        _massageId = [[json objectForKey:@"massageId"] unsignedIntegerValue];
        _name = [json objectForKey:@"name"];
        _power = [[json objectForKey:@"power"] unsignedIntegerValue];
        _pressure = [[json objectForKey:@"pressure"] unsignedIntegerValue];
        _speed = [[json objectForKey:@"speed"] unsignedIntegerValue];
        _width = [[json objectForKey:@"width"] unsignedIntegerValue];
    }
    return self;
}

@end
