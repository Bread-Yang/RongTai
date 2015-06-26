//
//  Massage.h
//  rongtai
//
//  Created by William-zhang on 15/6/26.
//  Copyright (c) 2015年 William-zhang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Massage : NSObject

/**
 *  按摩描述
 */
@property(nonatomic, strong)NSString* mDescription;

/**
 *  图标链接
 */
@property(nonatomic, strong)NSString* imageUrl;

/**
 *  id
 */
@property(nonatomic)NSInteger massageId;

/**
 *  名称
 */
@property(nonatomic, strong)NSString* name;

/**
 *  力度
 */
@property(nonatomic)NSUInteger power;

/**
 *  气压
 */
@property(nonatomic)NSUInteger pressure;

/**
 *  速度
 */
@property(nonatomic)NSUInteger speed;

/**
 *  宽度
 */
@property(nonatomic)NSUInteger width;


/**
 *  请使用下列方法初始化
 */
-(instancetype)initWithJSON:(NSDictionary*)json;

@end
