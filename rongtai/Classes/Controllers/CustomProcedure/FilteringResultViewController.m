//
//  FilteringResultViewController.m
//  rongtai
//
//  Created by yoghourt on 9/21/15.
//  Copyright © 2015 William-zhang. All rights reserved.
//

#import "FilteringResultViewController.h"
#import "RTBleConnector.h"
#import "MBProgressHUD.h"
#import "MassageProgramRequest.h"
#import "ProgramDownloadTableViewCell.h"
#import "RTBleConnector.h"
#import "RTCommand.h"

@interface FilteringResultViewController () <UITableViewDelegate, UITableViewDataSource, RTBleConnectorDelegate> {
	
	MBProgressHUD *_loadingHUD;
	NSArray *_localProgramArray, *_allNetworkProgramArray;
	NSMutableArray *_notYetInstallProgramArray, *_alreadyInstallProgramArray;
	RTBleConnector* _bleConnector;
	MassageProgram *_filterPrgoram;
}

@property (weak, nonatomic) IBOutlet UITableView *selectableProgramTableView, *alreadyInstallProgramTableView;

@end

@implementation FilteringResultViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.title = NSLocalizedString(@"筛选结果", nil);
	
	UIBarButtonItem *item = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"icon_back"] style:UIBarButtonItemStylePlain target:self action:@selector(goBack)];
	self.navigationItem.leftBarButtonItem = item;
	
	self.isListenBluetoothStatus = YES;
	
	// 让UITableView滑动的时候, header不float
	CGFloat dummyViewHeight = 40;
	UIView *dummyView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.selectableProgramTableView.bounds.size.width, dummyViewHeight)];
	
	self.selectableProgramTableView.tableHeaderView = dummyView;
	self.selectableProgramTableView.contentInset = UIEdgeInsetsMake(-dummyViewHeight, 0, 0, 0);
	
	self.alreadyInstallProgramTableView.tableHeaderView = dummyView;
	self.alreadyInstallProgramTableView.contentInset = UIEdgeInsetsMake(-dummyViewHeight, 0, 0, 0);
	
	// 自带程序的数据
	NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"LocalProgramList" ofType:@"plist"];
	_localProgramArray = [[NSArray alloc] initWithContentsOfFile:plistPath];
	
	//MBProgressHUD
	_loadingHUD = [[MBProgressHUD alloc]initWithView:self.view];
	_loadingHUD.labelText = NSLocalizedString(@"读取中...", nil);
	[self.view addSubview:_loadingHUD];
	
	// 网络程序请求
	[_loadingHUD show:YES];
	
	MassageProgramRequest *request = [[MassageProgramRequest alloc] init];
	
	[request requestNetworkMassageProgramListByIndex:0 Size:100 success:^(NSArray *networkMassageProgramArray) {
		
		[self refreshTableViewAfterRequest:networkMassageProgramArray];
		
	} failure:^(NSArray *localMassageProgramArray) {
		NSLog(@"下载程序：读取本地记录：%@",localMassageProgramArray);
		[self refreshTableViewAfterRequest:localMassageProgramArray];
		
	}];
}

#pragma mark - 更新数据

- (void)refreshTableViewAfterRequest:(NSArray *) massageProgramArray {
	[_loadingHUD hide:YES];
	
	_allNetworkProgramArray = [NSArray arrayWithArray:massageProgramArray];
	
	[self resortData];
	
}

- (void)resortData {

	_alreadyInstallProgramArray = [[NSMutableArray alloc] init];
	
	_notYetInstallProgramArray = [_allNetworkProgramArray mutableCopy];
	
	for (NSNumber *item in [RTBleConnector shareManager].rtNetworkProgramStatus.networkProgramStatusArray) {
		int networkMassageId = [item intValue];
		
		if (networkMassageId != 0) {
			
			for (MassageProgram *program in _allNetworkProgramArray) {
				
				if ([program.massageId integerValue] == self.programId) {
					_filterPrgoram = program;
				}
				
				if ([program.commandId intValue] == networkMassageId) {
					[_alreadyInstallProgramArray addObject:program];
					[_notYetInstallProgramArray removeObject:program];
					continue;
				}
			}
		}
	}
	
	[self.selectableProgramTableView reloadData];
	
	[self.alreadyInstallProgramTableView reloadData];
}

#pragma mark - 返回

- (void)goBack {
	//	[[RTBleConnector shareManager] sendControlByBytes:[[RTBleConnector shareManager] exitEditMode]];  // 退出编辑模式
	[self.navigationController popViewControllerAnimated:YES];
	//	[self backToMainViewController];
	[[[MassageProgramRequest alloc] init] cancelRequest];
}

#pragma mark - RTBleConnectorDelegate

- (void)didUpdateNetworkMassageStatus:(RTNetworkProgramStatus *)rtNetwrokProgramStatus {
	NSLog(@"didUpdateNetworkMassageStatus");
	[self resortData];
}

- (void)didStartInstallProgramMassage {
	self.resettingDialog.reconnectTipsString = NSLocalizedString(@"安装中", nil);
	[self.resettingDialog show];
}

- (void)didEndInstallProgramMassage {
	[self.resettingDialog close];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	if (tableView == self.selectableProgramTableView) {
		return NSLocalizedString(@"可选择按摩程序", nil);
	} else {
		return NSLocalizedString(@"已有按摩程序", nil);
	}
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(tableView.frame), 30)];
	UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15, 5, 200, 25)];
	
	// 15 pixel padding will come from CGRectMake(15, 5, 200, 25).
	
	if (tableView == self.selectableProgramTableView) {
		label.text = NSLocalizedString(@"可选择按摩程序", nil);
	} else {
		label.text = NSLocalizedString(@"已有按摩程序", nil);
	}
	[view addSubview: label];
	return view;
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
	if ([view isKindOfClass:[UITableViewHeaderFooterView class]]) {
		UITableViewHeaderFooterView *headerView = (UITableViewHeaderFooterView *)view;
		headerView.contentView.backgroundColor = [UIColor clearColor];
		headerView.backgroundView.backgroundColor = [UIColor clearColor];
	}
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return 40;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	
	if (tableView == self.selectableProgramTableView) {
		
		// 显示自带程序 + 已经安装的云养程序 + 未安装的云养程序
//		return [_localProgramArray count] + [_alreadyInstallProgramArray count] + [_notYetInstallProgramArray count];
		
		if (_filterPrgoram) {
			return 1;
		} else {
			return 0;
		}
		
	} else {
		
		// 只显示已经安装的云养程序
		return [_alreadyInstallProgramArray count];
		
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	ProgramDownloadTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ProgramDownloadTableViewCell" forIndexPath:indexPath];
	
	UIImageView *bgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"list_bg"]];
	
	cell.backgroundView = bgView;
	
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
	
	cell.isLocalProgram = NO;
	
	if (tableView == self.selectableProgramTableView) {
//		if (indexPath.row < [_localProgramArray count]) {
//			NSDictionary *localProgramDic = _localProgramArray[indexPath.row];
//			
//			cell.isLocalProgram = YES;
//			
//			cell.programImageView.image = [UIImage imageNamed:localProgramDic[@"programImageUrl"]];
//			
//			// 程序名
//			cell.programNameLabel.text = localProgramDic[@"programName"];
//			
//			// 网络程序描述
//			cell.programDescriptionLabel.text = localProgramDic[@"programDescription"];
//			
//			cell.selectionStyle = UITableViewCellSelectionStyleDefault;
//			
//		} else if (indexPath.row >= [_localProgramArray count] && indexPath.row < ([_localProgramArray count] + [_alreadyInstallProgramArray count])) {
//			cell.isLocalProgram = YES;
//			
//			cell.massageProgram = [_alreadyInstallProgramArray objectAtIndex:indexPath.row - [_localProgramArray count]];
//			
//			cell.selectionStyle = UITableViewCellSelectionStyleDefault;
//		} else {
//			
//			cell.massageProgram = [_notYetInstallProgramArray objectAtIndex:indexPath.row - ([_localProgramArray count] + [_alreadyInstallProgramArray count])];
//		}
		cell.massageProgram = _filterPrgoram;
		
		
	} else {
		
		cell.massageProgram = [_alreadyInstallProgramArray objectAtIndex:indexPath.row];
	}
	
	
	NSInteger isAlreadyInstall = [[RTBleConnector shareManager].rtNetworkProgramStatus isAlreadyIntall:[cell.massageProgram.commandId integerValue]];
	
	RTBleConnector* bleconnector = [RTBleConnector shareManager];
	if (bleconnector.currentConnectedPeripheral == nil || ![RTBleConnector isBleTurnOn]) {
		
		cell.isAlreadyDownload = false;
		
	} else {
		if (isAlreadyInstall) {
			cell.isAlreadyDownload = true;
		} else {
			cell.isAlreadyDownload = false;
		}
	}
	return cell;
}

//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//	
//	if (indexPath.section == 1) {   //已有程序点击没有点击事件
//		return;
//	}
//	
//	if (indexPath.row >= ([_localProgramArray count] + [_alreadyInstallProgramArray count])) {
//		return;
//	}
//	
//	switch (indexPath.row) {
//			
//			// 运动恢复
//		case 0:
//			[[RTBleConnector shareManager] sendControlMode:H10_KEY_CHAIR_AUTO_0];
//			break;
//			
//			// 舒展活络
//		case 1:
//			[[RTBleConnector shareManager] sendControlMode:H10_KEY_CHAIR_AUTO_1];
//			break;
//			
//			// 休憩促眠
//		case 2:
//			[[RTBleConnector shareManager] sendControlMode:H10_KEY_CHAIR_AUTO_2];
//			break;
//			
//			// 工作减压
//		case 3:
//			[[RTBleConnector shareManager] sendControlMode:H10_KEY_CHAIR_AUTO_3];
//			break;
//			
//			// 肩颈重点
//		case 4:
//			[[RTBleConnector shareManager] sendControlMode:H10_KEY_CHAIR_AUTO_4];
//			break;
//			
//			// 腰椎舒缓
//		case 5:
//			[[RTBleConnector shareManager] sendControlMode:H10_KEY_CHAIR_AUTO_5];
//			break;
//			
//			// 云养程序一
//		case 6:
//			[[RTBleConnector shareManager] sendControlMode:H10_KEY_CHAIR_AUTO_NETCLOUD_1];
//			break;
//			// 云养程序二
//		case 7:
//			[[RTBleConnector shareManager] sendControlMode:H10_KEY_CHAIR_AUTO_NETCLOUD_2];
//			break;
//			// 云养程序三
//		case 8:
//			[[RTBleConnector shareManager] sendControlMode:H10_KEY_CHAIR_AUTO_NETCLOUD_3];
//			break;
//			// 云养程序四
//		case 9:
//			[[RTBleConnector shareManager] sendControlMode:H10_KEY_CHAIR_AUTO_NETCLOUD_4];
//			break;
//	}
//	
//	RTMassageChairStatus *rtMassageChairStatus = [RTBleConnector shareManager].rtMassageChairStatus;
//	
//	if ([RTBleConnector shareManager].currentConnectedPeripheral != nil && rtMassageChairStatus != nil) {
//		
//		if (rtMassageChairStatus && rtMassageChairStatus.deviceStatus == RtMassageChairStatusMassaging) {
//			
//			[self jumpToCorrespondingControllerByMassageStatus];
//			
//		} else {
//			
//			// 延迟1.5秒再进入按摩界面
//			
//			double delayInSeconds = 1.5;
//			
//			dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
//			
//			dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
//				[self jumpToCorrespondingControllerByMassageStatus];
//			});
//		}
//	}
//}


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
