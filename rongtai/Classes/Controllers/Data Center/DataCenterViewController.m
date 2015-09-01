//
//  DataCenterViewController.m
//  rongtai
//
//  Created by William-zhang on 15/6/10.
//  Copyright (c) 2015年 William-zhang. All rights reserved.
//


#import "DataCenterViewController.h"
#import "UseTimeViewController.h"
#import "PowerConsumeViewController.h"
#import "DoughnutViewController.h"
#import "RongTaiConstant.h"
#import "UILabel+WLAttributedString.h"
#import "CoreData+MagicalRecord.h"
#import "ProgramCount.h"
#import "MassageRecord.h"

@interface DataCenterViewController ()<UIScrollViewDelegate>
{
    UIScrollView* _scroll;
    UseTimeViewController* _useTimeVc;  //使用时长统计页面
    PowerConsumeViewController* _powerConsumeVC;  //耗电量页面
    DoughnutViewController* _doughnutVC;  //使用次数统计页面
    UIPageControl* _pageControl;
    UILabel* _titleLabel;  //标签
    NSUInteger _totalTime;  //总使用时长
    NSUInteger _todayUseTime;  //今日使用时长
}

@end

@implementation DataCenterViewController

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    CGFloat w = [UIScreen mainScreen].bounds.size.width;
    CGFloat h = [UIScreen mainScreen].bounds.size.height;
    self.title = NSLocalizedString(@"数据中心", nil);
    UIBarButtonItem* rightItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"icon_share"] style:UIBarButtonItemStylePlain target:self action:@selector(share)];
    self.navigationItem.rightBarButtonItem = rightItem;

    self.navigationItem.leftBarButtonItem = [UIBarButtonItem goBackItemByTarget:self Action:@selector(goBack)];
    
    //查询使用次数，并计算出总使用时间
    NSArray* counts = [ProgramCount MR_findAll];
    _totalTime = 0;

    
    //查询今天的按摩记录，并计算出今日使用时间
    NSDate* date = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"YYYY-MM-dd"];
    NSString* todayIndex = [dateFormatter stringFromDate:date];
    NSArray* todayRecord = [MassageRecord MR_findByAttribute:@"date" withValue:todayIndex];
    _todayUseTime = 0;
    for (int i = 0; i<todayRecord.count;i++) {
        MassageRecord* m = todayRecord[i];
        _todayUseTime += [m.useTime integerValue];
    }
    
    
    //分页控制器
    _pageControl = [[UIPageControl alloc]initWithFrame:CGRectMake((w - 60)/2, 64+5, 60, 10)];
    _pageControl.pageIndicatorTintColor = [UIColor colorWithRed:169/255.0 green:190/255.0 blue:205/255.0 alpha:1];
    _pageControl.currentPageIndicatorTintColor = BLUE;
    _pageControl.numberOfPages = 3;
    _pageControl.currentPage = 0;
    [_pageControl addTarget:self action:@selector(pageControllClicked:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:_pageControl];
    
    //标题Label
    _titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0.2*w, 64+16, w*0.6, 35)];
    if (_totalTime<60) {
        _titleLabel.text = [NSString stringWithFormat:@"%@: %ldm",NSLocalizedString(@"总使用时长", nil),_totalTime];
    }
    else
    {
        NSUInteger h = _totalTime/60;
        NSUInteger m = _totalTime%60;
        _titleLabel.text = [NSString stringWithFormat:@"%@: %ldh %ldm",NSLocalizedString(@"总使用时长", nil),h,m];
    }
    
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    _titleLabel.font = [UIFont systemFontOfSize:15];
    [_titleLabel setNumebrByFont:[UIFont systemFontOfSize:18] Color:BLUE];
    [self.view addSubview:_titleLabel];
    
    
    //左右切换按钮
    UIButton* left = [[UIButton alloc]initWithFrame:CGRectMake(0.1*w, 64+16, w*0.1, 35)];
    [left setImage:[UIImage imageNamed:@"data_arrow_left"] forState:UIControlStateNormal];
    [left addTarget:self action:@selector(leftButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:left];
    
    UIButton* right = [[UIButton alloc]initWithFrame:CGRectMake(0.8*w, 64+16, w*0.1, 35)];
    [right setImage:[UIImage imageNamed:@"data_arrow_right"] forState:UIControlStateNormal];
    [right addTarget:self action:@selector(rightButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:right];
    
    //SrcollView
    CGFloat sh = h-64-50;
    _scroll = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 64+50, w, sh)];
    _scroll.bounces = NO;
    _scroll.showsHorizontalScrollIndicator = NO;
    _scroll.showsVerticalScrollIndicator = NO;
    _scroll.backgroundColor = [UIColor clearColor];
    _scroll.contentSize = CGSizeMake(w*3, sh);
    _scroll.pagingEnabled = YES;
    _scroll.delegate = self;
    [self.view addSubview:_scroll];
    
    //使用时长
    UIStoryboard* s = [UIStoryboard storyboardWithName:@"Login" bundle:nil];
    _useTimeVc = (UseTimeViewController*)[s instantiateViewControllerWithIdentifier:@"UseTime"];
    _useTimeVc.view.frame = CGRectMake(0, 0, w, sh);
    [_scroll addSubview:_useTimeVc.view];
    [self addChildViewController:_useTimeVc];
    [_useTimeVc setTodayRecord:todayRecord AndTodayUseTime:_todayUseTime];
    
    //耗电量
    _powerConsumeVC = (PowerConsumeViewController*)[s instantiateViewControllerWithIdentifier:@"PowerConsume"];
    _powerConsumeVC.view.frame = CGRectMake(w, 0, w, sh);
    [_scroll addSubview:_powerConsumeVC.view];
    [self addChildViewController:_powerConsumeVC];
    [_powerConsumeVC setTotalTime:_totalTime AndTodayUseTime:_todayUseTime];
    
    //使用次数
    _doughnutVC = (DoughnutViewController*)[s instantiateViewControllerWithIdentifier:@"DoughnutVC"];
    _doughnutVC.view.frame = CGRectMake(w*2, 0, w, sh);
    [_scroll addSubview:_doughnutVC.view];
    _doughnutVC.progarmCounts = counts;
    [self addChildViewController:_doughnutVC];
    // Do any additional setup after loading the view.
}

#pragma mark - 返回
-(void)goBack
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - 左切换按钮
-(void)leftButtonClicked
{
    CGPoint p = _scroll.contentOffset;
    NSInteger page = p.x/SCREENWIDTH;
    if (page > 0) {
        p.x = (page-1)*SCREENWIDTH;
        CGRect f = _scroll.frame;
        f.origin = p;
        [_scroll scrollRectToVisible:f animated:YES];
    }
}

#pragma mark - 右切换按钮
-(void)rightButtonClicked
{
    CGPoint p = _scroll.contentOffset;
    NSInteger page = p.x/SCREENWIDTH;
    if (page < 2) {
        p.x = (page+1)*SCREENWIDTH;
        CGRect f = _scroll.frame;
        f.origin = p;
        [_scroll scrollRectToVisible:f animated:YES];
    }
}

#pragma mark - pageControll的点击方法
-(void)pageControllClicked:(UIPageControl*)sender
{
    CGPoint p = _scroll.contentOffset;
    p.x = sender.currentPage*SCREENWIDTH;
    CGRect f = _scroll.frame;
    f.origin = p;
    [_scroll scrollRectToVisible:f animated:YES];
}

#pragma mark - scroll代理
-(void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    NSInteger page = scrollView.contentOffset.x/SCREENWIDTH;
    _pageControl.currentPage = page;
    if (_pageControl.currentPage == 0) {
        if (_totalTime<60) {
            _titleLabel.text = [NSString stringWithFormat:@"%@: %ldm",NSLocalizedString(@"总使用时长", nil),_totalTime];
        }
        else
        {
            NSUInteger h = _totalTime/60;
            NSUInteger m = _totalTime%60;
            _titleLabel.text = [NSString stringWithFormat:@"%@: %ldh %ldm",NSLocalizedString(@"总使用时长", nil),h,m];
        }
        [_titleLabel setNumebrByFont:[UIFont systemFontOfSize:18] Color:BLUE];
    }
    else if (_pageControl.currentPage == 1)
    {
        _titleLabel.text = NSLocalizedString(@"耗电量", nil);
    }
    else
    {
        _titleLabel.text = NSLocalizedString(@"爱用程序", nil);
    }
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    NSInteger page = scrollView.contentOffset.x/SCREENWIDTH;
    _pageControl.currentPage = page;
    if (_pageControl.currentPage == 0) {
        if (_totalTime<60) {
            _titleLabel.text = [NSString stringWithFormat:@"%@: %ldm",NSLocalizedString(@"总使用时长", nil),_totalTime];
        }
        else
        {
            NSUInteger h = _totalTime/60;
            NSUInteger m = _totalTime%60;
            _titleLabel.text = [NSString stringWithFormat:@"%@: %ldh %ldm",NSLocalizedString(@"总使用时长", nil),h,m];
        }
        [_titleLabel setNumebrByFont:[UIFont systemFontOfSize:18] Color:BLUE];
    }
    else if (_pageControl.currentPage == 1)
    {
        _titleLabel.text = NSLocalizedString(@"耗电量", nil);
    }
    else
    {
        _titleLabel.text = NSLocalizedString(@"爱用程序", nil);
    }
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
