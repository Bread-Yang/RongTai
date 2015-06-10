//
//  UseTimeViewController.m
//  rongtai
//
//  Created by William-zhang on 15/6/10.
//  Copyright (c) 2015年 William-zhang. All rights reserved.
//

#import "UseTimeViewController.h"
#import "WLFanChart.h"

@interface UseTimeViewController ()
{
    __weak IBOutlet WLFanChart *_fanView;
      //扇形的View
    __weak IBOutlet UIView *_storeLineChartView;  //用来存放折线图的View
    __weak IBOutlet UILabel *_todayUseTime; //今日使用时长
    __weak IBOutlet UILabel *_totalUseTime;  //总计使用时长
}
@end

@implementation UseTimeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setFanView];
    // Do any additional setup after loading the view.
}

#pragma mark - 扇形数据设置
-(void)setFanView
{
    _fanView.dataSource = @[@0.33,@0.67];
    _fanView.colors = @[[UIColor redColor],[UIColor greenColor]];
    _fanView.r = _fanView.frame.size.height/4;
}



#pragma mark - 分段控制器选择时
- (IBAction)selectTime:(UISegmentedControl *)sender {
    if (sender.selectedSegmentIndex == 0)
    {
        
    }
    else if (sender.selectedSegmentIndex == 1)
    {
        
    }
    else
    {
        
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
