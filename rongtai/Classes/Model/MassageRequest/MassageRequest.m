//
//  MassageRequest.m
//  RTAPITest
//
//  Created by William-zhang on 15/6/26.
//  Copyright (c) 2015年 William-zhang. All rights reserved.
//

#import "MassageRequest.h"
#import <AFNetworking.h>

#define REQUESTURL @"http://192.168.2.49:8080/RongTaiWeb"
#define APPID @"781b7b9b7e074b1685217537ad1ab1c5"

@interface MassageRequest ()
{
    AFHTTPRequestOperationManager* _manager;
}
@end

@implementation MassageRequest

-(instancetype)init
{
    if (self = [super init]) {
        _manager = [AFHTTPRequestOperationManager manager];
        //不加这句会导致请求失败
        _manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    }
    return self;
}

#pragma mark - 获取按摩程序列表
-(void)requestMassageListByUid:(NSString*)uid Index:(NSInteger)index Size:(NSInteger)size
{
    [self cancelRequest];
    NSString* url = [NSString stringWithFormat:@"%@/loadMassage",REQUESTURL];
    NSLog(@"请求链接：%@\n请求参数：uid：%@\n index:%ld\n size:%ld\n",url,uid,index,size);
    NSMutableDictionary* parameters = [NSMutableDictionary new];
    [parameters setObject:uid forKey:@"uid"];
    [parameters setObject:[NSNumber numberWithInteger:index] forKey:@"index"];
    [parameters setObject:[NSNumber numberWithInteger:size] forKey:@"size"];
    NSLog(@"请求参数:%@",parameters);
    [_manager POST:url parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"获取按摩程序列表成功:%@",responseObject);
        NSNumber* code = [responseObject objectForKey:@"responseCode"];
        if ([code integerValue] == 200) {
            if ([self.delegate respondsToSelector:@selector(massageRequestMassageListFinish:Result:)]) {
                [self.delegate massageRequestMassageListFinish:YES Result:responseObject];
            }
        }
        else
        {
            if ([self.delegate respondsToSelector:@selector(massageRequestMassageListFinish:Result:)]) {
                [self.delegate massageRequestMassageListFinish:NO Result:responseObject];
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"获取按摩程序列表失败:%@",error);
        if ([self.delegate respondsToSelector:@selector(massageRequestMassageListFinish:Result:)]) {
            [self.delegate massageRequestMassageListFinish:NO Result:nil];
        }
    }];
}

#pragma mark - 获取用户下载的按摩程序列表
-(void)requestFavoriteMassageListByUid:(NSString*)uid Index:(NSInteger)index Size:(NSInteger)size
{
    [self cancelRequest];
    NSString* url = [NSString stringWithFormat:@"%@/loadFavoriteMassage",REQUESTURL];
    NSLog(@"请求链接：%@\n请求参数：uid：%@\n index:%ld\n size:%ld\n",url,uid,index,size);
    NSMutableDictionary* parameters = [NSMutableDictionary new];
    [parameters setObject:uid forKey:@"uid"];
    [parameters setObject:[NSNumber numberWithInteger:index] forKey:@"index"];
    [parameters setObject:[NSNumber numberWithInteger:size] forKey:@"size"];
    [_manager POST:url parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"获取用户下载的按摩程序列表成功:%@",responseObject);
        NSNumber* code = [responseObject objectForKey:@"responseCode"];
        if ([code integerValue] == 200) {
            if ([self.delegate respondsToSelector:@selector(massageRequestFavoriteMassageListFinish:Result:)]) {
                [self.delegate massageRequestFavoriteMassageListFinish:YES Result:responseObject];
            }
        }
        else
        {
            if ([self.delegate respondsToSelector:@selector(massageRequestFavoriteMassageListFinish:Result:)]) {
                [self.delegate massageRequestFavoriteMassageListFinish:NO Result:responseObject];
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"获取用户下载的按摩程序列表失败:%@",error);
        if ([self.delegate respondsToSelector:@selector(massageRequestFavoriteMassageListFinish:Result:)]) {
            [self.delegate massageRequestFavoriteMassageListFinish:NO Result:nil];
        }
    }];
}

#pragma mark - 添加用户按摩程序下载
-(void)requestAddFavoriteMassageByUid:(NSString*)uid MassageIds:(NSString*)masssageIds
{
    [self cancelRequest];
    NSString* url = [NSString stringWithFormat:@"%@/addFavorite",REQUESTURL];
    NSLog(@"请求链接：%@\n请求参数：uids:%@\n MassageIds：%@",url,uid,masssageIds);
    NSMutableDictionary* parameters = [NSMutableDictionary new];
    [parameters setObject:uid forKey:@"uid"];
    [parameters setObject:masssageIds forKey:@"massageIds"];
    [_manager POST:url parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"添加用户按摩程序成功:%@",responseObject);
        NSNumber* code = [responseObject objectForKey:@"responseCode"];
        if ([code integerValue] == 200) {
//            NSLog(@"服务器添加成功");
            if ([self.delegate respondsToSelector:@selector(massageRequestAddFavoriteMassageFinish:)]) {
                [self.delegate massageRequestAddFavoriteMassageFinish:YES];
            }
        }
        else
        {
//            NSLog(@"服务器添加失败");
            if ([self.delegate respondsToSelector:@selector(massageRequestAddFavoriteMassageFinish:)]) {
                [self.delegate massageRequestAddFavoriteMassageFinish:NO];
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"添加用户按摩程序失败:%@",error);
        if ([self.delegate respondsToSelector:@selector(massageRequestAddFavoriteMassageFinish:)]) {
            [self.delegate massageRequestAddFavoriteMassageFinish:NO];
        }
    }];
}

#pragma mark - 取消请求
-(void)cancelRequest
{
    [_manager.operationQueue cancelAllOperations];
}




@end
