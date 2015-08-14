//
//  BasicViewController.m
//  rongtai
//
//  Created by William-zhang on 15/7/10.
//  Copyright (c) 2015年 William-zhang. All rights reserved.
//

#import "BasicViewController.h"
#import "MainViewController.h"
#import "AutoMassageViewController.h"
#import "ScanViewController.h"
#import "ManualViewController.h"
#import "FinishMassageViewController.h"

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
	
	self.resettingDialog = [[CustomIOSAlertView alloc] init];
	self.resettingDialog.isReconnectDialog = YES;
	self.resettingDialog.reconnectTipsString = NSLocalizedString(@"复位中", nil);
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
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
    [super viewWillDisappear:animated];
	if (self.isListenBluetoothStatus) {
		bleConnector.delegate = nil;
	}
}

- (void)backToMainViewController {
	[RTBleConnector shareManager].delegate = nil;
	
	for (int i = 0; i < [self.navigationController.viewControllers count]; i++) {
		UIViewController *temp = self.navigationController.viewControllers[i];
		if ([temp isKindOfClass:[MainViewController class]]) {
			[self.navigationController popToViewController:temp animated:YES];
			return;
		}
	}
}

- (void)jumpToAutoMassageViewConroller {
	// 按摩椅处在正在按摩的状态下才给跳转
	if ([RTBleConnector shareManager].rtMassageChairStatus.deviceStatus == RtMassageChairStatusMassaging) {
		
		[RTBleConnector shareManager].delegate = nil;
		
		for (int i = 0; i < [self.navigationController.viewControllers count]; i++) {
			UIViewController *temp = self.navigationController.viewControllers[i];
			if ([temp isKindOfClass:[AutoMassageViewController class]]) {
				[self.navigationController popToViewController:temp animated:YES];
				return;
			}
		}
		
		UIStoryboard *s = [UIStoryboard storyboardWithName:@"Login" bundle:nil];
		AutoMassageViewController *autoVC = (AutoMassageViewController*)[s instantiateViewControllerWithIdentifier:@"AutoMassageVC"];
		[self.navigationController pushViewController:autoVC animated:YES];
		
	}
}

- (void)jumpToScanViewConroller {
	// 按摩椅处在正在按摩的状态下才给跳转
	if ([RTBleConnector shareManager].rtMassageChairStatus.deviceStatus == RtMassageChairStatusMassaging) {
		
		[RTBleConnector shareManager].delegate = nil;
		
		for (int i = 0; i < [self.navigationController.viewControllers count]; i++) {
			UIViewController *temp = self.navigationController.viewControllers[i];
			if ([temp isKindOfClass:[ScanViewController class]]) {
				[self.navigationController popToViewController:temp animated:YES];
				return;
			}
		}
		
		UIStoryboard *s = [UIStoryboard storyboardWithName:@"Login" bundle:nil];
		ScanViewController *scan = (ScanViewController *)[s instantiateViewControllerWithIdentifier:@"ScanVC"];
		
		[self.navigationController pushViewController:scan animated:YES];
		
	}
}

- (void)jumpToManualMassageViewConroller {
	// 按摩椅处在正在按摩的状态下才给跳转
	if ([RTBleConnector shareManager].rtMassageChairStatus.deviceStatus == RtMassageChairStatusMassaging) {
		
		[RTBleConnector shareManager].delegate = nil;
		
		for (int i = 0; i < [self.navigationController.viewControllers count]; i++) {
			UIViewController *temp = self.navigationController.viewControllers[i];
			if ([temp isKindOfClass:[ManualViewController class]]) {
				[self.navigationController popToViewController:temp animated:YES];
				return;
			}
		}
		
		UIStoryboard *s = [UIStoryboard storyboardWithName:@"Login" bundle:nil];
		ManualViewController* mVC = (ManualViewController*)[s instantiateViewControllerWithIdentifier:@"ManualVC"];
		
		[self.navigationController pushViewController:mVC animated:YES];
	}
}

- (void)jumpToFinishMassageViewConroller {
	[RTBleConnector shareManager].delegate = nil;
	
	for (int i = 0; i < [self.navigationController.viewControllers count]; i++) {
		UIViewController *temp = self.navigationController.viewControllers[i];
		if ([temp isKindOfClass:[FinishMassageViewController class]]) {
			[self.navigationController popToViewController:temp animated:YES];
			return;
		}
	}
	UIStoryboard *s = [UIStoryboard storyboardWithName:@"Login" bundle:nil];
	FinishMassageViewController *finishViewController = (FinishMassageViewController *)[s instantiateViewControllerWithIdentifier:@"FinishMassageVC"];
	[self.navigationController pushViewController:finishViewController animated:YES];
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
	
	[_resettingDialog close];
	[reconnectDialog show];
}

@end
