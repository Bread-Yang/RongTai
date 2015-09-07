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
#import "MainViewController.h"
#import "UIBarButtonItem+goBack.h"

@interface RTBleListViewController () <RTBleConnectorDelegate> {
    NSMutableArray *blePeriphrals;
    
    NSArray *segueIdentifiers;
    
    RTBleConnector *bleConnector;
    UIBarButtonItem *refreshItem;
    UIImageView* _cView;
    BOOL _isRefresh; //是否正在刷新
    NSUInteger _count;
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
    
    _cView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 22, 22)];
    _cView.userInteractionEnabled = YES;
    UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(refreshTableView)];
    [_cView addGestureRecognizer:tap];
    _cView.image = [UIImage imageNamed:@"icon_refresh"];
    _cView.backgroundColor = [UIColor clearColor];
    refreshItem = [[UIBarButtonItem alloc]initWithCustomView:_cView];
    
    self.navigationItem.rightBarButtonItem = refreshItem;
    
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem goBackItemByTarget:self Action:@selector(back)];
    
    _isRefresh = NO;
    _count = 6;
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

#pragma mark - 返回按钮方法
-(void)back
{
    [self.navigationController popViewControllerAnimated:YES];
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
	cell.backgroundColor = [UIColor clearColor];
	cell.contentView.backgroundColor = [UIColor clearColor];

    
    NSDictionary *peripheralInfo = blePeriphrals[indexPath.row];
    CBPeripheral *peripheral = peripheralInfo[RTBle_Periperal];
	
	int remainder = indexPath.row % 3;
	
	UIImage *image;
	
	switch (remainder) {
  		case 0:
			image = [UIImage imageNamed:@"connect_device_1"];
			break;
		case 1:
			image = [UIImage imageNamed:@"connect_device_2"];
			break;
		case 2:
			image = [UIImage imageNamed:@"connect_device_3"];
			break;
	}
	
	cell.imageView.image = image;
    cell.textLabel.text = peripheral.name?:@"Periphral";
    cell.detailTextLabel.text = [peripheral.identifier UUIDString];
	
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
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
			[self.navigationController popViewControllerAnimated:YES];
		}
    } else {
		[bleConnector cancelCurrentConnectedRTPeripheral];  // cancal current device connection, then connect another device
        [bleConnector connectRTPeripheral:peripheral];
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
	NSLog(@"didUpdateRTBleState:");
	
	switch (state) {
		case CBCentralManagerStatePoweredOn :
			self.periphralTableView.hidden = false;
			[bleConnector startScanRTPeripheral:nil];
			break;
		case CBCentralManagerStatePoweredOff :
			self.periphralTableView.hidden = true;
			break;
        default:
            break;
	}
}

- (void)didUpdateMassageChairStatus:(RTMassageChairStatus *)rtMassageChairStatus {
//	NSLog(@"didUpdateMassageChairStatus:");
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
//    _isRefresh = NO;
}

- (void)didConnectRTBlePeripheral:(CBPeripheral *)peripheral {
	NSLog(@"didConnectRTBlePeripheral()");
//    [SVProgressHUD dismiss];
	if ([peripheral.name isEqualToString:RTLocalName]) {
//		[self performSegueWithIdentifier:@"rtSegue" sender:nil];
		
		[self.navigationController popViewControllerAnimated:YES];
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

#pragma mark - 刷新按钮动画
-(void)refreshAnimation:(NSTimeInterval)time
{
    [UIView animateWithDuration:time delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        _cView.transform = CGAffineTransformRotate(_cView.transform, -M_PI_2);
    } completion:^(BOOL finished) {
        _cView.frame = CGRectMake(0, 0, 22, 22);
    }];
}

-(void)refreshTimer:(NSTimer*)timer
{
    if (_count<1) {
        [timer invalidate];
        _count = 6;
        _isRefresh = NO;
    }
    else
    {
        [self refreshAnimation:0.25];
        _count--;
    }
}

#pragma mark --Misc
- (void)refreshTableView {
    if (!_isRefresh) {
        _isRefresh = YES;
        //刷新按钮 开始旋转动画
        NSLog(@"刷新");
        [NSTimer scheduledTimerWithTimeInterval:0.25 target:self
                                       selector:@selector(refreshTimer:) userInfo:nil repeats:YES];
        [blePeriphrals removeAllObjects];
        [self.periphralTableView reloadData];
        [bleConnector stopScanRTPeripheral];
        [bleConnector startScanRTPeripheral:nil];
    }
}

@end
