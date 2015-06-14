//
//  PowerConsumeViewController.m
//  rongtai
//
//  Created by William-zhang on 15/6/10.
//  Copyright (c) 2015年 William-zhang. All rights reserved.
//

#import "PowerConsumeViewController.h"

@interface PowerConsumeViewController ()
{
    __weak IBOutlet UILabel *_ygdf;
}

@end

@implementation PowerConsumeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
   //    NSLog(@"%@",NSStringFromCGRect(_ygdf.frame));
    // Do any additional setup after loading the view.
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    NSLog(@"耗电量：%@",NSStringFromCGRect(_ygdf.frame));
    _ygdf.adjustsFontSizeToFitWidth = YES;
    _ygdf.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
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
