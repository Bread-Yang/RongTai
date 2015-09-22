//
//  MassageRequest.m
//  RTAPITest
//
//  Created by William-zhang on 15/6/26.
//  Copyright (c) 2015年 William-zhang. All rights reserved.
//

#import <AFNetworking.h>

#import "MassageProgramRequest.h"
#import "CoreData+MagicalRecord.h"
#import "RongTaiConstant.h"
#import "MBProgressHUD.h"
#import "AppDelegate.h"
#import "AFHTTPRequestOperationManager+timeout.h"

#define REQUESTURL @"http://recipe.xtremeprog.com/RongTaiWeb/"


@interface MassageProgramRequest () {
	
    AFHTTPRequestOperationManager* _manager;
	
}

@property(nonatomic) NSTimeInterval overTime;

@end

@implementation MassageProgramRequest

-(instancetype)init {
    if (self = [super init]) {
        _manager = [AFHTTPRequestOperationManager manager];
        //不加这句会导致请求失败
        _manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
		
		_overTime = 30;
    }
    return self;
}

#pragma mark - 获取网络按摩程序列表

- (void)requestNetworkMassageProgramListByIndex:(NSInteger)index Size:(NSInteger)size success:(void (^)(NSArray *))success failure:(void (^)(NSArray *))failure {
	
	NSString *url = [RongTaiDefaultDomain stringByAppendingString:@"loadMassage"];
	NSString *uid = [[NSUserDefaults standardUserDefaults] objectForKey:@"uid"];
	
	NSMutableDictionary* parameters = [NSMutableDictionary new];
	[parameters setObject:uid forKey:@"uid"];
	[parameters setObject:[NSNumber numberWithInteger:index] forKey:@"index"];
	[parameters setObject:[NSNumber numberWithInteger:size] forKey:@"size"];
	
	[_manager POST:url parameters:parameters timeoutInterval:_overTime success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSLog(@"获取按摩程序列表成功:%@",responseObject);
		
		NSNumber *code = [responseObject objectForKey:@"responseCode"];
		
		if ([code integerValue] == 200) {
			
			[MassageProgram MR_truncateAllInContext:[NSManagedObjectContext MR_defaultContext]];
			
			NSArray *arr = [responseObject objectForKey:@"result"];
			
//			NSLog(@"用户下载列表:%@",arr);
			
			NSMutableArray *networkMassageProgramArray = [[NSMutableArray alloc] init];
			
			if (arr.count > 0) {
				for (int i = 0; i < arr.count; i++) {
					MassageProgram *massage = [MassageProgram MR_createEntity];
//                    NSLog(@"😄%d：%@",i,arr[i]);
					[massage setValueByJSON:arr[i]];
                    [networkMassageProgramArray addObject:massage];
                    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
				}
			}
			
			if (success) {
				success([networkMassageProgramArray copy]);
			}
			
		} else {
			NSLog(@"获取按摩程序列表失败:responseCode不等于200");
			
			if (failure) {
				failure([self getAlreadySaveNetworkMassageProgramList]);
			}
		}
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		NSLog(@"获取按摩程序列表失败:%@",error);
		NSLog(@"error._code : %zd", error.code);
		
		if (failure) {
			failure([self getAlreadySaveNetworkMassageProgramList]);
		}
		
		if (error.code == NSURLErrorTimedOut) {  // 超时
			[self requestTimeOut];
		}
		
	}];
}

- (NSArray *)getAlreadySaveNetworkMassageProgramList {
	NSArray *localMassageProgram = [MassageProgram MR_findAll];
	
	return localMassageProgram;
}

#pragma mark - 获取用户下载的按摩程序列表
-(void)requestFavoriteMassageListByUid:(NSString*)uid Index:(NSInteger)index Size:(NSInteger)size
{
//    [self cancelRequest];
    NSString* url = [NSString stringWithFormat:@"%@/loadFavoriteMassage",REQUESTURL];
    NSLog(@"请求链接：%@\n请求参数：uid：%@\n index:%ld\n size:%ld\n",url,uid,(long)index,size);
    NSMutableDictionary* parameters = [NSMutableDictionary new];
    [parameters setObject:uid forKey:@"uid"];
    [parameters setObject:[NSNumber numberWithInteger:index] forKey:@"index"];
    [parameters setObject:[NSNumber numberWithInteger:size] forKey:@"size"];
    [_manager POST:url parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        NSLog(@"获取用户下载的按摩程序列表成功:%@",responseObject);
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
//    [self cancelRequest];
    NSString* url = [NSString stringWithFormat:@"%@/addFavorite",REQUESTURL];
    NSLog(@"请求链接：%@\n请求参数：uids:%@\n MassageIds：%@",url,uid,masssageIds);
    NSMutableDictionary* parameters = [NSMutableDictionary new];
    [parameters setObject:uid forKey:@"uid"];
    [parameters setObject:masssageIds forKey:@"massageIds"];
    [_manager POST:url parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        NSLog(@"添加用户按摩程序成功:%@",responseObject);
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

//=========  自定义程序请求方法  ==========//

#pragma mark - 获取自定义程序列表
-(void)requsetCustomProgramListByUid:(NSString*)uid Index:(NSInteger)index Size:(NSInteger)size
{
//    [self cancelRequest];
    NSString* url = [NSString stringWithFormat:@"%@/loadCustomProgram",REQUESTURL];
    NSLog(@"请求链接：%@\n请求参数：uid：%@\n index:%ld\n size:%ld\n",url,uid,index,size);
    NSMutableDictionary* parameters = [NSMutableDictionary new];
    [parameters setObject:uid forKey:@"uid"];
    [parameters setObject:[NSNumber numberWithInteger:index] forKey:@"index"];
    [parameters setObject:[NSNumber numberWithInteger:size] forKey:@"size"];
    [_manager POST:url parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        NSLog(@"获取自定义程序列表成功:%@",responseObject);
        NSNumber* code = [responseObject objectForKey:@"responseCode"];
        if ([code integerValue] == 200) {
            if ([self.delegate respondsToSelector:@selector(massageRequestCustomProgramListFinish:Result:)]) {
                [self.delegate massageRequestCustomProgramListFinish:YES Result:responseObject];
            }
        }
        else
        {
            if ([self.delegate respondsToSelector:@selector(massageRequestCustomProgramListFinish:Result:)]) {
                [self.delegate massageRequestCustomProgramListFinish:NO Result:responseObject];
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"获取自定义程序列表失败:%@",error);
        if ([self.delegate respondsToSelector:@selector(massageRequestCustomProgramListFinish:Result:)]) {
            [self.delegate massageRequestCustomProgramListFinish:NO Result:nil];
        }
    }];
}


#pragma mark - 添加自定义程序
-(void)addCustomProgram:(CustomProgram*)customProgram Uid:(NSString*)uid
{
//    [self cancelRequest];
    NSString* url = [NSString stringWithFormat:@"%@/addCustomProgram",REQUESTURL];
    NSMutableDictionary* parameters = [NSMutableDictionary new];
    [parameters setObject:uid forKey:@"uid"];
    [parameters setObject:customProgram.name forKey:@"name"];
    [parameters setObject:customProgram.useTime forKey:@"useTime"];
    [parameters setObject:customProgram.useAid forKey:@"useAim"];
    [parameters setObject:customProgram.keyPart forKey:@"keyPart"];
    [parameters setObject:customProgram.massageType forKey:@"messageType"];
    [parameters setObject:customProgram.massagePreference forKey:@"messagePerfrence"];
    [parameters setObject:customProgram.speed forKey:@"speed"];
    [parameters setObject:customProgram.airPressure forKey:@"pressure"];
    [parameters setObject:customProgram.power forKey:@"power"];
    [parameters setObject:customProgram.width forKey:@"width"];
    
    NSLog(@"请求链接：%@\n请求参数：customProgram:%@\n",url,parameters);
    [_manager POST:url parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"添加自定义程序成功:%@",responseObject);
        NSNumber* code = [responseObject objectForKey:@"responseCode"];
        if ([code integerValue] == 200) {
            NSLog(@"服务器添加成功");
            if ([self.delegate respondsToSelector:@selector(massageRequestAddCustomProgramFinish:Result:)]) {
                NSInteger pid = [[responseObject objectForKey:@"programId"] integerValue];
                customProgram.programId = [NSNumber numberWithInteger:pid];
                [self.delegate massageRequestAddCustomProgramFinish:YES Result:customProgram];
            }
        }
        else
        {
            NSLog(@"服务器添加失败");
            if ([self.delegate respondsToSelector:@selector(massageRequestAddCustomProgramFinish:Result:)]) {
                [self.delegate massageRequestAddCustomProgramFinish:NO Result:customProgram];
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"添加自定义程序失败:%@",error);
        if ([self.delegate respondsToSelector:@selector(massageRequestAddCustomProgramFinish:Result:)]) {
            [self.delegate massageRequestAddCustomProgramFinish:NO Result:customProgram];
        }
    }];
}

#pragma mark - 编辑自定义程序
-(void)updateCustomProgram:(CustomProgram*)customProgram Uid:(NSString*)uid
{
//    [self cancelRequest];
    NSString* url = [NSString stringWithFormat:@"%@/updateCustomProgram",REQUESTURL];
    NSMutableDictionary* parameters = [NSMutableDictionary new];
    [parameters setObject:uid forKey:@"uid"];
    [parameters setObject:customProgram.name forKey:@"name"];
    [parameters setObject:customProgram.useTime forKey:@"useTime"];
    [parameters setObject:customProgram.useAid forKey:@"useAim"];
    [parameters setObject:customProgram.keyPart forKey:@"keyPart"];
    [parameters setObject:customProgram.massageType forKey:@"messageType"];
    [parameters setObject:customProgram.massagePreference forKey:@"messagePerfrence"];
    [parameters setObject:customProgram.speed forKey:@"speed"];
    [parameters setObject:customProgram.airPressure forKey:@"pressure"];
    [parameters setObject:customProgram.power forKey:@"power"];
    [parameters setObject:customProgram.programId forKey:@"programId"];
    [parameters setObject:customProgram.width forKey:@"width"];
    
    NSLog(@"请求链接：%@\n请求参数：customProgram:%@\n",url,parameters);
    [_manager POST:url parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        NSLog(@"编辑自定义程序成功:%@",responseObject);
        NSNumber* code = [responseObject objectForKey:@"responseCode"];
        if ([code integerValue] == 200) {
            NSLog(@"服务器编辑成功");
            if ([self.delegate respondsToSelector:@selector(massageRequestUpdateCustomProgramFinish:Result:)]) {
                NSInteger pid = [[responseObject objectForKey:@"programId"] integerValue];
                customProgram.programId = [NSNumber numberWithInteger:pid];
                [self.delegate massageRequestUpdateCustomProgramFinish:YES Result:customProgram];
            }
        }
        else
        {
            NSLog(@"服务器编辑失败");
            if ([self.delegate respondsToSelector:@selector(massageRequestUpdateCustomProgramFinish:Result:)]) {
                [self.delegate massageRequestUpdateCustomProgramFinish:NO Result:customProgram];
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"编辑自定义程序失败:%@",error);
        if ([self.delegate respondsToSelector:@selector(massageRequestUpdateCustomProgramFinish:Result:)]) {
            [self.delegate massageRequestUpdateCustomProgramFinish:NO Result:customProgram];
        }
    }];
}

#pragma mark - 删除自定义程序
-(void)deleteCustomProgram:(CustomProgram*)customProgram Uid:(NSString*)uid
{
//    [self cancelRequest];
    NSString* url = [NSString stringWithFormat:@"%@/deleteCustomProgram",REQUESTURL];
    NSMutableDictionary* parameters = [NSMutableDictionary new];
    [parameters setObject:uid forKey:@"uid"];
    [parameters setObject:customProgram.programId forKey:@"programId"];
    
    NSLog(@"请求链接：%@\n请求参数：customProgram:%@\n",url,parameters);
    [_manager POST:url parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"删除自定义程序成功:%@",responseObject);
        NSNumber* code = [responseObject objectForKey:@"responseCode"];
        if ([code integerValue] == 200) {
            NSLog(@"服务器删除成功");
            if ([self.delegate respondsToSelector:@selector(massageRequestDeleteCustomProgramFinish:Result:)]) {
                [self.delegate massageRequestDeleteCustomProgramFinish:YES Result:customProgram];
            }
        }
        else
        {
            NSLog(@"服务器删除失败");
            if ([self.delegate respondsToSelector:@selector(massageRequestDeleteCustomProgramFinish:Result:)]) {
                [self.delegate massageRequestDeleteCustomProgramFinish:NO Result:customProgram];
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"删除自定义程序失败:%@",error);
        if ([self.delegate respondsToSelector:@selector(massageRequestDeleteCustomProgramFinish:Result:)]) {
            [self.delegate massageRequestDeleteCustomProgramFinish:NO Result:customProgram];
        }
    }];
}

#pragma mark - 超时方法
-(void)requestTimeOut {
	AppDelegate *app = [UIApplication sharedApplication].delegate;
	UIWindow *appWindow = app.window;
	MBProgressHUD *alert = [MBProgressHUD showHUDAddedTo:appWindow animated:YES];
	alert.mode = MBProgressHUDModeText;
	alert.labelText = NSLocalizedString(@"请求超时，请检测网络", nil);
	alert.margin = 10.f;
	alert.removeFromSuperViewOnHide = YES;
	[alert hide:YES afterDelay:1.5];
}

#pragma mark - 取消请求

-(void)cancelRequest {
    [_manager.operationQueue cancelAllOperations];
}




@end
