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
