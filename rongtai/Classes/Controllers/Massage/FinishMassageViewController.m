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
    __weak IBOutlet UILabel *_functionLabel;
    __weak IBOutlet UILabel *_usingTime;
    __weak IBOutlet UILabel *_date;
    CWStarRateView *_starRateView;
}
@end

@implementation FinishMassageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedString(@"按摩完毕", nil);
    
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem goBackItemByTarget:self Action:@selector(goBack)];
    
    UIBarButtonItem* share = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"icon_share"] style:UIBarButtonItemStylePlain target:self action:@selector(share)];
    self.navigationItem.rightBarButtonItem = share;
    
    //
    UIFont* font = [UIFont fontWithName:@"Arial-BoldItalicMT" size:50];
    [_score setNumebrByFont:font Color:ORANGE];
    
    //
    [_usingTime setNumebrByFont:[UIFont systemFontOfSize:15] Color:BLUE];
    
    
    //
    _starRateView = [[CWStarRateView alloc]initWithFrame:CGRectMake(0, 0, SCREENWIDTH*0.84, 0.1*SCREENHEIGHT) numberOfStars:5];
    _starRateView.scorePercent = 0.9;
    _starRateView.delegate = self;
    _starRateView.starRateType = WLStarRateViewHalfType;
    [_addStarView addSubview:_starRateView];
    
    
    // Do any additional setup after loading the view.
}

#pragma mark - 保存自定义程序
- (IBAction)save:(id)sender {
    IQKeyboardManager* key = [IQKeyboardManager sharedManager];
    [key setEnable:NO];
    UIAlertView* alert = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"自定义程序名称",nil) message:nil delegate:self cancelButtonTitle:NSLocalizedString(@"取消", nil) otherButtonTitles:NSLocalizedString(@"保存", nil), nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alert show];
}

-(void)starRateView:(CWStarRateView *)starRateView scroePercentDidChange:(CGFloat)newScorePercent
{
    _score.text = [NSString stringWithFormat:@"%.1f分",newScorePercent];
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
