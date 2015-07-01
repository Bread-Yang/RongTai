//
//  TimingPlan.h
//  rongtai
//
//  Created by William-zhang on 15/7/1.
//  Copyright (c) 2015年 William-zhang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import <UIKit/UIKit.h>


@interface TimingPlan : NSManagedObject

@property (nonatomic, retain) id localNotification;
@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSNumber * isOn;
@property (nonatomic, retain) NSNumber * week;

@end
