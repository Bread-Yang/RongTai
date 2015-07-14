//
//  ViewController.m
//  BLETool
//
//  Created by Jaben on 14-12-23.
//  Copyright (c) 2014年 Jaben. All rights reserved.
//

#import "RTBleListViewController.h"
#import "JRBluetoothManager.h"
#import "RTBleConnector.h"

@interface RTBleListViewController () <RTBleConnectorDelegate> {
    NSMutableArray *blePeriphrals;
    
    NSArray *segueIdentifiers;
    
    RTBleConnector *bleConnector;
}

@end

@implementation RTBleListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	
	UIImageView *backgroundImageView = [[UIImageView alloc]initWithFrame:self.view.frame];
	backgroundImageView.image = [UIImage imageNamed:@"bg"];
	[self.view insertSubview:backgroundImageView atIndex:0];
	
	self.periphralTableView.backgroundView = [[UIImageView alloc] initWithImage:
									 [UIImage imageNamed:@"bg"]];
	
    self.title = @"蓝牙连接";
	
	bleConnector = [RTBleConnector shareManager];
    
    blePeriphrals = [[NSMutableArray alloc] init];
	
    segueIdentifiers = @[@"scaleViewController", @"timerViewController", @"thermometerViewController"];
    
    UIBarButtonItem *refreshItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refreshTableView)];
    self.navigationItem.rightBarButtonItem = refreshItem;
}

- (void)viewWillAppear:(BOOL)animated {
    bleConnector.delegate = self;
	[bleConnector startScanRTPeripheral:nil];
	
	if (![RTBleConnector isBleTurnOn]) {
		self.periphralTableView.hidden = true;
	}
}

- (void)viewWillDisappear:(BOOL)animated {
	NSLog(@"viewWillDisappear()");
	[super viewWillDisappear:animated];
	
	[bleConnector stopScanRTPeripheral];
	//    bleConnector.delegate = nil;
}

- (void)viewDidDisappear:(BOOL)animated {
	NSLog(@"viewDidDisappear()");
    [super viewDidDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"mpSegue"]) {
        
    }
}

#pragma mark - TableView Data Source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return blePeriphrals.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *reuserId = @"BLE_PERIPHRAL_CELL";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuserId];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuserId];
    }
    
    NSDictionary *peripheralInfo = blePeriphrals[indexPath.row];
    CBPeripheral *peripheral = peripheralInfo[RTBle_Periperal];
    cell.textLabel.text = peripheral.name?:@"Periphral";
    cell.detailTextLabel.text = [peripheral.identifier UUIDString];
    
    return cell;
}

#pragma mark - TableView delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    NSDictionary *peripheralInfo = blePeriphrals[indexPath.row];
    CBPeripheral *peripheral = peripheralInfo[RTBle_Periperal];
    
    NSLog(@"statue == CBPeripheralStateConnected : %d",peripheral.state == CBPeripheralStateConnected);
	
    if (peripheral.state == CBPeripheralStateConnected) {
		if ([peripheral.name isEqualToString:RTLocalName]) {
			[self performSegueWithIdentifier:@"rtSegue" sender:nil];
		}
    } else {
        [[JRBluetoothManager shareManager] connectPeripheral:peripheral];
    }
    
    //    if ([peripheral.name isEqualToString:kDeviceThermometerName]) {
    //        [self performSegueWithIdentifier:@"thermometerViewController" sender:nil];
    //
    //    }else if([peripheral.name isEqualToString:kDeviceTimerName]) {
    //        [self performSegueWithIdentifier:@"timerViewController" sender:nil];
    //
    //    }else if([peripheral.name isEqualToString:kDeviceScaleName]) {
    //        [self performSegueWithIdentifier:@"scaleViewController" sender:nil];
    //    }
    
	
}

#pragma mark - RTBleConnectorDelegate

- (void)didUpdateRTBleState:(CBCentralManagerState)state {
	
	switch (state) {
		case CBCentralManagerStatePoweredOn :
			self.periphralTableView.hidden = false;
			[bleConnector startScanRTPeripheral:nil];
			break;
		case CBCentralManagerStatePoweredOff :
			self.periphralTableView.hidden = true;
			break;
	}
}

- (void)didFoundRTBlePeriperalInfo:(NSDictionary *)periperalInfo {
	
    CBPeripheral *newPeripheral = periperalInfo[RTBle_Periperal];
	
	if (![newPeripheral.name isEqualToString:RTLocalName]) {
		return;
	}
	
    for(NSDictionary *tempInfo in blePeriphrals) {
        CBPeripheral *existPeripheral = tempInfo[RTBle_Periperal];
        if([[existPeripheral.identifier UUIDString] isEqualToString:[newPeripheral.identifier UUIDString]]) {
            return;
        }
    }
	
    [blePeriphrals addObject:periperalInfo];
	
    [self.periphralTableView reloadData];
}

- (void)didConnectRTBlePeripheral:(CBPeripheral *)peripheral {
	NSLog(@"didConnectRTBlePeripheral()");
//    [SVProgressHUD dismiss];
	if ([peripheral.name isEqualToString:RTLocalName]) {
		[self performSegueWithIdentifier:@"rtSegue" sender:nil];
	}
}

- (void)didFailToConnectRTBlePeripheral:(CBPeripheral *)peripheral {
	NSLog(@"didFailToConnectRTBlePeripheral()");
//    [SVProgressHUD dismiss];
//    [VMAlertUtil show:@"连接设备失败"];
}

- (void)didDisconnectRTBlePeripheral:(CBPeripheral *)peripheral {
	NSLog(@"didDisconnectRTBlePeripheral");
}

#pragma mark --Misc

- (void)refreshTableView {
    [blePeriphrals removeAllObjects];
    [self.periphralTableView reloadData];
    [bleConnector stopScanRTPeripheral];
    [bleConnector startScanRTPeripheral:nil];
}

@end
