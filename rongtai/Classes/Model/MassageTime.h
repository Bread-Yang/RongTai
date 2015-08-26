//
//  MassageTime.h
//  rongtai
//
//  Created by William-zhang on 15/8/26.
//  Copyright (c) 2015年 William-zhang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface MassageTime : NSManagedObject

@property (nonatomic, retain) NSNumber * useTime;
@property (nonatomic, retain) NSNumber * year;
@property (nonatomic, retain) NSNumber * month;
@property (nonatomic, retain) NSNumber * day;

@end
