//
//  ProgramCount.m
//  rongtai
//
//  Created by William-zhang on 15/8/25.
//  Copyright (c) 2015年 William-zhang. All rights reserved.
//

#import "ProgramCount.h"
#import "DataRequest.h"
#import "CoreData+MagicalRecord.h"


@implementation ProgramCount

@dynamic programId;
@dynamic name;
@dynamic useCount;
@dynamic unUpdateCount;
@dynamic uid;

#pragma mark - 对象转换为字典
-(NSDictionary*)toDictionary
{
    NSUInteger count = [self.useCount integerValue];
    NSUInteger unUpdateCount = [self.unUpdateCount integerValue];
    if (unUpdateCount>0) {
        count += unUpdateCount;
    }
    NSNumber* newCount = [NSNumber numberWithUnsignedInteger:count];
    NSDictionary* dic = @{
                          @"name":self.name,
                          @"count":newCount,
                          @"programId":self.programId
                          };
    return dic;
}

#pragma mark - 根据字典赋值
-(void)setValueByDictionary:(NSDictionary*)dic
{
    self.name = [dic objectForKey:@"name"];
    self.useCount = [dic objectForKey:@"count"];
    NSString* pId = [dic objectForKey:@"programId"];
    self.programId = [NSNumber numberWithUnsignedInteger:[pId integerValue]];
}

#pragma mark - 统计次数数据同步
+(void)synchroUseCountDataFormServer:(BOOL)isUploadLoalData Success:(void(^)())success Fail:(void(^)(NSDictionary* dic)) fail
{
    //先读取服务器数据
    NSLog(@"读取统计次数服务器数据");
    DataRequest* request = [DataRequest new];
    [request getFavoriteProgramCountSuccess:^(NSArray *programs) {
//        NSLog(@"按摩次数:%@",programs);
        NSString* uid = [[NSUserDefaults standardUserDefaults] objectForKey:@"uid"];
        NSArray* counts = [ProgramCount MR_findAllWithPredicate:[NSPredicate predicateWithFormat:@"uid == %@",uid]];
        NSMutableArray* mutPrograms = [NSMutableArray arrayWithArray:programs];
        NSLog(@"统计次数数据同步至本地");
        for (NSDictionary* dic in mutPrograms) {
            BOOL isExist = NO;
            NSString* programIdStr = [dic objectForKey:@"programId"];
            NSUInteger programId = [programIdStr integerValue];
            //按名字遍历数据库，存在同样名称的按摩程序则用网络数据覆盖掉本地数据，但不覆盖未更新使用次数
            for (ProgramCount* p in counts) {
                if ([p.programId integerValue] == programId) {
                    isExist = YES;
                    [p setValueByDictionary:dic];
                }
            }
            
            //本地不存在这样的数据记录，则需要生成一条新数据
            if (!isExist) {
                ProgramCount* new = [ProgramCount MR_createEntity];
                new.uid = uid;
                [new setValueByDictionary:dic];
            }
            [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
        }
        //再把本地数据同步至服务器
        if (isUploadLoalData) {
            [ProgramCount synchroLocalDataToServerSuccess:success Fail:fail];
        }
        else
        {
            if (success) {
                success();
            }
        }
    } fail:^(NSDictionary *dic) {
        NSLog(@"读取统计次数服务器数据失败😢");
        if (fail) {
            fail(dic);
        }
    }];
}

#pragma mark - 本地数据同步至服务器
+(void)synchroLocalDataToServerSuccess:(void(^)())success Fail:(void(^)(NSDictionary* dic)) fail
{
    NSString* uid = [[NSUserDefaults standardUserDefaults] objectForKey:@"uid"];
    NSLog(@"开始同步统计次数到服务器");
    NSArray* counts = [ProgramCount MR_findAllWithPredicate:[NSPredicate predicateWithFormat:@"(uid == %@)",uid]];
    
    //生成请求参数数组
    NSMutableArray* jsons = [NSMutableArray new];
    for (ProgramCount* p in counts) {
        [jsons addObject:[p toDictionary]];
    }
    NSLog(@"同步记录为:%@",jsons);
    //有数据的话才进行服务器同步
    if (jsons.count>0) {
        DataRequest* request = [DataRequest new];
        [request addProgramUsingCount:jsons Success:^{
            NSLog(@"统计次数数据同步至服务器成功");
            //请求成功要更新本地数据，把 未更新的统计次数（unUpdateCount）叠加进 使用次数 里面（useCount），再把 未更新的统计次数 置零。
            for (ProgramCount* p in counts) {
                NSUInteger count = [p.useCount integerValue]+[p.unUpdateCount integerValue];
                p.useCount = [NSNumber numberWithUnsignedInteger:count];
                p.unUpdateCount = [NSNumber numberWithInt:0];
            }
            [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
            if (success) {
                success();
            }
        } fail:^(NSDictionary *dic) {
            NSLog(@"统计次数数据同步至服务器失败");
            if (fail) {
                fail(dic);
            }
        }];
    }
    else
    {
        if (success) {
            success();
        }
    }
}

@end
