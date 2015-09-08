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
#import "ProgramCount.h"
#import "MassageRecord.h"
#import "CoreData+MagicalRecord.h"

@interface BasicViewController () <CustomIOSAlertViewDelegate> {
	
	RTBleConnector *bleConnector;
	
	CustomIOSAlertView *reconnectDialog;
	
    RTMassageChairProgramType _type;  //按摩类型
    
    RTMassageChairProgramType _autoType;  //自动按摩类型
    
    NSString* _uid;
    
    NSUserDefaults* _defaults;
    
    ProgramCount* _programCount;
    
    NSString* _programName;
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
    
    self.isListenBluetoothStatus = YES;
    
    //
    _uid = [[NSUserDefaults standardUserDefaults] objectForKey:@"uid"];
    
    _defaults = [NSUserDefaults standardUserDefaults];
	
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
		[reconnectDialog setButtonTitles:[NSMutableArray arrayWithObjects:NSLocalizedString(@"取消", nil), nil]];
		
		__weak RTBleConnector *weakPointer = bleConnector;
		[reconnectDialog setOnButtonTouchUpInside:^(CustomIOSAlertView *alertView, int buttonIndex) {
			if (weakPointer.reconnectTimer && [weakPointer.reconnectTimer isValid]) {
				[weakPointer.reconnectTimer invalidate];
			}
			[alertView close];
		}];
        
        //页面出现就记录当前按摩椅按摩状态
        if (bleConnector.rtMassageChairStatus.deviceStatus == RtMassageChairStatusMassaging) {
            _type = bleConnector.rtMassageChairStatus.programType;
            if (_type == RtMassageChairProgramAuto) {
                //如果是自动按摩的话，要记录
                _autoType = bleConnector.rtMassageChairStatus.autoProgramType;
            }
        }
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

- (void)didUpdateMassageChairStatus:(RTMassageChairStatus *)rtMassageChairStatus
{
    if (rtMassageChairStatus.deviceStatus == RtMassageChairStatusMassaging) {
        if (rtMassageChairStatus.programType == RtMassageChairProgramManual) {
            //手动按摩
//            NSLog(@"%@手动按摩",[self class]);
            if (_type != RtMassageChairProgramManual) {
                NSLog(@"切换到手动按摩");
                //从自动按摩切换过来的话，需要进行按摩时间和次数统计
                if (_type == RtMassageChairProgramAuto) {
                    
                    [self countMassageTime];
                }
                _type = RtMassageChairProgramManual;
            }
        }
        else if (rtMassageChairStatus.programType == RtMassageChairProgramAuto)
        {
            //自动按摩
//            NSLog(@"%@自动按摩",[self class]);
            if (_type != RtMassageChairProgramAuto) {
                //每次切换到自动按摩程序的时候，就设置开始按摩时间
                _type = RtMassageChairProgramAuto;
                bleConnector.startTime = [NSDate date];
                NSLog(@"切换到自动按摩");
                NSLog(@"设置开始时间");
            }
            
            if (_autoType != rtMassageChairStatus.autoProgramType) {
                _autoType = rtMassageChairStatus.autoProgramType;
                //一直处于自动按摩的时候，切换不同的按摩种类时，需要进行按摩时间和次数统计
                NSLog(@"切换了自动按摩种类:%@",[rtMassageChairStatus autoMassageName]);
                [self countMassageTime];
                bleConnector.startTime = [NSDate date];
            }
        }
        else if (rtMassageChairStatus.programType == RtMassageChairProgramNetwork)
        {
            //网络按摩
//            NSLog(@"%@网络按摩",[self class]);
            if (_type != RtMassageChairProgramNetwork) {
                NSLog(@"切换到网络按摩");
                //从自动按摩切换过来的话，需要进行按摩时间和次数统计
                if (_type == RtMassageChairProgramAuto) {
                    [self countMassageTime];
                }
                _type = RtMassageChairProgramNetwork;
            }
        }
    }
    else if (rtMassageChairStatus.deviceStatus == RtMassageChairStatusResetting)
    {
        if (_type == RtMassageChairProgramAuto) {
            NSLog(@"复位前是自动按摩");
            //复位前是自动按摩需要统计
            [self countMassageTime];
            _type = RtMassageChairProgramManual;
        }
        bleConnector.startTime = nil;
    }
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

#pragma mark - 计算按摩时间
-(void)countMassageTime
{
    //计算按摩时间
    NSDate* end = [NSDate date];
    NSDate* start = bleConnector.startTime;
    if (start) {
        NSLog(@"统计一次");
        NSTimeInterval time = [end timeIntervalSinceDate:start];
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
        }
        
        //统计完成要把开始时间置空，表示此次按摩已结束
        bleConnector.startTime = nil;
    }
    
    
    
    
    
    
//
//    //将开始按摩的日期转成字符串
//    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//    [dateFormatter setDateFormat:@"YYYY-MM-dd"];
//    NSString* date = [dateFormatter stringFromDate:start];
//    
//    NSArray* result = [ProgramCount MR_findAllWithPredicate:[NSPredicate predicateWithFormat:@"(name == %@) AND (uid == %@)",_programName,_uid]];
//    //            NSArray* result = [ProgramCount MR_findByAttribute:@"name" withValue:_programName]
//    
//    //按摩次数统计
//    if (result.count >0) {
//        _programCount = result[0];
//        NSUInteger count = [_programCount.unUpdateCount integerValue];
//        count++;
//        _programCount.unUpdateCount = [NSNumber numberWithUnsignedInteger:count];
//        _programCount.programId = [NSNumber numberWithInteger:_autoMassageFlag];
//    }
//    else
//    {
//        _programCount = [ProgramCount MR_createEntity];
//        _programCount.name = _programName;
//        _programCount.uid = _uid;
//        _programCount.unUpdateCount = [NSNumber numberWithInt:1];
//        _programCount.programId = [NSNumber numberWithInteger:_autoMassageFlag];
//    }
//    
//    //开始统计次数的网络数据同步
//    [ProgramCount synchroUseCountDataFormServer:YES Success:nil Fail:nil];
//    
//    //按摩记录
//    MassageRecord* massageRecord;
//    NSArray* records = [MassageRecord MR_findAllWithPredicate:[NSPredicate predicateWithFormat:@"(name == %@) AND (date == %@) AND (uid == %@)",_programName,date,_uid]];
//    if (records.count > 1) {
//        NSLog(@"查找数组:%@",records);
//        massageRecord = records[0];
//    }
//    if (massageRecord) {
//        NSUInteger oldTime = [massageRecord.useTime integerValue];
//        oldTime += min;
//        massageRecord.useTime = [NSNumber numberWithUnsignedInteger:oldTime];
//    }
//    else
//    {
//        //创建一条按摩记录
//        massageRecord = [MassageRecord MR_createEntity];
//        massageRecord.useTime = [NSNumber numberWithUnsignedInteger:min];
//        massageRecord.name = _programName;
//        massageRecord.date = date;
//        massageRecord.uid = _uid;
//        massageRecord.programId = [NSNumber numberWithInteger:_autoMassageFlag];
//        
//    }
}


@end
