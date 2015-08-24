//
//  CustomMassageViewController.m
//  rongtai
//
//  Created by William-zhang on 15/6/15.
//  Copyright (c) 2015年 William-zhang. All rights reserved.
//

#import "CustomMassageViewController.h"
#import "WLPolar.h"
#import "MassageMode.h"
#import "FinishMassageViewController.h"

@interface CustomMassageViewController ()
{
    
    __weak IBOutlet UILabel *_timelabel;  //按摩时间Label
    __weak IBOutlet UIView *_polarView;  //放极线图的View
    
    __weak IBOutlet UILabel *_useTimingLabel;  //使用时机Label
    
    __weak IBOutlet UILabel *_usePurposeLabel;  //使用目的Label
    
    __weak IBOutlet UILabel *_importantPartLabel;  //重点部分Label
    
    __weak IBOutlet UILabel *_massageWayLabel;  //按摩手法
    
    __weak IBOutlet UILabel *_skillPreference;  //技法偏好Label
    
    __weak IBOutlet UIView *_musicView;  //播放音乐的View
    
    WLPolar* _polar;  //极线图
}
@end

@implementation CustomMassageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedString(@"自定义程序", nil);
    
    UIBarButtonItem* stop = [[UIBarButtonItem alloc]initWithTitle:NSLocalizedString(@"结束", nil) style:UIBarButtonItemStylePlain target:self action:@selector(stop)];
    self.navigationItem.leftBarButtonItem = stop;
    
    UIBarButtonItem* anion = [[UIBarButtonItem alloc]initWithTitle:NSLocalizedString(@"负离子", nil) style:UIBarButtonItemStylePlain target:self action:@selector(anion)];
    self.navigationItem.rightBarButtonItem = anion;
    
    
    //极线图初始化
    [self wlPolarInit];
    
    
    // Do any additional setup after loading the view.
}

#pragma mark - 极线图初始化
-(void)wlPolarInit
{
    CGFloat w = [UIScreen mainScreen].bounds.size.width;
    CGFloat h = [UIScreen mainScreen].bounds.size.height;
    _polar = [[WLPolar alloc]initWithFrame:CGRectMake(0, 0, (w-32), h*0.35)];
    _polar.attributes = @[NSLocalizedString(@"速度", nil),NSLocalizedString(@"宽度", nil),NSLocalizedString(@"气压", nil),NSLocalizedString(@"力度", nil),];
    _polar.maxValue = 5;
    _polar.minValue = 0;
    _polar.dataSeries = @[@[@2,@4.5,@1.5,@2.3]];
    _polar.steps = 2;
    [_polarView addSubview:_polar];
}

#pragma mark - massageMode的set方法
-(void)setMassageMode:(MassageMode *)massageMode
{
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = massageMode.name;
}

#pragma mark - 开始/暂停按钮方法
- (IBAction)_startCilcked:(UIButton *)sender {
    
}

#pragma mark - 结束方法
-(void)stop
{
    UIStoryboard* s = [UIStoryboard storyboardWithName:@"Login" bundle:nil];
    FinishMassageViewController* f = (FinishMassageViewController*)[s instantiateViewControllerWithIdentifier:@"FinishMassageVC"];
    [self.navigationController pushViewController:f animated:YES];
}

#pragma mark - 负离子方法
-(void)anion
{
    
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
