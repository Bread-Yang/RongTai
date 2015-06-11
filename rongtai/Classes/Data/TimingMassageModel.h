//
//  TimingMassageModel.h
//  rongtai
//
//  Created by yoghourt on 6/11/15.
//  Copyright (c) 2015 William-zhang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TimingMassageModel : NSObject

@property (nonatomic, assign) NSInteger mode;

@property (nonatomic, assign) NSInteger hour;

@property (nonatomic, assign) NSInteger minute;

@property (nonatomic, copy) NSString* loopDate;

@end
