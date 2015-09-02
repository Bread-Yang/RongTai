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
}
@end

@implementation RegisterViewController

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    //返回按钮设置
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem goBackItemByTarget:self Action:@selector(goBack)];
    
    _loginRequest = [LoginRequest new];
    _loginRequest.delegate = self;

    //验证码发送倒计时
    _countTime = 30;
    _canSend = YES;
}

#pragma mark - 返回
-(void)goBack
{
    [self.navigationController popViewControllerAnimated:YES];
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
        _countTime = 30;
        _canSend = YES;
        _registerBtn.userInteractionEnabled = YES;
        [_registerBtn setTitle:@"发送验证码" forState:UIControlStateNormal];
        [_registerBtn setBackgroundImage:[UIImage imageNamed:@"register_button"] forState:UIControlStateNormal];
    }
    else
    {
        _registerBtn.userInteractionEnabled = NO;
        [_registerBtn setTitle:[NSString stringWithFormat:@"%lds后可重发",_countTime] forState:UIControlStateNormal];
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

        if ([self checkPhoneNum]) {
            _canSend = NO;
            [_loginRequest requestAuthCodeByPhone:phone];
        }
        else
        {
            [self showProgressHUDByString:@"手机号码格式错误"];
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
    if (phone.length > 10) {
        NSPredicate* pre = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",@"^(0|86|17951)?(13[0-9]|15[012356789]|17[678]|18[0-9]|14[57])[0-9]{8}$"];
        result = [pre evaluateWithObject:phone];
    }
    return result;
}

#pragma mark - 登录请求代理
-(void)loginRequestAuthCodeFinished:(BOOL)success
{
    if (success) {
        //验证码发送成功
        NSLog(@"验证码发送成功");
        [self showProgressHUDByString:@"验证码发送成功"];
        [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(countTimeToSendAuthCode:) userInfo:nil repeats:YES];
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
    if (success&&result) {
        NSLog(@"注册成功");
        NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:[result objectForKey:@"uid"] forKey:@"uid"];
        [defaults setObject:[result objectForKey:@"token"] forKey:@"token"];
        [self showProgressHUDByString:@"注册成功"];
        UIStoryboard* s = [UIStoryboard storyboardWithName:@"Login" bundle:nil];
        UserInformationViewController* rVC = (UserInformationViewController*)[s instantiateViewControllerWithIdentifier:@"UserInformation"];
        rVC.isRegister = YES;
        [self.navigationController pushViewController:rVC animated:YES];
    }
    else
    {
        [self showProgressHUDByString:@"注册失败"];
    }
}

#pragma mark - 注册方法
- (IBAction)registerUser:(id)sender {
    if ([self checkPhoneNum]) {
        NSString* code = _authCode.text;
        code = [code stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        if (code.length > 0) {
            if (_password.text.length > 5 && _password.text.length < 19) {
                NSString* phone = _phoneNum.text;
                phone = [phone stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                [_loginRequest registerAccountByPhone:phone Password:_password.text Code:code];
            }
            else
            {
                [self showProgressHUDByString:@"请输入6-18位密码"];
            }
        }
        else
        {
            [self showProgressHUDByString:@"请填写验证码"];
        }
    }
    else
    {
        [self showProgressHUDByString:@"手机号码格式错误"];
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
