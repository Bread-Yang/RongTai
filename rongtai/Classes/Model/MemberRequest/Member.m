//
//  Member.m
//  rongtai
//
//  Created by yoghourt on 6/17/15.
//  Copyright (c) 2015 William-zhang. All rights reserved.
//

#import "Member.h"


@implementation Member

@dynamic birthday;
@dynamic height;
@dynamic heightUnit;
@dynamic imageURL;
@dynamic name;
@dynamic sex;
@dynamic status;
@dynamic userId;

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

-(NSDictionary*)memberToDictionary
{
    NSDictionary* dic = @{@"uid" : @"15521377721",
      @"name" : self.name,
      @"sex" : self.sex,
      @"height" : self.height,
      @"heightUnit" : self.heightUnit,
      @"imageUrl" : self.imageURL,
      @"birthday" : self.birthday,
      };
    return dic;
}

@end
