//
//  ChangeUserViewController.h
//  rongtai
//
//  Created by William-zhang on 15/7/13.
//  Copyright (c) 2015年 William-zhang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BasicViewController.h"

@protocol ChangeUserViewControllerDelegate <NSObject>

@optional
-(void)changeUser:(UIImage*)image;

@end

@interface ChangeUserViewController : BasicViewController

@property(nonatomic, weak) id<ChangeUserViewControllerDelegate> delegate;

@end
