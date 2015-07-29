//
//  FinishMassageViewController.m
//  rongtai
//
//  Created by William-zhang on 15/6/15.
//  Copyright (c) 2015年 William-zhang. All rights reserved.
//

#import "FinishMassageViewController.h"
#import "IQKeyboardManager.h"
#import "RongTaiConstant.h"
#import "CWStarRateView.h"
#import "UILabel+WLAttributedString.h"

@interface FinishMassageViewController ()<UIAlertViewDelegate,CWStarRateViewDelegate>
{
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
    
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem goBackItemByTarget:self Action:@selector(goBack)];
//    UIBarButtonItem* item = self.navigationItem.leftBarButtonItem;
//    item.customView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"icon_back"]];
    
    UIBarButtonItem* share = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"icon_share"] style:UIBarButtonItemStylePlain target:self action:@selector(share)];
    self.navigationItem.rightBarButtonItem = share;
    
    //
    _saveBtn.layer.cornerRadius = 5;
    
    //
    _functionTextView.font = [UIFont systemFontOfSize:WSCALE*13];
    _functionL.font = [UIFont systemFontOfSize:WSCALE*14];
    _usingTimeL.font = [UIFont systemFontOfSize:WSCALE*14];
    _usingTime.font = [UIFont systemFontOfSize:WSCALE*13];
    _date.font = [UIFont systemFontOfSize:WSCALE*13];
    _nameLabel.font = [UIFont systemFontOfSize:WSCALE*20];
    _saveBtn.titleLabel.font = [UIFont systemFontOfSize:HSCALE*13];
    
    //
    UIFont* font = [UIFont fontWithName:@"Arial-BoldItalicMT" size:38*WSCALE];
    [_score setNumebrByFont:font Color:ORANGE];
    
    //
    [_usingTime setNumebrByFont:[UIFont systemFontOfSize:14*WSCALE] Color:BLUE];
    
    
    //
    _starRateView = [[CWStarRateView alloc]initWithFrame:CGRectMake(0, 0, SCREENWIDTH*0.84*0.7, 0.1*SCREENHEIGHT*0.6) numberOfStars:5];
    _starRateView.scorePercent = 0.9;
    _starRateView.delegate = self;
    _starRateView.starRateType = WLStarRateViewHalfType;
    [_addStarView addSubview:_starRateView];
    
    //

    
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
-(void)goBack
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - 分享
-(void)share
{
    
}

-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    IQKeyboardManager* key = [IQKeyboardManager sharedManager];
    [key setEnable:YES];
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
