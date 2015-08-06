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

@interface ScanViewController () {
    UIImageView* _scanLight;
    __weak IBOutlet UIImageView *_body;
    int i;
    CGRect frame;
    NSTimer* _t;
}
@end

@implementation ScanViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	self.isListenBluetoothStatus = YES;
	
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
    // Do any additional setup after loading the view.
}

-(void)goBack
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
      _t = [NSTimer scheduledTimerWithTimeInterval:1.05 target:self selector:@selector(timerScan:) userInfo:nil repeats:YES];
//	[self scanAnimation];
}

-(void)timerScan:(NSTimer*)timer {
	[self scanAnimation];
//    if (i > 4) {
//        [timer invalidate];
//        UIStoryboard *s = [UIStoryboard storyboardWithName:@"Login" bundle:nil];
//        AutoMassageViewController* autoVC = (AutoMassageViewController*)[s instantiateViewControllerWithIdentifier:@"AutoMassageVC"];
//        autoVC.massage = self.massage;
//        [self.navigationController pushViewController:autoVC animated:YES];
//    } else {
//        _scanLight.frame = frame;
//        [self scanAnimation];
//        i++;
//    }
}

#pragma mark - 扫描动画
-(void)scanAnimation
{
    [UIView animateWithDuration:1 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        CGRect f = frame;
        f.origin.y = CGRectGetHeight(_body.frame) - f.size.height;
        _scanLight.frame = f;
    } completion:^(BOOL finished) {
        
    }];
}

#pragma mark - RTBleConnectorDelegate

- (void)didUpdateMassageChairStatus:(RTMassageChairStatus *)rtMassageChairStatus {
	
	NSLog(@"体型检测标记 : %zd", 	rtMassageChairStatus.figureCheckFlag);
	
	if (rtMassageChairStatus.deviceStatus == RtMassageChairMassaging) {
//		[RTBleConnector shareManager].delegate = nil;  // 停止接收回调
		
		if (rtMassageChairStatus.figureCheckFlag == 0 && rtMassageChairStatus.figureCheckResult == 1){	// 按摩程序(体型检测成功的前提下)
			UIStoryboard *s = [UIStoryboard storyboardWithName:@"Login" bundle:nil];
			AutoMassageViewController* autoVC = (AutoMassageViewController*)[s instantiateViewControllerWithIdentifier:@"AutoMassageVC"];
			autoVC.massage = self.massage;
			[self.navigationController pushViewController:autoVC animated:YES];
		}
	} else if (rtMassageChairStatus.deviceStatus == RtMassageChairStandby) {
		
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
