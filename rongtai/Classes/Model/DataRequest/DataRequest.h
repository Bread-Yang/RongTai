//
//  DataRequest.h
//  rongtai
//
//  Created by William-zhang on 15/8/20.
//  Copyright (c) 2015年 William-zhang. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface DataRequest : NSObject

/**
 *  超时设置，若设置时间小于等于0，则不启用超时检测，默认为0
 */
@property(nonatomic)NSTimeInterval overTime;


/**
 *  获取爱用程序的使用次数
 */
-(void)getFavoriteProgramCountSuccess:(void (^)(NSArray* programs))success fail:(void (^)(NSDictionary* dic))fail;

/**
 *  上传程序使用次数
 */
-(void)uploadProgramUsingCountSuccess:(void (^)())success fail:(void (^)(NSDictionary* dic))fail;


@end
