//
//  Member.h
//  rongtai
//
//  Created by yoghourt on 6/17/15.
//  Copyright (c) 2015 William-zhang. All rights reserved.


//  家庭成员

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Member : NSManagedObject

/**
 *  生日
 */
@property (nonatomic, retain) NSDate * birthday;

/**
 *  身高
 */
@property (nonatomic, retain) NSNumber * height;

/**
 *  身高单位
 */
@property (nonatomic, retain) NSString * heightUnit;

/**
 *  头像链接
 */
@property (nonatomic, retain) NSString * imageURL;

/**
 *  名称
 */
@property (nonatomic, retain) NSString * name;

/**
 *  性别（0是男，1是女）
 */
@property (nonatomic, retain) NSNumber * sex;

/**
 *  数据状态（0是无操作，1是添加，2是编辑，3是删除）
 */
@property (nonatomic, retain) NSNumber * status;

/**
 *  用户id
 */
@property (nonatomic, retain) NSNumber * userId;

/**
 *  成员Id
 */
@property (nonatomic, retain) NSNumber* memberId;

/**
 *  用户uid
 */
@property (nonatomic, retain) NSString* uid;

/**
 *  根据字典来设置Member
 */
-(void)setValueBy:(NSDictionary*)dic;

/**
 *  把Member转成字典
 */

-(NSDictionary*)memberToDictionary;

/**
 *  根据一条Member的Json数据更新数据库
 */
+(Member*)updateMemberDB:(NSDictionary*)dic;

@end
