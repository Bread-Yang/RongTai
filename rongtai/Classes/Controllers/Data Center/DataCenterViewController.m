//
//  DataCenterViewController.m
//  rongtai
//
//  Created by William-zhang on 15/6/10.
//  Copyright (c) 2015年 William-zhang. All rights reserved.
//

#define SCREENWIDTH [UIScreen mainScreen].bounds.size.width
#define SCREENHEIGHT [UIScreen mainScreen].bounds.size.height

#import "DataCenterViewController.h"
#import "UseTimeViewController.h"
#import "PowerConsumeViewController.h"
#import "DoughnutViewController.h"

@interface DataCenterViewController ()
{
    UIScrollView* _scroll;
    UseTimeViewController* _useTimeVc;  //使用时长统计页面
    PowerConsumeViewController* _powerConsumeVC;  //耗电量页面
    DoughnutViewController* _doughnutVC;  //使用次数统计页面
}

@end

@implementation DataCenterViewController

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedString(@"数据中心", nil);
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIBarButtonItem* right = [[UIBarButtonItem alloc]initWithTitle:NSLocalizedString(@"分享", nil) style:UIBarButtonItemStylePlain target:self action:@selector(share)];
    self.navigationItem.rightBarButtonItem = right;
    _scroll = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHT)];
    _scroll.bounces = NO;
    _scroll.showsHorizontalScrollIndicator = NO;
    _scroll.showsVerticalScrollIndicator = NO;
    _scroll.backgroundColor = [UIColor clearColor];
    _scroll.contentSize = CGSizeMake(SCREENWIDTH*3, SCREENHEIGHT-64);
    _scroll.pagingEnabled = YES;
    [self.view addSubview:_scroll];
    
    //使用时长
    UIStoryboard* s = [UIStoryboard storyboardWithName:@"Login" bundle:nil];
    _useTimeVc = (UseTimeViewController*)[s instantiateViewControllerWithIdentifier:@"UseTime"];
    _useTimeVc.view.frame = CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHT-64);
    [_scroll addSubview:_useTimeVc.view];
    [self addChildViewController:_useTimeVc];
    
    //耗电量
    _powerConsumeVC = (PowerConsumeViewController*)[s instantiateViewControllerWithIdentifier:@"PowerConsume"];
    _powerConsumeVC.view.frame = CGRectMake(SCREENWIDTH, 0, SCREENWIDTH, SCREENHEIGHT-64);
    [_scroll addSubview:_powerConsumeVC.view];
    [self addChildViewController:_powerConsumeVC];
    
    //使用次数
    _doughnutVC = (DoughnutViewController*)[s instantiateViewControllerWithIdentifier:@"DoughnutVC"];
    _doughnutVC.view.frame = CGRectMake(SCREENWIDTH*2, 0, SCREENWIDTH, SCREENHEIGHT-64);
    [_scroll addSubview:_doughnutVC.view];
    [self addChildViewController:_doughnutVC];
    // Do any additional setup after loading the view.
}

#pragma mark - 分享方法
-(void)share
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
