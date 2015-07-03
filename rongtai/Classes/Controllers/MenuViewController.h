//
//  MenuViewController.h
//  rongtai
//
//  Created by William-zhang on 15/6/8.
//  Copyright (c) 2015年 William-zhang. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MenuViewControllerDelegate <NSObject>

@optional
-(void)switchChange:(BOOL)isOn;

@end

@interface MenuViewController : UIViewController

@property(nonatomic, weak)id<MenuViewControllerDelegate> delegate;

@end
