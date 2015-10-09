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

#import "WelcomeViewController.h"
#import "AppIntrouceView.h"
#import "CoreData+MagicalRecord.h"
#import "Member.h"
#import "LoginRequest.h"
#import "UIView+RT.h"
#import "TimingPlanRequest.h"
#import "DataRequest.h"

#import "MassageRecord.h"

@interface WelcomeViewController () <AppIntroduceViewDelegate, LoginRequestDelegate>

@property AppIntrouceView *introduceView;

@property MPMusicPlayerController *musicPlayer;

@property LoginRequest *loginRequest;

@end

@implementation WelcomeViewController

id segment[3];
UISegmentedControl *segmentedControl;

//获取Documents目录
- (NSString *)dirDoc {
	//[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSLog(@"app_home_doc: %@",documentsDirectory);
	return documentsDirectory;
}

//获取Library目录
- (void)dirLib {
	//[NSHomeDirectory() stringByAppendingPathComponent:@"Library"];
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
	NSString *libraryDirectory = [paths objectAtIndex:0];
	NSLog(@"app_home_lib: %@",libraryDirectory);
}

//获取Cache目录
- (void)dirCache {
	NSArray *cacPath = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
	NSString *cachePath = [cacPath objectAtIndex:0];
	NSLog(@"app_home_lib_cache: %@",cachePath);
}

//获取Tmp目录
- (void)dirTmp {
	//[NSHomeDirectory() stringByAppendingPathComponent:@"tmp"];
	NSString *tmpDirectory = NSTemporaryDirectory();
	NSLog(@"app_home_tmp: %@",tmpDirectory);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIButton* testBtn = [[UIButton alloc]initWithFrame:CGRectMake(100, 100, 130, 30)];
    [testBtn setTitle:@"定时计划接口" forState:UIControlStateNormal];
    testBtn.backgroundColor = [UIColor cyanColor];
    [testBtn addTarget:self action:@selector(testBtnCilcked) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:testBtn];
    
	
	NSLog(@"取模运算 : %i", (7 % 4));
	
	NSString *dirHome = NSHomeDirectory();
	NSLog(@"app_home: %@", dirHome);
	
	NSString *documentsPath =[self dirDoc];
	NSString *testDirectory = [documentsPath stringByAppendingPathComponent:@"test"];
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSString *testPath = [testDirectory stringByAppendingPathComponent:@"test.txt"];
	
//	BOOL res=[content writeToFile:testPath atomically:YES encoding:NSUTF8StringEncoding error:nil];
	BOOL res=[fileManager createFileAtPath:testPath contents:nil attributes:nil];
	if (res) {
		NSLog(@"文件写入成功");
	}else
		NSLog(@"文件写入失败");
	
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
//    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
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
	
	 UIImage *shareimage =  [UIView getImageFromView:self.view];
      
    //1、构造分享内容
    id<ISSContent> publishContent = [ShareSDK content:@"可以连接蓝牙的太空按摩椅"
                                       defaultContent:@"在IOS上分享"
                                                image:[ShareSDK pngImageWithImage:shareimage]
                                                title:@"荣泰按摩椅分享"
                                                  url:@"http://www.rongtai-china.com/product"
                                          description:@"这是一条演示信息"
                                            mediaType:SSPublishContentMediaTypeNews];
  
    id<ISSContainer> container = [ShareSDK container];
	
	//要分享的列表
	NSArray *shareList = [ShareSDK getShareListWithType:ShareTypeWeixiSession, ShareTypeWeixiTimeline, ShareTypeQQ, ShareTypeSinaWeibo, nil];
	
    //2、弹出分享菜单
    [ShareSDK showShareActionSheet:container
                         shareList:shareList
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
                               
//                               NSString *info = [uid stringByAppendingString:token];
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
							   
//							   NSString *info = [uid stringByAppendingString:token];
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
     

-(void)testBtnCilcked
{
    NSLog(@"Test");
//    TimingPlanRequest* r = [TimingPlanRequest new];
//    [r deleteTimingPlanId:81 success:nil fail:nil];
	
//    [r updateTimingPlan:nil success:^{
//        
//    } fail:^(NSDictionary *dic) {
//        
//    }];
    
//    [r getTimingPlanListSuccess:^(NSArray *timingPlanList) {
//
//    } fail:^(NSDictionary *dic) {
//        
//    }];
    
//    [r addTimingPlan:nil success:^(NSUInteger timingPlanId) {
//        NSLog(@"添加定时计划成功：%ld",timingPlanId);
//    } fail:^(NSDictionary *dic) {
//        NSLog(@"添加定时计划失败:%@",dic);
//    }];
    
//    NSLog(@"tp");
    
    
//    DataRequest* dr = [DataRequest new];
//    [dr addProgramUsingCount:@[@{@"name":@"舒筋活络",@"count":@1,@"programId":@2312},@{@"name":@"舒筋活络",@"count":@18,@"programId":@2222}] Success:nil fail:nil];
//
//    
//    [dr getFavoriteProgramCountSuccess:^(NSArray *programs) {
//        NSLog(@"数组:%@",programs);
//        NSDictionary* dic = programs[0];
//        NSString* name = [dic objectForKey:@"name"];
//        NSLog(@"名字:%@",name);
//    } fail:^(NSDictionary *dic) {
//        
//    }];
    
    //添加几条按摩数据，测试用
//    [MassageRecord MR_truncateAll];
    
//    MassageRecord* m = [MassageRecord MR_createEntity];
//    m.date = @"2015-08-26";
//    m.state = 0;
//    m.useTime = [NSNumber numberWithInt:160];
//    m.name = @"运动恢复";
//    m.programId = @1;
    
    
//    MassageRecord* m1 = [MassageRecord MR_createEntity];
//    m1.date = @"2015-08-26";
//    m1.state = 0;
//    m1.useTime = [NSNumber numberWithInt:200];
//    m1.name = @"运动恢复";
//    m1.programId = @1;
//    
//    MassageRecord* m2 = [MassageRecord MR_createEntity];
//    m2.date = @"2015-08-28";
//    m2.state = 0;
//    m2.useTime = [NSNumber numberWithInt:500];
//    m2.name = @"工作减压";
//    m2.programId = @4;
//    
//    MassageRecord* m3 = [MassageRecord MR_createEntity];
//    m3.date = @"2015-08-30";
//    m3.state = 0;
//    m3.useTime = [NSNumber numberWithInt:100];
//    m3.name = @"肩颈重点";
//    m3.programId = @1;
//    
//    MassageRecord* m4 = [MassageRecord MR_createEntity];
//    m4.date = @"2015-09-01";
//    m4.state = 0;
//    m4.useTime = [NSNumber numberWithInt:200];
//    m4.name = @"腰椎舒缓";
//    m4.programId = @6;
//    
//    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
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
