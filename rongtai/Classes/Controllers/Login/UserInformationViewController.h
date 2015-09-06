//
//  UserInformationViewController.h
//  rongtai
//
//  Created by William-zhang on 15/6/2.
//  Copyright (c) 2015年 William-zhang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BasicViewController.h"

@class Member;

typedef void (^EditUserInformationBlock)(NSDictionary *entity);

@protocol UserInformationDelegate <NSObject>

@optional
- (void)deleteButtonClicked:(Member*)user WithIndex:(NSUInteger)index;

@end

@interface UserInformationViewController : BasicViewController

/**
 *  代理
 */
@property(nonatomic, weak)id<UserInformationDelegate> delegate;

@property(nonatomic)BOOL isRegister;

/**
 *  编辑模式
 */
- (void)editMode:(Member*)user WithIndex:(NSUInteger)index;


@end
