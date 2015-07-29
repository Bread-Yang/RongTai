//
//  BasicViewController.m
//  rongtai
//
//  Created by William-zhang on 15/7/10.
//  Copyright (c) 2015年 William-zhang. All rights reserved.
//

#import "BasicViewController.h"

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
		
		if (!bleConnector.currentConnectedPeripheral) {
			reconnectDialog = [[CustomIOSAlertView alloc] init];
			reconnectDialog.isReconnectDialog = YES;
			
			reconnectDialog.reconnectTipsString = NSLocalizedString(@"未连接设备", nil);
			[reconnectDialog setButtonTitles:[NSMutableArray arrayWithObjects:NSLocalizedString(@"重新连接", nil), nil]];
			
			__weak UIViewController *weakSelf = self;
			[reconnectDialog setOnButtonTouchUpInside:^(CustomIOSAlertView *alertView, int buttonIndex) {
				UIStoryboard *secondStoryBoard = [UIStoryboard storyboardWithName:@"Second" bundle:[NSBundle mainBundle]];
    			UIViewController *viewController = [secondStoryBoard instantiateViewControllerWithIdentifier:@"ScanVC"];
    			[weakSelf.navigationController pushViewController:viewController animated:YES];
				
				[alertView close];
			}];
			
			[reconnectDialog show];
		} else {
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
