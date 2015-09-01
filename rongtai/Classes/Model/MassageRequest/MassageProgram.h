//
//  Massage.h
//  rongtai
//
//  Created by William-zhang on 15/6/26.
//  Copyright (c) 2015年 William-zhang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface MassageProgram : NSManagedObject

/**
 *  按摩描述
 */
@property (nonatomic, retain) NSString *mDescription;

/**
 *  图标链接
 */
@property (nonatomic, retain) NSString *imageUrl;

/**
 *	bin文件链接
 */
@property (nonatomic, retain) NSString *binUrl;

/**
 *  commnadId
 */
@property (nonatomic, retain) NSNumber *commandId;

/**
 *  id
 */
@property (nonatomic, retain) NSNumber *massageId;

/**
 *  名称
 */
@property (nonatomic, retain) NSString *name;

/**
 *  力度
 */
@property (nonatomic, retain) NSNumber *power;

/**
 *  气压
 */
@property (nonatomic, retain) NSNumber *pressure;

/**
 *  速度
 */
@property (nonatomic, retain) NSNumber *speed;

/**
 *  宽度
 */
@property (nonatomic, retain) NSNumber *width;

/**
 *	是否是本地写死的6个按摩椅自带的模式
 */
@property (nonatomic, retain) NSNumber *isLocalDummyData;


/**
 *  根据字典来设置MassageProgram
 */
- (void)setValueByJSON:(NSDictionary*)json;

@end
