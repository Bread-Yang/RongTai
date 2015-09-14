//
//  RegisterViewController.m
//  rongtai
//
//  Created by William-zhang on 15/6/1.
//  Copyright (c) 2015年 William-zhang. All rights reserved.
//

#import "RegisterViewController.h"
#import "LoginRequest.h"
#import "UIBarButtonItem+goBack.h"
#import "MBProgressHUD.h"
#import "UserInformationViewController.h"

@interface RegisterViewController ()<LoginRequestDelegate>
{
    __weak IBOutlet UITextField *_phoneNum; //手机号码TextField
    __weak IBOutlet UITextField *_authCode; //验证码TextField
    __weak IBOutlet UITextField *_password; //密码TextField
    LoginRequest* _loginRequest;
    NSUInteger _countTime;
    __weak IBOutlet UIButton *_registerBtn; //注册按钮
    BOOL _canSend;
     MBProgressHUD* _loading;
    BOOL _isReset;
    
    __weak IBOutlet UIButton *_registerButton;
    
}
@end

@implementation RegisterViewController

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
    [_phoneNum becomeFirstResponder];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    //返回按钮设置
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem goBackItemByTarget:self Action:@selector(goBack)];
    
    _loginRequest = [LoginRequest new];
    _loginRequest.delegate = self;
    _loginRequest.overTime = 30;

    //验证码发送倒计时
    _countTime = 60;
    _canSend = YES;
    
    //MBProgressHUD
    _loading = [[MBProgressHUD alloc]initWithView:self.view];
    _loading.labelText = NSLocalizedString(@"注册中...", nil);
    [self.view addSubview:_loading];
    _isReset = NO;
}

#pragma mark - 返回
-(void)goBack
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - 忘记密码模式
-(void)forgetPasswordMode
{
    self.view.backgroundColor = [UIColor clearColor];
    self.title = NSLocalizedString(@"忘记密码", nil);
    _loading.labelText = NSLocalizedString(@"重置中...", nil);
    [_registerButton setTitle:NSLocalizedString(@"重置密码", nil) forState:UIControlStateNormal];
    _password.placeholder = NSLocalizedString(@"新密码", nil);
    _isReset = YES;
}

#pragma mark - 快速提示
-(void)showProgressHUDByString:(NSString*)message
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.labelText = message;
    hud.margin = 10.f;
    hud.removeFromSuperViewOnHide = YES;
    [hud hide:YES afterDelay:0.7];
}

#pragma mark - 验证码倒计时重发
-(void)countTimeToSendAuthCode:(NSTimer*)timer
{
    if (_countTime < 1) {
        [timer invalidate];
        _countTime = 60;
        _canSend = YES;
        _registerBtn.userInteractionEnabled = YES;
        [_registerBtn setTitle:@"发送验证码" forState:UIControlStateNormal];
        [_registerBtn setBackgroundImage:[UIImage imageNamed:@"register_button"] forState:UIControlStateNormal];
    }
    else
    {
        _registerBtn.userInteractionEnabled = NO;
        [_registerBtn setTitle:[NSString stringWithFormat:@"重新获取(%ld)",_countTime] forState:UIControlStateNormal];
        [_registerBtn setBackgroundImage:[UIImage imageNamed:@"register_button_gray"] forState:UIControlStateNormal];
        _countTime--;
    }
}

#pragma mark - 获取验证码
- (IBAction)getAuthCode:(id)sender {
    //先判断手机号码
    if (_canSend) {
        NSString* phone = _phoneNum.text;
        //去掉首尾空格
        phone = [phone stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];

        if (phone.length > 0) {
            if (phone.length == 11) {
//                _canSend = NO;
                if ([self checkPhoneNum]) {
                    [_loginRequest requestAuthCodeByPhone:phone];
                }
                else
                {
                    [self showProgressHUDByString:@"请输入正确的手机号码"];
                }
            }
            else
            {
                [self showProgressHUDByString:@"请输入11位手机号码"];
            }
        }
        else
        {
            [self showProgressHUDByString:@"请输入手机号码"];
        }
    }
}

#pragma mark - 验证手机号码
-(BOOL)checkPhoneNum
{
    BOOL result = NO;
    NSString* phone = _phoneNum.text;
    //去掉首尾空格
    phone = [phone stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSPredicate* pre = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",@"^(0|86|17951)?(13[0-9]|15[012356789]|17[678]|18[0-9]|14[57])[0-9]{8}$"];
    result = [pre evaluateWithObject:phone];
    return result;
}

#pragma mark - 登录请求代理
-(void)loginRequestAuthCodeFinished:(BOOL)success
{
    if (success) {
        //验证码发送成功
        NSLog(@"验证码发送成功");
        [self showProgressHUDByString:@"验证码发送成功"];
//        [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(countTimeToSendAuthCode:) userInfo:nil repeats:YES];
    }
    else
    {
        //验证码发送失败
        NSLog(@"验证码发送失败");
        [self showProgressHUDByString:@"验证码发送失败"];
        _canSend = YES;
    }
}

-(void)loginRequestRegisterAccountFinished:(BOOL)success Result:(NSDictionary *)result
{
    [_loading hide:YES];
    if (success&&result) {
        NSLog(@"注册成功");
        NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:[result objectForKey:@"uid"] forKey:@"uid"];
        [defaults setObject:[result objectForKey:@"token"] forKey:@"token"];
        NSString* phone = _phoneNum.text;
        phone = [phone stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        [defaults setObject:phone forKey:@"phone"];
        [self showProgressHUDByString:@"注册成功"];
        UIStoryboard* s = [UIStoryboard storyboardWithName:@"Login" bundle:nil];
        UserInformationViewController* rVC = (UserInformationViewController*)[s instantiateViewControllerWithIdentifier:@"UserInformation"];
        rVC.isRegister = YES;
        [self.navigationController pushViewController:rVC animated:YES];
    }
    else
    {
        if (result) {
            NSError* error = [result objectForKey:@"error"];
            if (error.code == -1009) {
                [self showProgressHUDByString:@"网络连接已断开,请检查！"];
            }
            else
            {
                [self showProgressHUDByString:@"请确认号码并重新获取验证码"];
            }
        }
        else
        {
            [self showProgressHUDByString:@"请确认号码并重新获取验证码"];
        }
    }
}

-(void)loginRequestForgetPasswordFinished:(BOOL)success Result:(NSDictionary *)result
{
    [_loading hide:YES];
    if (success&&result) {
        NSLog(@"重置密码成功");
        [self showProgressHUDByString:@"重置密码成功"];
        [self.navigationController popViewControllerAnimated:YES];
    }
    else
    {
        [self showProgressHUDByString:@"重置密码失败"];
    }
}

-(void)loginRequestrequestTimeOut:(LoginRequest *)request
{
    [_loading hide:YES];
    [self showProgressHUDByString:@"请求超时"];
}

#pragma mark - 注册方法
- (IBAction)registerUser:(id)sender {
    NSString* phone = _phoneNum.text;
    //去掉首尾空格
    phone = [phone stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if (phone.length>0) {
        if (phone.length != 11) {
            [self showProgressHUDByString:@"请输入11位手机号码"];
        }
        else
        {
            if ([self checkPhoneNum]) {
                NSString* code = _authCode.text;
                code = [code stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                if (code.length > 0) {
                    if (_password.text.length < 1)
                    {
                        [self showProgressHUDByString:@"请输入密码"];
                    }
                    else
                    {
                        if (_password.text.length > 5 && _password.text.length < 19) {
                            [_loading show:YES];
                            NSString* phone = _phoneNum.text;
                            phone = [phone stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                            if (_isReset) {
                                [_loginRequest resetPasswordByByPhone:phone Password:_password.text Code:code];
                            }
                            else
                            {
//                                NSString* phone = _phoneNum.text;
//                                phone = [phone stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
//                                [[NSUserDefaults standardUserDefaults] setObject:phone forKey:@"phone"];
//                                UIStoryboard* s = [UIStoryboard storyboardWithName:@"Login" bundle:nil];
//                                UserInformationViewController* rVC = (UserInformationViewController*)[s instantiateViewControllerWithIdentifier:@"UserInformation"];
//                                rVC.isRegister = YES;
//                                [self.navigationController pushViewController:rVC animated:YES];
                                [_loginRequest registerAccountByPhone:phone Password:_password.text Code:code];
                            }
                        }
                        else
                        {
                            [self showProgressHUDByString:@"请输入6-18位密码"];
                        }
                    }
                }
                else
                {
                    [self showProgressHUDByString:@"请输入验证码"];
                }
            }
            else
            {
                [self showProgressHUDByString:@"请输入正确的手机号码"];
            }
        }
    }
    else
    {
        [self showProgressHUDByString:@"请输入手机号码"];
    }
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
