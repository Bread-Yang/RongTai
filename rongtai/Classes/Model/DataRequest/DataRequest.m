//
//  DataRequest.m
//  rongtai
//
//  Created by William-zhang on 15/8/20.
//  Copyright (c) 2015年 William-zhang. All rights reserved.
//

#import "DataRequest.h"
#import <AFNetworking.h>

@interface DataRequest ()
{
    AFHTTPRequestOperationManager* _manager;
    NSString* _uid;
    BOOL _isTimeOut;
    NSString* _requestURL;
}
@end

@implementation DataRequest

-(instancetype)init
{
    if (self = [super init]) {
        _manager = [AFHTTPRequestOperationManager manager];
        _manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
        NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
        _uid = [defaults objectForKey:@"uid"];
        _overTime = 0;
        _isTimeOut = NO;
        _requestURL = @"http://recipe.xtremeprog.com/RongTaiWeb/";
    }
    return self;
}

#pragma mark - 获取爱用程序的使用次数
-(void)getFavoriteProgramCountSuccess:(void (^)(NSArray *))success fail:(void (^)(NSDictionary *))fail
{
    _isTimeOut = YES;
    NSString* url = [_requestURL stringByAppendingString:@"loadUserData"];
    NSDictionary* parmeters = @{@"uid":_uid};
    if (_overTime > 0) {
        [self performSelector:@selector(requestTimeOut) withObject:nil afterDelay:_overTime];
    }
    [_manager POST:url parameters:parmeters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        _isTimeOut = NO;
        NSLog(@"获取爱用程序使用次数:%@",responseObject);
        NSNumber* code = [responseObject objectForKey:@"responseCode"];
        if ([code integerValue] == 200) {
            NSArray* arr = [responseObject objectForKey:@"result"];
            if (success) {
                success(arr);
            }
        }
        else
        {
            if (fail) {
                fail(responseObject);
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        _isTimeOut = NO;
        if (fail) {
            fail(nil);
        }
    }];
}

#pragma mark - 上传程序使用次数
-(void)addProgramUsingCount:(NSArray*)arr Success:(void (^)())success fail:(void (^)(NSDictionary *))fail
{
    _isTimeOut = YES;
    NSString* url = [_requestURL stringByAppendingString:@"addUserData"];
    //测试用
    NSDictionary* parmeters = @{@"uid":_uid,@"result":@[
                                                       @{
                                                           @"name":@"舒筋活络",
                                                           @"count":@1,
                                                           @"programId":@2312
                                                       },
                                                        @{
                                                            @"name":@"舒筋活络",
                                                            @"count":@20,
                                                            @"programId":@2313
                                                        }
                                                       ]};
    if (_overTime > 0) {
        [self performSelector:@selector(requestTimeOut) withObject:nil afterDelay:_overTime];
    }
    [_manager POST:url parameters:parmeters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        _isTimeOut = NO;
        NSLog(@"上传程序使用次数:%@",responseObject);
        NSNumber* code = [responseObject objectForKey:@"responseCode"];
        if ([code integerValue] == 200) {
            if (success) {
                success();
            }
        }
        else
        {
            if (fail) {
                fail(responseObject);
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        _isTimeOut = NO;
        if (fail) {
            fail(nil);
        }
    }];
}

#pragma mark - 超时方法
-(void)requestTimeOut
{
    if (_isTimeOut) {
        NSLog(@"定时计划请求超时");
        [self cancelRequest];

    }
}

#pragma mark - 取消请求
-(void)cancelRequest
{
    [_manager.operationQueue cancelAllOperations];
}

@end
