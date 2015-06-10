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

@interface DataCenterViewController ()
{
    UIScrollView* _scroll;
    UseTimeViewController* _useTimeVc;  //使用时长统计页面
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
    _scroll = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 64, SCREENWIDTH, SCREENHEIGHT-64)];
    _scroll.backgroundColor = [UIColor cyanColor];
    [self.view addSubview:_scroll];
    
    //
    UIStoryboard* s = [UIStoryboard storyboardWithName:@"Login" bundle:nil];
    _useTimeVc = (UseTimeViewController*)[s instantiateViewControllerWithIdentifier:@"UseTime"];
    _useTimeVc.view.frame = CGRectMake(0, -64, SCREENWIDTH, SCREENHEIGHT-64);
    [_scroll addSubview:_useTimeVc.view];
    
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
