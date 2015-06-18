//
//  Member.h
//  rongtai
//
//  Created by yoghourt on 6/17/15.
//  Copyright (c) 2015 William-zhang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Member : NSManagedObject

@property (nonatomic, retain) NSDate * birthday;
@property (nonatomic, retain) NSNumber * height;
@property (nonatomic, retain) NSString * heightUnit;
@property (nonatomic, retain) NSString * imageURL;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * sex;
@property (nonatomic, retain) NSNumber * status;
@property (nonatomic, retain) NSNumber * userId;

@end
