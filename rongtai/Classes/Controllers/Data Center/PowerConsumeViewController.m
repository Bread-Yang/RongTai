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
    _kwh = 0.26;
//    _saveKwh = 0.4;
    _totalTime = 60;
    _todayTime = 60;
    // Do any additional setup after loading the view.
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [_oneView addLineBorder];
    [_tow addLineBorder];
    [_three addLineBorder];
    _moneyOfPower.text = [NSString stringWithFormat:@"%.1f%@",_money,NSLocalizedString(@"元/度", nil)];
    [_moneyOfPower setNumebrByFont:[UIFont fontWithName:@"Helvetica-Light" size:20] Color:LIGHTGREEN];
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
    _rightCell.name = NSLocalizedString(@"总计预估电费", nil);
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

-(void)updateUI
{
    CGFloat todayH = _todayTime/60.0;
    CGFloat totalH = _totalTime/60.0;
    _leftCell.countLabel.text = [NSString stringWithFormat:@"%.2f%@",todayH*_kwh*_money,NSLocalizedString(@"元", nil)];
    [_leftCell.countLabel setNumebrByFont:[UIFont systemFontOfSize:20] Color:BLUE];
    _leftCell.detailLabel.hidden = YES;
//    _leftCell.detailLabel.text = [NSString stringWithFormat:@"%@%d%@",NSLocalizedString(@"预估节省", nil),(int)(todayH*_saveKwh*_money),NSLocalizedString(@"元", nil)];
//    [_leftCell.detailLabel setNumebrByFont:[UIFont systemFontOfSize:12] Color:BLUE];
    
    _rightCell.countLabel.text = [NSString stringWithFormat:@"%.2f%@",totalH*_kwh*_money,NSLocalizedString(@"元", nil)];;
    [_rightCell.countLabel setNumebrByFont:[UIFont systemFontOfSize:20] Color:LIGHTGREEN];
    _rightCell.detailLabel.hidden = YES;
//    _rightCell.detailLabel.text = [NSString stringWithFormat:@"%@%d%@",NSLocalizedString(@"预估节省", nil),(int)(totalH*_saveKwh*_money),NSLocalizedString(@"元", nil)];
//    [_rightCell.detailLabel setNumebrByFont:[UIFont systemFontOfSize:12] Color:LIGHTGREEN];
    
    _todayPowerConsume.text = [NSString stringWithFormat:@"%.2fkwh",todayH*_kwh];
    [_todayPowerConsume setNumebrByFont:[UIFont fontWithName:@"Helvetica-Light" size:25] Color:LIGHTGREEN];
    
    _totalPowerConsum.text = [NSString stringWithFormat:@"%.2fkwh",totalH*_kwh];
    [_totalPowerConsum setNumebrByFont:[UIFont fontWithName:@"Helvetica-Light" size:25] Color:LIGHTGREEN];
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
