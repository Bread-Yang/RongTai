//
//  RegisterViewController.m
//  rongtai
//
//  Created by William-zhang on 15/6/1.
//  Copyright (c) 2015年 William-zhang. All rights reserved.
//

#import "RegisterViewController.h"
#import "LoginRequest.h"

//
#import "WLWeatherView.h"

@interface RegisterViewController ()<LoginRequestDelegate>
{
    __weak IBOutlet UITextField *_phoneNum; //手机号码TextField
    __weak IBOutlet UITextField *_authCode; //验证码TextField
    __weak IBOutlet UITextField *_password; //密码TextField
    LoginRequest* _loginRequest;
}
@end

@implementation RegisterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    WLWeatherView* weatherView = [[WLWeatherView alloc]initWithFrame:CGRectMake(0, 0, 90, 44)];
    UIBarButtonItem* right = [[UIBarButtonItem alloc]initWithCustomView:weatherView];
    self.navigationItem.rightBarButtonItem  = right;
    _loginRequest = [LoginRequest new];
    // Do any additional setup after loading the view.
}

#pragma mark - 返回按钮方法
//- (IBAction)goback:(UIBarButtonItem *)sender {
//    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
//}

#pragma mark - 获取验证码
- (IBAction)getAuthCode:(id)sender {
    [_loginRequest requestAuthCodeByPhone:_phoneNum.text];
}

#pragma mark - 登录请求代理
-(void)loginRequestAuthCodeFinished:(BOOL)success
{
    
}

-(void)loginRequestRegisterAccountFinished:(BOOL)success Result:(NSDictionary *)result
{
    
}

#pragma mark - 注册方法
- (IBAction)registerUser:(id)sender {
//    [_loginRequest registerAccountByPhone:_phoneNum.text Password:_password.text Code:_authCode.text];
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
