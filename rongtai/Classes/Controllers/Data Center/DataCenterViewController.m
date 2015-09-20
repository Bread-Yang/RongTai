//
//  DataCenterViewController.m
//  rongtai
//
//  Created by William-zhang on 15/6/10.
//  Copyright (c) 2015年 William-zhang. All rights reserved.
//

#import <ShareSDK/ShareSDK.h>

#import "DataCenterViewController.h"
#import "UseTimeViewController.h"
#import "PowerConsumeViewController.h"
#import "DoughnutViewController.h"
#import "RongTaiConstant.h"
#import "UILabel+WLAttributedString.h"
#import "CoreData+MagicalRecord.h"
#import "MassageRecord.h"
#import "MBProgressHUD.h"
#import "DataRequest.h"
#import "UIView+RT.h"

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
    NSString* _uid;
    MBProgressHUD *_loading;
    UIView* _clearView;  //再显示菊花图的生活盖住最上层View
}
@end

@implementation DataCenterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    CGFloat w = [UIScreen mainScreen].bounds.size.width;
    CGFloat h = [UIScreen mainScreen].bounds.size.height;
    self.title = NSLocalizedString(@"数据中心", nil);
    UIBarButtonItem* rightItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"icon_share"] style:UIBarButtonItemStylePlain target:self action:@selector(share)];
    self.navigationItem.rightBarButtonItem = rightItem;

    self.navigationItem.leftBarButtonItem = [UIBarButtonItem goBackItemByTarget:self Action:@selector(goBack)];
    _uid = [[NSUserDefaults standardUserDefaults] objectForKey:@"uid"];
	
    
    //分页控制器
    _pageControl = [[UIPageControl alloc]initWithFrame:CGRectMake((w - 60)/2, 5, 60, 10)];
    _pageControl.pageIndicatorTintColor = [UIColor colorWithRed:169/255.0 green:190/255.0 blue:205/255.0 alpha:1];
    _pageControl.currentPageIndicatorTintColor = BLUE;
    _pageControl.numberOfPages = 3;
    _pageControl.currentPage = 0;
    [_pageControl addTarget:self action:@selector(pageControllClicked:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:_pageControl];
    
    //标题Label
    _titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0.2*w, 16, w*0.6, 35)];
    _titleLabel.text = [NSString stringWithFormat:@"%@: %0m",NSLocalizedString(@"总使用时长", nil)];
    
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    _titleLabel.font = [UIFont systemFontOfSize:15];
    [_titleLabel setNumebrByFont:[UIFont systemFontOfSize:18] Color:BLUE];
    [self.view addSubview:_titleLabel];
    
    //左右切换按钮
//    UIButton* left = [[UIButton alloc]initWithFrame:CGRectMake(0.1*w, 16, w*0.1, 35)];
//    [left setImage:[UIImage imageNamed:@"data_arrow_left"] forState:UIControlStateNormal];
//    [left addTarget:self action:@selector(leftButtonClicked) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:left];
//    
//    UIButton* right = [[UIButton alloc]initWithFrame:CGRectMake(0.8*w, 16, w*0.1, 35)];
//    [right setImage:[UIImage imageNamed:@"data_arrow_right"] forState:UIControlStateNormal];
//    [right addTarget:self action:@selector(rightButtonClicked) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:right];
    
    //SrcollView
    CGFloat sh = h-64-50;
    _scroll = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 50, w, sh)];
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
//    [_useTimeVc setTodayRecord:todayRecord AndTodayUseTime:_todayUseTime];
    
    //耗电量
    _powerConsumeVC = (PowerConsumeViewController*)[s instantiateViewControllerWithIdentifier:@"PowerConsume"];
    _powerConsumeVC.view.frame = CGRectMake(w, 0, w, sh);
    [_scroll addSubview:_powerConsumeVC.view];
    [self addChildViewController:_powerConsumeVC];
//    [_powerConsumeVC setTotalTime:_totalTime AndTodayUseTime:_todayUseTime];
    
    //使用次数
    _doughnutVC = (DoughnutViewController*)[s instantiateViewControllerWithIdentifier:@"DoughnutVC"];
    _doughnutVC.view.frame = CGRectMake(w*2, 0, w, sh);
    [_scroll addSubview:_doughnutVC.view];
    [self addChildViewController:_doughnutVC];
    
    //MBProgressHUD
    _clearView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHT)];
    _clearView.backgroundColor = [UIColor clearColor];
    _loading = [[MBProgressHUD alloc]initWithView:self.view];
    _loading.labelText = NSLocalizedString(@"读取中...", nil);
    [self.view addSubview:_loading];
    
    // Do any additional setup after loading the view.
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    //查询按摩记录，计算今日使用时长和总使用时长
    [_loading show:YES];
    _totalTime = 0;
    _todayUseTime = 0;
    DataRequest* r = [DataRequest new];
    [r getMassageRecordFrom:[NSDate dateWithTimeIntervalSince1970:0] To:[NSDate dateWithTimeIntervalSinceNow:0] Success:^(NSArray *arr) {
        [_loading hide:YES];
        //统计时间
        NSDate* date = [NSDate date];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"YYYY-MM-dd"];
        NSString* todayIndex = [dateFormatter stringFromDate:date];
        NSMutableArray* todayRecord = [NSMutableArray new];
        for (NSDictionary* dic in arr) {
            NSString* date = [dic objectForKey:@"useDate"];
            NSUInteger useTime = [[dic objectForKey:@"useTime"] integerValue];
            if ([date isEqualToString:todayIndex]) {
                _todayUseTime += useTime;
                [todayRecord addObject:dic];
            }
            _totalTime += useTime;
        }

        //数据传到耗电量页面
        [_powerConsumeVC setTotalTime:_totalTime AndTodayUseTime:_todayUseTime];
        
        //数据传到使用时长页面
        [_useTimeVc setTodayRecord:todayRecord AndTodayUseTime:_todayUseTime];
        [_useTimeVc setWeekData:arr ByDataCenterVC:self];
        
        //设置该页面的总使用时长
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
        
    } fail:^(NSDictionary *dic) {
        [_loading hide:YES];
        [self showProgressHUDByString:@"读取数据失败，请检测网络"];
    }];
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
            _titleLabel.text = [NSString stringWithFormat:@"%@: %ldm",NSLocalizedString(@"总使用时长", nil), (unsigned long)_totalTime];
        }
        else
        {
            NSUInteger h = _totalTime/60;
            NSUInteger m = _totalTime%60;
            _titleLabel.text = [NSString stringWithFormat:@"%@: %ldh %ldm",NSLocalizedString(@"总使用时长", nil),(unsigned long)h,m];
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
        [_doughnutVC requestData:self];
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
        [_doughnutVC requestData:self];
    }
}

#pragma mark - 分享方法

-(void)share {
	UIImage *shareimage =  [UIView getImageFromView:self.view];
	
	//1、构造分享内容
	id<ISSContent> publishContent = [ShareSDK content:@"我刚刚使用荣泰按摩椅进行按摩,觉得很不错,推荐给你们"
									   defaultContent:@"我刚刚使用荣泰按摩椅进行按摩,觉得很不错,推荐给你们"
												image:[ShareSDK pngImageWithImage:shareimage]
												title:@"荣泰按摩椅分享"
												  url:@"http://www.rongtai-china.com/product"
										  description:@"这是一条演示信息"
											mediaType:SSPublishContentMediaTypeNews];
	
	id<ISSContainer> container = [ShareSDK container];
	
	//要分享的列表
	NSArray *shareList = [ShareSDK getShareListWithType:ShareTypeWeixiSession, ShareTypeWeixiTimeline, ShareTypeQQ, ShareTypeSinaWeibo, nil];
	
	//2、弹出分享菜单
	[ShareSDK showShareActionSheet:container
						 shareList:shareList
						   content:publishContent
					 statusBarTips:YES
					   authOptions:nil
					  shareOptions:nil
							result:^(ShareType type, SSResponseState state, id<ISSPlatformShareInfo> statusInfo, id<ICMErrorInfo> error, BOOL end) {
								
								//可以根据回调提示用户。
								if (state == SSResponseStateSuccess)
								{
									UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"分享成功", nil)
																					message:nil
																				   delegate:self
																		  cancelButtonTitle:@"OK"
																		  otherButtonTitles:nil, nil];
									[alert show];
								}
								else if (state == SSResponseStateFail)
								{
									UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"分享失败", nil)
																					message:[NSString stringWithFormat:@"%@：%@",NSLocalizedString(@"失败描述", nil),[error errorDescription]]
																				   delegate:self
																		  cancelButtonTitle:@"OK"
																		  otherButtonTitles:nil, nil];
									[alert show];
								}
							}];
}

#pragma mark - 显示HUD
-(void)showHUD
{
    [_loading show:YES];
}

#pragma mark - 关闭HUD
-(void)hideHUD
{
    [_loading hide:NO];
}

#pragma mark - 快速提示
-(void)showProgressHUDByString:(NSString*)message
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.labelText = message;
    hud.margin = 10.f;
    hud.removeFromSuperViewOnHide = YES;
    [hud hide:YES afterDelay:0.7];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
