//
//  RTBleBaseBusinessViewController.m
//  rongtai
//
//  Created by yoghourt on 6/29/15.
//  Copyright (c) 2015 William-zhang. All rights reserved.
//

#import "RTBleBaseBusinessViewController.h"

@interface RTBleBaseBusinessViewController ()<RTBleConnectorDelegate> {
	
	RTBleConnector *bleConnector;
	
}

@end

@implementation RTBleBaseBusinessViewController

- (void)viewDidLoad {
    [super viewDidLoad];

	bleConnector = [RTBleConnector shareManager];
}

- (void)viewWillAppear:(BOOL)animated {
	bleConnector.delegate = self;
}

#pragma mark - RTBleConnectorDelegate

- (void)didUpdateRTBleState:(CBCentralManagerState)state {
	// todo
	
	if (self.delegate && [self.delegate respondsToSelector:@selector(didUpdateRTBleState:)]) {
		[self.delegate didUpdateRTBleState:state];
	}
}

- (void)didFoundRTBlePeriperalInfo:(NSDictionary *)periperalInfo {
	// todo
	
}

- (void)didConnectRTBlePeripheral:(CBPeripheral *)peripheral {
	// todo
	
	if (self.delegate && [self.delegate respondsToSelector:@selector(didConnectRTBlePeripheral:)]) {
		[self.delegate didConnectRTBlePeripheral:peripheral];
	}
}

- (void)didFailToConnectRTBlePeripheral:(CBPeripheral *)peripheral {
	// todo
	
	if (self.delegate && [self.delegate respondsToSelector:@selector(didFailToConnectRTBlePeripheral:)]) {
		[self.delegate didFailToConnectRTBlePeripheral:peripheral];
	}
}

- (void)didDisconnectRTBlePeripheral:(CBPeripheral *)peripheral {
	// todo
	
	if (self.delegate && [self.delegate respondsToSelector:@selector(didDisconnectRTBlePeripheral:)]) {
		[self.delegate didDisconnectRTBlePeripheral:peripheral];
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

@end
