//
//  FinishMassageViewController.m
//  rongtai
//
//  Created by William-zhang on 15/6/15.
//  Copyright (c) 2015年 William-zhang. All rights reserved.
//

#import <ShareSDK/ShareSDK.h>

#import "FinishMassageViewController.h"
#import "RongTaiConstant.h"
#import "CWStarRateView.h"
#import "UILabel+WLAttributedString.h"
#import "UIView+RT.h"
#import "MassageRecord.h"

@interface FinishMassageViewController ()<UIAlertViewDelegate,CWStarRateViewDelegate> {
    __weak IBOutlet UILabel *_score;
    __weak IBOutlet UIView *_addStarView;
    __weak IBOutlet UILabel *_nameLabel;  //按摩模式名称
    __weak IBOutlet UILabel *_usingTime;   //用时
    __weak IBOutlet UILabel *_date; //按摩日期
    CWStarRateView *_starRateView;
    
    __weak IBOutlet UITextView *_functionTextView; //按摩功能
    
    __weak IBOutlet UILabel *_functionL;
    
    __weak IBOutlet UILabel *_usingTimeL;
    
    __weak IBOutlet UIButton *_saveBtn;
    
    __weak IBOutlet NSLayoutConstraint *_manImageTop;
    RTBleConnector* _bleConnector;
}
@end

@implementation FinishMassageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedString(@"按摩完毕", nil);
    self.isListenBluetoothStatus = NO;
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    
    //返回按钮设置
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem goBackItemByTarget:self Action:@selector(goBack)];
    
    //导航栏右边按钮，分享按钮
    UIBarButtonItem* share = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"icon_share"] style:UIBarButtonItemStylePlain target:self action:@selector(share)];
    self.navigationItem.rightBarButtonItem = share;
    
    //保存按钮圆角设置
    _saveBtn.layer.cornerRadius = SCREENHEIGHT*0.065*0.5;
    
    //按比例设置各个控件的字体
    _functionTextView.font = [UIFont systemFontOfSize:WSCALE*13];
    _functionL.font = [UIFont systemFontOfSize:WSCALE*14];
    _usingTimeL.font = [UIFont systemFontOfSize:WSCALE*14];
    _usingTime.font = [UIFont systemFontOfSize:WSCALE*11];
    _date.font = [UIFont systemFontOfSize:WSCALE*11];
    _nameLabel.font = [UIFont systemFontOfSize:WSCALE*20];
    _saveBtn.titleLabel.font = [UIFont systemFontOfSize:HSCALE*13];
    
    //分数数字字体设置
    UIFont* font = [UIFont fontWithName:@"Arial-BoldItalicMT" size:38*WSCALE];
    [_score setNumebrByFont:font Color:ORANGE];
    
    //使用时间数字字体设置
    [_usingTime setNumebrByFont:[UIFont systemFontOfSize:13*WSCALE] Color:BLUE];
    
    //创建星级评分控件
    _starRateView = [[CWStarRateView alloc]initWithFrame:CGRectMake(0, 0, SCREENWIDTH*0.84*0.7, 0.1*SCREENHEIGHT*0.6) numberOfStars:5];
    _starRateView.scorePercent = 1;
    _starRateView.delegate = self;
    _starRateView.starRateType = WLStarRateViewCompleteType;
    [_addStarView addSubview:_starRateView];
    
    _bleConnector = [RTBleConnector shareManager];
    self.massageRecord = _bleConnector.massageRecord;
    
    [_functionTextView scrollRangeToVisible:NSMakeRange(0, 1)];
    
//    _functionTextView.text = @"为您匠心定制，享誉业内的肩颈重点按摩程序，80%时间集中肩部和颈部，缓解用户最为关心的肩颈酸痛症状。椅身靠背的曲线设计使得按摩滚轮完全触及颈部部位，结合荣泰独有的颈部“揉捏和摁压”技法，此程序有效缓解用户该部位的疲劳和僵硬。";
    // Do any additional setup after loading the view.
}

#pragma mark - 按摩记录set方法
-(void)setMassageRecord:(NSDictionary *)massageRecord
{
    if (massageRecord != nil) {
        //使用时间
        NSNumber* useTimeStr = [massageRecord objectForKey:@"useTime"];
        NSInteger useTime = [useTimeStr integerValue];
        if (useTime>=60) {
//            if (useTime>=3600) {
                _usingTime.text = [NSString stringWithFormat:@"共%d分",(int)round(useTime/60.0)];
//            }
//            else
//            {
//                 _usingTime.text = [NSString stringWithFormat:@"共%d小时",(int)round(useTime/3600.0)];
//            }
        }
        else
        {
            _usingTime.text = [NSString stringWithFormat:@"共%ld秒",(long)useTime];
        }
        [_usingTime setNumebrByFont:[UIFont systemFontOfSize:13*WSCALE] Color:BLUE];
        
        //按摩日期
        NSString* date = [massageRecord objectForKey:@"useDate"];
        date = [date stringByReplacingOccurrencesOfString:@"-" withString:@"."];
        
        NSDateFormatter* formatter = [NSDateFormatter new];
        [formatter setDateFormat:@"hh:mm:ss"];
        NSDate* start = [massageRecord objectForKey:@"startTime"];
        NSString* startTime = [formatter stringFromDate:start];
        NSDate* end = [massageRecord objectForKey:@"endTime"];
        NSString* endTime = [formatter stringFromDate:end];
        
        _date.text = [NSString stringWithFormat:@"%@  %@ -- %@",date,startTime,endTime];
        
        NSString* name = [massageRecord objectForKey:@"name"];
        _nameLabel.text = name;
        _functionTextView.text = [massageRecord objectForKey:@"function"];
    }
}

#pragma mark - 保存自定义程序
- (IBAction)save:(id)sender {
    
}

#pragma mark - 保存模式
-(void)saveMode
{
    self.view.backgroundColor =[UIColor clearColor];
    _manImageTop.constant = 10;
    _saveBtn.hidden = NO;
}

#pragma mark - starRateView代理
-(void)starRateView:(CWStarRateView *)starRateView scroePercentDidChange:(CGFloat)newScorePercent
{
    _score.text = [NSString stringWithFormat:@"%d分",(int)(newScorePercent*5)];
    UIFont* font = [UIFont fontWithName:@"Arial-BoldItalicMT" size:38*WSCALE];
    [_score setNumebrByFont:font Color:ORANGE];
}

#pragma mark - 返回方法
-(void)goBack {
	[self backToMainViewController];
}

#pragma mark - 分享
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
