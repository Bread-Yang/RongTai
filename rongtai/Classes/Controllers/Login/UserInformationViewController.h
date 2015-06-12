//
//  UserInformationViewController.h
//  rongtai
//
//  Created by William-zhang on 15/6/2.
//  Copyright (c) 2015年 William-zhang. All rights reserved.
//

#import <UIKit/UIKit.h>

@class User;
@class UserInformationViewController;

@protocol UserInformationDelegate <NSObject>

@optional
-(void)deleteButtonClicked:(User*)user WithIndex:(NSUInteger)index;

@end

@interface UserInformationViewController : UIViewController

/**
 *  代理
 */
@property(nonatomic, weak)id<UserInformationDelegate> delegate;

/**
 *  编辑模式
 */
-(void)editMode:(User*)user WithIndex:(NSUInteger)index;

@end
