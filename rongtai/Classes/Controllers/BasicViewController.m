//
//  BasicViewController.m
//  rongtai
//
//  Created by William-zhang on 15/7/10.
//  Copyright (c) 2015年 William-zhang. All rights reserved.
//

#import "BasicViewController.h"
#import "MainViewController.h"

#import "CustomIOSAlertView.h"

@interface BasicViewController () <CustomIOSAlertViewDelegate> {
	
	RTBleConnector *bleConnector;
	
	CustomIOSAlertView *reconnectDialog;
	
}

@end 

@implementation BasicViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	
    CGSize size = [UIScreen mainScreen].bounds.size;
    UIImageView *bg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
    bg.image = [UIImage imageNamed:@"bg"];
	
    [self.view addSubview:bg];
    [self.view sendSubviewToBack:bg];
	
}

- (void)viewWillAppear:(BOOL)animated {
	if (self.isListenBluetoothStatus) {
		bleConnector = [RTBleConnector shareManager];
		bleConnector.delegate = self;
		
		reconnectDialog = [[CustomIOSAlertView alloc] init];
		reconnectDialog.isReconnectDialog = YES;
		reconnectDialog.reconnectTipsString = NSLocalizedString(@"设备连接断开", nil);
		[reconnectDialog setButtonTitles:[NSMutableArray arrayWithObjects:@"取消", nil]];
		
		__weak RTBleConnector *weakPointer = bleConnector;
		[reconnectDialog setOnButtonTouchUpInside:^(CustomIOSAlertView *alertView, int buttonIndex) {
			if (weakPointer.reconnectTimer && [weakPointer.reconnectTimer isValid]) {
				[weakPointer.reconnectTimer invalidate];
			}
			[alertView close];
		}];
	}
}

- (void)viewWillDisappear:(BOOL)animated {
	if (self.isListenBluetoothStatus) {
		bleConnector.delegate = nil;
	}
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)backToMainViewController {
	for (int i = 0; i < [self.navigationController.viewControllers count]; i++) {
		UIViewController *temp = self.navigationController.viewControllers[i];
		if ([temp isKindOfClass:[MainViewController class]]) {
//			NSLog(@"当前的index : %zd", i);
			[self.navigationController popToViewController:temp animated:YES];
		}
	}
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - RTBleConnectorDelegate

- (void)didUpdateRTBleState:(CBCentralManagerState)state {
}

- (void)didUpdateMassageChairStatus:(RTMassageChairStatus *)rtMassageChairStatus {
}

- (void)didConnectRTBlePeripheral:(CBPeripheral *)peripheral {
	// dimiss reconnect dialog
	[reconnectDialog close];
}

- (void)didFailToConnectRTBlePeripheral:(CBPeripheral *)peripheral {
	
}

- (void)didDisconnectRTBlePeripheral:(CBPeripheral *)peripheral {
	// show reconnect dialog
	
	[reconnectDialog show];
}

@end
