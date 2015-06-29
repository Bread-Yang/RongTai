//
//  LoginViewController.m
//  rongtai
//
//  Created by William-zhang on 15/6/1.
//  Copyright (c) 2015年 William-zhang. All rights reserved.
//

#import "LoginViewController.h"
#import "LoginRequest.h"


//
#import "DataCenterViewController.h"
#import "FamilyManageViewController.h"
#import "CustomProcedureViewController.h"
#import "MainViewController.h"

@interface LoginViewController ()<LoginRequestDelegate>
{
    __weak IBOutlet UIView *_loginFeild;  //登录外边框
    
    __weak IBOutlet UIButton *_registerBtn;  //注册按钮
    
    __weak IBOutlet UITextField *_phoneNum;  //手机号码TextField
    
    __weak IBOutlet UITextField *_password;  //密码TextField
    
    LoginRequest* _loginRequest;
}

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//    _loginFeild.layer.cornerRadius = 5;
//    _loginFeild.layer.borderColor = [UIColor lightGrayColor].CGColor;
//    _loginFeild.layer.borderWidth = 1;
    _loginRequest = [LoginRequest new];
    _loginRequest.delegate = self;
    // Do any additional setup after loading the view.
}

#pragma mark - 登陆按钮方法
- (IBAction)login:(id)sender {
    [_loginRequest loginByPhone:_phoneNum.text Password:_password.text];
}

#pragma mark - 注册按钮方法
- (IBAction)registerUser:(id)sender {
}

#pragma mark - 登录完成后
-(void)loginRequestLoginFinished:(BOOL)success Result:(NSDictionary *)result
{
    if (success) {
        NSUserDefaults* ud = [NSUserDefaults standardUserDefaults];
        NSString* token = [result objectForKey:@"token"];
        NSString* uid = [result objectForKey:@"uid"];
        [ud setObject:token forKey:@"token"];
        [ud setObject:uid forKey:@"uid"];
        [self.navigationController pushViewController:[MainViewController new] animated:YES];
    }
}

#pragma mark - qq登陆按钮方法
- (IBAction)qqLogin:(id)sender {
//    [self.navigationController pushViewController:[DataCenterViewController new] animated:YES];
    UIStoryboard* s = [UIStoryboard storyboardWithName:@"Login" bundle:nil];
    CustomProcedureViewController* c = (CustomProcedureViewController*)[s instantiateViewControllerWithIdentifier:@"CustomProcedure"];
    [self.navigationController pushViewController:c animated:YES];
	
}

#pragma mark - 新浪登陆按钮方法
- (IBAction)sinaLogin:(id)sender {
        [self.navigationController pushViewController:[FamilyManageViewController new] animated:YES];
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
