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
    
    __weak IBOutlet UIButton *_registerBtn;  //注册按钮
    
    __weak IBOutlet UITextField *_phoneNum;  //手机号码TextField
    
    __weak IBOutlet UITextField *_password;  //密码TextField
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

#pragma mark - 显示密码方法
- (IBAction)displayPassword:(UISwitch *)sender {
    if (sender.on) {
        _password.secureTextEntry = NO;
    }
    else
    {
        _password.secureTextEntry = YES;
    }
}

#pragma mark - 登陆按钮方法
- (IBAction)login:(id)sender {
    
}

#pragma mark - 注册按钮方法
- (IBAction)registerUser:(id)sender {
}


#pragma mark - qq登陆按钮方法
- (IBAction)qqLogin:(id)sender {
}

#pragma mark - 新浪登陆按钮方法
- (IBAction)sinaLogin:(id)sender {
    
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
