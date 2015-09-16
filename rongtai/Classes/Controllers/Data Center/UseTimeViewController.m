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
#import "MBProgressHUD.h"
#import "DataCenterViewController.h"

@interface UseTimeViewController ()
{
    __weak IBOutlet UIView *_doughnutAddView;
    
    WLDoughnutStatsView *_doughnutView;  //环形统计图
    
    __weak IBOutlet UIView *_storeLineChartView;  //用来存放折线图的View

    __weak IBOutlet UIButton *_dayBtn;
    __weak IBOutlet UIButton *_monthBtn;
    __weak IBOutlet UIButton *_yeayBtn;
    __weak IBOutlet UILabel *_usingTime;

    WLLineChart* _lineChart;  //折线图
    NSArray* _todayRecord;  //今天按摩记录
    DataRequest* _dataRequest;
    __weak DataCenterViewController* _dateCenterVC;
}
@end

@implementation UseTimeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    CGFloat h = (SCREENHEIGHT-64-50)*0.4*0.9;
    
    _doughnutView = [[WLDoughnutStatsView alloc]initWithFrame:CGRectMake(0.05*SCREENWIDTH, 0, SCREENWIDTH*0.9, SCREENHEIGHT*0.3)];
    _doughnutView.r = h/2;
    _doughnutView.doughnutWidth = _doughnutView.r*0.25;
    
    [_doughnutAddView addSubview:_doughnutView];
    
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
    
//    [self weekData:[NSDate date] From:[NSDate dateWithTimeIntervalSinceNow:0]];
//    [self monthDataByYear:2015 AndMonth:9];
//    [self yearData:2015];
    
}

-(void)setTodayRecord:(NSArray *)todayRecord AndTodayUseTime:(NSInteger)useTime
{
    _todayRecord = todayRecord;
    NSMutableArray* td = [[NSMutableArray alloc]initWithArray:todayRecord];
    //比例数组
    NSLog(@"今天按摩数据:%@",_todayRecord);
    if (_todayRecord.count>0) {
        NSLog(@"今天有按摩数据");
        NSMutableArray* percents = [NSMutableArray new];
        NSMutableArray* names = [NSMutableArray new];
        NSMutableArray* useTimes = [NSMutableArray new];
        for (int i = 0; i<td.count; i++) {
            NSDictionary* r = td[i];
            NSNumber* rID = [r objectForKey:@"massageId"];
            NSString* s = [r objectForKey:@"useTime"];
            NSInteger time = [s integerValue];
            for (int j = i+1; j<td.count; j++) {
                NSDictionary* restRecord = td[j];
                NSNumber* restID = [restRecord objectForKey:@"massageId"];
                if ([rID integerValue]==[restID integerValue]) {
                    NSString* useTime = [r objectForKey:@"useTime"];
                    time += [useTime integerValue];
                    [td removeObject:restRecord];
                    j--;
                }
            }
            
            float percent = time/(float)useTime;
            NSNumber* num = [NSNumber numberWithFloat:percent];
            [percents addObject:num];
            
            NSString* ut;
            if (time>60) {
                int h = time/60;
                int m = time%60;
                ut = [NSString stringWithFormat:@"%dh%dm",h,m];
            }
            else
            {
                ut = [NSString stringWithFormat:@"%lum",time];
            }
            [useTimes addObject:ut];
            
            NSString* name = [r objectForKey:@"name"];
            [names addObject:name];
        }
        _doughnutView.percents = [NSArray arrayWithArray:percents];
        _doughnutView.makersName = [NSArray arrayWithArray:names];
        _doughnutView.makersDescription = [NSArray arrayWithArray:useTimes];
        
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
            else
            {
                _usingTime.text = [NSString stringWithFormat:@"%ldm",(unsigned long)useTime];
            }
        }
        [_usingTime setNumebrByFont:[UIFont fontWithName:@"Helvetica" size:20*HSCALE] Color:BLUE];
    }
    else
    {
        NSLog(@"今天没有按摩数据");
        //今天暂时没使用该app进行按摩
        _doughnutView.percents = @[@1];
        _usingTime.text= @"今天未使用该APP";
    }
}

-(void)setWeekData:(NSArray*)weekRecords ByDataCenterVC:(DataCenterViewController*)dataCenterVC
{
    NSDateFormatter* formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"YYYY-MM-dd"];
    
    NSDateFormatter* shortFormatter = [[NSDateFormatter alloc]init];
    [shortFormatter setDateFormat:@"M.d"];
    
    NSMutableArray* xValue = [NSMutableArray new];
    NSMutableArray* points = [NSMutableArray new];
    NSMutableArray* records = [NSMutableArray arrayWithArray:weekRecords];
    NSDate* now = [NSDate date];
    for (int i = 0; i<7; i++) {
        NSDate* date = [NSDate dateWithTimeInterval:-24*3600*(6-i) sinceDate:now];
        NSString* dateStr = [formatter stringFromDate:date];
        NSUInteger useTime = 0;
        for (int j = 0; j<records.count; j++) {
            NSDictionary* dic = records[j];
            if ([dateStr isEqualToString:[dic objectForKey:@"useDate"]]) {
                NSUInteger time = [[dic objectForKey:@"useTime"] integerValue];
                useTime += time;
                [records removeObject:dic];
            }
        }
        [xValue addObject:[shortFormatter stringFromDate:date]];
        //计算各个点的坐标
        [points addObject:[NSValue valueWithCGPoint:CGPointMake(20*i, useTime)]];
    }
    
    _lineChart.xValues = xValue;
    _lineChart.points = points;
    //由于x轴是日期，需要数值来代表各个点的x坐标，固以20为间距，有7个点，最大值为120
    _lineChart.xSection = CGPointMake(0, 120);
    
    _lineChart.yValues = @[@"0",@"2",@"4",@"6",@"8"];
    _lineChart.ySection = CGPointMake(0, 8*60);
    
    _dateCenterVC = dataCenterVC;
}

#pragma mark - 底部年月日按钮
- (IBAction)dateSelected:(UIButton*)sender {
    NSDate* now = [NSDate date];
    if (sender.tag == 1110)
    {
        //日
        _dayBtn.backgroundColor = BLUE;
        _monthBtn.backgroundColor = [UIColor clearColor];
        _yeayBtn.backgroundColor = [UIColor clearColor];
        NSDate* weekAgo = [NSDate dateWithTimeIntervalSinceNow:-24*2600*6];
        [self weekData:now From:weekAgo];
        
    }
    else if (sender.tag == 1111)
    {
        //月
        _monthBtn.backgroundColor = BLUE;
        _dayBtn.backgroundColor = [UIColor clearColor];
        _yeayBtn.backgroundColor = [UIColor clearColor];
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSDateComponents *dateComponent = [calendar components:NSCalendarUnitMonth|NSCalendarUnitYear fromDate:now];
        [self monthDataByYear:[dateComponent year] AndMonth:[dateComponent month]];
    }
    else if (sender.tag == 1112)
    {
        //年
        _yeayBtn.backgroundColor = BLUE;
        _dayBtn.backgroundColor = [UIColor clearColor];
        _monthBtn.backgroundColor = [UIColor clearColor];
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSDateComponents *dateComponent = [calendar components:NSCalendarUnitYear fromDate:now];
        [self yearData:[dateComponent year]];
    }
}

#pragma mark - 查询一周数据
-(void)weekData:(NSDate*)date1 From:(NSDate*)date2
{
    [_dateCenterVC showHUD];
    NSDateFormatter* formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"YYYY-MM-dd"];
    
    NSDateFormatter* shortFormatter = [[NSDateFormatter alloc]init];
    [shortFormatter setDateFormat:@"M.d"];
    
    NSMutableArray* xValue = [NSMutableArray new];
    NSMutableArray* points = [NSMutableArray new];
    
    [_dataRequest getMassageRecordFrom:date1 To:date2 Success:^(NSArray *arr) {
        NSLog(@"数据请求成功🆚");
        NSMutableArray* records = [NSMutableArray arrayWithArray:arr];
//        NSUInteger max = 0;
//        NSUInteger min = INT64_MAX;
        
        for (int i = 0; i<7; i++) {
            NSDate* date = [NSDate dateWithTimeInterval:-24*3600*(6-i) sinceDate:date1];
            NSString* dateStr = [formatter stringFromDate:date];
            NSUInteger useTime = 0;
            for (int j = 0; j<records.count; j++) {
                NSDictionary* dic = records[j];
                if ([dateStr isEqualToString:[dic objectForKey:@"useDate"]]) {
                    NSUInteger time = [[dic objectForKey:@"useTime"] integerValue];
                    useTime += time;
                    [records removeObject:dic];
                }
            }
            
            //计算使用时间的最大值，最小值，以确定y轴数值的范围
//            if (useTime < min) {
//                min = useTime;
//            }
//            
//            if (useTime > max) {
//                max = useTime;
//            }
            //把日期作为x轴数据源
            [xValue addObject:[shortFormatter stringFromDate:date]];
            //计算各个点的坐标
            [points addObject:[NSValue valueWithCGPoint:CGPointMake(20*i, useTime)]];
        }
        
        _lineChart.xValues = xValue;
        _lineChart.points = points;
        //由于x轴是日期，需要数值来代表各个点的x坐标，固以20为间距，有7个点，最大值为120
        _lineChart.xSection = CGPointMake(0, 120);
       
        _lineChart.yValues = @[@"0",@"2",@"4",@"6",@"8"];
        _lineChart.ySection = CGPointMake(0, 8*60);
        [_dateCenterVC hideHUD];
        
    } fail:^(NSDictionary *dic) {
        NSLog(@"数据请求失败🆚");
        [_dateCenterVC hideHUD];
        [_dateCenterVC showProgressHUDByString:@"读取数据失败，请检测网络"];
    }];
}

#pragma mark - 查询一个月数据
-(void)monthDataByYear:(NSUInteger)year AndMonth:(NSUInteger)month
{
    [_dateCenterVC showHUD];
//    NSLog(@"年：%ld,月：%ld",year,month);
    NSDateFormatter* formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"YYYY-MM-dd"];
    
    NSDate* date1 = [formatter dateFromString:[NSString stringWithFormat:@"%lu-%lu-01",(unsigned long)year,(unsigned long)month]];
    NSCalendar *c = [NSCalendar currentCalendar];
    NSRange days = [c rangeOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitMonth forDate:date1];
    
    NSDate* date2 = [formatter dateFromString:[NSString stringWithFormat:@"%lu-%lu-%lu",(unsigned long)year,(unsigned long)month,(unsigned long)days.length]];
    
    NSMutableArray* xValue = [NSMutableArray new];
    NSMutableArray* points = [NSMutableArray new];
    
    NSLog(@"date1:%@,date2:%@",date1,date2);
    [_dataRequest getMassageRecordFrom:date1 To:date2 Success:^(NSArray *arr) {
        NSLog(@"数据请求成功🆚");
        NSMutableArray* records = [NSMutableArray arrayWithArray:arr];
//        NSUInteger max = 0;
//        NSUInteger min = INT64_MAX;
        
        for(int i = 0;i<7;i++)
        {
            //把日期作为x轴数据源
            int day = 1+i*5;
            if (day>=days.length) {
                [xValue addObject:[NSString stringWithFormat:@"%lu.%lu",(unsigned long)month,(unsigned long)days.length]];
                break;
            }
            [xValue addObject:[NSString stringWithFormat:@"%lu.%d",(unsigned long)month,day]];
        }
        NSLog(@"月份xValues:%@",xValue);
        
        
        for (int i = 0; i<26; i++) {
            NSDate* date = [NSDate dateWithTimeInterval:24*3600*i sinceDate:date1];
            NSString* dateStr = [formatter stringFromDate:date];
            NSUInteger useTime = 0;
            for (int j = 0; j<records.count; j++) {
                NSDictionary* dic = records[j];
                if ([dateStr isEqualToString:[dic objectForKey:@"useDate"]]) {
                    NSUInteger time = [[dic objectForKey:@"useTime"] integerValue];
                    useTime += time;
                    [records removeObject:dic];
                }
            }
            
            //计算各个点的坐标
            [points addObject:[NSValue valueWithCGPoint:CGPointMake(4*i, useTime)]];
        }
        
        float dlt =  20.0/(days.length - 26);
        
        for (int i = 26; i<days.length; i++) {
            NSDate* date = [NSDate dateWithTimeInterval:24*3600*i sinceDate:date1];
            NSString* dateStr = [formatter stringFromDate:date];
            NSUInteger useTime = 0;
            for (int j = 0; j<records.count; j++) {
                NSDictionary* dic = records[j];
                if ([dateStr isEqualToString:[dic objectForKey:@"useDate"]]) {
                    NSUInteger time = [[dic objectForKey:@"useTime"] integerValue];
                    useTime += time;
                    [records removeObject:dic];
                }
            }
            //计算各个点的坐标
            [points addObject:[NSValue valueWithCGPoint:CGPointMake(100+dlt*(i-25), useTime)]];
        }
        
        _lineChart.xValues = xValue;
        _lineChart.points = points;
        NSLog(@"Points:%@",points);
        //由于x轴是日期，需要数值来代表各个点的x坐标，固以20为间距，有7个点，最大值为120
        _lineChart.xSection = CGPointMake(0, 120);
        
        _lineChart.yValues = @[@"0",@"2",@"4",@"6",@"8"];
        _lineChart.ySection = CGPointMake(0, 8*60);
        [_dateCenterVC hideHUD];
    } fail:^(NSDictionary *dic) {
        NSLog(@"数据请求失败🆚");
        [_dateCenterVC hideHUD];
        [_dateCenterVC showProgressHUDByString:@"读取数据失败，请检测网络"];
    }];
}

#pragma mark - 查询一年的数据
-(void)yearData:(NSUInteger)year
{
    [_dateCenterVC showHUD];
    NSDateFormatter* formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"YYYY-MM-dd"];
    
    NSDate* date1 = [formatter dateFromString:[NSString stringWithFormat:@"%lu-01-01",(unsigned long)year]];

    NSDate* date2 = [formatter dateFromString:[NSString stringWithFormat:@"%lu-12-31",(unsigned long)year]];
    
    NSMutableArray* xValue = [NSMutableArray new];
    NSMutableArray* points = [NSMutableArray new];
    
    NSLog(@"date1:%@,date2:%@",date1,date2);
    [_dataRequest getMassageRecordFrom:date1 To:date2 Success:^(NSArray *arr) {
        NSLog(@"数据请求成功🆚");
        NSMutableArray* records = [NSMutableArray arrayWithArray:arr];
//        NSUInteger max = 0;
//        NSUInteger min = INT64_MAX;
        NSCalendar *calendar = [NSCalendar currentCalendar];
        
        for(int i = 0;i<12;i++)
        {
            NSUInteger useTime = 0;
            for (int j = 0; j<records.count; j++) {
                NSDictionary* dic = records[j];
                NSString* mDateString = [dic objectForKey:@"useDate"];
                NSDate* mDate = [formatter dateFromString:mDateString];
                NSDateComponents *dateComponent = [calendar components:NSCalendarUnitMonth fromDate:mDate];
                
                if ([dateComponent month] == i+1) {
                    NSUInteger time = [[dic objectForKey:@"useTime"] integerValue];
                    useTime += time;
                    [records removeObject:dic];
                }
            }
            
            //计算各个点的坐标
            [points addObject:[NSValue valueWithCGPoint:CGPointMake(10*i, useTime)]];
            
            //把月份作为x轴数据源
            [xValue addObject:[NSString stringWithFormat:@"%d",i+1]];
        }
        NSLog(@"月份xValues:%@",xValue);
        
        _lineChart.xValues = xValue;
        _lineChart.points = points;
        NSLog(@"Points:%@",points);
        //由于x轴是月份，需要数值来代表各个点的x坐标，固以10为间距，有12个点，最大值为110
        _lineChart.xSection = CGPointMake(0, 110);
    
        _lineChart.yValues = @[@"0",@"2",@"4",@"6",@"8"];
        _lineChart.ySection = CGPointMake(0, 8*60);
        [_dateCenterVC hideHUD];
    } fail:^(NSDictionary *dic) {
        NSLog(@"数据请求失败🆚");
        [_dateCenterVC hideHUD];
        [_dateCenterVC showProgressHUDByString:@"读取数据失败，请检测网络"];
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

@end
