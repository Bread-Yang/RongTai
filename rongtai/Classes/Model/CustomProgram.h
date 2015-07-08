//
//  CustomProgram.h
//  rongtai
//
//  Created by William-zhang on 15/7/8.
//  Copyright (c) 2015年 William-zhang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface CustomProgram : NSManagedObject

@property (nonatomic, retain) id airPressure;
@property (nonatomic, retain) id keyPart;
@property (nonatomic, retain) id massagePreference;
@property (nonatomic, retain) id massageType;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * power;
@property (nonatomic, retain) NSNumber * programId;
@property (nonatomic, retain) NSNumber * speed;
@property (nonatomic, retain) NSNumber * status;
@property (nonatomic, retain) id useAid;
@property (nonatomic, retain) id useTime;
@property (nonatomic, retain) NSNumber * width;

@end
