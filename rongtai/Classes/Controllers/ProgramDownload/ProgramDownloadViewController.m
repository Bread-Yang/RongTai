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
#import "ProgramCount.h"
#import "CoreData+MagicalRecord.h"
#import "RTCommand.h"

@interface ProgramDownloadViewController ()<UITableViewDelegate, UITableViewDataSource, RTBleConnectorDelegate> {
	
	MBProgressHUD *_loadingHUD;
	NSArray *_localProgramArray, *_allNetworkProgramArray;
	NSMutableArray *_notYetInstallProgramArray, *_alreadyInstallProgramArray;
    NSInteger _massageFlag;
    RTBleConnector* _bleConnector;
    NSArray* _skillsPreferenceName;
    ProgramCount* _programCount;
    NSString* _programName;
    
    NSInteger flag;

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
		self.title = NSLocalizedString(@"筛选结果", nil);
		
		// 让UITableView滑动的时候, header不float
		CGFloat dummyViewHeight = 40;
		UIView *dummyView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.bounds.size.width, dummyViewHeight)];
		self.tableView.tableHeaderView = dummyView;
		self.tableView.contentInset = UIEdgeInsetsMake(-dummyViewHeight, 0, 0, 0);
	} else {
		self.title = NSLocalizedString(@"程序下载", nil);
	}
	self.tableView.hidden = YES;
    _bleConnector = [RTBleConnector shareManager];
    
    _skillsPreferenceName = @[NSLocalizedString(@"揉捏", nil), NSLocalizedString(@"敲击", nil), NSLocalizedString(@"揉敲", nil), NSLocalizedString(@"叩击", nil), NSLocalizedString(@"指压", nil), NSLocalizedString(@"韵律", nil)];
	
	NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"LocalProgramList" ofType:@"plist"];
	_localProgramArray = [[NSArray alloc] initWithContentsOfFile:plistPath];

}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	
	AFNetworkReachabilityManager *reachability = [AFNetworkReachabilityManager sharedManager];
//	if (reachability.reachable) {
		//网络请求
		_loadingHUD.labelText = @"读取中...";
		[_loadingHUD show:YES];
		
		MassageProgramRequest *request = [[MassageProgramRequest alloc] init];
		
		[request requestNetworkMassageProgramListByIndex:0 Size:100 success:^(NSArray *networkMassageProgramArray) {
			
			[self refreshTableViewAfterRequest:networkMassageProgramArray];
			
		} failure:^(NSArray *localMassageProgramArray) {
            NSLog(@"下载程序：读取本地记录：%@",localMassageProgramArray);
			[self refreshTableViewAfterRequest:localMassageProgramArray];
			
		}];
//	} else {
//		NSLog(@"没网，本地记录读取成员");
//        [self showProgressHUDByString:@"无法访问网络"];
//	}
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (_bleConnector.rtMassageChairStatus.deviceStatus == RtMassageChairStatusMassaging) {
        _massageFlag = _bleConnector.rtMassageChairStatus.massageProgramFlag;
    }
}

- (void)refreshTableViewAfterRequest:(NSArray *) massageProgramArray {
	[_loadingHUD hide:YES];
	
	_allNetworkProgramArray = [NSArray arrayWithArray:massageProgramArray];
	
	[self resortData];
	
	[self.tableView reloadData];
	
	self.tableView.hidden = NO;
}

- (void)resortData {
	if (self.isDownloadCustomProgram) {
		_alreadyInstallProgramArray = [[NSMutableArray alloc] init];
		
		_notYetInstallProgramArray = [_allNetworkProgramArray mutableCopy];
		
		for (NSNumber *item in [RTBleConnector shareManager].rtNetworkProgramStatus.networkProgramStatusArray) {
			int networkMassageId = [item intValue];
			
			if (networkMassageId != 0) {
				
				for (MassageProgram *program in _allNetworkProgramArray) {
					if ([program.commandId intValue] == networkMassageId) {
						[_alreadyInstallProgramArray addObject:program];
						[_notYetInstallProgramArray removeObject:program];
						continue;
					}
				}
			}
		}
	}
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 返回

- (void)goBack {
    [self.navigationController popViewControllerAnimated:YES];
//	[self backToMainViewController];
	
//	[[RTBleConnector shareManager] sendControlByBytes:[[RTBleConnector shareManager] exitEditMode]];  // 退出编辑模式
}

#pragma mark - RTBleConnectorDelegate

- (void)didUpdateStatusInProgramMode:(NSData *)rawData {
	
}

-(void)didUpdateMassageChairStatus:(RTMassageChairStatus *)rtMassageChairStatus
{
    if (_bleConnector.rtMassageChairStatus.deviceStatus == RtMassageChairStatusMassaging)
    {
        //按摩中
        if (_bleConnector.rtMassageChairStatus.programType == RtMassageChairProgramManual)
        {
            if (_massageFlag != 7) {
                
                NSLog(@"切换到手动按摩");
                //从自动按摩切换过来的话，需要进行按摩时间和次数统计
                [self countMassageTime];
                _bleConnector.startTime = [NSDate date];
                _massageFlag = rtMassageChairStatus.massageProgramFlag;
            }
      
            //手动按摩模式
            flag = _bleConnector.rtMassageChairStatus.massageTechniqueFlag;
    
        }
        else if (_bleConnector.rtMassageChairStatus.programType == RtMassageChairProgramAuto ||_bleConnector.rtMassageChairStatus.programType == RtMassageChairProgramNetwork)
        {
            //自动按摩
            if (_massageFlag != rtMassageChairStatus.massageProgramFlag) {
                if (_massageFlag == 7 || _massageFlag == 0) {
                    //每次切换到自动按摩程序的时候，就设置开始按摩时间
                    [self countMassageTime];
                    
                    _bleConnector.startTime = [NSDate date];
                    NSLog(@"切换到自动按摩");
                    NSLog(@"设置开始时间");
                }
                else
                {
                    NSLog(@"更换自动按摩种类:%ld",_massageFlag);
                    //切换自动按摩程序种类，需要进行按摩时间和次数统计
                    [self countMassageTime];
                    //再次设置开始时间
                    _bleConnector.startTime = [NSDate date];
                }
                _massageFlag = rtMassageChairStatus.massageProgramFlag;
            }
          
        }
        else
        {
            //未知情况

        }
    }
    else if (_bleConnector.rtMassageChairStatus.deviceStatus == RtMassageChairStatusResetting)
    {
        //复位中
        [self countMassageTime];
    }
    else
    {
        //其他状态
    }

}

-(void)didDisconnectRTBlePeripheral:(CBPeripheral *)peripheral
{
//    NSLog(@"设备断开了");
//    [_tableView reloadData];
}

-(void)didUpdateRTBleState:(CBCentralManagerState)state
{
    NSLog(@"设备状态更新");
    if (state == CBCentralManagerStatePoweredOff) {
        NSLog(@"设备断开了");
        [_tableView reloadData];
    }
}

- (void)didUpdateNetworkMassageStatus:(RTNetworkProgramStatus *)rtNetwrokProgramStatus {
	NSLog(@"didUpdateNetworkMassageStatus");
	[self resortData];
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
			// 显示自带程序 + 已经安装的云养程序 + 未安装的云养程序
			return [_localProgramArray count] + [_alreadyInstallProgramArray count] + [_notYetInstallProgramArray count];
		} else {
			// 只显示已经安装的云养程序
			return [_alreadyInstallProgramArray count];
		}
	} else {
		return [_allNetworkProgramArray count];
	}
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
    ProgramDownloadTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ProgramDownloadTableViewCell" forIndexPath:indexPath];
	
	UIImageView *bgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"list_bg"]];
	
	cell.backgroundView = bgView;
	
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
	
	cell.isLocalProgram = NO;
	
	
	if (self.isDownloadCustomProgram) {
		if (indexPath.section == 0) {
			if (indexPath.row < [_localProgramArray count]) {
				NSDictionary *localProgramDic = _localProgramArray[indexPath.row];
				
//				[UIImageView loadImageByURL:massageProgramDic[@"imageUrl"] imageView:cell.programImageView];
				
				cell.isLocalProgram = YES;
				
				cell.programImageView.image = [UIImage imageNamed:localProgramDic[@"programImageUrl"]];
				
				// 程序名
				cell.programNameLabel.text = localProgramDic[@"programName"];
				
				// 网络程序描述
				cell.programDescriptionLabel.text = localProgramDic[@"programDescription"];
				
				cell.selectionStyle = UITableViewCellSelectionStyleDefault;
				
			} else if (indexPath.row >= [_localProgramArray count] && indexPath.row < ([_localProgramArray count] + [_alreadyInstallProgramArray count])) {
				cell.isLocalProgram = YES;
				
 				cell.massageProgram = [_alreadyInstallProgramArray objectAtIndex:indexPath.row - [_localProgramArray count]];
				
				cell.selectionStyle = UITableViewCellSelectionStyleDefault;
			} else {
				
				cell.massageProgram = [_notYetInstallProgramArray objectAtIndex:indexPath.row - ([_localProgramArray count] + [_alreadyInstallProgramArray count])];
			}
			
		} else {
			
			cell.massageProgram = [_alreadyInstallProgramArray objectAtIndex:indexPath.row];
		}
		
	} else {
		cell.massageProgram = [_allNetworkProgramArray objectAtIndex:indexPath.row];
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	//	NSIndexPath *alreadySelectIndexPath = [_table indexPathForSelectedRow];
	//
	//	if (!alreadySelectIndexPath && alreadySelectIndexPath.row != indexPath.row) {
	//		[tableView deselectRowAtIndexPath:indexPath animated:YES];
	//	}
	
	//	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	//	if ([RTBleConnector shareManager].currentConnectedPeripheral == nil) {
	//        NSLog(@"连接设备为空");
	//		[reconnectDialog show];
	//		return;
	//	}
	
	if (indexPath.section == 1) {   //已有程序点击没有效果
		return;
	}
	
	if (indexPath.row >= ([_localProgramArray count] + [_alreadyInstallProgramArray count])) {
		return;
	}
	
	switch (indexPath.row) {
			
			// 运动恢复
		case 0:
			[[RTBleConnector shareManager] sendControlMode:H10_KEY_CHAIR_AUTO_0];
			break;
			
			// 舒展活络
		case 1:
			[[RTBleConnector shareManager] sendControlMode:H10_KEY_CHAIR_AUTO_1];
			break;
			
			// 休憩促眠
		case 2:
			[[RTBleConnector shareManager] sendControlMode:H10_KEY_CHAIR_AUTO_2];
			break;
			
			// 工作减压
		case 3:
			[[RTBleConnector shareManager] sendControlMode:H10_KEY_CHAIR_AUTO_3];
			break;
			
			// 肩颈重点
		case 4:
			[[RTBleConnector shareManager] sendControlMode:H10_KEY_CHAIR_AUTO_4];
			break;
			
			// 腰椎舒缓
		case 5:
			[[RTBleConnector shareManager] sendControlMode:H10_KEY_CHAIR_AUTO_5];
			break;
			
			// 云养程序一
		case 6:
			[[RTBleConnector shareManager] sendControlMode:H10_KEY_CHAIR_AUTO_NETCLOUD_1];
			break;
			// 云养程序二
		case 7:
			[[RTBleConnector shareManager] sendControlMode:H10_KEY_CHAIR_AUTO_NETCLOUD_2];
			break;
			// 云养程序三
		case 8:
			[[RTBleConnector shareManager] sendControlMode:H10_KEY_CHAIR_AUTO_NETCLOUD_3];
			break;
			// 云养程序四
		case 9:
			[[RTBleConnector shareManager] sendControlMode:H10_KEY_CHAIR_AUTO_NETCLOUD_4];
			break;
	}
	
	RTMassageChairStatus *rtMassageChairStatus = [RTBleConnector shareManager].rtMassageChairStatus;
	
	if ([RTBleConnector shareManager].currentConnectedPeripheral != nil && rtMassageChairStatus != nil) {
		
		if (rtMassageChairStatus && rtMassageChairStatus.deviceStatus == RtMassageChairStatusMassaging) {
			
			[self jumpToCorrespondingControllerByMassageStatus];
			
		} else {
			
			// 延迟1.5秒再进入按摩界面
			
			double delayInSeconds = 1.5;
			
			dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
			
			dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
				[self jumpToCorrespondingControllerByMassageStatus];
			});
		}
	}
}

#pragma mark - 计算按摩时间
-(void)countMassageTime
{
    //计算按摩时间
    NSDate* end = [NSDate date];
    NSDate* start = _bleConnector.startTime;
    NSLog(@"开始时间:%@",start);
    if (start) {
        NSLog(@"进入统计");
        NSTimeInterval time = [end timeIntervalSinceDate:start];
        //把按摩信息保存到RTBleConnector里面
        //将开始按摩的日期转成字符串
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"YYYY-MM-dd"];
        NSString* date = [dateFormatter stringFromDate:start];
        NSInteger programId = -1;
        NSString* function;
        if (_massageFlag<7&&_massageFlag>0) {
            //属于自动按摩的统计
            NSLog(@"自动按摩统计");
            _programName = [_bleConnector.rtMassageChairStatus autoMassageNameByIndex:_massageFlag];
            programId = _massageFlag;
            function = [_bleConnector.rtMassageChairStatus autoMassageFunctionByIndex:_massageFlag];;
        }
        else if (_massageFlag<11&&_massageFlag>7)
        {
            //属于网络按摩的统计
            NSLog(@"网络按摩统计：%ld",programId);
            MassageProgram* p = [_bleConnector.rtNetworkProgramStatus getNetworkProgramNameBySlotIndex:_massageFlag-8];
            programId = [p.massageId integerValue];
            _programName = p.name;
            function = p.mDescription;
        }
        else
        {
            if (flag>0&&flag<7) {
                _programName = _skillsPreferenceName[flag-1];
                programId = -flag;
                function = _programName;
            }
            else
            {
                _programName = @"手动按摩";
                function = _programName;
            }
        }
        NSNumber* pId = [NSNumber numberWithInteger:programId];
        NSNumber* useTime = [NSNumber numberWithInt:(int)time];
        NSDictionary* dic = @{@"name":_programName,@"useTime":useTime,@"programId":pId,@"useDate":date,@"startTime":start,@"endTime":end,@"function":function};
        _bleConnector.massageRecord = dic;
        
        if (_massageFlag != 7) {
            //非手动按摩需要统计时间
            NSLog(@"此次按摩了%f秒",time);
            if (time>30) {
                //时间大于30秒才开始统计
                NSUInteger min;
                if (time<=60) {
                    min = 1;
                }
                else
                {
                    min = (int)round(time/60);
                }
                NSLog(@"此次按摩了%ld分钟",min);
                
                if (programId>0)
                {
                    NSLog(@"统计一次");
                    NSArray* result = [ProgramCount MR_findAllWithPredicate:[NSPredicate predicateWithFormat:@"(programId == %ld) AND (uid == %@)",programId,self.uid]];
                    
                    //按摩次数统计
                    if (result.count >0) {
                        _programCount = result[0];
                        NSUInteger count = [_programCount.unUpdateCount integerValue];
                        count++;
                        _programCount.unUpdateCount = [NSNumber numberWithUnsignedInteger:count];
                        _programCount.programId = [NSNumber numberWithInteger:programId];
                    }
                    else
                    {
                        _programCount = [ProgramCount MR_createEntity];
                        _programCount.name = _programName;
                        _programCount.uid = self.uid;
                        _programCount.unUpdateCount = [NSNumber numberWithInt:1];
                        _programCount.programId = [NSNumber numberWithInteger:programId];
                    }
                    
                    //开始统计次数的网络数据同步
                    [ProgramCount synchroUseCountDataFormServer:YES Success:nil Fail:nil];
                    
                    //按摩记录
                    MassageRecord* massageRecord;
                    NSArray* records = [MassageRecord MR_findAllWithPredicate:[NSPredicate predicateWithFormat:@"(programId == %ld) AND (date == %@) AND (uid == %@) AND (state == 1)",programId,date,self.uid]];
                    if (records.count > 1) {
                        NSLog(@"查找数组:%@",records);
                        massageRecord = records[0];
                    }
                    if (massageRecord) {
                        NSUInteger oldTime = [massageRecord.useTime integerValue];
                        oldTime += min;
                        massageRecord.useTime = [NSNumber numberWithUnsignedInteger:oldTime];
                    }
                    else
                    {
                        //创建一条按摩记录
                        massageRecord = [MassageRecord MR_createEntity];
                        massageRecord.useTime = [NSNumber numberWithUnsignedInteger:min];
                        massageRecord.name = _programName;
                        massageRecord.date = date;
                        massageRecord.uid = self.uid;
                        massageRecord.programId = [NSNumber numberWithInteger:programId];
                        massageRecord.state = [NSNumber numberWithInt:1];
                    }
                    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
                    //把本地所有未同步到服务器的按摩记录都推到服务器
                    [DataRequest synchroMassageRecord];
                }
            }
            else
            {
                NSLog(@"不统计");
            }
        }
        //统计完成要把开始时间置空，表示此次按摩已结束
        _bleConnector.startTime = nil;
        NSLog(@"设置开始时间为空");
    }
}


#pragma mark - 快速提示
-(void)showProgressHUDByString:(NSString*)message
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.labelText = message;
    hud.margin = 10.f;
    hud.removeFromSuperViewOnHide = YES;
    [hud hide:YES afterDelay:0.7];
}

@end
