//
//  UserViewController.h
//  rongtai
//
//  Created by William-zhang on 15/9/30.
//  Copyright (c) 2015年 William-zhang. All rights reserved.
//

#import "BasicViewController.h"

@class Member;

@interface UserViewController : BasicViewController

@property(nonatomic)BOOL isRegister;

/**
 *  编辑模式
 */
- (void)editMode:(Member*)user WithIndex:(NSUInteger)index;

/**
 *  设置uid和token
 */
-(void)setUid:(NSString *)uid AndToken:(NSString*)token;


@end
