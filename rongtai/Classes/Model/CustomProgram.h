//
//  CustomProgram.h
//  rongtai
//
//  Created by yoghourt on 6/17/15.
//  Copyright (c) 2015 William-zhang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface CustomProgram : NSManagedObject

@property (nonatomic, retain) NSNumber * airPressure;
@property (nonatomic, retain) NSNumber * keyPart;
@property (nonatomic, retain) NSNumber * massagePreference;
@property (nonatomic, retain) NSNumber * massageType;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * power;
@property (nonatomic, retain) NSNumber * programId;
@property (nonatomic, retain) NSNumber * speed;
@property (nonatomic, retain) NSNumber * status;
@property (nonatomic, retain) NSNumber * useAid;
@property (nonatomic, retain) NSNumber * useTime;
@property (nonatomic, retain) NSNumber * width;

@end
