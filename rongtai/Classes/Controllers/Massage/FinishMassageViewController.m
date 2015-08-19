//
//  FinishMassageViewController.m
//  rongtai
//
//  Created by William-zhang on 15/6/15.
//  Copyright (c) 2015年 William-zhang. All rights reserved.
//
#import <ShareSDK/ShareSDK.h>

#import "FinishMassageViewController.h"
#import "IQKeyboardManager.h"
#import "RongTaiConstant.h"
#import "CWStarRateView.h"
#import "UILabel+WLAttributedString.h"
#import "UIView+RT.h"

@interface FinishMassageViewController ()<UIAlertViewDelegate,CWStarRateViewDelegate> {
    __weak IBOutlet UILabel *_score;
    __weak IBOutlet UIView *_addStarView;
    __weak IBOutlet UILabel *_nameLabel;
    __weak IBOutlet UILabel *_usingTime;
    __weak IBOutlet UILabel *_date;
    CWStarRateView *_starRateView;
    
    __weak IBOutlet UITextView *_functionTextView;
    
    __weak IBOutlet UILabel *_functionL;
    
    __weak IBOutlet UILabel *_usingTimeL;
    
    __weak IBOutlet UIButton *_saveBtn;
    
    __weak IBOutlet NSLayoutConstraint *_manImageTop;
}
@end

@implementation FinishMassageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedString(@"按摩完毕", nil);
    
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
    _usingTime.font = [UIFont systemFontOfSize:WSCALE*13];
    _date.font = [UIFont systemFontOfSize:WSCALE*13];
    _nameLabel.font = [UIFont systemFontOfSize:WSCALE*20];
    _saveBtn.titleLabel.font = [UIFont systemFontOfSize:HSCALE*13];
    
    //分数数字字体设置
    UIFont* font = [UIFont fontWithName:@"Arial-BoldItalicMT" size:38*WSCALE];
    [_score setNumebrByFont:font Color:ORANGE];
    
    //使用时间数字字体设置
    [_usingTime setNumebrByFont:[UIFont systemFontOfSize:14*WSCALE] Color:BLUE];
    
    //创建星级评分控件
    _starRateView = [[CWStarRateView alloc]initWithFrame:CGRectMake(0, 0, SCREENWIDTH*0.84*0.7, 0.1*SCREENHEIGHT*0.6) numberOfStars:5];
    _starRateView.scorePercent = 0.9;
    _starRateView.delegate = self;
    _starRateView.starRateType = WLStarRateViewHalfType;
    [_addStarView addSubview:_starRateView];
    
    // Do any additional setup after loading the view.
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
    _score.text = [NSString stringWithFormat:@"%.1f分",newScorePercent*5];
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
	
	//2、弹出分享菜单
	[ShareSDK showShareActionSheet:container
						 shareList:nil
						   content:publishContent
					 statusBarTips:YES
					   authOptions:nil
					  shareOptions:nil
							result:^(ShareType type, SSResponseState state, id<ISSPlatformShareInfo> statusInfo, id<ICMErrorInfo> error, BOOL end) {
								
								//可以根据回调提示用户。
								if (state == SSResponseStateSuccess)
								{
									UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"分享成功"
																					message:nil
																				   delegate:self
																		  cancelButtonTitle:@"OK"
																		  otherButtonTitles:nil, nil];
									[alert show];
								}
								else if (state == SSResponseStateFail)
								{
									UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"分享失败"
																					message:[NSString stringWithFormat:@"失败描述：%@",[error errorDescription]]
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
