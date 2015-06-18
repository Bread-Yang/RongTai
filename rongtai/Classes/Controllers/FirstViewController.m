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

@interface FirstViewController () <AppIntroduceViewDelegate>

@property AppIntrouceView *introduceView;

@property MPMusicPlayerController *musicPlayer;

@end

@implementation FirstViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.navigationController.navigationBar.barTintColor = [UIColor blackColor];
	
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
    [self.navigationController pushViewController:viewController animated:YES];

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
         
                               NSString *uid = [userInfo uid];
                               NSString *nickName = [userInfo nickname];
                               
                               NSString *info = [uid stringByAppendingString:nickName];
        
                               if (result) {
                                   UIAlertView *alertView = [[UIAlertView alloc]
                                       initWithTitle:@"Hello"
                                       message:info
                                       delegate:nil
                                       cancelButtonTitle:@"知道了"
                                       otherButtonTitles: nil];
                                   [alertView show];
                               }
         
     }];
}

- (IBAction)qqLoginAction:(id)sender {
}

- (IBAction)logoutAction:(id)sender {
    [ShareSDK cancelAuthWithType:ShareTypeSinaWeibo];
    [ShareSDK cancelAuthWithType:ShareTypeQQ];
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
