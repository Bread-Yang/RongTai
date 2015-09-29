//
//  ScanViewController.m
//  rongtai
//
//  Created by William-zhang on 15/7/22.
//  Copyright (c) 2015年 William-zhang. All rights reserved.
//

#import "ScanViewController.h"
#import "AutoMassageViewController.h"
#import "RongTaiConstant.h"
#import "MassageProgram.h"
#import "RTBleConnector.h"
#import "CoreData+MagicalRecord.h"

@interface ScanViewController () {
    UIImageView* _scanLight;
    __weak IBOutlet UIImageView *_body;
    int i;
    CGRect frame;
//    NSTimer* _t;
    NSInteger _massageFlag;
    NSString* _programName;
    
    NSInteger flag;
    
    ProgramCount* _programCount;
    //
    RTBleConnector* _bleConnector;
    NSArray* _skillsPreferenceName;    //技法偏好选项数组
    CustomIOSAlertView* _alert;
}
@end

@implementation ScanViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	self.isListenBluetoothStatus = YES;
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
	
    i = 0;
    self.title = NSLocalizedString(@"体型智能检测", nil);
    _scanLight = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"scan"]];
    CGFloat h = CGRectGetHeight([UIScreen mainScreen].bounds);
    CGFloat w = 0.75*h/423;
    h = w*97;
    w = w*180;
    frame = CGRectMake(0, 0, w, h);
    _scanLight.frame = frame;
    [_body addSubview:_scanLight];
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem goBackItemByTarget:self Action:@selector(goBack)];
    //
    _bleConnector = [RTBleConnector shareManager];
    
    //技法偏好类型数组
    _skillsPreferenceName = @[NSLocalizedString(@"揉捏", nil), NSLocalizedString(@"敲击", nil), NSLocalizedString(@"揉敲", nil), NSLocalizedString(@"叩击", nil), NSLocalizedString(@"指压", nil), NSLocalizedString(@"韵律", nil)];
    
    _alert = [[CustomIOSAlertView alloc]init];
    [_alert setTitleString:@"提示"];
    UILabel* l = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, SCREENWIDTH*0.8, SCREENHEIGHT*0.15)];
    l.text = @"已切换到手动模式";
    l.textAlignment = NSTextAlignmentCenter;
    l.textColor = [UIColor lightGrayColor];
    [_alert setContainerView:l];
    [_alert setButtonTitles:@[NSLocalizedString(@"确定", nil)]];
    __weak ScanViewController* svc = self;
    [_alert setOnButtonTouchUpInside:^(CustomIOSAlertView *alertView, int buttonIndex) {
        [svc backToMainViewController];
    }];
    [_alert setUseMotionEffects:true];
    
    // Do any additional setup after loading the view.
}

-(void)goBack {
    if (_backVC) {
        [self.navigationController popToViewController:_backVC animated:YES];
    }
    else
    {
        [self backToMainViewController];
    }
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
//	if (_t && [_t isValid]) {
//		[_t invalidate];
//	}
//      _t = [NSTimer scheduledTimerWithTimeInterval:1.05 target:self selector:@selector(timerScan:) userInfo:nil repeats:YES];
//	[self scanAnimation];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
//    [_t invalidate];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (_bleConnector.rtMassageChairStatus.deviceStatus == RtMassageChairStatusMassaging) {
        _massageFlag = _bleConnector.rtMassageChairStatus.massageProgramFlag;
    }
    [self scanAnimation];
}

//-(void)timerScan:(NSTimer*)timer {
//	_scanLight.frame = frame;
//	[self scanAnimation];
//}

#pragma mark - 扫描动画
-(void)scanAnimation
{
    [UIView animateWithDuration:1 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        CGRect f = frame;
        f.origin.y = CGRectGetHeight(_body.frame) - f.size.height;
        _scanLight.frame = f;
    } completion:^(BOOL finished) {
        _scanLight.frame = frame;
        [self scanAnimation];
    }];
}

#pragma mark - RTBleConnectorDelegate
- (void)didUpdateMassageChairStatus:(RTMassageChairStatus *)rtMassageChairStatus {
	
	// 界面跳转
	
	if (rtMassageChairStatus.figureCheckFlag == 0) {
		if (rtMassageChairStatus.programType == RtMassageChairProgramAuto || rtMassageChairStatus.programType == RtMassageChairProgramNetwork) {  // 跳到自动按摩界面
            if (_massageFlag!= rtMassageChairStatus.massageProgramFlag) {
                _massageFlag = rtMassageChairStatus.massageProgramFlag;
            }
			[self jumpToAutoMassageViewConroller];
		}
        else if (rtMassageChairStatus.programType == RtMassageChairProgramManual)
        {
            //自动按摩
            if (_massageFlag != 7) {
                NSLog(@"切换到手动按摩");
                [self countMassageTime];
                _massageFlag = rtMassageChairStatus.massageProgramFlag;
                
                //自动切换到手动，弹出提示框
                if (!_alert.isShowing) {
                    [_alert show];
                }
            }
        }
	}
    else
    {
        NSLog(@"肩部调节:%ld",rtMassageChairStatus.shoulderAjustFlag);
        NSLog(@"肩部位置:%ld",rtMassageChairStatus.figureCheckPositionFlag);
    }

	if (rtMassageChairStatus.deviceStatus == RtMassageChairStatusStandby || rtMassageChairStatus.deviceStatus == RtMassageChairStatusResetting) {
        [self countMassageTime];
		[self backToMainViewController];
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
            NSLog(@"网络按摩统计");
            MassageProgram* p = [_bleConnector.rtNetworkProgramStatus getNetworkProgramNameBySlotIndex:_massageFlag-8];
            programId = [p.commandId integerValue];
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
                    [DataRequest synchroMassageRecordSuccess:nil fail:nil];
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
