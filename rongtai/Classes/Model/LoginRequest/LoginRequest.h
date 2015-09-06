//
//  LoginRequest.h
//  RTAPITest
//
//  Created by William-zhang on 15/6/25.
//  Copyright (c) 2015年 William-zhang. All rights reserved.
//

#import <Foundation/Foundation.h>

@class LoginRequest;
@protocol LoginRequestDelegate <NSObject>
@optional

/**
 *  请求验证码结束后
 */
-(void)loginRequestAuthCodeFinished:(BOOL)success;

/**
 *  注册结束后
 */
-(void)loginRequestRegisterAccountFinished:(BOOL)success Result:(NSDictionary*)result;

/**
 *  登录结束后
 */
-(void)loginRequestLoginFinished:(BOOL)success Result:(NSDictionary*)result;

/**
 *  第三方登录结束后
 */
-(void)loginRequestThirdLoginFinished:(BOOL)success Result:(NSDictionary*)result;

/**
 *  超时调用
 */
-(void)loginRequestTimeOut:(LoginRequest*)request;

/**
 *  忘记密码
 */
-(void)loginRequestForgetPasswordFinished:(BOOL)success Result:(NSDictionary*)result;

@end

@interface LoginRequest : NSObject

@property(nonatomic, weak)id<LoginRequestDelegate> delegate;

/**
 *  超时设置，若设置时间小于等于0，则不启用超时检测，默认为0
 */
@property(nonatomic)NSTimeInterval overTime;

/**
 *  通过手机号码请求验证码
 */
-(void)requestAuthCodeByPhone:(NSString*)phone;

/**
 *  注册
 */
-(void)registerAccountByPhone:(NSString*)phone Password:(NSString*)password Code:(NSString*)code;

/**
 *  登录
 */
-(void)loginByPhone:(NSString*)phone Password:(NSString*)password;

/**
 *  第三方登录
 */
-(void)thirdLoginBySrc:(NSString*)name Uid:(NSString*)uid Token:(NSString*)token;

/**
 *  忘记密码
 */
-(void)resetPasswordByByPhone:(NSString*)phone Password:(NSString*)password Code:(NSString*)code;

/**
 *  取消请求
 */
-(void)cancelRequest;

@end
