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
}
@end

@implementation MemberRequest

-(instancetype)init
{
    if (self = [super init]) {
        _manager = [AFHTTPRequestOperationManager manager];
        //不加这句会导致请求失败
        _manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
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
         NSDictionary* dic = [NSJSONSerialization JSONObjectWithData:operation.responseData options:NSJSONReadingAllowFragments error:nil];
        NSLog(@"Image s:%@",dic);
        NSLog(@"Image Success:%@",responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Image Failure:%@",error);
    }];
    //11c6c6b0a1fc901859281520de0ead1a   a49d99fe0976978ca1474130267cdfae
}

#pragma mark - 获取成员列表
-(void)requestMemberListByUid:(NSString *)uid Index:(NSInteger)index Size:(NSInteger)size success:(void (^)(NSArray *))success failure:(void (^)(id))failure
{
    
}


@end
