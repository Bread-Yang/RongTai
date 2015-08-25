//
//  MassageRecord.h
//  rongtai
//
//  Created by William-zhang on 15/8/25.
//  Copyright (c) 2015年 William-zhang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface MassageRecord : NSManagedObject

@property (nonatomic, retain) NSString * massageName;
@property (nonatomic, retain) NSNumber * useTime;
@property (nonatomic, retain) NSDate * startTime;
@property (nonatomic, retain) NSDate * endTime;
@property (nonatomic, retain) NSString * date;

@end
