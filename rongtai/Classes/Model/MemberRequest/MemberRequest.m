//
//  MemberRequest.m
//  rongtai
//
//  Created by William-zhang on 15/7/31.
//  Copyright (c) 2015年 William-zhang. All rights reserved.
//

#import "MemberRequest.h"

#define REQUESTURL @"http://recipe.xtremeprog.com/RongTaiWeb/"

@interface MemberRequest ()
{
    AFHTTPRequestOperationManager* _manager;
    NSString* _uid;
    BOOL _isTimeOut;
}
@end

@implementation MemberRequest

-(instancetype)init
{
    if (self = [super init]) {
        _manager = [AFHTTPRequestOperationManager manager];
        //不加这句会导致请求失败
        _manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
        NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
        _uid = [defaults objectForKey:@"uid"];
        _overTime = 0;
        _isTimeOut = NO;
    }
    return self;
}

#pragma mark - 上传图片
-(void)uploadImage:(UIImage *)image success:(void (^)(NSString *))success failure:(void (^)(id))failure
{
    NSString* url = @"http://recipe.xtremeprog.com/file/upload";
    [_manager POST:url parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) { 
        [formData appendPartWithFileData:UIImageJPEGRepresentation(image, 1) name:@"file1" fileName:@"Image" mimeType:@"image/*"];
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString* urlKey = [responseObject objectForKey:@"urlKey"];
        if (urlKey) {
            if (success) {
                success(urlKey);
            }
        }
        else
        {
            if (failure) {
                 failure(responseObject);
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Image Failure:%@",error);
        if (failure) {
            failure(nil);
        }
    }];
    //11c6c6b0a1fc901859281520de0ead1a   a49d99fe0976978ca1474130267cdfae
}

#pragma mark - 获取成员列表
-(void)requestMemberListByIndex:(NSInteger)index Size:(NSInteger)size success:(void (^)(NSArray *))success failure:(void (^)(id))failure
{
    _isTimeOut = YES;
    NSString* url = [REQUESTURL stringByAppendingString:@"loadMember"];
    NSMutableDictionary* parmeters = [NSMutableDictionary new];
    [parmeters setObject:_uid forKey:@"uid"];
    [parmeters setObject:[NSNumber numberWithInteger:index] forKey:@"index"];
    [parmeters setObject:[NSNumber numberWithInteger:size] forKey:@"size"];
    if (_overTime > 0) {
        [self performSelector:@selector(requestTimeOut) withObject:nil afterDelay:_overTime];
    }
    [_manager POST:url parameters:parmeters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        _isTimeOut = NO;
        NSLog(@"获取成员列表:%@",responseObject);
        NSNumber* code = [responseObject objectForKey:@"responseCode"];
        if ([code integerValue] == 200) {
            NSArray* arr = [responseObject objectForKey:@"result"];
            if (success) {
                success(arr);
            }
        }
        else
        {
            if (failure) {
                failure(responseObject);
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        _isTimeOut = NO;
        if (failure) {
            failure(nil);
        }
    }];
}

#pragma mark - 添加成员
-(void)addMember:(Member *)member success:(void (^)(NSString *))success failure:(void (^)(id))failure{
    _isTimeOut = YES;
    NSString* url = [REQUESTURL stringByAppendingString:@"addMember"];
    NSMutableDictionary* parmeters  = [NSMutableDictionary new];
    [parmeters setObject:member.uid forKey:@"uid"];
    [parmeters setObject:member.name forKey:@"name"];
    [parmeters setObject:member.sex forKey:@"sex"];
    [parmeters setObject:member.height forKey:@"height"];
    [parmeters setObject:member.heightUnit forKey:@"heightUnit"];
    [parmeters setObject:member.birthday forKey:@"birthday"];
    [parmeters setObject:member.imageURL forKey:@"imageUrl"];
    if (_overTime > 0) {
        [self performSelector:@selector(requestTimeOut) withObject:nil afterDelay:_overTime];
    }
    [_manager POST:url parameters:parmeters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        _isTimeOut = NO;
        NSLog(@"添加成员:%@",responseObject);
        NSNumber* code = [responseObject objectForKey:@"responseCode"];
        if ([code integerValue] == 200) {
            NSDictionary* reslut = [responseObject objectForKey:@"result"];
            NSString* memberId = [reslut objectForKey:@"memberId"];
            if (success) {
                success(memberId);
            }
        }
        else
        {
            if (failure) {
                failure(responseObject);
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"添加成员错误:%@",error);
        _isTimeOut = NO;
        if (failure) {
            failure(nil);
        }
    }];
}

#pragma mark - 编辑成员
-(void)editMember:(Member *)member success:(void (^)(id))success failure:(void (^)(id))failure
{
    _isTimeOut = YES;
    NSString* url = [REQUESTURL stringByAppendingString:@"updateMember"];
    NSMutableDictionary* parmeters  = [NSMutableDictionary new];
    [parmeters setObject:_uid forKey:@"uid"];
    [parmeters setObject:member.name forKey:@"name"];
    [parmeters setObject:member.sex forKey:@"sex"];
    [parmeters setObject:member.height forKey:@"height"];
    [parmeters setObject:member.heightUnit forKey:@"heightUnit"];
    [parmeters setObject:member.birthday forKey:@"birthday"];
    [parmeters setObject:member.imageURL forKey:@"imageUrl"];
    [parmeters setObject:member.memberId forKey:@"memberId"];
    if (_overTime > 0) {
        [self performSelector:@selector(requestTimeOut) withObject:nil afterDelay:_overTime];
    }
    [_manager POST:url parameters:parmeters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        _isTimeOut = NO;
        NSLog(@"编辑成员:%@",responseObject);
        NSNumber* code = [responseObject objectForKey:@"responseCode"];
        if ([code integerValue] == 200) {
            if (success) {
                success(responseObject);
            }
        }
        else
        {
            if (failure) {
                failure(responseObject);
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        _isTimeOut = NO;
        NSLog(@"编辑成员错误:%@",error);
        if (failure) {
            failure(nil);
        }
    }];
}

#pragma mark - 删除成员
-(void)deleteMember:(Member *)member success:(void (^)(id))success failure:(void (^)(id))failure
{
    _isTimeOut = YES;
    NSString* url = [REQUESTURL stringByAppendingString:@"deleteMember"];
    NSMutableDictionary* parmeters  = [NSMutableDictionary new];
    [parmeters setObject:_uid forKey:@"uid"];
    [parmeters setObject:member.memberId forKey:@"memberId"];
    if (_overTime > 0) {
        [self performSelector:@selector(requestTimeOut) withObject:nil afterDelay:_overTime];
    }
    [_manager POST:url parameters:parmeters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        _isTimeOut = NO;
        NSLog(@"删除成员:%@",responseObject);
        NSNumber* code = [responseObject objectForKey:@"responseCode"];
        if ([code integerValue] == 200) {
            if (success) {
                success(responseObject);
            }
        }
        else
        {
            if (failure) {
                failure(responseObject);
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        _isTimeOut = NO;
        NSLog(@"删除成员错误:%@",error);
        if (failure) {
            failure(nil);
        }
    }];
}

#pragma mark - 超时方法
-(void)requestTimeOut
{
    if (_isTimeOut) {
        NSLog(@"成员请求超时");
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
