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
#import "MassageTime.h"
#import "DataRequest.h"

@interface UseTimeViewController ()
{
    __weak IBOutlet WLDoughnutStatsView *_doughnutView;   //环形统计图
    
    __weak IBOutlet UIView *_storeLineChartView;  //用来存放折线图的View

    __weak IBOutlet UIButton *_dayBtn;
    __weak IBOutlet UIButton *_monthBtn;
    __weak IBOutlet UIButton *_yeayBtn;
    __weak IBOutlet UILabel *_usingTime;

    WLLineChart* _lineChart;  //折线图
    NSArray* _todayRecord;  //今天按摩记录
    DataRequest* _dataRequest;
}
@end

@implementation UseTimeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    CGFloat h = (SCREENHEIGHT-64-50)*0.4*0.9;
    
    _doughnutView.r = h/2;
    _doughnutView.doughnutWidth = _doughnutView.r*0.25;
    
    _lineChart = [[WLLineChart alloc]initWithFrame:CGRectMake(0.05*SCREENWIDTH, 0.15*h, 0.9*SCREENWIDTH, 0.9*h)];
    _lineChart.showXRuler = NO;
    _lineChart.isPointDashed = NO;
    _lineChart.lineColor = BLUE;
    _lineChart.rulerColor = [UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:0.5];
    _lineChart.xAxisHidden = YES;
    _lineChart.yAxisHidden = YES;
    _lineChart.yUnit = @"(h)";
//    _lineChart.xUnit = @"(Day)";
    _lineChart.yValueFont = [UIFont systemFontOfSize:11];
    _lineChart.yUnitFont = [UIFont systemFontOfSize:11];
    _lineChart.xValueFont = [UIFont systemFontOfSize:11];
    _lineChart.xUnitFont = [UIFont systemFontOfSize:11];
    [_storeLineChartView addSubview:_lineChart];
    
    _usingTime.font = [UIFont fontWithName:@"Helvetica" size:10*HSCALE];
    [_usingTime setNumebrByFont:[UIFont fontWithName:@"Helvetica" size:20*HSCALE] Color:BLUE];
    _dataRequest = [DataRequest new];
    [self weekData];
}

-(void)setTodayRecord:(NSArray *)todayRecord AndTodayUseTime:(NSInteger)useTime
{
    _todayRecord = todayRecord;
    //比例数组
    if (_todayRecord.count>0) {
        NSMutableArray* percents = [NSMutableArray new];
        for (int i = 0; i<_todayRecord.count; i++) {
            NSDictionary* r = _todayRecord[i];
            NSString* s = [r objectForKey:@"useTime"];
            float percent = [s integerValue]/(float)useTime;
            NSNumber* num = [NSNumber numberWithFloat:percent];
            [percents addObject:num];
        }
        _doughnutView.percents = [NSArray arrayWithArray:percents];
        
        //设置文字
        if (useTime>60) {
            NSUInteger h = useTime/60;
            NSUInteger m = useTime%60;
            _usingTime.text = [NSString stringWithFormat:@"%ldh%ldm",(unsigned long)h,(unsigned long)m];
        }
        else if(useTime<=60 && useTime>0)
        {
            if (useTime == 60) {
                _usingTime.text = @"1h";
            }
            else if (useTime >0)
            {
                _usingTime.text = [NSString stringWithFormat:@"%ldm",(unsigned long)useTime];
            }
        }
        [_usingTime setNumebrByFont:[UIFont fontWithName:@"Helvetica" size:20*HSCALE] Color:BLUE];
    }
    else
    {
        //今天暂时没使用该app进行按摩
        _doughnutView.percents = @[@1];
        _usingTime.text= @"今天未使用该APP";
    }
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

#pragma mark - 查询一周数据
-(void)weekData
{
    NSDate* now = [NSDate date];
    NSDateFormatter* formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"YYYY-MM-dd"];
    
    NSDateFormatter* shortFormatter = [[NSDateFormatter alloc]init];
    [shortFormatter setDateFormat:@"M.d"];
    
    NSMutableArray* xValue = [NSMutableArray new];
    NSMutableArray* points = [NSMutableArray new];
    
    [_dataRequest getMassageRecordFrom:[NSDate date] To:[NSDate dateWithTimeIntervalSinceNow:-24*3600*7] Success:^(NSArray *arr) {
        NSMutableArray* records = [NSMutableArray arrayWithArray:arr];
        NSUInteger max = 0;
        NSUInteger min = INT64_MAX;
        for (int i = 0; i<7; i++) {
            NSDate* date = [NSDate dateWithTimeInterval:-24*3600*(6-i) sinceDate:now];
            NSString* dateStr = [formatter stringFromDate:date];
            NSUInteger useTime = 0;
            for (int i = 0; i<records.count; i++) {
                NSDictionary* dic = records[i];
                if ([dateStr isEqualToString:[dic objectForKey:@"useDate"]]) {
                    NSUInteger time = [[dic objectForKey:@"useTime"] integerValue];
                    useTime += time;
                    [records removeObject:dic];
                }
            }
            
            //计算使用时间的最大值，最小值，以确定y轴数值的范围
            if (useTime < min) {
                min = useTime;
            }
            
            if (useTime > max) {
                max = useTime;
            }
            //把日期作为x轴数据源
            [xValue addObject:[shortFormatter stringFromDate:date]];
            //计算各个点的坐标
            [points addObject:[NSValue valueWithCGPoint:CGPointMake(20*i, useTime)]];
        }
        
        _lineChart.xValues = [[xValue reverseObjectEnumerator] allObjects];
        _lineChart.points = [[points reverseObjectEnumerator] allObjects];
        //由于x轴是日期，需要数值来代表各个点的x坐标，固以20为间距，有7个点，最大值为120
        _lineChart.xSection = CGPointMake(0, 120);
        if (max == 0) {
            //如果最大值是零，说明所有数据的使用时间都是0，即这7天都是没有使用才app进行按摩
            _lineChart.yValues = @[@"0",@"2",@"4",@"6",@"8"];
            _lineChart.ySection = CGPointMake(0, 8*60);
        }
        else
        {
            //max不小于0则需要计算出y的取值区间
            NSMutableArray* yValues = [NSMutableArray new];
            NSUInteger maxH = max/60;
            NSUInteger minH = min/60;
            NSUInteger step = maxH/4;
            if (maxH%4 > 0) {
                step++;
            }
            for (int i = 0; i<5; i++) {
                [yValues addObject:[NSString stringWithFormat:@"%lu",minH+i*step]];
            }
            _lineChart.yValues = yValues;
            _lineChart.ySection = CGPointMake(minH*60, (minH+5*step)*60);
        }
    } fail:^(NSDictionary *dic) {
        
    }];
    

//    for (int i = 0; i<7; i++) {
//        //今天起往前数7天的数据
//        NSDate* date = [NSDate dateWithTimeInterval:-24*60*60*i sinceDate:now];
//        NSString* dateStr = [formatter stringFromDate:date];
//        NSArray* arr = [MassageRecord MR_findByAttribute:@"useDate" withValue:dateStr];
//        NSUInteger useTime = 0;
//        //计算第i天的使用总时间
//        for (MassageRecord * r in arr) {
//            useTime += [r.useTime integerValue];
//        }
//        
//        //计算使用时间的最大值，最小值，以确定y轴数值的范围
////        if (useTime < min) {
////            min = useTime;
////        }
////        
////        if (useTime > max) {
////            max = useTime;
////        }
//        
//        //把日期作为x轴数据源
//        [xValue addObject:[shortFormatter stringFromDate:date]];
//        //计算各个点的坐标
//        [points addObject:[NSValue valueWithCGPoint:CGPointMake(20*(6-i), useTime)]];
//    }
//    xValue = (NSMutableArray*)[[xValue reverseObjectEnumerator] allObjects];
//    points = (NSMutableArray*)[[points reverseObjectEnumerator] allObjects];
//    _lineChart.xValues = [[xValue reverseObjectEnumerator] allObjects];
//    _lineChart.points = [[points reverseObjectEnumerator] allObjects];
//    //由于x轴是日期，需要数值来代表各个点的x坐标，固以20为间距，有7个点，最大值为120
//    _lineChart.xSection = CGPointMake(0, 120);
//    if (max == 0) {
//        //如果最大值是零，说明所有数据的使用时间都是0，即这7天都是没有使用才app进行按摩
//        _lineChart.yValues = @[@"0",@"2",@"4",@"6",@"8"];
//        _lineChart.ySection = CGPointMake(0, 8*60);
//    }
//    else
//    {
//        //max不小于0则需要计算出y的取值区间
//        NSMutableArray* yValues = [NSMutableArray new];
//        NSUInteger maxH = max/60;
//        NSUInteger minH = min/60;
//        NSUInteger step = maxH/4;
//        if (maxH%4 > 0) {
//            step++;
//        }
//        for (int i = 0; i<5; i++) {
//            [yValues addObject:[NSString stringWithFormat:@"%lu",minH+i*step]];
//        }
//        _lineChart.yValues = yValues;
//        _lineChart.ySection = CGPointMake(minH*60, (minH+5*step)*60);
//    }
}

#pragma mark - 查询一个月数据
-(void)monthData
{
    
}

#pragma mark - 查询一年的数据
-(void)yearData
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
