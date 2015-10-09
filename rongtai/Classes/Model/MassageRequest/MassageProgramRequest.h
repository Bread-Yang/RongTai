//
//  MassageRequest.h
//  RTAPITest
//
//  Created by William-zhang on 15/6/26.
//  Copyright (c) 2015年 William-zhang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MassageProgram.h"
#import "CustomProgram.h"

@class CustomProgram;

@protocol MassageRequestDelegate <NSObject>

@optional
/**
 *  获取按摩程序列表结束后
 */
-(void)massageRequestNetwrokMassageProgramListFinish:(BOOL)success Result:(NSDictionary*)dic;

/**
 *  获取用户下载的按摩程序列表结束后
 */
-(void)massageRequestFavoriteMassageListFinish:(BOOL)success Result:(NSDictionary*)dic;

/**
 *  添加用户按摩程序下载结束后
 */
-(void)massageRequestAddFavoriteMassageFinish:(BOOL)success;

/**
 *  获取自定义程序列表结束后
 */
-(void)massageRequestCustomProgramListFinish:(BOOL)success Result:(NSDictionary*)dic;

/**
 *  添加自定义程序结束后
 */
-(void)massageRequestAddCustomProgramFinish:(BOOL)success Result:(CustomProgram*)customProgram;

/**
 *  编辑自定义程序结束后
 */
-(void)massageRequestUpdateCustomProgramFinish:(BOOL)success Result:(CustomProgram*)customProgram;

/**
 *  删除自定义程序结束后
 */
-(void)massageRequestDeleteCustomProgramFinish:(BOOL)success Result:(CustomProgram *)customProgram;

@end

@interface MassageProgramRequest : NSObject

@property(nonatomic, weak)id<MassageRequestDelegate> delegate;

+ (instancetype)shareManager;

/**
 *  获取网络按摩程序列表
 */
- (void)requestNetworkMassageProgramListByIndex:(NSInteger)index Size:(NSInteger)size success:(void (^)(NSArray *networkMassageProgramArray))success failure:(void (^)(NSArray *localMassageProgramArray))failure;

/**
 *	得到本地保存的程序列表
 */
- (NSArray *)getAlreadySaveNetworkMassageProgramList;

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
 *  获取自定义程序列表
 */
-(void)requsetCustomProgramListByUid:(NSString*)uid Index:(NSInteger)index Size:(NSInteger)size;

/**
 *  添加自定义程序
 */
-(void)addCustomProgram:(CustomProgram*)customProgram Uid:(NSString*)uid;

/**
 *  编辑自定义程序
 */
-(void)updateCustomProgram:(CustomProgram*)customProgram Uid:(NSString*)uid;

/**
 *  删除自定义程序
 */
-(void)deleteCustomProgram:(CustomProgram*)customProgram Uid:(NSString*)uid;

/**
 *  取消请求
 */
-(void)cancelRequest;

@end
