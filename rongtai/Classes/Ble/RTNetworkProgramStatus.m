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
	return -1;
}

- (NSInteger)getIntByIndex:(NSInteger)index {
	if (index < 0 || index > [self.networkProgramStatusArray count] - 1) {
		return 0;
	}
	for (int i = 0; i < [self.networkProgramStatusArray count]; i++) {
		if (i == index) {
			return [(NSNumber *)[self.networkProgramStatusArray objectAtIndex:i] intValue];
		}
	}
	return 0;
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
