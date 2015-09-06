//
//  LoginViewController.m
//  rongtai
//
//  Created by William-zhang on 15/6/1.
//  Copyright (c) 2015年 William-zhang. All rights reserved.
//

#import <ShareSDK/ShareSDK.h>

#import "LoginViewController.h"
#import "LoginRequest.h"
#import "SlideNavigationController.h"
#import "MenuViewController.h"
#import "IQKeyboardManager.h"

#import "DataCenterViewController.h"
#import "FamilyManageViewController.h"
#import "CustomProcedureViewController.h"
#import "MainViewController.h"
#import "MBProgressHUD.h"

@interface LoginViewController ()<LoginRequestDelegate>
{	
	__weak IBOutlet UIButton *_registerBtn;  //注册按钮
	
	__weak IBOutlet UITextField *_phoneNum;  //手机号码TextField
	
	__weak IBOutlet UITextField *_password;  //密码TextField
	
	LoginRequest* _loginRequest;
    
    MBProgressHUD* _loading;
}

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _loginRequest = [LoginRequest new];
    _loginRequest.delegate = self;
    _loginRequest.overTime = 30;

    _phoneNum.text = @"13435814424";
    _password.text = @"123456";
    
    //
     SlideNavigationController* silder = [SlideNavigationController sharedInstance];
    
    MenuViewController* menu = [[MenuViewController alloc]init];
    silder.leftMenu = menu;
    silder.enableSwipeGesture = YES;
    silder.enableShadow = NO;
    silder.navigationBar.translucent = NO;
    silder.portraitSlideOffset = 0.3*[UIScreen mainScreen].bounds.size.width;
    [silder.navigationBar setTintColor:[UIColor whiteColor]];
    [silder.navigationBar setBackgroundImage:[UIImage imageNamed:@"navBar"] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName];
    
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    //MBProgressHUD
    _loading = [[MBProgressHUD alloc]initWithView:self.view];
    _loading.labelText = NSLocalizedString(@"登录中...", nil);
    [self.view addSubview:_loading];
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
}

#pragma mark - 登陆按钮方法
- (IBAction)login:(id)sender {
    /*
     在4s使用时，如果不加这句，推到主界面后会出现整个view上移，而导致下边出现黑边
    */
    [[IQKeyboardManager sharedManager] resignFirstResponder];
    
    
    if ([self checkPhoneNum]) {
        if (_password.text.length >5&&_password.text.length < 19) {
            [_loading show:YES];
            [_loginRequest loginByPhone:_phoneNum.text Password:_password.text];
        }
        else
        {
            [self showProgressHUDByString:@"请输入6-18位密码"];
        }
    }
    else
    {
        [self showProgressHUDByString:@"手机格式不正确"];
    }
}

#pragma mark - LoginRequestDelegate
#pragma mark - 登录完成后

-(void)loginRequestLoginFinished:(BOOL)success Result:(NSDictionary *)result
{
    [_loading hide:YES];
	if (success) {
		NSUserDefaults* ud = [NSUserDefaults standardUserDefaults];
		NSString* token = [result objectForKey:@"token"];
		NSString* uid = [result objectForKey:@"uid"];
		[ud setObject:token forKey:@"token"];
		[ud setObject:uid forKey:@"uid"];
		[self.navigationController pushViewController:[MainViewController new] animated:YES];
	}
    else
    {
        [self showProgressHUDByString:@"登录失败，请检查账号密码"];
    }
}

- (void)loginRequestThirdLoginFinished:(BOOL)success Result:(NSDictionary *)result {
	if (success) {
		NSUserDefaults* ud = [NSUserDefaults standardUserDefaults];
		NSString* token = [result objectForKey:@"token"];
		NSString* uid = [result objectForKey:@"uid"];
		[ud setObject:token forKey:@"token"];
		[ud setObject:uid forKey:@"uid"];
		//		[self.navigationController pushViewController:[MainViewController new] animated:YES];
		
		[self.navigationController pushViewController:[MainViewController new] animated:YES];
	}
}

-(void)requestTimeOut:(LoginRequest *)request
{
    //登陆超时
    [_loading hide:YES];
    [self showProgressHUDByString:@"登录超时，请检测网络"];
    
}

#pragma mark - qq登陆按钮方法
- (IBAction)qqLogin:(id)sender {
	//    [self.navigationController pushViewController:[DataCenterViewController new] animated:YES];
	//    UIStoryboard* s = [UIStoryboard storyboardWithName:@"Login" bundle:nil];
	//    CustomProcedureViewController* c = (CustomProcedureViewController*)[s instantiateViewControllerWithIdentifier:@"CustomProcedure"];
	//    [self.navigationController pushViewController:c animated:YES];
	
	[ShareSDK getUserInfoWithType:ShareTypeQQSpace
					  authOptions:nil
						   result:^(BOOL result, id<ISSPlatformUser> userInfo, id<ICMErrorInfo> error) {
							   
							   NSString *uid = [userInfo uid];
							   NSString *token = [[userInfo credential] token];
							   
							   NSLog(@"QQ登录返回的uid : %@, token : %@", uid, token);
							   
							   [_loginRequest thirdLoginBySrc:@"qq" Uid:uid Token:token];
						   }];
	
	
}

#pragma mark - 新浪登陆按钮方法
- (IBAction)sinaLogin:(id)sender {
	//        [self.navigationController pushViewController:[FamilyManageViewController new] animated:YES];
	[ShareSDK getUserInfoWithType:ShareTypeSinaWeibo
					  authOptions:nil
						   result:^(BOOL result, id<ISSPlatformUser> userInfo, id<ICMErrorInfo> error) {
							   
							   NSString *uid = [userInfo uid];
							   NSString *token = [[userInfo credential] token];
							   
							   NSLog(@"SINA登录返回的uid : %@, token : %@", uid, token);
							   
							   [_loginRequest thirdLoginBySrc:@"sina" Uid:uid Token:token];
						   }];
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

- (void)didUpdateMassageChairStatus:(RTMassageChairStatus *)rtMassageChairStatus {
	[super didUpdateMassageChairStatus:rtMassageChairStatus];
	NSLog(@"didUpdateMassageChairStatus:");
}

@end
