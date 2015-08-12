//
//  RTNetworkProgramStatus.h
//  rongtai
//
//  Created by yoghourt on 8/11/15.
//  Copyright (c) 2015 William-zhang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RTNetworkProgramStatus : NSObject

@property (nonatomic, retain) NSArray *networkProgramStatusArray;

- (NSInteger)getIndexByMassageId:(NSInteger)massageId;

@end
