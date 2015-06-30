//
//  RTController.m
//  BLETool
//
//  Created by Jaben on 15/5/20.
//  Copyright (c) 2015年 Jaben. All rights reserved.
//

#import "RTViewController.h"
#import "RTBleConnector.h"
#import "RTCommand.h"

@interface RTViewController ()

@end

@implementation RTViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	NSLog(@"viewDidLoad()");
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	NSLog(@"viewWillAppear()");
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	NSLog(@"viewDidAppear()");
}

- (void)viewDidLayoutSubviews {
	[super viewDidLayoutSubviews];
	NSLog(@"viewDidLayoutSubviews()");
}

- (void)viewWillLayoutSubviews {
	[super viewWillLayoutSubviews];
	NSLog(@"viewWillLayoutSubviews()");
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
	[super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
	NSLog(@"viewWillTransitionToSize");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Button Action

- (IBAction)powerSwitchControlAction:(id)sender {
    [[RTBleConnector shareManager] controlMode:H10_KEY_POWER_SWITCH];
}

- (IBAction)autoMode0Action:(id)sender {
    [[RTBleConnector shareManager] controlMode:H10_KEY_CHAIR_AUTO_0];
}

- (IBAction)autoMode1Action:(id)sender {
    [[RTBleConnector shareManager] controlMode:H10_KEY_CHAIR_AUTO_1];
}

- (IBAction)autoMode2Action:(id)sender {
    [[RTBleConnector shareManager] controlMode:H10_KEY_CHAIR_AUTO_2];
}

- (IBAction)autoMode3Action:(id)sender {
    [[RTBleConnector shareManager] controlMode:H10_KEY_CHAIR_AUTO_3];
}

- (IBAction)autoMode4Action:(id)sender {
    [[RTBleConnector shareManager] controlMode:H10_KEY_CHAIR_AUTO_4];
}

- (IBAction)autoMode5Action:(id)sender {
    [[RTBleConnector shareManager] controlMode:H10_KEY_CHAIR_AUTO_5];
}

- (IBAction)massageSpeed1Action:(id)sender {
    [[RTBleConnector shareManager] controlMode:H10_KEY_SPEED_1];
}

- (IBAction)massageSpeed2Action:(id)sender {
    [[RTBleConnector shareManager] controlMode:H10_KEY_SPEED_2];
}

- (IBAction)massageSpeed3Action:(id)sender {
    [[RTBleConnector shareManager] controlMode:H10_KEY_SPEED_3];
}

- (IBAction)massageSpeed4Action:(id)sender {
     [[RTBleConnector shareManager] controlMode:H10_KEY_SPEED_4];
}

- (IBAction)massageSpeed5Action:(id)sender {
     [[RTBleConnector shareManager] controlMode:H10_KEY_SPEED_5];
}

- (IBAction)rollerSpeedOff:(id)sender {
    [[RTBleConnector shareManager] controlMode:H10_KEY_WHEEL_SPEED_OFF];
}

- (IBAction)rollerSpeedSlow:(id)sender {
    [[RTBleConnector shareManager] controlMode:H10_KEY_WHEEL_SPEED_SLOW];
}

- (IBAction)rollerSpeedMed:(id)sender {
    [[RTBleConnector shareManager] controlMode:H10_KEY_WHEEL_SPEED_MED];
}

- (IBAction)rollerSpeedFast:(id)sender {
    [[RTBleConnector shareManager] controlMode:H10_KEY_WHEEL_SPEED_FAST];
}
@end
