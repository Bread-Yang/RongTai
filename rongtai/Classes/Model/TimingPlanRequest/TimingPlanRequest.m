//
//  TimingPlanRequest.m
//  rongtai
//
//  Created by William-zhang on 15/8/20.
//  Copyright (c) 2015年 William-zhang. All rights reserved.
//

#import "TimingPlanRequest.h"

@interface TimingPlanRequest ()
{
    AFHTTPRequestOperationManager* _manager;
    NSString* _uid;
    BOOL _isTimeOut;
    NSString* _requestURL;
}
@end

@implementation TimingPlanRequest

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

#pragma mark - 获取定时计划列表
-(void)getTimingPlanListSuccess:(void (^)(NSArray *))success fail:(void (^)(NSDictionary *))fail
{
    _isTimeOut = YES;
    NSString* url = [_requestURL stringByAppendingString:@"loadPlan"];
    NSDictionary* parmeters = [NSDictionary dictionaryWithObject:_uid forKey:@"uid"];
    if (_overTime > 0) {
        [self performSelector:@selector(requestTimeOut) withObject:nil afterDelay:_overTime];
    }
    [_manager POST:url parameters:parmeters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        _isTimeOut = NO;
        NSLog(@"获取定时计划列表:%@",responseObject);
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

#pragma mark - 添加定时计划
-(void)addTimingPlan:(TimingPlan *)timingPlan success:(void (^)(NSUInteger))success fail:(void (^)(NSDictionary *))fail
{
    _isTimeOut = YES;
    NSString* url = [_requestURL stringByAppendingString:@"addPlan"];
//    NSMutableDictionary* parmeters = [NSMutableDictionary dictionaryWithObject:_uid forKey:@"uid"];
    
    //测试用
    NSDictionary* parmeters = @{@"uid":_uid,@"massageName":@"工作减压",@"ptime":@"10:46",@"days":@"1,3,4",@"isOpen":@1,@"massageProgramId":@"1235"};
    if (_overTime > 0) {
        [self performSelector:@selector(requestTimeOut) withObject:nil afterDelay:_overTime];
    }
    [_manager POST:url parameters:parmeters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        _isTimeOut = NO;
//        NSLog(@"添加定时计划:%@",responseObject);
        NSNumber* code = [responseObject objectForKey:@"responseCode"];
        if ([code integerValue] == 200) {
            NSDictionary* dic = [responseObject objectForKey:@"result"];
            NSString* tId = [dic objectForKey:@"planId"];
            NSUInteger timingPlanId = [tId integerValue];
            if (success) {
                 success(timingPlanId);
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

#pragma mark - 修改定时计划
-(void)updateTimingPlan:(TimingPlan *)timingPlan success:(void (^)())success fail:(void (^)(NSDictionary *))fail
{
    _isTimeOut = YES;
    NSString* url = [_requestURL stringByAppendingString:@"updatePlan"];
    //    NSMutableDictionary* parmeters = [NSMutableDictionary dictionaryWithObject:_uid forKey:@"uid"];
    
    //测试用
    NSDictionary* parmeters = @{@"uid":_uid,@"planId":@81,@"massageName":@"工作减压",@"ptime":@"11:40",@"days":@"1,3,4",@"isOpen":@1,@"massageProgramId":@"1235"};
    if (_overTime > 0) {
        [self performSelector:@selector(requestTimeOut) withObject:nil afterDelay:_overTime];
    }
    [_manager POST:url parameters:parmeters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        _isTimeOut = NO;
        NSLog(@"修改定时计划:%@",responseObject);
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

#pragma mark - 删除定时计划
-(void)deleteTimingPlanId:(NSUInteger)timingPlanId success:(void (^)())success fail:(void (^)(NSDictionary *))fail
{
    _isTimeOut = YES;
    NSString* url = [_requestURL stringByAppendingString:@"deletePlan"];
    NSNumber* tId = [NSNumber numberWithInteger:timingPlanId];
    NSDictionary* parmeters = @{@"uid":_uid,@"planId":tId};
    if (_overTime > 0) {
        [self performSelector:@selector(requestTimeOut) withObject:nil afterDelay:_overTime];
    }
    [_manager POST:url parameters:parmeters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        _isTimeOut = NO;
        NSLog(@"删除定时计划:%@",responseObject);
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
        if ([self.delegate respondsToSelector:@selector(timingPlanRequestTimeOut:)]) {
            [self.delegate timingPlanRequestTimeOut:self];
        }
    }
}

#pragma mark - 取消请求
-(void)cancelRequest
{
    [_manager.operationQueue cancelAllOperations];
}

@end
