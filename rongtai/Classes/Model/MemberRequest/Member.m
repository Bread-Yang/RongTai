//
//  Member.m
//  rongtai
//
//  Created by yoghourt on 6/17/15.
//  Copyright (c) 2015 William-zhang. All rights reserved.
//

#import "Member.h"
#import "CoreData+MagicalRecord.h"


@implementation Member

@dynamic birthday;
@dynamic height;
@dynamic heightUnit;
@dynamic imageURL;
@dynamic name;
@dynamic sex;
@dynamic status;
@dynamic userId;
@dynamic memberId;
@dynamic uid;

#pragma mark - 根据字典来设置Member
-(void)setValueBy:(NSDictionary *)dic
{
    self.name = [dic objectForKey:@"name"];
    NSString* str = [dic objectForKey:@"sex"];
    self.sex = [NSNumber numberWithUnsignedInteger:[str integerValue]];
    str = [dic objectForKey:@"height"];
    self.height = [NSNumber numberWithUnsignedInteger:[str integerValue]];
    self.heightUnit = [dic objectForKey:@"heightUnit"];
    self.imageURL = [dic objectForKey:@"imageUrl"];
    str = [dic objectForKey:@"memberId"];
    self.memberId = [NSNumber numberWithUnsignedInteger:[str integerValue]];
    NSDateFormatter* formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSString* d = [dic objectForKey:@"birthday"];
    self.birthday = [formatter dateFromString:d];
}

#pragma mark - 把Member转成字典
-(NSDictionary*)memberToDictionary
{
    NSDateFormatter* formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSDictionary* dic = @{
      @"name" : self.name,
      @"sex" : self.sex,
      @"height" : self.height,
      @"heightUnit" : self.heightUnit,
      @"imageUrl" : self.imageURL,
      @"birthday" : [formatter stringFromDate:self.birthday],
      @"memberId" : self.memberId
      };
    return dic;
}

#pragma mark - 根据网络数据来更新本地
+(void)updateLocalDataByNetworkData:(NSArray*)members
{
    NSMutableArray* mutMembers = [NSMutableArray arrayWithArray:members];
    NSString* uid = [[NSUserDefaults standardUserDefaults] objectForKey:@"uid"];
    NSArray* localMembers = [Member MR_findByAttribute:@"uid" withValue:uid];
    for (int i = 0; i<localMembers.count; i++) {
        Member* m = localMembers[i];
        NSNumber* mid = m.userId;
        BOOL isExist = NO;
        for (NSDictionary* dic in mutMembers) {
            NSString* str = [dic objectForKey:@"memberId"];
            if ([mid integerValue] == [str integerValue]) {
                isExist = YES;
                [m setValueBy:dic];
                [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
                [mutMembers removeObjectAtIndex:i];
                break;
            }
        }
        
        if (!isExist) {
            //不存在这条记录则删除
            [m MR_deleteEntity];
            [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
        }
    }
    
    if (mutMembers.count > 0) {
        for (NSDictionary* dic in mutMembers) {
            Member* m = [Member MR_createEntity];
            [m setValueBy:dic];
            m.uid = [[NSUserDefaults standardUserDefaults] objectForKey:@"uid"];
        }
        [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
    }
}




@end
