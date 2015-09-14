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
#import "MassageTime.h"
#import "NAPickerView.h"
#import "CustomIOSAlertView.h"

@interface AutoMassageViewController ()<RTBleConnectorDelegate,UIAlertViewDelegate> {
    __weak IBOutlet UILabel *_timeSetLabel;
    __weak IBOutlet UILabel *_functionLabel;
	__weak IBOutlet UITextView *_functionTextView;
    __weak IBOutlet UILabel *_usingTimeLabel;
    __weak IBOutlet UIButton *_stopBtn;
	__weak IBOutlet UIImageView *_movementPositionImageView;
	__weak IBOutlet UIImageView *_rollerStatusImageView;
	
    NSString* _programName;
    NSInteger _autoMassageFlag;
    
	//定时
	NAPickerView* _timePickerView;   //时间选择器
	
    ProgramCount* _programCount;
    
    MassageRecord* _massageRecord;
    NSInteger _massageFlag;
    RTBleConnector* _bleConnector;
    NSArray* _skillsPreferenceArray;
    BOOL _isJumpFinish;
    NSString *functionString;
}
@end

@implementation AutoMassageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	self.isListenBluetoothStatus = YES;
	
	[_functionTextView scrollRangeToVisible:NSMakeRange(0, 1)];
    
    UIBarButtonItem* item = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"icon_back"] style:UIBarButtonItemStylePlain target:self action:@selector(goBack)];
    self.navigationItem.leftBarButtonItem =item;
	
	_timePickerView = [self createMinutePickerView];
    
    //停止按摩圆角
    _stopBtn.layer.cornerRadius = SCREENHEIGHT*0.055*0.5;
    
    //
    _timeSetLabel.textColor = BLUE;
    [_timeSetLabel setNumebrByFont:[UIFont systemFontOfSize:28 weight:10] Color:BLUE];
    [_usingTimeLabel setNumebrByFont:[UIFont systemFontOfSize:16] Color:BLUE];
    
    //
    UIBarButtonItem* right = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"icon_set"] style:UIBarButtonItemStylePlain target:self action:@selector(rightItemClicked:)];
    self.navigationItem.rightBarButtonItem = right;
    
	// 时间view加入单击手势
	UITapGestureRecognizer* tTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(setTiming)];
	[_timeSetLabel addGestureRecognizer:tTap];
    
    //
    _bleConnector = [RTBleConnector shareManager];
    
    _isJumpFinish = YES;
    
    _skillsPreferenceArray = @[NSLocalizedString(@"揉捏", nil), NSLocalizedString(@"敲击", nil), NSLocalizedString(@"揉敲", nil), NSLocalizedString(@"叩击", nil), NSLocalizedString(@"指压", nil), NSLocalizedString(@"韵律", nil)];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    //获取按摩椅自动按摩名称
    if (_bleConnector.rtMassageChairStatus.deviceStatus == RtMassageChairStatusMassaging)
    {
        //按摩中
        _massageFlag = _bleConnector.rtMassageChairStatus.massageProgramFlag;
        RTMassageChairProgramType programType = _bleConnector.rtMassageChairStatus.programType;
        if (programType == RtMassageChairProgramNetwork || programType == RtMassageChairProgramAuto) {
            // 自动按摩
            
            // 定时时间
            NSInteger minutes = _bleConnector.rtMassageChairStatus.remainingTime / 60;
            NSInteger seconds = _bleConnector.rtMassageChairStatus.remainingTime % 60;
            _timeSetLabel.text = [NSString stringWithFormat:@"%@: %02zd:%02zd", NSLocalizedString(@"定时", nil), minutes, seconds];
            
            // 按摩简介
            
            // 当前为自动程序
            if (programType == RtMassageChairProgramAuto) {
                
                switch (_bleConnector.rtMassageChairStatus.autoProgramType) {
                        
                    case RtMassageChairProgramSportRecover:
                        self.title = NSLocalizedString(@"运动恢复", nil);
                        functionString = NSLocalizedString(@"运动恢复功能", nil);
                        break;
                        
                    case RtMassageChairProgramExtension:
                        self.title = NSLocalizedString(@"舒展活络", nil);
                        functionString = NSLocalizedString(@"舒展活络功能", nil);
                        break;
                        
                    case RtMassageChairProgramRestAndSleep:
                        self.title = NSLocalizedString(@"休憩促眠", nil);
                        functionString = NSLocalizedString(@"休憩促眠功能", nil);
                        break;
                        
                    case RtMassageChairProgramWorkingRelieve:
                        self.title = NSLocalizedString(@"工作减压", nil);
                        functionString = NSLocalizedString(@"工作减压功能", nil);
                        break;
                        
                    case RtMassageChairProgramShoulderAndNeck:
                        self.title = NSLocalizedString(@"肩颈重点", nil);
                        functionString = NSLocalizedString(@"肩颈重点功能", nil);
                        break;
                        
                    case RtMassageChairProgramWaistAndSpine:
                        self.title = NSLocalizedString(@"腰椎舒缓", nil);
                        functionString = NSLocalizedString(@"腰椎舒缓功能", nil);
                        break;
                }
            }
            else if (programType == RtMassageChairProgramNetwork)
            {  // 当前为网络程序
                
                MassageProgram *networkProgram = nil;
                
                switch (_bleConnector.rtMassageChairStatus.networkProgramType) {
                        
                    case RTMassageChairProgramNetwork1:
                        networkProgram = [[RTBleConnector shareManager].rtNetworkProgramStatus getNetworkProgramNameBySlotIndex:0];
                        break;
                        
                    case RTMassageChairProgramNetwork2:
                        networkProgram = [[RTBleConnector shareManager].rtNetworkProgramStatus getNetworkProgramNameBySlotIndex:1];
                        break;
                        
                    case RTMassageChairProgramNetwork3:
                        networkProgram = [[RTBleConnector shareManager].rtNetworkProgramStatus getNetworkProgramNameBySlotIndex:2];
                        break;
                        
                    case RTMassageChairProgramNetwork4:
                        networkProgram = [[RTBleConnector shareManager].rtNetworkProgramStatus getNetworkProgramNameBySlotIndex:3];
                        break;
                }
                
                if (networkProgram) {
                    self.title = networkProgram.name;
                    functionString = networkProgram.mDescription;
                }
            }
            
            _functionLabel.text = functionString;
            [_functionLabel sizeToFit];
            
            if (![_functionTextView.text isEqualToString:functionString]) {
                _functionTextView.text = functionString;
                [_functionTextView scrollRangeToVisible:NSMakeRange(0, 1)];
            }
            
            // 用时时间
            _usingTimeLabel.text = [NSString stringWithFormat:@"共%02zd分", _bleConnector.rtMassageChairStatus.preprogrammedTime];
            [_usingTimeLabel setNumebrByFont:[UIFont systemFontOfSize:16] Color:BLUE];
            
            // 机芯位置和滚轮是否打开
            
            NSInteger movementPosition = _bleConnector.rtMassageChairStatus.movementPositionFlag;
            
            if (movementPosition > -1 && movementPosition < 12) { // 目前按摩椅的机芯位置是0至12
                _movementPositionImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"sit_%zd", movementPosition]];
            }
            
            if (_bleConnector.rtMassageChairStatus.isRollerOn) {
                _rollerStatusImageView.image = [UIImage imageNamed:@"piont_3"];
            } else {
                _rollerStatusImageView.image = [UIImage imageNamed:@"sit_food_piont"];
            }
        }
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

- (void)setTiming {
	CustomIOSAlertView *skillPreferenceAlerView = [[CustomIOSAlertView alloc] init];
	[skillPreferenceAlerView setContainerView:_timePickerView];
	[skillPreferenceAlerView setTitleString:NSLocalizedString(@"定时", nil)];
	[skillPreferenceAlerView setButtonTitles:[NSMutableArray arrayWithObjects:NSLocalizedString(@"取消", nil), NSLocalizedString(@"保存", nil), nil]];
	[skillPreferenceAlerView setOnButtonTouchUpInside:^(CustomIOSAlertView *alertView, int buttonIndex) {
		if (buttonIndex == 0) {
			[alertView close];
		} else if (buttonIndex == 1) {
			switch ([_timePickerView getHighlightIndex]) {
				case 0:  // 10分钟
					[[RTBleConnector shareManager] sendControlMode:H10_KEY_WORK_TIME_10MIN];
					break;
				case 1:  // 20分钟
					[[RTBleConnector shareManager] sendControlMode:H10_KEY_WORK_TIME_20MIN];
					break;
				case 2:  // 30分钟
					[[RTBleConnector shareManager] sendControlMode:H10_KEY_WORK_TIME_30MIN];
					break;
			}
		}
	}];
	[skillPreferenceAlerView setUseMotionEffects:true];
	[skillPreferenceAlerView show];
}

#pragma mark - 创建时间选择器

- (NAPickerView *)createMinutePickerView
{
	NSMutableArray *leftItems = [[NSMutableArray alloc] init];
	for (int i = 1; i < 4;  i++) {
		[leftItems addObject:[NSString stringWithFormat:@"%d", i*10]];
	}
	NAPickerView *pickerView = [[NAPickerView alloc] initWithFrame:CGRectMake(0, 0, 270, 200) andItems:leftItems andDelegate:self];
	pickerView.overlayColor = [UIColor colorWithRed:223.0 / 255.0 green:1 blue:1 alpha:1];
	
	pickerView.infiniteScrolling = YES;
	pickerView.overlayLeftImage = [UIImage imageNamed:@"icon_set_time"];
	pickerView.overlayRightString = NSLocalizedString(@"分钟", nil);
	pickerView.showOverlay = YES;
	
	pickerView.highlightBlock = ^(NALabelCell *cell) {
		cell.textView.textColor = BLUE;
		cell.textView.font = [UIFont fontWithName:@"DS-Digital-Bold" size:30];
	};
	pickerView.unhighlightBlock = ^(NALabelCell *cell) {
		cell.textView.textColor = [UIColor colorWithRed:26/255.0 green:154/255.0 blue:222/255.0 alpha:0.6];
		cell.textView.font = [UIFont fontWithName:@"DS-Digital-Bold" size:18];
	};
	return pickerView;
}

#pragma mark - RTBleConnectorDelegate

- (void)didUpdateMassageChairStatus:(RTMassageChairStatus *)rtMassageChairStatus
{
	// 以下是界面跳转
	
	if (rtMassageChairStatus.figureCheckFlag == 1 && rtMassageChairStatus.deviceStatus == RtMassageChairStatusMassaging){  // 执行体型检测程序
		[self jumpToScanViewConroller];
	}
	
	// 定时时间
	NSInteger minutes = rtMassageChairStatus.remainingTime / 60;
	NSInteger seconds = rtMassageChairStatus.remainingTime % 60;
	_timeSetLabel.text = [NSString stringWithFormat:@"%@: %02zd:%02zd", NSLocalizedString(@"定时", nil), minutes, seconds];
	
    if (rtMassageChairStatus.deviceStatus == RtMassageChairStatusMassaging) {
        //按摩中
        
        if (rtMassageChairStatus.programType == RtMassageChairProgramNetwork || rtMassageChairStatus.programType == RtMassageChairProgramAuto) {
            
            //自动按摩
            if (_massageFlag != rtMassageChairStatus.massageProgramFlag) {
                if (_massageFlag == 7 || _massageFlag == 0) {
                    //每次切换到自动按摩程序的时候，就设置开始按摩时间
                    [self countMassageTime];
                    _massageFlag = rtMassageChairStatus.massageProgramFlag;
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
                    _massageFlag = rtMassageChairStatus.massageProgramFlag;
                }
            }
            
            
            // 按摩简介
            
            // 当前为自动程序
            if (rtMassageChairStatus.programType == RtMassageChairProgramAuto) {
                
                switch (rtMassageChairStatus.autoProgramType) {
                        
                    case RtMassageChairProgramSportRecover:
                        self.title = NSLocalizedString(@"运动恢复", nil);
                        functionString = NSLocalizedString(@"运动恢复功能", nil);
                        break;
                        
                    case RtMassageChairProgramExtension:
                        self.title = NSLocalizedString(@"舒展活络", nil);
                        functionString = NSLocalizedString(@"舒展活络功能", nil);
                        break;
                        
                    case RtMassageChairProgramRestAndSleep:
                        self.title = NSLocalizedString(@"休憩促眠", nil);
                        functionString = NSLocalizedString(@"休憩促眠功能", nil);
                        break;
                        
                    case RtMassageChairProgramWorkingRelieve:
                        self.title = NSLocalizedString(@"工作减压", nil);
                        functionString = NSLocalizedString(@"工作减压功能", nil);
                        break;
                        
                    case RtMassageChairProgramShoulderAndNeck:
                        self.title = NSLocalizedString(@"肩颈重点", nil);
                        functionString = NSLocalizedString(@"肩颈重点功能", nil);
                        break;
                        
                    case RtMassageChairProgramWaistAndSpine:
                        self.title = NSLocalizedString(@"腰椎舒缓", nil);
                        functionString = NSLocalizedString(@"腰椎舒缓功能", nil);
                        break;
                }
                
            } else if (rtMassageChairStatus.programType == RtMassageChairProgramNetwork) {  // 当前为网络程序
                
                MassageProgram *networkProgram = nil;
                
                switch (rtMassageChairStatus.networkProgramType) {
                        
                    case RTMassageChairProgramNetwork1:
                        networkProgram = [[RTBleConnector shareManager].rtNetworkProgramStatus getNetworkProgramNameBySlotIndex:0];
                        break;
                        
                    case RTMassageChairProgramNetwork2:
                        networkProgram = [[RTBleConnector shareManager].rtNetworkProgramStatus getNetworkProgramNameBySlotIndex:1];
                        break;
                        
                    case RTMassageChairProgramNetwork3:
                        networkProgram = [[RTBleConnector shareManager].rtNetworkProgramStatus getNetworkProgramNameBySlotIndex:2];
                        break;
                        
                    case RTMassageChairProgramNetwork4:
                        networkProgram = [[RTBleConnector shareManager].rtNetworkProgramStatus getNetworkProgramNameBySlotIndex:3];
                        break;
                }
                
                if (networkProgram) {
                    self.title = networkProgram.name;
                    functionString = networkProgram.mDescription;
                }
            }
            
            _functionLabel.text = functionString;
            [_functionLabel sizeToFit];
            
            if (![_functionTextView.text isEqualToString:functionString]) {
                _functionTextView.text = functionString;
                [_functionTextView scrollRangeToVisible:NSMakeRange(0, 1)];
            }
            
            // 用时时间
            _usingTimeLabel.text = [NSString stringWithFormat:@"共%02zd分", rtMassageChairStatus.preprogrammedTime];
            [_usingTimeLabel setNumebrByFont:[UIFont systemFontOfSize:16] Color:BLUE];
            
            // 机芯位置和滚轮是否打开
            
            NSInteger movementPosition = rtMassageChairStatus.movementPositionFlag;
            
            if (movementPosition > -1 && movementPosition < 12) { // 目前按摩椅的机芯位置是0至12
                _movementPositionImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"sit_%zd", movementPosition]];
            }
            
            if (rtMassageChairStatus.isRollerOn) {
                _rollerStatusImageView.image = [UIImage imageNamed:@"piont_3"];
            } else {
                _rollerStatusImageView.image = [UIImage imageNamed:@"sit_food_piont"];
            }
        }
        else if (rtMassageChairStatus.programType == RtMassageChairProgramManual)
        {
            if (_massageFlag != 7) {
                
                NSLog(@"切换到手动按摩");
                //从自动按摩切换过来的话，需要进行按摩时间和次数统计
                [self countMassageTime];
                
                _massageFlag = rtMassageChairStatus.massageProgramFlag;
                
                //自动切换到手动，弹出提示框
                NSLog(@"切换到手动了");
                _isJumpFinish = NO;
                CustomIOSAlertView* alert = [[CustomIOSAlertView alloc]init];
                [alert setTitleString:@"提示"];
                UILabel* l = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, SCREENWIDTH*0.8, SCREENHEIGHT*0.15)];
                l.text = @"已切换到手动模式";
                l.textAlignment = NSTextAlignmentCenter;
                l.textColor = [UIColor lightGrayColor];
                [alert setContainerView:l];
               
                [alert setButtonTitles:@[NSLocalizedString(@"确定", nil)]];
                [alert setOnButtonTouchUpInside:^(CustomIOSAlertView *alertView, int buttonIndex) {
                    [self.navigationController popViewControllerAnimated:YES];
                }];
                [alert setUseMotionEffects:true];
                [alert show];
                
//                UIAlertView* alert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"当前已切换到手动按摩" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
//                [alert show];
            }
        }
    }else if (rtMassageChairStatus.deviceStatus == RtMassageChairStatusResetting)
    {
        // 按摩完毕
        [self countMassageTime];
        [self.resettingDialog show];
        
        // 用时时间
        _usingTimeLabel.text = [NSString stringWithFormat:@"共%02zd分", rtMassageChairStatus.preprogrammedTime];
        [_usingTimeLabel setNumebrByFont:[UIFont systemFontOfSize:16] Color:BLUE];
        
        // 机芯位置和滚轮是否打开
        
        NSInteger movementPosition = rtMassageChairStatus.movementPositionFlag;
        
        if (movementPosition > -1 && movementPosition < 12) { // 目前按摩椅的机芯位置是0至12
            _movementPositionImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"sit_%zd", movementPosition]];
        }
        
        if (rtMassageChairStatus.isRollerOn) {
            _rollerStatusImageView.image = [UIImage imageNamed:@"piont_3"];
        } else {
            _rollerStatusImageView.image = [UIImage imageNamed:@"sit_food_piont"];
        }
	} else {
		if (self.resettingDialog.isShowing) {
			
			[self.resettingDialog close];
            
            if (_isJumpFinish) {
                [self jumpToFinishMassageViewConroller];
            }
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
            function = functionString;
        }
        else if (_massageFlag<11&&_massageFlag>7)
        {
            //属于网络按摩的统计
            NSLog(@"网络按摩统计");
            MassageProgram* p = [_bleConnector.rtNetworkProgramStatus getNetworkProgramNameBySlotIndex:_massageFlag-8];
            programId = [p.commandId integerValue];
            _programName = p.name;
            function = functionString;
        }
        else
        {
            NSInteger massageTechniqueFlag = _bleConnector.rtMassageChairStatus.massageTechniqueFlag;
            if (massageTechniqueFlag>0&&massageTechniqueFlag<7) {
                _programName = _skillsPreferenceArray[massageTechniqueFlag-1];
                programId = -massageTechniqueFlag;
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
               
                if (programId>0) {
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


#pragma mark - alertView代理
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"确定"]) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

-(void)willPresentAlertView:(UIAlertView *)alertView
{
    NSLog(@"切换到手动了");
    _isJumpFinish = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


//////

//            //计算按摩时间
//            NSDate* end = [NSDate date];
//            NSDate* start = [[NSUserDefaults standardUserDefaults] objectForKey:@"MassageStartTime"];
//            NSTimeInterval time = [end timeIntervalSinceDate:start];
//            NSLog(@"此次按摩了%f秒",time);
//            NSUInteger min = (int)round(time)/60;
//
//            //将开始按摩的日期转成字符串
//            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//            [dateFormatter setDateFormat:@"YYYY-MM-dd"];
//            NSString* date = [dateFormatter stringFromDate:start];
//
//            NSArray* result = [ProgramCount MR_findAllWithPredicate:[NSPredicate predicateWithFormat:@"(name == %@) AND (uid == %@)",_programName,self.uid]];
////            NSArray* result = [ProgramCount MR_findByAttribute:@"name" withValue:_programName]
//
//            //按摩次数统计
//            if (result.count >0) {
//                _programCount = result[0];
//                NSUInteger count = [_programCount.unUpdateCount integerValue];
//                count++;
//                _programCount.unUpdateCount = [NSNumber numberWithUnsignedInteger:count];
//                _programCount.programId = [NSNumber numberWithInteger:_autoMassageFlag];
//            }
//            else
//            {
//                _programCount = [ProgramCount MR_createEntity];
//                _programCount.name = _programName;
//                _programCount.uid = self.uid;
//                _programCount.unUpdateCount = [NSNumber numberWithInt:1];
//                _programCount.programId = [NSNumber numberWithInteger:_autoMassageFlag];
//            }
//
//            //开始统计次数的网络数据同步
//            [ProgramCount synchroUseCountDataFormServer:YES Success:nil Fail:nil];
//
//            //按摩记录
//            MassageRecord* massageRecord;
//            NSArray* records = [MassageRecord MR_findAllWithPredicate:[NSPredicate predicateWithFormat:@"(name == %@) AND (date == %@) AND (uid == %@)",_programName,date,self.uid]];
//            if (records.count > 1) {
//                NSLog(@"查找数组:%@",records);
//                massageRecord = records[0];
//            }
//            if (massageRecord) {
//                NSUInteger oldTime = [massageRecord.useTime integerValue];
//                oldTime += min;
//                massageRecord.useTime = [NSNumber numberWithUnsignedInteger:oldTime];
//            }
//            else
//            {
//                //创建一条按摩记录
//                massageRecord = [MassageRecord MR_createEntity];
//                massageRecord.useTime = [NSNumber numberWithUnsignedInteger:min];
//                massageRecord.name = _programName;
//                massageRecord.date = date;
//                massageRecord.uid = self.uid;
//                massageRecord.programId = [NSNumber numberWithInteger:_autoMassageFlag];
//
//            }

//按摩使用时长统计
//            MassageTime* massageTime;
//            NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
//            NSInteger unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay;
//            NSDateComponents *comps  = [calendar components:unitFlags fromDate:start];
//            NSArray* timeResult = [MassageTime MR_findAllWithPredicate:[NSPredicate predicateWithFormat:@"(year == %ld) AND (month == %ld) AND (day == %ld)",comps.year,comps.month,comps.day]];
//            if (timeResult.count > 0)
//            {
//                massageTime = timeResult[0];
//                NSUInteger old = [massageTime.useTime integerValue];
//                old += min;
//                massageTime.useTime = [NSNumber numberWithUnsignedInteger:old];
//            }
//            else
//            {
//                massageTime = [MassageTime MR_createEntity];
//                massageTime.useTime = [NSNumber numberWithUnsignedInteger:min];
//                massageTime.year = [NSNumber numberWithInteger:comps.year];
//                massageTime.month = [NSNumber numberWithInteger:comps.month];
//                massageTime.day = [NSNumber numberWithInteger:comps.day];
//            }

//            [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];


@end
