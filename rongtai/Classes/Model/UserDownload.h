//
//  UserDownload.h
//  rongtai
//
//  Created by William-zhang on 15/6/29.
//  Copyright (c) 2015年 William-zhang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface UserDownload : NSManagedObject

@property (nonatomic, retain) NSNumber * massageId;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * mDescription;
@property (nonatomic, retain) NSString * imageUrl;
@property (nonatomic, retain) NSNumber * speed;
@property (nonatomic, retain) NSNumber * pressure;
@property (nonatomic, retain) NSNumber * power;
@property (nonatomic, retain) NSNumber * width;
@property (nonatomic, retain) NSNumber * isDownload;
@property (nonatomic, retain) NSNumber * userId;


@end
