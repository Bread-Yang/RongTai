//
//  UseTimeViewController.m
//  rongtai
//
//  Created by William-zhang on 15/6/10.
//  Copyright (c) 2015年 William-zhang. All rights reserved.
//

#import "UseTimeViewController.h"
#import "WLDoughnutStatsView.h"
#import "RongTaiConstant.h"
#import "WLLineChart.h"
#import "UILabel+WLAttributedString.h"
#import "CoreData+MagicalRecord.h"
#import "MassageRecord.h"

@interface UseTimeViewController ()
{
    __weak IBOutlet WLDoughnutStatsView *_doughnutView;   //环形统计图
    
    __weak IBOutlet UIView *_storeLineChartView;  //用来存放折线图的View

    __weak IBOutlet UIButton *_dayBtn;
    __weak IBOutlet UIButton *_monthBtn;
    __weak IBOutlet UIButton *_yeayBtn;
    
    __weak IBOutlet UILabel *_usingTime;
    

    WLLineChart* _lineChart;  //折线图
}
@end

@implementation UseTimeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    CGFloat h = (SCREENHEIGHT-64-50)*0.4*0.9;
    
    _doughnutView.r = h/2;
    _doughnutView.doughnutWidth = _doughnutView.r*0.25;
    
    //读取今天的按摩记录
    NSDate* date = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"YYYY/MM/dd"];
    NSString* todayIndex = [dateFormatter stringFromDate:date];
    NSArray* todayRecord = [MassageRecord MR_findByAttribute:@"date" withValue:todayIndex];
    
    //比例数组
    if (todayRecord.count>0) {
        NSMutableArray* percents = [NSMutableArray new];
        NSUInteger totalTime = 0;
        for (int i = 0; i<todayRecord.count; i++) {
            MassageRecord* r = todayRecord[i];
            totalTime += [r.useTime integerValue];
        }
        
        for (int i = 0; i<todayRecord.count; i++) {
            MassageRecord* r = todayRecord[i];
            float percent = [r.useTime integerValue]/(float)totalTime;
            NSNumber* num = [NSNumber numberWithFloat:percent];
            [percents addObject:num];
        }
        _doughnutView.percents = [NSArray arrayWithArray:percents];
        
        //设置文字
        if (totalTime>=60) {
            NSUInteger h = totalTime/60;
            NSUInteger m = totalTime%60;
            _usingTime.text = [NSString stringWithFormat:@"%ldh%ldm",h,m];
        }
        else
        {
            _usingTime.text = [NSString stringWithFormat:@"%ldm",totalTime];
        }
    }
    else
    {
        //今天暂时没使用该app进行按摩
        
    }
    
    _lineChart = [[WLLineChart alloc]initWithFrame:CGRectMake(0.05*SCREENWIDTH, 0.15*h, 0.9*SCREENWIDTH, 0.9*h)];
    _lineChart.showXRuler = NO;
    _lineChart.isPointDashed = NO;
    _lineChart.lineColor = BLUE;
    _lineChart.rulerColor = [UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:0.5];
    _lineChart.xAxisHidden = YES;
    _lineChart.yAxisHidden = YES;
    _lineChart.yUnit = @"(h)";
    _lineChart.xUnit = @"(Day)";
    _lineChart.yValueFont = [UIFont systemFontOfSize:11];
    _lineChart.yUnitFont = [UIFont systemFontOfSize:11];
    _lineChart.xValueFont = [UIFont systemFontOfSize:11];
    _lineChart.xUnitFont = [UIFont systemFontOfSize:11];
    [_storeLineChartView addSubview:_lineChart];
    
    _usingTime.font = [UIFont fontWithName:@"Helvetica" size:10*HSCALE];
    [_usingTime setNumebrByFont:[UIFont fontWithName:@"Helvetica" size:20*HSCALE] Color:BLUE];
    
    // Do any additional setup after loading the view.
}

#pragma mark - 底部年月日按钮
- (IBAction)dateSelected:(UIButton*)sender {
    if (sender.tag == 1110)
    {
        //日
        _dayBtn.backgroundColor = BLUE;
        _monthBtn.backgroundColor = [UIColor clearColor];
        _yeayBtn.backgroundColor = [UIColor clearColor];
        
    }
    else if (sender.tag == 1111)
    {
        //月
        _monthBtn.backgroundColor = BLUE;
        _dayBtn.backgroundColor = [UIColor clearColor];
        _yeayBtn.backgroundColor = [UIColor clearColor];
    }
    else if (sender.tag == 1112)
    {
        //年
        _yeayBtn.backgroundColor = BLUE;
        _dayBtn.backgroundColor = [UIColor clearColor];
        _monthBtn.backgroundColor = [UIColor clearColor];
    }
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
