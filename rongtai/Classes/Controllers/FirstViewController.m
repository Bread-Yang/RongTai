//
//  FirstViewController.m
//  rongtai
//
//  Created by Jaben on 15/5/26.
//  Copyright (c) 2015年 William-zhang. All rights reserved.
//

#import <MediaPlayer/MediaPlayer.h>
#import <ShareSDK/ShareSDK.h>

#import "NSString+RT.h"

#import "FirstViewController.h"
#import "AppIntrouceView.h"
#import "CoreData+MagicalRecord.h"
#import "Member.h"
#import "LoginRequest.h"

@interface FirstViewController () <AppIntroduceViewDelegate, LoginRequestDelegate>

@property AppIntrouceView *introduceView;

@property MPMusicPlayerController *musicPlayer;

@property LoginRequest *loginRequest;

@end

@implementation FirstViewController

id segment[3];
UISegmentedControl *segmentedControl;

- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.loginRequest = [LoginRequest new];
	self.loginRequest.delegate = self;
	
	self.navigationController.navigationBar.barTintColor = [UIColor blackColor];   // 背景为黑色
	self.navigationController.navigationBar.tintColor = [UIColor whiteColor];	   // 返回箭头为白色
	[self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName]];				// 标题为白色
	
	UIBarButtonItem *myBarButtonItem = [[UIBarButtonItem alloc] init];
	myBarButtonItem.title = @""; // or whatever text you want
	
	self.navigationItem.backBarButtonItem = myBarButtonItem;
	
    // Do any additional setup after loading the view.
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (![defaults objectForKey:@"intro_screen_viewed"]) {
        self.introduceView = [[AppIntrouceView alloc] initWithFrame:self.view.frame];
        self.introduceView.delegate = self;
        self.introduceView.backgroundColor = [UIColor greenColor];
        [self.view addSubview:self.introduceView];
    }
    
    self.musicPlayer = [MPMusicPlayerController systemMusicPlayer];
    
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    
    [notificationCenter
     addObserver: self
     selector:    @selector (handle_NowPlayingItemChanged)
     name:        MPMusicPlayerControllerNowPlayingItemDidChangeNotification
     object:      self.musicPlayer];
    
    [notificationCenter
     addObserver: self
     selector:    @selector (handle_PlaybackStateChanged)
     name:        MPMusicPlayerControllerPlaybackStateDidChangeNotification
     object:      self.musicPlayer];
    
    [self.musicPlayer beginGeneratingPlaybackNotifications];
	
	NSArray *itens = [NSArray arrayWithObjects: @"Option 1", @"Option 2", @"Option 3", nil];
	segmentedControl = [[UISegmentedControl alloc] initWithItems:itens];
	[segmentedControl setFrame:CGRectMake(20, 20, 300, 30)];
	[segmentedControl setSegmentedControlStyle:UISegmentedControlStyleBar];
	[segmentedControl addTarget:self
						 action:@selector(segmentedControl:)
			   forControlEvents:UIControlEventAllEvents];
	
	for (int i=0; i<3; i++) {
		//The most important trick to work, have to retain the subviews
		segment[i] = [[segmentedControl subviews] objectAtIndex:i];
	}
	[self changeColor];
//	[self.view addSubview:segmentedControl];
}

- (void)segmentedControl:(id)sender
{
	//do some thing
	[self changeColor];
}

- (void)changeColor{
	for (int i=0; i<3; i++) {
		[segment[i] setTintColor:[UIColor lightGrayColor]];
	}
	int select = segmentedControl.selectedSegmentIndex;
	[segment[select] setTintColor:[UIColor blueColor]];
}

- (void)viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:YES];
    [super viewWillAppear:animated];
	
	NSLog(@"viewWillAppear");
}

- (void)viewWillDisappear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [super viewWillDisappear:animated];
	
	NSLog(@"viewWillDisappear");
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

#pragma mark - LoginRequestDelegate

- (void)loginRequestThirdLoginFinished:(BOOL)success Result:(NSDictionary *)result {
	NSLog(@"loginRequestThirdLoginFinished() success : %i", success);
}

#pragma mark - AppIntroduceViewDelegate

- (void)onDoneButtonPressed {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//    [defaults setObject:@"YES"forKey:@"intro_screen_viewed"];
//    [defaults synchronize];
    [UIView animateWithDuration:1.0 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.introduceView.alpha = 0;
		
		// 清空所有本地的UILocalNotification
		[[UIApplication sharedApplication] cancelAllLocalNotifications];
    } completion:^(BOOL finished) {
        [self.introduceView removeFromSuperview];
    }];
}

#pragma mark - Handle Music Player Notification

- (void)handle_NowPlayingItemChanged {
	MPMediaItem *nowPlayingItem = self.musicPlayer.nowPlayingItem;
    NSString *songName = [nowPlayingItem valueForProperty: MPMediaItemPropertyTitle];
    NSString *artist = [nowPlayingItem valueForProperty: MPMediaItemPropertyArtist];
    
    if (![NSString isBlankString:artist]) {
        songName = [songName stringByAppendingFormat:@" - %@", artist];
    }
    
    self.currentPlaySongLabel.text = songName;
}

- (void)handle_PlaybackStateChanged {
    if (self.musicPlayer.playbackState == MPMusicPlaybackStatePlaying) {
        self.playOrPauseButton.titleLabel.text = @"暂停";
    } else {
        self.playOrPauseButton.titleLabel.text = @"播放";
    }
}

#pragma mark - View Action

- (IBAction)toBleControllerAction:(id)sender {
    UIStoryboard *secondStoryBoard = [UIStoryboard storyboardWithName:@"Second" bundle:[NSBundle mainBundle]];
    UIViewController *viewController = [secondStoryBoard instantiateViewControllerWithIdentifier:@"ScanVC"];
    [self.navigationController pushViewController:viewController animated:YES];
}

- (IBAction)toLoginControllerAction:(id)sender {
    UIStoryboard *loginStoryBoard = [UIStoryboard storyboardWithName:@"Login" bundle:[NSBundle mainBundle]];
    UIViewController *viewController = [loginStoryBoard instantiateViewControllerWithIdentifier:@"LoginVC"];
//    [viewController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navBar"] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController pushViewController:viewController animated:YES];
//    [self presentViewController:viewController animated:YES completion:nil];
}


- (IBAction)shareSDKAction:(id)sender {
     NSString *imagePath = [[NSBundle mainBundle] pathForResource:@"Intro_Screen_Four" ofType:@"png"];
    
    //1、构造分享内容
    id<ISSContent> publishContent = [ShareSDK content:@"可以连接蓝牙的太空按摩椅"
                                       defaultContent:@"在IOS上分享"
                                                image:[ShareSDK imageWithPath:imagePath]
                                                title:@"荣泰按摩椅分享"
                                                  url:@"http://www.rongtai-china.com/product"
                                          description:@"这是一条演示信息"
                                            mediaType:SSPublishContentMediaTypeNews];
  
    id<ISSContainer> container = [ShareSDK container];
    
    //2、弹出分享菜单
    [ShareSDK showShareActionSheet:container
                         shareList:nil
                           content:publishContent
                     statusBarTips:YES
                       authOptions:nil
                      shareOptions:nil
                            result:^(ShareType type, SSResponseState state, id<ISSPlatformShareInfo> statusInfo, id<ICMErrorInfo> error, BOOL end) {
                                
                                //可以根据回调提示用户。
                                if (state == SSResponseStateSuccess)
                                {
                                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"分享成功"
                                                                                    message:nil
                                                                                   delegate:self
                                                                          cancelButtonTitle:@"OK"
                                                                          otherButtonTitles:nil, nil];
                                    [alert show];
                                }
                                else if (state == SSResponseStateFail)
                                {
                                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"分享失败"
                                                                                    message:[NSString stringWithFormat:@"失败描述：%@",[error errorDescription]]
                                                                                   delegate:self
                                                                          cancelButtonTitle:@"OK"
                                                                          otherButtonTitles:nil, nil];
                                    [alert show];
                                }
                            }];
}


- (IBAction)sinaLoginAction:(id)sender {
	
    [ShareSDK getUserInfoWithType:ShareTypeSinaWeibo
                      authOptions:nil
                           result:^(BOOL result, id<ISSPlatformUser> userInfo, id<ICMErrorInfo> error) {
							if (result) {
                               NSString *uid = [userInfo uid];
                               NSString *nickName = [userInfo nickname];
							   NSString *token = [[userInfo credential] token];
                               
                               NSString *info = [uid stringByAppendingString:token];
							   NSString *information = [NSString stringWithFormat:@"uid : %@, nickName : %@, token : %@",uid, nickName, token];
							   NSLog(@"第三方登录之前, %@", information);
							   [self.loginRequest thirdLoginBySrc:@"sina" Uid:uid Token:token];
        
							   
                                   UIAlertView *alertView = [[UIAlertView alloc]
                                       initWithTitle:@"Hello"
                                       message:information
                                       delegate:nil
                                       cancelButtonTitle:@"知道了"
                                       otherButtonTitles: nil];
                                   [alertView show];
							}
     }];
}

- (IBAction)qqLoginAction:(id)sender {
	[ShareSDK getUserInfoWithType:ShareTypeQQSpace
					  authOptions:nil
						   result:^(BOOL result, id<ISSPlatformUser> userInfo, id<ICMErrorInfo> error) {
							if (result) {
							   NSString *uid = [userInfo uid];
							   NSString *nickName = [userInfo nickname];
							   NSString *token = [[userInfo credential] token];
							   
							   NSString *info = [uid stringByAppendingString:token];
							   NSString *information = [NSString stringWithFormat:@"uid : %@, nickName : %@, token : %@",uid, nickName, token];
							   NSLog(@"第三方登录之前, %@", information);
							   [self.loginRequest thirdLoginBySrc:@"sina" Uid:uid Token:token];
							   
								   UIAlertView *alertView = [[UIAlertView alloc]
															 initWithTitle:@"Hello"
															 message:information
															 delegate:nil
															 cancelButtonTitle:@"知道了"
															 otherButtonTitles: nil];
								   [alertView show];
							   }
						   }];
	
}

- (void)authroizedWithShareType:(ShareType)type {
	
//	id<ISSAuthOptions> authOptions = [ShareSDK authOptionsWithAutoAuth:YES
//														 allowCallback:YES
//														 authViewStyle:SSAuthViewStyleFullScreenPopup
//														  viewDelegate:nil
//											   authManagerViewDelegate:appDelegate.viewDelegate];
//	
//	[ShareSDK getUserInfoWithType:type
//					  authOptions:authOptions
//						   result:^(BOOL result, id<ISSPlatformUser> userInfo, id<ICMErrorInfo> error) {
//							   if (result)
//							   {
//								   
//								   NSLog(@"userInfo%@",userInfo);
//								   
//								   [item setObject:[userInfo nickname] forKey:@"username"];
//								   [_shareTypeArray writeToFile:[NSString stringWithFormat:@"%@/authListCache.plist",NSTemporaryDirectory()] atomically:YES];
//							   }
//							   NSLog(@"%ld:%@",(long)[error errorCode], [error errorDescription]);
//						   }];
}

- (IBAction)logoutAction:(id)sender {
    [ShareSDK cancelAuthWithType:ShareTypeSinaWeibo];
    [ShareSDK cancelAuthWithType:ShareTypeQQSpace];
}

- (IBAction)previousSongAction:(id)sender {
    [self.musicPlayer skipToPreviousItem];
}

- (IBAction)nextSongAction:(id)sender {
    [self.musicPlayer skipToNextItem];
}

- (IBAction)playOrPauseAction:(id)sender {
    if (self.musicPlayer.playbackState == MPMusicPlaybackStatePlaying) {
        [self.musicPlayer pause];
    } else {
        [self.musicPlayer play];
    }
}
@end
