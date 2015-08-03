//
//  MemberRequest.h
//  rongtai
//
//  Created by William-zhang on 15/7/31.
//  Copyright (c) 2015年 William-zhang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking.h>
#import "Member.h"

@interface MemberRequest : NSObject

/**
 *  上传图片
 */
-(void)uploadImage:(UIImage*)image success:(void (^)(NSString* urlKey))success failure:(void (^)(id responseObject))failure;

/**
 *  获取成员列表
 */
-(void)requestMemberListByUid:(NSString*)uid Index:(NSInteger)index Size:(NSInteger)size success:(void (^)(NSArray* members))success failure:(void (^)(id responseObject))failure;

/**
 *  添加成员列表
 */
-(void)addMember:(Member*)member ByUid:(NSString*)uid success:(void (^)(NSString* memberId))success failure:(void (^)(id responseObject))failure;

/**
 *  编辑成员列表
 */
-(void)editMember:(Member*)member ByUid:(NSString*)uid success:(void (^)(id responseObject))success failure:(void (^)(id responseObject))failure;

/**
 *  删除成员列表
 */
-(void)deleteMember:(Member*)member ByUid:(NSString*)uid success:(void (^)(id responseObject))success failure:(void (^)(id responseObject))failure;

@end
