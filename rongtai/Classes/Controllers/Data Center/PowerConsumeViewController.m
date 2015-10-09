//
//  PowerConsumeViewController.m
//  rongtai
//
//  Created by William-zhang on 15/6/10.
//  Copyright (c) 2015年 William-zhang. All rights reserved.
//

#import "PowerConsumeViewController.h"
#import "UILabel+WLAttributedString.h"
#import "UIView+AddBorder.h"
#import "RongTaiConstant.h"
#import "DoughnutCollectionViewCell.h"
#import "CustomIOSAlertView.h"
#import "MBProgressHUD.h"
#import "AppDelegate.h"
#import "IQKeyboardManager.h"

@interface PowerConsumeViewController ()
{
    __weak IBOutlet UILabel *_todayPowerConsume;  //今日耗电量
    __weak IBOutlet UILabel *_totalPowerConsum;  //总耗电量
    __weak IBOutlet UILabel *_moneyOfPower;  //每度电多少钱
    __weak IBOutlet UIView *_oneView;
    __weak IBOutlet UIView *_tow;
    __weak IBOutlet UIView *_three;
    DoughnutCollectionViewCell* _leftCell;
    DoughnutCollectionViewCell* _rightCell;
    CGFloat _kwh;  //按摩椅每小时用多少电
    CGFloat _saveKwh;  //按摩椅每小时可以节省多少电
    CGFloat _money;  //一度电的价格，单位元
    NSUInteger _totalTime;
    NSUInteger _todayTime;
}
@end

@implementation PowerConsumeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _money = 0.6;
    NSNumber* money = [[NSUserDefaults standardUserDefaults] objectForKey:@"moneOfPower"];
    if (money) {
        _money = [money floatValue];
    }
    _kwh = 0.26;
//    _saveKwh = 0.4;
    _totalTime = 60;
    _todayTime = 60;
    
    //给电费的view添加手势
    UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(editMoneyOfPower)];
    [_three addGestureRecognizer:tap];
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    IQKeyboardManager* key = [IQKeyboardManager sharedManager];
    key.enableAutoToolbar = NO;
    key.enable = NO;
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    IQKeyboardManager* key = [IQKeyboardManager sharedManager];
    key.enableAutoToolbar = YES;
    key.enable = YES;
}


-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [_oneView addLineBorder];
    [_tow addLineBorder];
    [_three addLineBorder];
    //
    CGFloat w = CGRectGetWidth(_tow.frame);
    CGFloat h = CGRectGetHeight(_tow.frame);
    _leftCell = [[DoughnutCollectionViewCell alloc]initWithFrame:CGRectMake(0, 0, w/2, h)];
    [_leftCell changeUIFrame];
    _leftCell.name = NSLocalizedString(@"今日预估电费", nil);
    _leftCell.doughnut.finishColor = BLUE;
    [_tow addSubview:_leftCell];
    
    _rightCell = [[DoughnutCollectionViewCell alloc]initWithFrame:CGRectMake(w/2, 0, w/2, h)];
    [_rightCell changeUIFrame];
    _rightCell.name = NSLocalizedString(@"总预估电费", nil);
    _rightCell.doughnut.finishColor = LIGHTGREEN;
    [_tow addSubview:_rightCell];
    [self updateUI];
}

-(void)setTotalTime:(NSUInteger)totalTime AndTodayUseTime:(NSUInteger)todayUseTime
{
    _totalTime = totalTime;
    _todayTime = todayUseTime;
    [self updateUI];
}

#pragma mark - 更新界面信息
-(void)updateUI
{
    _moneyOfPower.text = [NSString stringWithFormat:@"%.2f%@",_money,NSLocalizedString(@"元/度", nil)];
    [_moneyOfPower setNumebrByFont:[UIFont fontWithName:@"Helvetica-Light" size:20] Color:LIGHTGREEN];
    CGFloat todayH = _todayTime/60.0;
    CGFloat totalH = _totalTime/60.0;
    _leftCell.countLabel.text = [NSString stringWithFormat:@"%.2f%@",todayH*_kwh*_money,NSLocalizedString(@"元", nil)];
    [_leftCell.countLabel setNumebrByFont:[UIFont systemFontOfSize:20] Color:BLUE];
    _leftCell.doughnut.percent = _todayTime/(float)_totalTime;
    _leftCell.detailLabel.hidden = YES;
//    _leftCell.detailLabel.text = [NSString stringWithFormat:@"%@%d%@",NSLocalizedString(@"预估节省", nil),(int)(todayH*_saveKwh*_money),NSLocalizedString(@"元", nil)];
//    [_leftCell.detailLabel setNumebrByFont:[UIFont systemFontOfSize:12] Color:BLUE];
    
    _rightCell.countLabel.text = [NSString stringWithFormat:@"%.2f%@",totalH*_kwh*_money,NSLocalizedString(@"元", nil)];;
    [_rightCell.countLabel setNumebrByFont:[UIFont systemFontOfSize:20] Color:LIGHTGREEN];
    _rightCell.doughnut.percent = 1;
    _rightCell.detailLabel.hidden = YES;
//    _rightCell.detailLabel.text = [NSString stringWithFormat:@"%@%d%@",NSLocalizedString(@"预估节省", nil),(int)(totalH*_saveKwh*_money),NSLocalizedString(@"元", nil)];
//    [_rightCell.detailLabel setNumebrByFont:[UIFont systemFontOfSize:12] Color:LIGHTGREEN];
    
    _todayPowerConsume.text = [NSString stringWithFormat:@"%.2fkwh",todayH*_kwh];
    [_todayPowerConsume setNumebrByFont:[UIFont fontWithName:@"Helvetica-Light" size:25] Color:LIGHTGREEN];
    
    _totalPowerConsum.text = [NSString stringWithFormat:@"%.2fkwh",totalH*_kwh];
    [_totalPowerConsum setNumebrByFont:[UIFont fontWithName:@"Helvetica-Light" size:25] Color:LIGHTGREEN];
}

#pragma mark - 点击电费的方法
-(void)editMoneyOfPower
{
    CustomIOSAlertView* alert = [[CustomIOSAlertView alloc]init];
    alert.useMotionEffects = NO;
    [alert setTitleString:@"电费修改"];
    UIView* view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREENWIDTH*0.8, SCREENHEIGHT*0.15)];
    view.backgroundColor = [UIColor clearColor];
    UITextField* textField = [[UITextField alloc]initWithFrame:CGRectMake(SCREENWIDTH*0.1, SCREENHEIGHT*0.03, SCREENWIDTH*0.6, SCREENHEIGHT*0.08)];
    textField.textColor = [UIColor colorWithRed:108.0/255.0 green:108.0/255.0 blue:108.0/255.0 alpha:1.0f];
    textField.backgroundColor = [UIColor colorWithRed:246.0 / 255.0 green:246.0 / 255.0  blue:246.0 / 255.0  alpha:1.0];
    textField.borderStyle = UITextBorderStyleNone;
    textField.keyboardType = UIKeyboardTypeDecimalPad;
    textField.text = [NSString stringWithFormat:@"%.2f",_money];
    [view addSubview:textField];
    [alert setContainerView:view];
    [alert setButtonTitles:@[NSLocalizedString(@"取消", nil),NSLocalizedString(@"保存", nil)]];
    [alert setOnButtonTouchUpInside:^(CustomIOSAlertView *alertView, int buttonIndex) {
        if (buttonIndex == 0) {
            [alertView close];
        }
        else
        {
            CGFloat m = [textField.text floatValue];
            if (m>0&&m<=100) {
                _money = m;
                [self updateUI];
                [alertView close];
                [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithFloat:_money] forKey:@"moneOfPower"];
            }
            else
            {
                //输入数字超过范围
                [self showProgressHUDByString:@"数值应在0~100之间"];
            }
            
        }
    }];
    [alert setUseMotionEffects:true];
    [alert show];
}


#pragma mark - 快速提示
-(void)showProgressHUDByString:(NSString*)message
{
    AppDelegate* appDelegate = [[UIApplication sharedApplication] delegate];
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:appDelegate.window animated:YES];
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



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
