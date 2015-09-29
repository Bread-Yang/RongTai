//
//  AppDelegate.m
//  rongtai
//
//  Created by William-zhang on 15/5/25.
//  Copyright (c) 2015年 William-zhang. All rights reserved.
//

#import <ShareSDK/ShareSDK.h>

#import "AppDelegate.h"

//以下是腾讯QQ和QQ空间
#import <TencentOpenAPI/QQApiInterface.h>
#import <TencentOpenAPI/TencentOAuth.h>

#import "WXApi.h"

//开启QQ网页授权需要
#import <QZoneConnection/ISSQZoneApp.h>

#import "CoreData+MagicalRecord.h"
#import "SlideNavigationController.h"
#import "MenuViewController.h"
#import <AFNetworkReachabilityManager.h>

#define SCREENWIDTH [UIScreen mainScreen].bounds.size.width
#define SCREENHEIGHT [UIScreen mainScreen].bounds.size.height

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    //开启网络监听
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
	
	// ShareSDK Setup
	[ShareSDK registerApp:@"7bbafb4115a9"];
	[self initializeSocialPlatform];
	
	// MagicalRecord Setup
	[MagicalRecord setupCoreDataStackWithStoreNamed:@"RongTai.sqlite"];
	
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    //ios8 需要询问用户是否允许才能发送通知
    float sysVersion=[[UIDevice currentDevice]systemVersion].floatValue;
    if (sysVersion>=8.0) {
        UIUserNotificationType type = UIUserNotificationTypeBadge | UIUserNotificationTypeAlert | UIUserNotificationTypeSound;
        UIUserNotificationSettings *setting=[UIUserNotificationSettings settingsForTypes:type categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:setting];
    }
    
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSString* uid = [defaults objectForKey:@"uid"];
    SlideNavigationController* rootVC;
    if (uid.length < 1) {
        //未登录
        UIStoryboard* s = [UIStoryboard storyboardWithName:@"Login" bundle:nil];
        rootVC = (SlideNavigationController*)[s instantiateViewControllerWithIdentifier:@"SliderNavigationVC"];
    }
    else
    {
        //用户登录过
        UIStoryboard* s = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        rootVC = (SlideNavigationController*)[s instantiateViewControllerWithIdentifier:@"SlideMenu"];
    }
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    self.window.rootViewController = rootVC;
    

    SlideNavigationController *slide = [SlideNavigationController sharedInstance];

    MenuViewController *menu = [[MenuViewController alloc] init];
    slide.leftMenu = menu;
    slide.enableSwipeGesture = YES;
    slide.enableShadow = NO;
    slide.portraitSlideOffset = 0.29 * SCREENWIDTH;
    [slide.navigationBar setTintColor:[UIColor whiteColor]];
//    [slide.navigationBar setBarTintColor:[UIColor colorWithRed:48/255.0 green:65/255.0 blue:77/255.0 alpha:1.0]];
    slide.navigationBar.translucent = NO;
//    [slide.navigationBar setBackgroundColor:[UIColor colorWithRed:48/255.0 green:65/255.0 blue:77/255.0 alpha:1.0]];
    [slide.navigationBar setBackgroundImage:[UIImage imageNamed:@"navBar"] forBarMetrics:UIBarMetricsDefault];

//    NSLog(@"SCREEN:%f,%f",SCREENWIDTH,SCREENHEIGHT);
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

-(void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
	
	// 判断应用程序当前的运行状态，如果是激活状态，则进行提醒，否则不提醒
	if (application.applicationState == UIApplicationStateActive) {
//    	NSDictionary *userInfo = notification.userInfo;
//    	NSString *message = [userInfo objectForKey:@"time"];
        NSString* message = notification.alertBody;
    	UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"定时计划" message:message delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles:nil];
    	[alert show];
	}
}

#pragma mark - 设置URL Scheme

- (BOOL)application:(UIApplication *)application
      handleOpenURL:(NSURL *)url {
    return [ShareSDK handleOpenURL:url
                        wxDelegate:self];
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    return [ShareSDK handleOpenURL:url
                 sourceApplication:sourceApplication
                        annotation:annotation
                        wxDelegate:self];
}

#pragma mark - initial social platform

- (void)initializeSocialPlatform {
    /**
     连接微信应用以使用相关功能，此应用需要引用WeChatConnection.framework和微信官方SDK
     http://open.weixin.qq.com上注册应用，并将相关信息填写以下字段
     **/
    [ShareSDK connectWeChatWithAppId:@"wx45290e76de9629e9"
                           appSecret:@"f9ac22d1a062f59b12b5481df7fb2e5b"
                           wechatCls:[WXApi class]];
    /**
     连接QQ应用以使用相关功能，此应用需要引用QQConnection.framework和QQApi.framework库
     http://mobile.qq.com/api/上注册应用，并将相关信息填写到以下字段
     **/
	// 实现在QQ好友,Q群,讨论组,QQ空间分享消息
    [ShareSDK connectQQWithQZoneAppKey:@"1104775475"
                     qqApiInterfaceCls:[QQApiInterface class]
                       tencentOAuthCls:[TencentOAuth class]];
	
	// 实现QQ授权登录(demo中可用的)
//	[ShareSDK connectQZoneWithAppKey:@"100371282"
//						   appSecret:@"aed9b0303e3ed1e27bae87c33761161d"
//				   qqApiInterfaceCls:[QQApiInterface class]
//					 tencentOAuthCls:[TencentOAuth class]];
	
	[ShareSDK connectQZoneWithAppKey:@"1104775475"
						   appSecret:@"vjlMk6zNNKyzZhHR"
				   qqApiInterfaceCls:[QQApiInterface class]
					 tencentOAuthCls:[TencentOAuth class]];
	
	//开启QQ空间网页授权开关(optional)
	id<ISSQZoneApp> app =(id<ISSQZoneApp>)[ShareSDK getClientWithType:ShareTypeQQSpace];
	[app setIsAllowWebAuthorize:YES];
	
    /**
     连接新浪微博开放平台应用以使用相关功能，此应用需要引用SinaWeiboConnection.framework
     http://open.weibo.com上注册新浪微博开放平台应用，并将相关信息填写到以下字段
     **/
    [ShareSDK connectSinaWeiboWithAppKey:@"2191044654"
                               appSecret:@"dc81714808d039ed932242ccb6a936b1"
                             redirectUri:@"http://www.sharesdk.cn"];
}

@end
