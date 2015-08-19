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

@interface ProgramDownloadViewController ()<UITableViewDelegate, UITableViewDataSource, RTBleConnectorDelegate> {
	
	MBProgressHUD *_loadingHUD;
	NSArray *_programArray;
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
	AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
	_loadingHUD = [[MBProgressHUD alloc]initWithWindow:appDelegate.window];
	[appDelegate.window addSubview:_loadingHUD];
	
	UIBarButtonItem *item = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"icon_back"] style:UIBarButtonItemStylePlain target:self action:@selector(goBack)];
	self.navigationItem.leftBarButtonItem = item;
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	
	AFNetworkReachabilityManager *reachability = [AFNetworkReachabilityManager sharedManager];
	if (reachability.reachable) {
		//网络请求
		_loadingHUD.labelText = @"读取中...";
		[_loadingHUD show:YES];
		
		NSLog(@"请求成员");
		NSString *uid = [[NSUserDefaults standardUserDefaults] objectForKey:@"uid"];
		NSMutableArray *arr = [NSMutableArray new];
		
		self.httpRequestManager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
		
		NSString *requestURL = [RongTaiDefaultDomain stringByAppendingString:@"loadMassage"];
		
		NSMutableDictionary *parmeters = [NSMutableDictionary new];
		[parmeters setObject:uid forKey:@"uid"];
		[parmeters setObject:[NSNumber numberWithInteger:0] forKey:@"index"];
		[parmeters setObject:[NSNumber numberWithInteger:1000] forKey:@"size"];
		
		[self.httpRequestManager POST:requestURL parameters:parmeters success:^(AFHTTPRequestOperation *operation, id responseObject) {
			
			NSLog(@"获取程序下载列表 :%@",responseObject);
			NSNumber *code = [responseObject objectForKey:@"responseCode"];
			if ([code integerValue] == 200) {
				[_loadingHUD hide:YES];
				
				NSMutableArray *arr = [NSMutableArray new];
				
				NSArray *result = [responseObject objectForKey:@"result"];
				
				for (NSDictionary *dic in result) {
					MassageProgram *program = [[MassageProgram alloc] initWithJSON:dic];
					[arr addObject:program];
				}
				
				_programArray = [NSArray arrayWithArray:arr];
				
				[self.tableView reloadData];
			} else {
				[_loadingHUD hide:YES];
			}
		} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
				[_loadingHUD hide:YES];
		}];
	} else {
		NSLog(@"没网，本地记录读取成员");
	}
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 返回

- (void)goBack {
    [self.navigationController popViewControllerAnimated:YES];
	
	[[RTBleConnector shareManager] sendControlByBytes:[[RTBleConnector shareManager] exitEditMode]];  // 退出编辑模式
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
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_programArray count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
    ProgramDownloadTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ProgramDownloadTableViewCell" forIndexPath:indexPath];
	cell.massageProgram = [_programArray objectAtIndex:indexPath.row];
	
	NSInteger isAlreadyInstall = [[RTBleConnector shareManager].rtNetworkProgramStatus isAlreadyIntall:cell.massageProgram.commandId];
	
	if (isAlreadyInstall) {
		cell.isAlreadyDownload = true;
	} else {
		cell.isAlreadyDownload = false;
	}
	
    return cell;
}

@end
