//
//  Massage.m
//  rongtai
//
//  Created by William-zhang on 15/6/26.
//  Copyright (c) 2015年 William-zhang. All rights reserved.
//

#import "MassageProgram.h"

@implementation MassageProgram

@dynamic mDescription;
@dynamic imageUrl;
@dynamic binUrl;
@dynamic commandId;
@dynamic massageId;
@dynamic name;
@dynamic power;
@dynamic pressure;
@dynamic speed;
@dynamic width;
@dynamic isLocalDummyData;

- (void)setValueByJSON:(NSDictionary*)json {
	self.mDescription = [json objectForKey:@"description"];
	self.imageUrl = [json objectForKey:@"imageUrl"];
	self.binUrl = [json objectForKey:@"binUrl"];
	self.commandId = [json objectForKey:@"commandId"];
	self.massageId = [json objectForKey:@"massageId"];
	self.name = [json objectForKey:@"name"];
	self.power = [json objectForKey:@"power"];
	self.pressure = [json objectForKey:@"pressure"];
	self.speed = [json objectForKey:@"speed"];
	self.width = [json objectForKey:@"width"];
}

@end
