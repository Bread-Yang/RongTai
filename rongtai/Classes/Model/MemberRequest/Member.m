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

#pragma mark - 根据字典来设置Member
-(void)setValueBy:(NSDictionary *)dic
{
    self.name = [dic objectForKey:@"name"];
    self.sex = [dic objectForKey:@"sex"];
    self.height = [dic objectForKey:@"height"];
    self.heightUnit = [dic objectForKey:@"heightUnit"];
    self.imageURL = [dic objectForKey:@"imageUrl"];
    self.memberId = [dic objectForKey:@"memberId"];
    NSDateFormatter* formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString* d = [dic objectForKey:@"birthday"];
    self.birthday = [formatter dateFromString:d];
}

#pragma mark - 把Member转成字典
-(NSDictionary*)memberToDictionary
{
    NSDateFormatter* formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
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


#pragma mark - 根据一条Member的Json数据更新数据库
+(Member*)updateMemberDB:(NSDictionary*)dic
{
    NSString* mid = [dic valueForKey:@"memberId"];
    NSNumber* memberId = [NSNumber numberWithInteger:[mid integerValue]];
    NSArray* arr = [Member MR_findByAttribute:@"memberId" withValue:memberId];
    Member* m;
    if (arr.count == 0) {
        m = [Member MR_createEntity];
    }
    else
    {
        m = arr[0];
    }
    [m setValueBy:dic];
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
    return m;
}


@end
