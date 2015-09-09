//
//  ProgramDownloadTableViewController.m
//  rongtai
//
//  Created by yoghourt on 6/14/15.
//  Copyright (c) 2015 William-zhang. All rights reserved.
//

#import "ProgramDownloadViewController.h"
#import "UIBarButtonItem+goBack.h"
#import "RTBleConnector.h"
#import "ReadFile.h"
#import "ProgramDownloadTableViewCell.h"
#import "MBProgressHUD.h"
#import "AFHTTPRequestOperationManager.h"
#import "AppDelegate.h"
#import "RongTaiConstant.h"
#import "MassageProgram.h"
#import "MassageProgramRequest.h"

@interface ProgramDownloadViewController ()<UITableViewDelegate, UITableViewDataSource, RTBleConnectorDelegate> {
	
	MBProgressHUD *_loadingHUD;
	NSMutableArray *_programArray, *_alreadyInstallArray;
}

@property(nonatomic, strong) AFHTTPRequestOperationManager *httpRequestManager;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation ProgramDownloadViewController

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.isListenBluetoothStatus = YES;
	
	self.httpRequestManager = [AFHTTPRequestOperationManager manager];
	
	self.resettingDialog.reconnectTipsString = NSLocalizedString(@"安装中", nil);
	
	//MBProgressHUD
    _loadingHUD = [[MBProgressHUD alloc]initWithView:self.view];
    _loadingHUD.labelText = NSLocalizedString(@"读取中...", nil);
    [self.view addSubview:_loadingHUD];
	
	UIBarButtonItem *item = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"icon_back"] style:UIBarButtonItemStylePlain target:self action:@selector(goBack)];
	self.navigationItem.leftBarButtonItem = item;
	
	if (self.isDownloadCustomProgram) {
		self.title = NSLocalizedString(@"已有程序", nil);
		
		// 让UITableView滑动的时候, header不float
		CGFloat dummyViewHeight = 40;
		UIView *dummyView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.bounds.size.width, dummyViewHeight)];
		self.tableView.tableHeaderView = dummyView;
		self.tableView.contentInset = UIEdgeInsetsMake(-dummyViewHeight, 0, 0, 0);
	} else {
		self.title = NSLocalizedString(@"程序下载", nil);
	}
	self.tableView.hidden = YES;
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	
	AFNetworkReachabilityManager *reachability = [AFNetworkReachabilityManager sharedManager];
	if (reachability.reachable) {
		//网络请求
		_loadingHUD.labelText = @"读取中...";
		[_loadingHUD show:YES];
		
		MassageProgramRequest *request = [[MassageProgramRequest alloc] init];
		
		[request requestNetworkMassageProgramListByIndex:0 Size:100 success:^(NSArray *networkMassageProgramArray) {
			
			[self refreshTableViewAfterRequest:networkMassageProgramArray];
			
		} failure:^(NSArray *localMassageProgramArray) {
			
			[self refreshTableViewAfterRequest:localMassageProgramArray];
			
		}];
	} else {
		NSLog(@"没网，本地记录读取成员");
	}
}

- (void)refreshTableViewAfterRequest:(NSArray *) massageProgramArray {
	[_loadingHUD hide:YES];
	
	_programArray = [[NSArray arrayWithArray:massageProgramArray] mutableCopy];
	
	if (self.isDownloadCustomProgram) {
		_alreadyInstallArray = [[NSMutableArray alloc] init];
		
		for (NSNumber *item in [RTBleConnector shareManager].rtNetworkProgramStatus.networkProgramStatusArray) {
			int networkMassageId = [item intValue];
			
			if (networkMassageId != 0) {
				
				NSArray *tempArray = [NSArray arrayWithArray:_programArray];
				
				for (MassageProgram *program in tempArray) {
					if ([program.commandId intValue] == networkMassageId) {
						[_alreadyInstallArray addObject:program];
						[_programArray removeObject:program];
						continue;
					}
				}
			}
		}
	}
	
	[self.tableView reloadData];
	
	self.tableView.hidden = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 返回

- (void)goBack {
//    [self.navigationController popViewControllerAnimated:YES];
	[self backToMainViewController];
	
//	[[RTBleConnector shareManager] sendControlByBytes:[[RTBleConnector shareManager] exitEditMode]];  // 退出编辑模式
}

#pragma mark - RTBleConnectorDelegate

- (void)didUpdateStatusInProgramMode:(NSData *)rawData {
	
}

- (void)didUpdateNetworkMassageStatus:(RTNetworkProgramStatus *)rtNetwrokProgramStatus {
	NSLog(@"didUpdateNetworkMassageStatus");
	[_tableView reloadData];
}

- (void)didStartInstallProgramMassage {
	[self.resettingDialog show];
}

- (void)didEndInstallProgramMassage {
	[self.resettingDialog close];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	if (self.isDownloadCustomProgram) {
		return 2;
	} else {
		return 1;
	}
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	if (self.isDownloadCustomProgram) {
		if (section == 0) {
			return NSLocalizedString(@"可选择按摩程序", nil);
		} else {
			return NSLocalizedString(@"已有按摩程序", nil);
		}
	} else {
		return nil;
	}
}

//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
// 	UITableViewHeaderFooterView *headerFoorterView = [[self tableView] dequeueReusableHeaderFooterViewWithIdentifier:@"headerFooterReuseIdentifier"];
//	headerFoorterView.backgroundColor = [UIColor clearColor];
//	headerFoorterView.contentView.backgroundColor = [UIColor clearColor];
// 	return headerFoorterView;
//}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
	if ([view isKindOfClass:[UITableViewHeaderFooterView class]]) {
		UITableViewHeaderFooterView *headerView = (UITableViewHeaderFooterView *)view;
		headerView.contentView.backgroundColor = [UIColor clearColor];
		headerView.backgroundView.backgroundColor = [UIColor clearColor];
	}
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	if (self.isDownloadCustomProgram) {
		return 40;
	}
	return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (self.isDownloadCustomProgram) {
		if (section == 0) {
			return [_programArray count];
		} else {
			return [_alreadyInstallArray count];
		}
	} else {
		return [_programArray count];
	}
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
    ProgramDownloadTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ProgramDownloadTableViewCell" forIndexPath:indexPath];
	
	UIImageView *bgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"list_bg"]];
	
	cell.backgroundView = bgView;
	
	
	if (self.isDownloadCustomProgram) {
		if (indexPath.section == 0) {
			cell.massageProgram = [_programArray objectAtIndex:indexPath.row];
		} else {
			cell.massageProgram = [_alreadyInstallArray objectAtIndex:indexPath.row];
		}
		
	} else {
		cell.massageProgram = [_programArray objectAtIndex:indexPath.row];
	}
	
	
	NSLog(@"值是 : %zd", [cell.massageProgram.commandId integerValue]);
	
	NSInteger isAlreadyInstall = [[RTBleConnector shareManager].rtNetworkProgramStatus isAlreadyIntall:[cell.massageProgram.commandId integerValue]];
	
	if (isAlreadyInstall) {
		cell.isAlreadyDownload = true;
	} else {
		cell.isAlreadyDownload = false;
	}
	
    return cell;
}

@end
