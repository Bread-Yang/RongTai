//
//  RTNetworkProgramStatus.m
//  rongtai
//
//  Created by yoghourt on 8/11/15.
//  Copyright (c) 2015 William-zhang. All rights reserved.
//

#import "RTNetworkProgramStatus.h"

@implementation RTNetworkProgramStatus

- (NSInteger)getEmptyPositionIndex {
	for (int i = 0; i < [self.networkProgramStatusArray count]; i++) {
		NSInteger value = [((NSNumber *)[self.networkProgramStatusArray objectAtIndex:i]) intValue];
		if (value == 0) {
			return i + 1;
		}
	}
	return 1;
}

- (NSInteger)getIndexByMassageId:(NSInteger)massageId {
	for (int i = 0; i < [self.networkProgramStatusArray count]; i++) {
		if ([(NSNumber *)[self.networkProgramStatusArray objectAtIndex:i] intValue] == massageId) {
			return i + 1;
		}
	}
	return -1;
}

- (BOOL)isAlreadyIntall:(NSInteger)massageId {
	for (int i = 0; i < [self.networkProgramStatusArray count]; i++) {
		if ([(NSNumber *)[self.networkProgramStatusArray objectAtIndex:i] intValue] == massageId) {
			return true;
		}
	}
	return false;
}

@end
