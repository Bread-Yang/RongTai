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
    }
    return self;
}

#pragma mark - 上传图片
-(void)uploadImage:(UIImage *)image success:(void (^)(NSString *))success failure:(void (^)(id))failure
{
    NSString* url = @"http://recipe.xtremeprog.com/file/upload";
//    NSString* url = @"http://192.168.2.70:8080/File/upload";
    [_manager POST:url parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) { 
        [formData appendPartWithFileData:UIImageJPEGRepresentation(image, 1) name:@"file1" fileName:@"Image" mimeType:@"image/*"];

    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString* urlKey = [responseObject objectForKey:@"urlKey"];
        if (urlKey) {
            success(urlKey);
        }
        else
        {
            failure(responseObject);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Image Failure:%@",error);
        failure(nil);
    }];
    //11c6c6b0a1fc901859281520de0ead1a   a49d99fe0976978ca1474130267cdfae
}

#pragma mark - 获取成员列表
-(void)requestMemberListByUid:(NSString *)uid Index:(NSInteger)index Size:(NSInteger)size success:(void (^)(NSArray *))success failure:(void (^)(id))failure
{
    NSString* url = [REQUESTURL stringByAppendingString:@"loadMember"];
    NSMutableDictionary* parmeters = [NSMutableDictionary new];
    [parmeters setObject:uid forKey:@"uid"];
    [parmeters setObject:[NSNumber numberWithInteger:index] forKey:@"index"];
    [parmeters setObject:[NSNumber numberWithInteger:size] forKey:@"size"];

    [_manager POST:url parameters:parmeters success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        NSLog(@"获取成员列表:%@",responseObject);
        NSNumber* code = [responseObject objectForKey:@"responseCode"];
        if ([code integerValue] == 200) {
            NSArray* arr = [responseObject objectForKey:@"result"];
            success(arr);
        }
        else
        {
            failure(responseObject);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failure(nil);
    }];
}

#pragma mark - 添加成员
-(void)addMember:(Member *)member ByUid:(NSString *)uid success:(void (^)(NSString *))success failure:(void (^)(id))failure{
    NSString* url = [REQUESTURL stringByAppendingString:@"addMember"];
    NSMutableDictionary* parmeters  = [NSMutableDictionary new];
    [parmeters setObject:uid forKey:@"uid"];
    [parmeters setObject:member.name forKey:@"name"];
    [parmeters setObject:member.sex forKey:@"sex"];
    [parmeters setObject:member.height forKey:@"height"];
    [parmeters setObject:member.heightUnit forKey:@"heightUnit"];
    [parmeters setObject:member.birthday forKey:@"birthday"];
    [parmeters setObject:member.imageURL forKey:@"imageUrl"];
    
    [_manager POST:url parameters:parmeters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"添加成员:%@",responseObject);
        NSNumber* code = [responseObject objectForKey:@"responseCode"];
        if ([code integerValue] == 200) {
            NSDictionary* reslut = [responseObject objectForKey:@"result"];
            NSString* memberId = [reslut objectForKey:@"memberId"];
            success(memberId);
        }
        else
        {
            failure(responseObject);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"添加成员错误:%@",error);
        failure(nil);
    }];
}

#pragma mark - 编辑成员
-(void)editMember:(Member *)member ByUid:(NSString *)uid success:(void (^)(id))success failure:(void (^)(id))failure
{
    NSString* url = [REQUESTURL stringByAppendingString:@"updateMember"];
    NSMutableDictionary* parmeters  = [NSMutableDictionary new];
    [parmeters setObject:uid forKey:@"uid"];
    [parmeters setObject:member.name forKey:@"name"];
    [parmeters setObject:member.sex forKey:@"sex"];
    [parmeters setObject:member.height forKey:@"height"];
    [parmeters setObject:member.heightUnit forKey:@"heightUnit"];
    [parmeters setObject:member.birthday forKey:@"birthday"];
    [parmeters setObject:member.imageURL forKey:@"imageUrl"];
    [parmeters setObject:member.memberId forKey:@"memberId"];
    
    [_manager POST:url parameters:parmeters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"编辑成员:%@",responseObject);
        NSNumber* code = [responseObject objectForKey:@"responseCode"];
        if ([code integerValue] == 200) {
            success(responseObject);
        }
        else
        {
            failure(responseObject);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"编辑成员错误:%@",error);
        failure(nil);
    }];
}

#pragma mark - 删除成员
-(void)deleteMember:(Member *)member ByUid:(NSString *)uid success:(void (^)(id))success failure:(void (^)(id))failure
{
    NSString* url = [REQUESTURL stringByAppendingString:@"deleteMember"];
    NSMutableDictionary* parmeters  = [NSMutableDictionary new];
    [parmeters setObject:uid forKey:@"uid"];
    [parmeters setObject:member.memberId forKey:@"memberId"];
    
    [_manager POST:url parameters:parmeters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"删除成员:%@",responseObject);
        NSNumber* code = [responseObject objectForKey:@"responseCode"];
        if ([code integerValue] == 200) {
            success(responseObject);
        }
        else
        {
            failure(responseObject);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"删除成员错误:%@",error);
        failure(nil);
    }];

}

@end
