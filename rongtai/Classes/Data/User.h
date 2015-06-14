//
//  User.h
//  rongtai
//
//  Created by William-zhang on 15/6/12.
//  Copyright (c) 2015年 William-zhang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface User : NSObject

/**
 *  用户昵称
 */
@property(nonatomic, strong)NSString* name;

/**
 *  性别
 */
@property(nonatomic)BOOL sex;

/**
 *  身高
 */
@property(nonatomic)CGFloat height;

/**
 *  身高单位
 */
@property(nonatomic, strong)NSString* unitOfHeight;

/**
 *  生日
 */
@property(nonatomic, strong)NSDate* birthday;

/**
 *  头像
 */
@property(nonatomic, strong)NSString* imageUrl;



@end
