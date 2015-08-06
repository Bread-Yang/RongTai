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

@class MemberRequest;

@protocol MemberRequestDelegate <NSObject>

@optional
-(void)requestTimeOut:(MemberRequest*)request;

@end

@interface MemberRequest : NSObject

/**
 *  超时设置，若设置时间小于等于0，则不启用超时检测，默认为0
 */
@property(nonatomic)NSTimeInterval overTime;

/**
 *  代理
 */
@property(nonatomic, weak) id<MemberRequestDelegate> delegate;

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

/**
 *  取消请求
 */
-(void)cancelRequest;

@end
