//
//  UserInformationViewController.m
//  rongtai
//
//  Created by William-zhang on 15/6/2.
//  Copyright (c) 2015年 William-zhang. All rights reserved.
//
#import "NSString+RT.h"

#import "UserInformationViewController.h"
#import "User.h"
#import "MBProgressHUD.h"
#import "CoreData+MagicalRecord.h"
#import "Member.h"


@interface UserInformationViewController ()<UIPickerViewDataSource, UIPickerViewDelegate>
{
    __weak IBOutlet UITextField *_name; //用户昵称TextField
    __weak IBOutlet UITextField *_height;  //身高TextField
    __weak IBOutlet UITextField *_birthday;  //生日年月TextFiled
	__weak IBOutlet UISegmentedControl *sexSegmentedControl;
	__weak IBOutlet UISegmentedControl *heightUnitSegmentedControl;
	
	UIDatePicker *_birthdayDatePicker;
	
    NSMutableArray* _heightArr;  //身高数组
    NSMutableArray* _year;       //生日年份
    NSMutableArray* _month;      //生日月份
    
    __weak IBOutlet UIView *_middleView;
    CGFloat _index; //记住编辑时传入的Index
    User* _user;
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
    _birthdayDatePicker = [[UIDatePicker alloc] initWithFrame:f];
	_birthdayDatePicker.datePickerMode = UIDatePickerModeDate;
	[_birthdayDatePicker addTarget:self action:@selector(onDatePickerValueChanged:) forControlEvents:UIControlEventValueChanged];
//    birthdayPicker.dataSource = self;
//    birthdayPicker.delegate = self;
//    birthdayPicker.tag = 1002;
//    [inputView2 addSubview:birthdayPicker];
	[inputView2 addSubview:_birthdayDatePicker];
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
        _birthday.text = [NSString stringWithFormat:@"%@/%@/",_year[yearRow],_month[monthRow]];
    }
}

#pragma mark - UIDatePicker

-(void)onDatePickerValueChanged:(UIDatePicker *)datePicker {
	NSDate *birthday = datePicker.date;
	NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
	[dateFormat setDateStyle:NSDateFormatterShortStyle];
	NSString *dateString = [dateFormat stringFromDate:birthday];
	NSLog(@"Date: %@", dateString);
	 _birthday.text = [NSString stringWithFormat:@"%@", dateString];
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
	NSString *userName = _name.text;
	if ([NSString isBlankString:userName]) {
		MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
		
		// Configure for text only and offset down
		hud.mode = MBProgressHUDModeText;
		hud.labelText = @"昵称不能为空";
		hud.margin = 10.f;
		hud.removeFromSuperViewOnHide = YES;
		
		[hud hide:YES afterDelay:1];
		return;
	}
	
	NSArray *existArray = [Member MR_findByAttribute:@"name" withValue:userName];
	
	if ([existArray count] != 0 && ![userName isEqual:_user.name]) {
		MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
		
		// Configure for text only and offset down
		hud.mode = MBProgressHUDModeText;
		hud.labelText = @"昵称已经存在";
		hud.margin = 10.f;
		hud.removeFromSuperViewOnHide = YES;
		
		[hud hide:YES afterDelay:3];
		return;
	}
	
	Member *editMember;
	//
	if ([self.title isEqual:NSLocalizedString(@"编辑信息", nil)]) {   // 编辑信息
		editMember =[Member MR_findByAttribute:@"name" withValue:_user.name][0];
	} else {													// 新增信息
		editMember = [Member MR_createEntity];
	}
	
	editMember.name = userName;
	
	editMember.sex = [NSNumber numberWithInteger:sexSegmentedControl.selectedSegmentIndex];
	
	editMember.height = [NSNumber numberWithFloat:[_height.text floatValue]];
	
	if (heightUnitSegmentedControl.selectedSegmentIndex == 0) {
		editMember.heightUnit = @"cm";
	} else {
		editMember.heightUnit = @"inch";
	}
	
	editMember.birthday = _birthdayDatePicker.date;
	
	[[NSManagedObjectContext MR_contextForCurrentThread] MR_saveToPersistentStoreAndWait];
	
	[self.navigationController popViewControllerAnimated:TRUE];
}

#pragma mark - 性别选择
- (IBAction)sexSelected:(id)sender {
}

#pragma mark - 身高单位选择
- (IBAction)heightUnitSelected:(id)sender {
}

#pragma mark - 编辑模式
-(void)editMode:(User *)user WithIndex:(NSUInteger)index
{
    _index = index;
    _user = user;
    [self upDateUI];
    self.title = NSLocalizedString(@"编辑信息", nil);
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    CGFloat height = [UIScreen mainScreen].bounds.size.height;
    UIButton* delete = [[UIButton alloc]initWithFrame:CGRectMake(width*0.325, height - height*0.15, width*0.35, height*0.06)];
    delete.backgroundColor = [UIColor colorWithRed:1 green:0 blue:0 alpha:0.6];
    [delete setTitle:NSLocalizedString(@"删除", nil) forState:UIControlStateNormal];
    [delete addTarget:self action:@selector(deleteUser:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:delete];
	
	NSArray *array = [Member MR_findByAttribute:@"name" withValue:user.name];
	if ([array count] == 1) {
		Member *editMember = array[0];
		_name.text = editMember.name;
		sexSegmentedControl.selectedSegmentIndex = [editMember.sex integerValue];
		_height.text = [editMember.height stringValue];
		if ([editMember.heightUnit isEqual:@"cm"]) {
			heightUnitSegmentedControl.selectedSegmentIndex = 0;
		} else {
			heightUnitSegmentedControl.selectedSegmentIndex = 1;
		}
		_birthdayDatePicker.date = editMember.birthday;
		
		NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
		[dateFormat setDateStyle:NSDateFormatterShortStyle];
		NSString *dateString = [dateFormat stringFromDate:editMember.birthday];
	    _birthday.text = [NSString stringWithFormat:@"%@", dateString];
	}
}

#pragma mark - 用户数据绑定在控件上
-(void)upDateUI
{
    
}

#pragma mark - 删除按钮方法
-(void)deleteUser:(id)sender
{
    if([self.delegate respondsToSelector:@selector(deleteButtonClicked:WithIndex:)])
    {
        [self.delegate deleteButtonClicked:_user WithIndex:_index];
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
