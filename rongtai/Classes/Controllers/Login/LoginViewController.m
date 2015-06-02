//
//  LoginViewController.m
//  rongtai
//
//  Created by William-zhang on 15/6/1.
//  Copyright (c) 2015年 William-zhang. All rights reserved.
//

#import "LoginViewController.h"

@interface LoginViewController ()
{
    __weak IBOutlet UIView *_loginFeild;  //登录外边框
    __weak IBOutlet UIButton *_loginBtn;  //登录按钮
    
    __weak IBOutlet UIButton *_registerBtn;  //注册按钮
    
}

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _loginFeild.layer.cornerRadius = 5;
    _loginFeild.layer.borderColor = [UIColor lightGrayColor].CGColor;
    _loginFeild.layer.borderWidth = 1;
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
