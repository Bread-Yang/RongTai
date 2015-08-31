//		[_skillsPreferencePickerView setIndex:rtMassageChairStatus.massageTechniqueFlag - 1];//
//  AutoMassageViewController.m
//  rongtai
//
//  Created by William-zhang on 15/7/22.
//  Copyright (c) 2015年 William-zhang. All rights reserved.
//

#import "AutoMassageViewController.h"
#import "MassageProgram.h"
#import "MainViewController.h"
#import "UILabel+WLAttributedString.h"
#import "RongTaiConstant.h"
#import "RTCommand.h"
#import "RTBleConnector.h"
#import "FinishMassageViewController.h"
#import "ScanViewController.h"
#import "AdjustView.h"
#import "ProgramCount.h"
#import "CoreData+MagicalRecord.h"
#import "RTBleConnector.h"
#import "MassageRecord.h"
#import "MassageTime.h"
#import "DataRequest.h"

@interface AutoMassageViewController ()<RTBleConnectorDelegate>
{
    __weak IBOutlet UILabel *_timeSet;
    __weak IBOutlet UILabel *_function;
    __weak IBOutlet UILabel *_usingTime;
    __weak IBOutlet UIButton *_stopBtn;
    NSString* _programName;
    NSInteger _autoMassageFlag;
}
@end

@implementation AutoMassageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	self.isListenBluetoothStatus = YES;
    
    UIBarButtonItem* item = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"icon_back"] style:UIBarButtonItemStylePlain target:self action:@selector(goBack)];
    self.navigationItem.leftBarButtonItem =item;
    
    //停止按摩圆角
    _stopBtn.layer.cornerRadius = SCREENHEIGHT*0.055*0.5;
    
    //
    _timeSet.textColor = BLUE;
    [_timeSet setNumebrByFont:[UIFont systemFontOfSize:28 weight:10] Color:BLUE];
    [_usingTime setNumebrByFont:[UIFont systemFontOfSize:16] Color:BLUE];
    
    //
    UIBarButtonItem* right = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"icon_set"] style:UIBarButtonItemStylePlain target:self action:@selector(rightItemClicked:)];
    self.navigationItem.rightBarButtonItem = right;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    //获取按摩椅自动按摩名称
    RTBleConnector* bleConnector = [RTBleConnector shareManager];
    _autoMassageFlag = bleConnector.rtMassageChairStatus.massageProgramFlag;
    NSLog(@"按摩状态数据:%ld",_autoMassageFlag);
    if (_autoMassageFlag>=1&&_autoMassageFlag!=7) {
        NSLog(@"自动按摩状态");
        switch (_autoMassageFlag) {
            case 1:
                _programName = NSLocalizedString(@"运动恢复", nil);
                break;
            case 2:
                _programName = NSLocalizedString(@"舒展活络", nil);
                break;
            case 3:
                _programName = NSLocalizedString(@"休憩促眠", nil);
                break;
            case 4:
                _programName = NSLocalizedString(@"工作减压", nil);
                break;
            case 5:
                _programName = NSLocalizedString(@"肩颈重点", nil);
                break;
            case 6:
                _programName = NSLocalizedString(@"腰椎舒缓", nil);
                break;
            case 8:
                _programName = NSLocalizedString(@"云养程序一", nil);
                break;
            case 9:
                _programName = NSLocalizedString(@"云养程序二", nil);
                break;
            case 10:
                _programName = NSLocalizedString(@"云养程序三", nil);
                break;
            case 11:
                _programName = NSLocalizedString(@"云养程序四", nil);
                break;
            default:
                _programName = nil;
                break;
        }
    }
    else
    {
        _programName = nil;
    }
    
    NSLog(@"programName:%@",_programName);
    if (_programName.length<1) {
        self.title = @"自动按摩";
    }
    else
    {
        self.title = _programName;
    }

    //按摩调节View出现
    [[AdjustView shareView] show];
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    //按摩调节View消失
    [[AdjustView shareView] hidden];
}

#pragma mark - 导航栏右边按钮方法
-(void)rightItemClicked:(id)sender
{
	NSLog(@"rightItemClicked");
	[[RTBleConnector shareManager] sendControlMode:H10_KEY_OZON_SWITCH];
}

#pragma mark - 返回按钮方法
-(void)goBack
{
    MainViewController* main;
    NSArray* viewControllers = self.navigationController.viewControllers;
    for (UIViewController* vc in viewControllers) {
        if ([vc isKindOfClass:[MainViewController class]]) {
            main = (MainViewController*)vc;
            break;
        }
    }
    if (main) {
        [self.navigationController popToViewController:main animated:YES];
    }
  
}

#pragma mark - 停止按摩
- (IBAction)stopMassage:(id)sender {
    [[RTBleConnector shareManager] sendControlMode:H10_KEY_POWER_SWITCH];
}

#pragma mark - RTBleConnectorDelegate

- (void)didUpdateMassageChairStatus:(RTMassageChairStatus *)rtMassageChairStatus {
	
	// 以下是界面跳转
	
	if (rtMassageChairStatus.figureCheckFlag == 1) {  // 执行体型检测程序
		[self jumpToScanViewConroller];
	}
	
	if (rtMassageChairStatus.deviceStatus == RtMassageChairStatusResetting) {  // 按摩完毕
       
        if (_programName.length > 0 && ![_programName isEqualToString:@"自动按摩"]) {
            //计算按摩时间
            NSDate* end = [NSDate date];
            NSDate* start = [[NSUserDefaults standardUserDefaults] objectForKey:@"MassageStartTime"];
            NSTimeInterval time = [end timeIntervalSinceDate:start];
            NSLog(@"此次按摩了%f秒",time);
            NSUInteger min = (int)round(time)/60;
            
            //将开始按摩的日期转成字符串
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"YYYY/MM/dd"];
            NSString* date = [dateFormatter stringFromDate:start];

            NSArray* result = [ProgramCount MR_findByAttribute:@"name" withValue:_programName];
            
            //按摩次数统计
            ProgramCount* programCount;
            if (result.count >0) {
                programCount = result[0];
                NSUInteger count = [programCount.useCount integerValue];
                count++;
                programCount.useCount = [NSNumber numberWithUnsignedInteger:count];
                programCount.programId = [NSNumber numberWithInteger:_autoMassageFlag];
            }
            else
            {
                programCount = [ProgramCount MR_createEntity];
                programCount.name = _programName;
                programCount.useCount = [NSNumber numberWithInt:1];
                programCount.programId = [NSNumber numberWithInteger:_autoMassageFlag];
                
            }
        
            //按摩记录
            MassageRecord* massageRecord;
            NSArray* records = [MassageRecord MR_findAllWithPredicate:[NSPredicate predicateWithFormat:@"(massageName == %@) AND (date == %@)",_programName,date]];
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
                massageRecord.massageName = _programName;
                massageRecord.startTime = start;
                massageRecord.endTime = end;
                massageRecord.date = date;
            }
            
            //按摩使用时长统计
            MassageTime* massageTime;
            NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
            NSInteger unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay;
            NSDateComponents *comps  = [calendar components:unitFlags fromDate:start];
            NSArray* timeResult = [MassageTime MR_findAllWithPredicate:[NSPredicate predicateWithFormat:@"(year == %ld) AND (month == %ld) AND (day == %ld)",comps.year,comps.month,comps.day]];
            if (timeResult.count > 0)
            {
                massageTime = timeResult[0];
                NSUInteger old = [massageTime.useTime integerValue];
                old += min;
                massageTime.useTime = [NSNumber numberWithUnsignedInteger:old];
            }
            else
            {
                massageTime = [MassageTime MR_createEntity];
                massageTime.useTime = [NSNumber numberWithUnsignedInteger:min];
                massageTime.year = [NSNumber numberWithInteger:comps.year];
                massageTime.month = [NSNumber numberWithInteger:comps.month];
                massageTime.day = [NSNumber numberWithInteger:comps.day];
            }
            
            [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
            
            //开始统计次数的网络数据同步
            [self synchroUseCountLocalData];
        }
        
		[self jumpToFinishMassageViewConroller];
	}
	
	if (rtMassageChairStatus.deviceStatus == RtMassageChairStatusStandby) {    // 跳回主界面
		[self backToMainViewController];
	}
	
	if (rtMassageChairStatus.programType == RtMassageChairProgramManual) {  // 跳到手动按摩界面
		[self jumpToManualMassageViewConroller];
	}
	
	// 以下是界面状态更新
	
	// 定时时间
	NSInteger minutes = rtMassageChairStatus.remainingTime / 60;
	NSInteger seconds = rtMassageChairStatus.remainingTime % 60;
	_timeSet.text = [NSString stringWithFormat:@"%@: %02zd:%02zd", NSLocalizedString(@"定时", nil), minutes, seconds];
	
	// 用时时间
	_usingTime.text = [NSString stringWithFormat:@"共%02zd分", rtMassageChairStatus.preprogrammedTime];
	[_usingTime setNumebrByFont:[UIFont systemFontOfSize:16] Color:BLUE];
}

#pragma mark - 同步统计次数的网络数据
-(void)synchroUseCountLocalData
{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[NSNumber numberWithBool:YES] forKey:@"ProgramCountNeedSynchro"];
    NSLog(@"开始同步统计次数网络数据");
    DataRequest* request = [DataRequest new];
    NSArray* counts = [ProgramCount MR_findAll];
    
    NSMutableArray* jsons = [NSMutableArray new];
    for (ProgramCount* p in counts) {
        [jsons addObject:[p toDictionary]];
    }
    if (jsons.count>0) {
        [request addProgramUsingCount:jsons Success:^{
            NSLog(@"统计次数数据同步成功");
            [defaults setObject:[NSNumber numberWithBool:NO] forKey:@"ProgramCountNeedSynchro"];
        } fail:^(NSDictionary *dic) {
            NSLog(@"统计次数数据同步失败");

        }];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
