//
//  LoginRequest.m
//  RTAPITest
//
//  Created by William-zhang on 15/6/25.
//  Copyright (c) 2015年 William-zhang. All rights reserved.
//

#import "LoginRequest.h"
#import <AFNetworking.h>
#import <AFURLRequestSerialization.h>
#import "NSString+RT.h"

#define REQUESTURL @"http://api.gizwits.com/app"
#define APPID @"781b7b9b7e074b1685217537ad1ab1c5"

@interface LoginRequest ()
{
    AFHTTPRequestOperationManager* _manager;
    BOOL _isTimeOut;
}
@end


@implementation LoginRequest

-(instancetype)init
{
    if (self = [super init]) {
        _manager = [AFHTTPRequestOperationManager manager];
        _manager.requestSerializer = [AFJSONRequestSerializer serializer];
        _manager.responseSerializer = [AFImageResponseSerializer serializer];
        [_manager.requestSerializer setValue:APPID forHTTPHeaderField:@"X-Gizwits-Application-Id"];
         //不加这句会导致请求失败
         _manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
        _overTime = 0;
        _isTimeOut = NO;
    }
    return self;
}

#pragma mark - 用户请求验证码
-(void)requestAuthCodeByPhone:(NSString*)phone
{
    //请求前先清空请求队列，以防线程阻塞
//    [self cancelRequest];
    _isTimeOut = YES;
    NSString* url = [NSString stringWithFormat:@"%@/codes",REQUESTURL];
    NSLog(@"请求链接：%@\n请求参数：phone：%@\n",url,phone);
    NSMutableDictionary* parameters = [NSMutableDictionary new];
    [parameters setObject:phone forKey:@"phone"];
    if (_overTime > 0) {
        [self performSelector:@selector(requestTimeOut) withObject:nil afterDelay:_overTime];
    }
    [_manager POST:url parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSError* error;
        NSDictionary* dic = [NSJSONSerialization JSONObjectWithData:operation.responseData options:NSJSONReadingAllowFragments error:&error];
        if (error) {
            NSLog(@"验证码，解析数据出错:%@",error);
        }
        else
        {
            NSLog(@"验证码请求成功:%@",dic);
        }
        //成功后调用代理
        if ([self.delegate respondsToSelector:@selector(loginRequestAuthCodeFinished:)]) {
            [self.delegate loginRequestAuthCodeFinished:YES];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"验证码请求失败:%@",error);
        //失败后调用代理
        if ([self.delegate respondsToSelector:@selector(loginRequestAuthCodeFinished:)]) {
            [self.delegate loginRequestAuthCodeFinished:NO];
        }
    }];
}

#pragma mark - 用户注册
-(void)registerAccountByPhone:(NSString*)phone Password:(NSString*)password Code:(NSString*)code
{
    _isTimeOut = YES;
//    [self cancelRequest];
    NSString* url = [NSString stringWithFormat:@"%@/users",REQUESTURL];
    NSLog(@"请求链接：%@\n请求参数：phone：%@\npassword：%@\ncode：%@\n",url,phone,password,code);
    NSMutableDictionary* parameters = [NSMutableDictionary new];
    [parameters setObject:phone forKey:@"phone"];
    [parameters setObject:password forKey:@"password"];
    [parameters setObject:code forKey:@"code"];
    if (_overTime > 0) {
        [self performSelector:@selector(requestTimeOut) withObject:nil afterDelay:_overTime];
    }
    [_manager POST:url parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSError* error;
        NSDictionary* dic = [NSJSONSerialization JSONObjectWithData:operation.responseData options:NSJSONReadingAllowFragments error:&error];
        if (error) {
            NSLog(@"注册，解析数据出错:%@",error);
            if ([self.delegate respondsToSelector:@selector(loginRequestRegisterAccountFinished:Result:)]) {
                [self.delegate loginRequestRegisterAccountFinished:YES Result:nil];
            }
        }
        else
        {
            NSLog(@"注册成功:%@",dic);
            if ([self.delegate respondsToSelector:@selector(loginRequestRegisterAccountFinished:Result:)]) {
                [self.delegate loginRequestRegisterAccountFinished:YES Result:dic];
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"注册失败:%@",error);
        if ([self.delegate respondsToSelector:@selector(loginRequestRegisterAccountFinished:Result:)]) {
            [self.delegate loginRequestRegisterAccountFinished:NO Result:nil];
        }
    }];
}

#pragma mark - 用户登录
-(void)loginByPhone:(NSString*)phone Password:(NSString*)password
{
    _isTimeOut = YES;
//    [self cancelRequest];
    NSString* url = [NSString stringWithFormat:@"%@/login",REQUESTURL];
    NSLog(@"请求链接：%@\n请求参数：phone：%@\npassword：%@\n",url,phone,password);
    NSMutableDictionary* parameters = [NSMutableDictionary new];
    [parameters setObject:phone forKey:@"username"];
    [parameters setObject:password forKey:@"password"];
    if (_overTime > 0) {
        [self performSelector:@selector(requestTimeOut) withObject:nil afterDelay:_overTime];
    }
    [_manager POST:url parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSError* error;
        NSDictionary* dic = [NSJSONSerialization JSONObjectWithData:operation.responseData options:NSJSONReadingAllowFragments error:&error];
        if (error) {
            NSLog(@"登录，解析数据出错:%@",error);
            if ([self.delegate respondsToSelector:@selector(loginRequestLoginFinished:Result:)]) {
                [self.delegate loginRequestLoginFinished:YES Result:nil];
            }
        }
        else
        {
            NSLog(@"登录成功:%@",dic);
            if ([self.delegate respondsToSelector:@selector(loginRequestLoginFinished:Result:)]) {
                [self.delegate loginRequestLoginFinished:YES Result:dic];
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"登录失败:%@",error);
        if ([self.delegate respondsToSelector:@selector(loginRequestLoginFinished:Result:)]) {
            [self.delegate loginRequestLoginFinished:NO Result:nil];
        }
    }];
}

#pragma mark - 第三方登录
-(void)thirdLoginBySrc:(NSString *)name Uid:(NSString *)uid Token:(NSString *)token
{
    _isTimeOut = YES;
//    [self cancelRequest];
    NSString* url = [NSString stringWithFormat:@"%@/users",REQUESTURL];
//    NSString* auth = [NSString stringWithFormat:@"{\"src\":\"%@\",\"uid\":\"%@\",\"token\":\"%@\"}",name,uid,token];
	if ([NSString isBlankString:token]) {
		return;
	}
    NSMutableDictionary *auth = [NSMutableDictionary new];
    [auth setObject:[NSString stringWithString:name] forKey:@"src"];
    [auth setObject:[NSString stringWithString:uid] forKey:@"uid"];
    [auth setObject:[NSString stringWithString:token] forKey:@"token"];
	NSLog(@"传过去的参数是 : %@", auth);
//    NSLog(@"请求链接：%@\n请求参数：authData：%@\n",url,auth);
    NSMutableDictionary *parameters = [NSMutableDictionary new];
    [parameters setObject:auth forKey:@"authData"];
	
//	NSDictionary *temp = @{@"authData" : @{@"src": @"qq", @"token": @"07F63CF53BF98A6556ABB57AD4E28DB3", @"uid": @"5CAF4D827B2DDAAE2AAF2BEFE945F1E1"}};

    if (_overTime > 0) {
        [self performSelector:@selector(requestTimeOut) withObject:nil afterDelay:_overTime];
    }
    [_manager POST:url parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSError* error;
        NSDictionary* dic = [NSJSONSerialization JSONObjectWithData:operation.responseData options:NSJSONReadingAllowFragments error:&error];
        if (error) {
            NSLog(@"第三方登录，解析数据出错:%@",error);
            if ([self.delegate respondsToSelector:@selector(loginRequestThirdLoginFinished:Result:)]) {
                [self.delegate loginRequestThirdLoginFinished:YES Result:nil];
            }
        }
        else
        {
            NSLog(@"第三方登录成功:%@",dic);
            if ([self.delegate respondsToSelector:@selector(loginRequestThirdLoginFinished:Result:)]) {
                [self.delegate loginRequestThirdLoginFinished:YES Result:dic];
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"第三方登录失败:%@",error);
        if ([self.delegate respondsToSelector:@selector(loginRequestThirdLoginFinished:Result:)]) {
            [self.delegate loginRequestThirdLoginFinished:NO Result:nil];
        }
    }];
}

#pragma mark - 超时方法
-(void)requestTimeOut
{
    if (_isTimeOut) {
        NSLog(@"登陆请求超时");
        [self cancelRequest];
        if ([self.delegate respondsToSelector:@selector(requestTimeOut:)]) {
            [self.delegate requestTimeOut:self];
        }
    }
}

#pragma mark - 取消请求
-(void)cancelRequest
{
    [_manager.operationQueue cancelAllOperations];
}


@end
