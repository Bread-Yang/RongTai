//
//  MassageRequest.h
//  RTAPITest
//
//  Created by William-zhang on 15/6/26.
//  Copyright (c) 2015年 William-zhang. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol MassageRequestDelegate <NSObject>

@optional
/**
 *  获取按摩程序列表结束后
 */
-(void)massageRequestMassageListFinish:(BOOL)success Result:(NSDictionary*)dic;

/**
 *  获取用户下载的按摩程序列表结束后
 */
-(void)massageRequestFavoriteMassageListFinish:(BOOL)success Result:(NSDictionary*)dic;

/**
 *  添加用户按摩程序下载结束后
 */
-(void)massageRequestAddFavoriteMassageFinish:(BOOL)success;

@end

@interface MassageRequest : NSObject

@property(nonatomic, weak)id<MassageRequestDelegate> delegate;

/**
 *  获取按摩程序列表
 */
-(void)requestMassageListByUid:(NSString*)uid Index:(NSInteger)index Size:(NSInteger)size;

/**
 *  获取用户下载的按摩程序列表
 */
-(void)requestFavoriteMassageListByUid:(NSString*)uid Index:(NSInteger)index Size:(NSInteger)size;

/**
 *  添加用户按摩程序下载
 *  参数说明：用户下载按摩程序的id列表，以逗号隔开，例如"3215,3216,3217…"
 */
-(void)requestAddFavoriteMassageByUid:(NSString*)uid MassageIds:(NSString*)masssageIds;

/**
 *  取消请求
 */
-(void)cancelRequest;

@end
