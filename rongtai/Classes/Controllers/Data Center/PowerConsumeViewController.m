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
}
@end

@implementation PowerConsumeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [_todayPowerConsume setNumebrByFont:[UIFont fontWithName:@"Helvetica-Light" size:25] Color:LIGHTGREEN];
    [_totalPowerConsum setNumebrByFont:[UIFont fontWithName:@"Helvetica-Light" size:25] Color:LIGHTGREEN];
    // Do any additional setup after loading the view.
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [_oneView addLineBorder];
    [_tow addLineBorder];
    [_three addLineBorder];
    [_moneyOfPower setNumebrByFont:[UIFont fontWithName:@"Helvetica-Light" size:20] Color:LIGHTGREEN];
    //
    CGFloat w = CGRectGetWidth(_tow.frame);
    CGFloat h = CGRectGetHeight(_tow.frame);
    _leftCell = [[DoughnutCollectionViewCell alloc]initWithFrame:CGRectMake(0, 0, w/2, h)];
    [_leftCell changeUIFrame];
    _leftCell.countLabel.text = @"1.44元";
    [_leftCell.countLabel setNumebrByFont:[UIFont systemFontOfSize:20] Color:BLUE];
    _leftCell.detailLabel.text = @"预估节省1元";
    [_leftCell.detailLabel setNumebrByFont:[UIFont systemFontOfSize:12] Color:BLUE];
    _leftCell.name = @"今日预估电费";
    _leftCell.doughnut.finishColor = BLUE;
    [_tow addSubview:_leftCell];
    
    _rightCell = [[DoughnutCollectionViewCell alloc]initWithFrame:CGRectMake(w/2, 0, w/2, h)];
    [_rightCell changeUIFrame];
    _rightCell.countLabel.text = @"74.4元";
    [_rightCell.countLabel setNumebrByFont:[UIFont systemFontOfSize:20] Color:LIGHTGREEN];
    _rightCell.detailLabel.text = @"预估节省24元";
    [_rightCell.detailLabel setNumebrByFont:[UIFont systemFontOfSize:12] Color:LIGHTGREEN];
    _rightCell.name = @"总计预估电费";
    _rightCell.doughnut.finishColor = LIGHTGREEN;
    [_tow addSubview:_rightCell];
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
