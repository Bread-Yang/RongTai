//
//  FirstViewController.h
//  rongtai
//
//  Created by Jaben on 15/5/26.
//  Copyright (c) 2015年 William-zhang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WelcomeViewController : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *currentPlaySongLabel;

@property (weak, nonatomic) IBOutlet UIButton *previousSongButton;

@property (weak, nonatomic) IBOutlet UIButton *playOrPauseButton;

@property (weak, nonatomic) IBOutlet UIButton *nextSongButton;

#pragma mark - View Action

- (IBAction)qqLoginAction:(id)sender;

- (IBAction)logoutAction:(id)sender;

- (IBAction)previousSongAction:(id)sender;

- (IBAction)nextSongAction:(id)sender;

- (IBAction)playOrPauseAction:(id)sender;

@end
