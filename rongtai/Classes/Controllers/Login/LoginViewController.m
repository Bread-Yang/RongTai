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
#import "DataCenterViewController.h"
#import "FamilyManageViewController.h"
#import "CustomProcedureViewController.h"
#import "MainViewController.h"
#import "MBProgressHUD.h"
#import "AppIntrouceView.h"
#import "MemberRequest.h"
#import "RegisterViewController.h"
#import "UserViewController.h"
#import "IQKeyboardManager.h"

@interface LoginViewController ()<AppIntroduceViewDelegate, LoginRequestDelegate> {
	__weak IBOutlet UIButton *_registerBtn;  //注册按钮
	
	__weak IBOutlet UITextField *_phoneNum;  //手机号码TextField
	
	__weak IBOutlet UITextField *_password;  //密码TextField
	
    __weak IBOutlet UIView *_placeholderView;
    __weak IBOutlet UIImageView *_RTIcon;
	LoginRequest* _loginRequest;
    
    MBProgressHUD* _loading;
    
}

@property AppIntrouceView *introduceView;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.isListenBluetoothStatus = NO;
	// 品牌及产品特色界面
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	if (![defaults objectForKey:@"intro_screen_viewed"]) {
		self.introduceView = [[AppIntrouceView alloc] initWithFrame:self.view.frame];
		self.introduceView.delegate = self;
		self.introduceView.backgroundColor = [UIColor greenColor];
		[self.view addSubview:self.introduceView];
	}
	
    _loginRequest = [LoginRequest new];
    _loginRequest.delegate = self;
    _loginRequest.overTime = 30;

//    _phoneNum.text = @"13435814424";
//    _password.text = @"123456";
    
    //
     SlideNavigationController* silder = [SlideNavigationController sharedInstance];
    
    MenuViewController* menu = [[MenuViewController alloc]init];
    silder.leftMenu = menu;
    silder.enableSwipeGesture = NO;
    silder.enableShadow = NO;
    silder.navigationBar.translucent = NO;
    silder.portraitSlideOffset = 0.29*[UIScreen mainScreen].bounds.size.width;
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
    NSString* phone = [[NSUserDefaults standardUserDefaults] objectForKey:@"phone"];
    if (phone) {
        _phoneNum.text = phone;
    }
    _password.text = nil;
}

#pragma mark - 登陆按钮方法
- (IBAction)login:(id)sender {
//    /*
//     在4s使用时，如果不加这句，推到主界面后会出现整个view上移，而导致下边出现黑边
//    */
//    [[IQKeyboardManager sharedManager] resignFirstResponder];
    
    NSString* phone = _phoneNum.text;
    //去掉首尾空格
    phone = [phone stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if (phone.length > 0)
    {
        if (phone.length == 11) {
            if ([self checkPhoneNum]) {
                if (_password.text.length > 0) {
                    if (_password.text.length >5&&_password.text.length < 19) {
                        [_loading show:YES];
                        [_password resignFirstResponder];
                        [_phoneNum resignFirstResponder];
                        [_loginRequest loginByPhone:_phoneNum.text Password:_password.text];
                    }
                    else
                    {
                        [self showProgressHUDByString:@"请输入6-18位密码"];
                    }
                }
                else
                {
                    [self showProgressHUDByString:@"请输入密码"];
                }

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

#pragma mark - 忘记密码方法
- (IBAction)forgetPassword:(id)sender {    
    UIStoryboard* s = [UIStoryboard storyboardWithName:@"Login" bundle:nil];
    RegisterViewController* rVC = [s instantiateViewControllerWithIdentifier:@"RegisterVC"];
    [rVC forgetPasswordMode];
    [self.navigationController pushViewController:rVC animated:YES];
}

#pragma mark - LoginRequestDelegate
#pragma mark - 登录完成后

-(void)loginRequestLoginFinished:(BOOL)success Result:(NSDictionary *)result
{
	if (success) {
		NSString* token = [result objectForKey:@"token"];
		NSString* uid = [result objectForKey:@"uid"];
        NSUserDefaults* ud = [NSUserDefaults standardUserDefaults];
        NSString* phone = _phoneNum.text;
        phone = [phone stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        [ud setObject:phone forKey:@"phone"];
        [ud setObject:uid forKey:@"uid"];
        
        MemberRequest* mr = [MemberRequest new];
        [mr requestMemberListByIndex:0 Size:2000 success:^(NSArray *members) {
            NSLog(@"成员:%@",members);
            if (members.count<1) {
                //没有家庭成员，要跳到添加成员页面
                [_loading hide:YES];
                [ud setObject:nil forKey:@"uid"];
//                UIStoryboard* s = [UIStoryboard storyboardWithName:@"Login" bundle:nil];
//                UserViewController* vc = [s instantiateViewControllerWithIdentifier:@"UserInformation"];
                UserViewController* vc = [UserViewController new];
                vc.isRegister = YES;
                vc.title = @"个人信息";
                [vc setUid:uid AndToken:token];
                [self.navigationController pushViewController:vc animated:YES];
            }
            else
            {
                [Member updateLocalDataByNetworkData:members];
                
                [ud setObject:token forKey:@"token"];
                
                [_loading hide:YES];
                MainViewController *vc = [MainViewController new];
                vc.isFromLoginViewController = true;
                [self.navigationController pushViewController:vc animated:YES];
            }
            
        } failure:^(id responseObject) {
            [_loading hide:YES];
            [ud setObject:nil forKey:@"uid"];
            [self showProgressHUDByString:@"用户数据加载失败，请重新登录"];
            NSLog(@"有网，本地记录读取成员");
        }];
	}
    else
    {
        [_loading hide:YES];
        if (result) {
            NSError* error = [result objectForKey:@"error"];
            if (error.code == -1009) {
                [self showProgressHUDByString:@"网络连接已断开,请检查！"];
            }
            else
            {
                [self showProgressHUDByString:@"登录失败，请检查账号密码"];
            }
        }
        else
        {
            [self showProgressHUDByString:@"登录失败，请检查账号密码"];
        }
    }
}

- (void)loginRequestThirdLoginFinished:(BOOL)success Result:(NSDictionary *)result {
    [_loading hide:YES];
	if (success) {
        NSString* token = [result objectForKey:@"token"];
        NSString* uid = [result objectForKey:@"uid"];
        NSUserDefaults* ud = [NSUserDefaults standardUserDefaults];
        [ud setObject:uid forKey:@"uid"];
        
        MemberRequest* mr = [MemberRequest new];
        [mr requestMemberListByIndex:0 Size:2000 success:^(NSArray *members) {
            NSLog(@"成员:%@",members);
            if (members.count<1) {
                //没有家庭成员，要跳到添加成员页面
                [_loading hide:YES];
                [ud setObject:nil forKey:@"uid"];
//                UIStoryboard* s = [UIStoryboard storyboardWithName:@"Login" bundle:nil];
//                UserViewController* vc = [s instantiateViewControllerWithIdentifier:@"UserInformation"];
                UserViewController* vc = [UserViewController new];
                vc.title = @"个人信息";
                vc.isRegister = YES;
                [vc setUid:uid AndToken:token];
                [self.navigationController pushViewController:vc animated:YES];
            }
            else
            {
                [Member updateLocalDataByNetworkData:members];
                
                [ud setObject:token forKey:@"token"];
                
                
                [_loading hide:YES];
                MainViewController *vc = [MainViewController new];
                vc.isFromLoginViewController = true;
                [self.navigationController pushViewController:vc animated:YES];
            }
            
        } failure:^(id responseObject) {
            [_loading hide:YES];
            [ud setObject:nil forKey:@"uid"];
            [self showProgressHUDByString:@"用户数据加载失败，请重新登录"];
            NSLog(@"有网，本地记录读取成员");
        }];
	}
    else
    {
        [self showProgressHUDByString:@"第三方授权失败"];
    }
}

-(void)loginRequestrequestTimeOut:(LoginRequest *)request
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
                               if (uid.length > 0 && token.length > 0) {
								   
                                   [_loading show:YES];
                                   [_loginRequest thirdLoginBySrc:@"qq" Uid:uid Token:token];
								   
                               } else {
                                   [self showProgressHUDByString:@"第三方授权失败"];
                               }
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
                               if (uid.length>0&&token.length>0) {
                                   [_loading show:YES];
                                   [_loginRequest thirdLoginBySrc:@"sina" Uid:uid Token:token];
                               }
                               else
                               {
                                   [self showProgressHUDByString:@"第三方授权失败"];
                               }
						   }];
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


#pragma mark - AppIntroduceViewDelegate
- (void)onDoneButtonPressed {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setObject:@"YES"forKey:@"intro_screen_viewed"];
	[defaults synchronize];
	
	[UIView animateWithDuration:1.0 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
		self.introduceView.alpha = 0;
	} completion:^(BOOL finished) {
		[self.introduceView removeFromSuperview];
	}];
}

@end
