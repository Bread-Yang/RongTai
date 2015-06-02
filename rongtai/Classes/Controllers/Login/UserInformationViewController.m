//
//  UserInformationViewController.m
//  rongtai
//
//  Created by William-zhang on 15/6/2.
//  Copyright (c) 2015年 William-zhang. All rights reserved.
//


#import "UserInformationViewController.h"

@interface UserInformationViewController ()<UIPickerViewDataSource, UIPickerViewDelegate>
{
    __weak IBOutlet UITextField *_name; //用户昵称TextField
    __weak IBOutlet UITextField *_height;  //身高TextField
    __weak IBOutlet UITextField *_birthday;  //生日年月TextFiled
    NSMutableArray* _heightArr;  //身高数组
    NSMutableArray* _year;       //生日年份
    NSMutableArray* _month;      //生日月份
    
    __weak IBOutlet UIView *_middleView;
}
@end

@implementation UserInformationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //由于是storyboard创建，身高的TextField比生日TextField跟晚加进View里面，导致使用IQKeyBoardManager时跳转顺序被打乱了
    [_middleView bringSubviewToFront:_birthday];
//    NSLog(@"%@",_middleView.subviews);
    
    //身高数组：范围为100~250cm
    _heightArr = [NSMutableArray new];
    for (int i = 100; i < 250; i++) {
        [_heightArr addObject:[NSString stringWithFormat:@"%d",i]];
    }
    
    //年份数组：现在年份倒推90年
    _year = [NSMutableArray new];
    NSDate* now = [NSDate date];
    NSDateComponents* components = [[NSCalendar currentCalendar] components:NSCalendarUnitYear fromDate:now];
    for (int i = components.year-90; i<components.year; i++) {
        [_year addObject:[NSString stringWithFormat:@"%d",i]];
    }
    
    //月份数组
    _month = [NSMutableArray new];
    for (int i = 1; i < 13; i++) {
        [_month addObject:[NSString stringWithFormat:@"%d",i]];
    }
    
    CGRect f = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 216);
    
    //改写_hegiht的键盘为身高选择器
    UIView* inputView = [[UIView alloc]initWithFrame:f];
    inputView.backgroundColor = [UIColor whiteColor];
    UIPickerView* heightPicker = [[UIPickerView alloc]initWithFrame:f];
    heightPicker.dataSource = self;
    heightPicker.delegate = self;
    heightPicker.tag = 1001;
    [inputView addSubview:heightPicker];
    _height.inputView = inputView;
    
    //改写_birthday的键盘为年月选择器
    UIView* inputView2 = [[UIView alloc]initWithFrame:f];
    inputView2.backgroundColor = [UIColor whiteColor];
    UIPickerView* birthdayPicker = [[UIPickerView alloc]initWithFrame:f];
    birthdayPicker.dataSource = self;
    birthdayPicker.delegate = self;
    birthdayPicker.tag = 1002;
    [inputView2 addSubview:birthdayPicker];
    _birthday.inputView = inputView2;
    
    // Do any additional setup after loading the view.
}

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    if (pickerView.tag == 1001) {
        return 1;
    }
    else
    {
        return 2;
    }
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (pickerView.tag == 1001) {
        return _heightArr.count;
    }
    else
    {
        if (component == 0) {
            return _year.count;
        }
        else
        {
            return _month.count;
        }
    }
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if (pickerView.tag == 1001) {
        return _heightArr[row];
    }
    else
    {
        if (component == 0) {
            return _year[row];
        }
        else
        {
            return _month[row];
        }
    }
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if (pickerView.tag == 1001) {
        _height.text = _heightArr[row];
    }
    else
    {
        NSInteger yearRow = [pickerView selectedRowInComponent:0];
        NSInteger monthRow = [pickerView selectedRowInComponent:1];
        _birthday.text = [NSString stringWithFormat:@"%@年%@月",_year[yearRow],_month[monthRow]];
    }
}

#pragma mark - 头像按钮方法
- (IBAction)selectUserIcon:(id)sender {
}


#pragma mark - 返回按钮方法
- (IBAction)goback:(id)sender {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - 保存信息按钮方法
- (IBAction)save:(id)sender {
}

#pragma mark - 性别选择
- (IBAction)sexSelected:(id)sender {
}

#pragma mark - 身高单位选择
- (IBAction)heightUnitSelected:(id)sender {
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
