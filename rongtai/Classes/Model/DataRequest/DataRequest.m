//
//  DataRequest.m
//  rongtai
//
//  Created by William-zhang on 15/8/20.
//  Copyright (c) 2015年 William-zhang. All rights reserved.
//

#import "DataRequest.h"
#import <AFNetworking.h>
#import "MassageRecord.h"
#import "CoreData+MagicalRecord.h"

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
-(void)getFavoriteProgramCountSuccess:(void (^)(NSArray * arr))success fail:(void (^)(NSDictionary * dic))fail
{
    _isTimeOut = YES;
    NSString* url = [_requestURL stringByAppendingString:@"loadUserData"];
    NSDictionary* parmeters = @{@"uid":_uid};
    if (_overTime > 0) {
        [self performSelector:@selector(requestTimeOut) withObject:nil afterDelay:_overTime];
    }
    [_manager POST:url parameters:parmeters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        _isTimeOut = NO;
//        NSLog(@"获取爱用程序使用次数:%@",responseObject);
        NSNumber* code = [responseObject objectForKey:@"responseCode"];
//        NSString* message = [responseObject objectForKey:@"responseMessage"];
//        NSLog(@"请求结果:%@",message);
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

    //数组需要先转成json格式才能post（字典却不需要）
    NSData* data = [NSJSONSerialization dataWithJSONObject:arr options:NSJSONWritingPrettyPrinted error:nil];
    NSString* str = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
//    NSLog(@"请求参数:%@",str);
    
    NSDictionary* parmeters = @{@"uid":_uid,@"result":str};
    if (_overTime > 0) {
        [self performSelector:@selector(requestTimeOut) withObject:nil afterDelay:_overTime];
    }
    [_manager POST:url parameters:parmeters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        _isTimeOut = NO;
//        NSLog(@"上传程序使用次数:%@",responseObject);
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

#pragma mark - 获取按摩记录
-(void)getMassageRecordFrom:(NSDate*)startDate To:(NSDate*)endDate Success:(void (^)(NSArray *))success fail:(void (^)(NSDictionary *))fail
{
    _isTimeOut = YES;
    NSString* url = [_requestURL stringByAppendingString:@"useDuration"];
    NSDateFormatter* formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSString* startStr = [formatter stringFromDate:startDate];
    NSString* endStr = [formatter stringFromDate:endDate];
    NSDictionary* parmeters = @{@"uid":_uid,@"startDate":startStr,@"endDate":endStr};
    NSLog(@"请求参数:%@",parmeters);
    
    if (_overTime > 0) {
        [self performSelector:@selector(requestTimeOut) withObject:nil afterDelay:_overTime];
    }
    [_manager POST:url parameters:parmeters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        _isTimeOut = NO;
//        NSLog(@"获取按摩记录:%@",responseObject);
        NSNumber* code = [responseObject objectForKey:@"responseCode"];
        //        NSString* message = [responseObject objectForKey:@"responseMessage"];
        //        NSLog(@"请求结果:%@",message);
        if ([code integerValue] == 200) {
            NSArray* arr = [responseObject objectForKey:@"result"];
//            NSLog(@"按摩记录:%@",arr);
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

#pragma mark - 上传按摩记录
-(void)addMassageRecord:(NSArray*)arr Success:(void (^)())success fail:(void (^)(NSDictionary *))fail
{
    _isTimeOut = YES;
    NSString* url = [_requestURL stringByAppendingString:@"addProgramUseDuration"];
    
    //数组需要先转成json格式才能post（字典却不需要）
    NSData* data = [NSJSONSerialization dataWithJSONObject:arr options:NSJSONWritingPrettyPrinted error:nil];
    NSString* str = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"请求参数:%@",str);
    
    NSDictionary* parmeters = @{@"uid":_uid,@"result":str};
    if (_overTime > 0) {
        [self performSelector:@selector(requestTimeOut) withObject:nil afterDelay:_overTime];
    }
    [_manager POST:url parameters:parmeters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        _isTimeOut = NO;
        NSLog(@"上传按摩记录:%@",responseObject);
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

#pragma mark - 同步按摩记录
+(void)synchroMassageRecord
{
    DataRequest* r = [DataRequest new];
    NSString* uid = [[NSUserDefaults standardUserDefaults] objectForKey:@"uid"];
    NSArray* arr = [MassageRecord MR_findAllWithPredicate:[NSPredicate predicateWithFormat:@"(uid == %@) AND (state == 1)",uid]];
    if (arr.count>0) {
        NSMutableArray* records = [NSMutableArray new];
        for (int i = 0; i<arr.count; i++) {
            MassageRecord* record = arr[i];
            NSDictionary* dic = [record toDictionary];
            [records addObject:dic];
        }
        [r addMassageRecord:records Success:^{
            NSLog(@"按摩记录同步成功");
            NSArray* arr = [MassageRecord MR_findAllWithPredicate:[NSPredicate predicateWithFormat:@"(uid == %@) AND (state == 1)",uid]];
            for (MassageRecord* r in arr) {
                r.state = [NSNumber numberWithInt:0];
                
                //同步数据成功就把本地的数据删了，以免按摩越多造成应用程序占用用户的存储量
                [r MR_deleteEntity];
            }
            [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
        } fail:^(NSDictionary *dic) {
            NSLog(@"按摩记录同步失败");
        }];
    }
    else
    {
        NSLog(@"没有需要同步的按摩记录数据");
    }
}

#pragma mark - 超时方法
-(void)requestTimeOut
{
    if (_isTimeOut) {
        NSLog(@"数据中心请求超时");
        [self cancelRequest];
    }
}

#pragma mark - 取消请求
-(void)cancelRequest
{
    [_manager.operationQueue cancelAllOperations];
}

@end
