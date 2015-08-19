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

@interface AutoMassageViewController ()<RTBleConnectorDelegate>
{
    __weak IBOutlet UILabel *_timeSet;
    __weak IBOutlet UILabel *_function;
    __weak IBOutlet UILabel *_usingTime;
    __weak IBOutlet UIButton *_stopBtn;
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
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
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
        }
    }
    if (main) {
        [self.navigationController popToViewController:main animated:YES];
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

#pragma mark - RTBleConnectorDelegate

- (void)didUpdateMassageChairStatus:(RTMassageChairStatus *)rtMassageChairStatus {
	
	// 以下是界面跳转
	
	if (rtMassageChairStatus.figureCheckFlag == 1) {  // 执行体型检测程序
		[self jumpToScanViewConroller];
	}
	
	if (rtMassageChairStatus.deviceStatus == RtMassageChairStatusResetting) {  // 按摩完毕
		[self jumpToFinishMassageViewConroller];
	}
	
	if (rtMassageChairStatus.deviceStatus == RtMassageChairStatusStandby) {    // 跳回主界面
		[self backToMainViewController];
	}
	
	if (rtMassageChairStatus.programType == RtMassageChairProgramManual) {  // 跳到手动按摩界面
		[self jumpToManualMassageViewConroller];
	}
	
	// 以下是界面状态更新
	
	// 标题
	self.title  = self.massage.name;
	
	// 定时时间
	NSInteger minutes = rtMassageChairStatus.remainingTime / 60;
	NSInteger seconds = rtMassageChairStatus.remainingTime % 60;
	_timeSet.text = [NSString stringWithFormat:@"%@: %02zd:%02zd", NSLocalizedString(@"定时", nil), minutes, seconds];
	
	// 用时时间
	_usingTime.text = [NSString stringWithFormat:@"共%02zd分", rtMassageChairStatus.preprogrammedTime];
	[_usingTime setNumebrByFont:[UIFont systemFontOfSize:16] Color:BLUE];
}

@end
