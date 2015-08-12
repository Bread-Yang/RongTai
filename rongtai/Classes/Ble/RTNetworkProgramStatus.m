//
//  RTNetworkProgramStatus.m
//  rongtai
//
//  Created by yoghourt on 8/11/15.
//  Copyright (c) 2015 William-zhang. All rights reserved.
//

#import "RTNetworkProgramStatus.h"

@implementation RTNetworkProgramStatus

- (NSInteger)getIndexByMassageId:(NSInteger)massageId {
	for (int i = 0; i < [self.networkProgramStatusArray count]; i++) {
		if ((NSInteger)[self.networkProgramStatusArray objectAtIndex:i] == massageId) {
			return i;
		}
	}
	return -1;
}

@end
