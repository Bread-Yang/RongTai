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
#import "AFHTTPRequestOperationManager.h"
#import "RongTaiConstant.h"
#import "UIImage+ImageBlur.h"


@interface UserInformationViewController ()<UIPickerViewDataSource, UIPickerViewDelegate,UIImagePickerControllerDelegate, UINavigationControllerDelegate> {
    __weak IBOutlet UITextField *_name; //用户昵称TextField
    __weak IBOutlet UITextField *_height;  //身高TextField
    __weak IBOutlet UITextField *_birthday;  //生日年月TextFiled
	__weak IBOutlet UISegmentedControl *sexSegmentedControl;
	__weak IBOutlet UISegmentedControl *heightUnitSegmentedControl;
    __weak IBOutlet UIButton *_userIcon;
    __weak IBOutlet UIImageView *_bgImageView;
	
	UIDatePicker *_birthdayDatePicker;
    NSMutableArray* _heightArr;  //身高数组
    
    __weak IBOutlet UIView *_middleView;
    CGFloat _index; //记住编辑时传入的Index
    User* _user;
    UIImage* _userImage;  //用户头像
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
	[inputView2 addSubview:_birthdayDatePicker];
    _birthday.inputView = inputView2;
    
    //头像按钮设置白色边框
    _userIcon.layer.borderColor = [UIColor whiteColor].CGColor;
    _userIcon.layer.borderWidth = 4;
    _userIcon.layer.cornerRadius = 0.125*[UIScreen mainScreen].bounds.size.width;
    
    //默认头像
    _userImage = [UIImage imageNamed:@"userDefaultIcon.jpg"];
    [_userIcon setImage:_userImage forState:UIControlStateNormal];
    _userIcon.clipsToBounds = YES;
    
    _bgImageView.contentMode = UIViewContentModeScaleAspectFill;
    _bgImageView.image = [_userImage blurImage:15.0];
    
    // Do any additional setup after loading the view.
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return _heightArr.count;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return _heightArr[row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    _height.text = _heightArr[row];
}

#pragma mark - UIDatePicker

- (void)onDatePickerValueChanged:(UIDatePicker *)datePicker {
	NSDate *birthday = datePicker.date;
	NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
	[dateFormat setDateFormat:@"yyyy/MM/dd"];
	NSString *dateString = [dateFormat stringFromDate:birthday];
	 _birthday.text = [NSString stringWithFormat:@"%@", dateString];
}

#pragma mark - 头像按钮方法
- (IBAction)selectUserIcon:(id)sender {
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum]) {
        UIImagePickerController* picker = [[UIImagePickerController alloc]init];
        [picker setSourceType:UIImagePickerControllerSourceTypeSavedPhotosAlbum];
        [picker setAllowsEditing:YES];
        picker.delegate = self;
        [self presentViewController:picker animated:YES completion:nil];
    }
	else
    {
        NSLog(@"访问相册失败");
    }
}

#pragma mark - 照相机按钮点击方法
- (IBAction)cameraClick:(id)sender {
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        UIImagePickerController* picker = [[UIImagePickerController alloc]init];
        [picker setSourceType:UIImagePickerControllerSourceTypeCamera];
        [picker setAllowsEditing:YES];
        picker.delegate = self;
        [self presentViewController:picker animated:YES completion:nil];
    }
    else
    {
        NSLog(@"访问相机失败");
    }

}

#pragma mark - UIImagePickerController代理实现
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    _userImage = [info objectForKey:@"UIImagePickerControllerEditedImage"];
    
    [_userIcon setImage:_userImage forState:UIControlStateNormal];
    _bgImageView.image = [_userImage blurImage:15.0];
    [self dismissViewControllerAnimated:YES completion:nil];
    
    //照片保存到本地
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString* doc = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
        NSString* path = [doc stringByAppendingString:@"/userIcon.png"];
        NSLog(@"头像路径:%@",path);
        NSData* data = UIImagePNGRepresentation(_userImage);
        [data writeToFile:path atomically:YES];
    });
    
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
	
	NSString *requestURL;
	
	if ([self.title isEqual:NSLocalizedString(@"编辑信息", nil)]) {   // 编辑信息
		requestURL = [RongTaiDefaultDomain stringByAppendingString:@"updateMember"];
	} else {													// 新增信息
		requestURL = [RongTaiDefaultDomain stringByAppendingString:@"addMember"];
	}
	
	NSString *heightUnit;
	if (heightUnitSegmentedControl.selectedSegmentIndex == 0) {
		heightUnit = @"cm";
	} else {
		heightUnit = @"inch";
	}
	
	NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
	[dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
	NSString *dateString = [dateFormat stringFromDate:_birthdayDatePicker.date];
	
	NSDictionary *parameters = @{@"uid" : @"15521377721",
								 @"name" : [userName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]],
								 @"sex" : [NSString stringWithFormat:@"%i", (int)sexSegmentedControl.selectedSegmentIndex],
								 @"height" : [NSString stringWithFormat:@"%i", [_height.text intValue]],
								 @"heightUnit" : heightUnit,
								 @"imageUrl" : @"http://hiphotos.baidu.com/zhixin/abpic/item/ca5257540923dd541500adbfd309b3de9d8248b2.jpg",
								 @"birthday" : dateString,
								 };
	
	NSLog(@"提交的json数据是 : %@", parameters);
	
	// 服务器提交
	AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
//	manager.responseSerializer = [AFJSONResponseSerializer serializer];
	manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
	
	[manager POST:requestURL parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSLog(@"Success Submit return json : %@", responseObject);
		[self.navigationController popViewControllerAnimated:TRUE];
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		NSLog(@"Error: %@", error);
		
		MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
		
		// Configure for text only and offset down
		hud.mode = MBProgressHUDModeText;
		hud.labelText = @"增加成员失败";
		hud.margin = 10.f;
		hud.removeFromSuperViewOnHide = YES;
		
		[hud hide:YES afterDelay:3];
	}];
	
	// 下面是本地数据库提交
	
//	Member *editMember;
//	
//	if ([self.title isEqual:NSLocalizedString(@"编辑信息", nil)]) {   // 编辑信息
//		editMember =[Member MR_findByAttribute:@"name" withValue:_user.name][0];
//	} else {													// 新增信息
//		editMember = [Member MR_createEntity];
//	}
//	
//	editMember.name = userName;
//	
//	editMember.sex = [NSNumber numberWithInteger:sexSegmentedControl.selectedSegmentIndex];
//	
//	editMember.height = [NSNumber numberWithFloat:[_height.text floatValue]];
//	
//	if (heightUnitSegmentedControl.selectedSegmentIndex == 0) {
//		editMember.heightUnit = @"cm";
//	} else {
//		editMember.heightUnit = @"inch";
//	}
//	
//	editMember.birthday = _birthdayDatePicker.date;
//	
//	[[NSManagedObjectContext MR_contextForCurrentThread] MR_saveToPersistentStoreAndWait];
}

#pragma mark - 性别选择
- (IBAction)sexSelected:(id)sender {
}

#pragma mark - 身高单位选择
- (IBAction)heightUnitSelected:(id)sender {
}

#pragma mark - 编辑模式
- (void)setEditUserInformation:(NSDictionary *)infoDictionary {
	self.title = NSLocalizedString(@"编辑信息", nil);
	CGFloat width = [UIScreen mainScreen].bounds.size.width;
	CGFloat height = [UIScreen mainScreen].bounds.size.height;
	UIButton *delete = [[UIButton alloc]initWithFrame:CGRectMake(width*0.325, height - height * 0.15, width * 0.35, height * 0.06)];
	delete.backgroundColor = [UIColor colorWithRed:1 green:0 blue:0 alpha:0.6];
	[delete setTitle:NSLocalizedString(@"删除", nil) forState:UIControlStateNormal];
	[delete addTarget:self action:@selector(deleteUser:) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:delete];
	
    
	_name.text = infoDictionary[@"name"];
	sexSegmentedControl.selectedSegmentIndex = [infoDictionary[@"sex"] integerValue];
	_height.text = infoDictionary[@"height"];
	if ([infoDictionary[@"heightUnit"] isEqualToString:@"cm"]) {
		heightUnitSegmentedControl.selectedSegmentIndex = 0;
	} else {
		heightUnitSegmentedControl.selectedSegmentIndex = 1;
	}
	NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init] ;
	[dateFormat setDateFormat:@"yyyy/MM/dd HH:mm:ss"];
	NSDate *date = [dateFormat dateFromString:infoDictionary[@"birthday"]];
	_birthdayDatePicker.date = date;
	
	[dateFormat setDateFormat:@"yyyy/MM/dd"];
	_birthday.text = [dateFormat stringFromDate:date];
								   
	//		_name.text = editMember.name;
	//		sexSegmentedControl.selectedSegmentIndex = [editMember.sex integerValue];
	//		_height.text = [editMember.height stringValue];
	//		if ([editMember.heightUnit isEqual:@"cm"]) {
	//			heightUnitSegmentedControl.selectedSegmentIndex = 0;
	//		} else {
	//			heightUnitSegmentedControl.selectedSegmentIndex = 1;
	//		}
	//		_birthdayDatePicker.date = editMember.birthday;
	//
	//		NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
	//		[dateFormat setDateStyle:NSDateFormatterShortStyle];
	//		NSString *dateString = [dateFormat stringFromDate:editMember.birthday];
	//	    _birthday.text = [NSString stringWithFormat:@"%@", dateString];
	
}

- (void)editMode:(User *)user WithIndex:(NSUInteger)index {
    _index = index;
    _user = user;
    [self upDateUI];
    self.title = NSLocalizedString(@"编辑信息", nil);
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    CGFloat height = [UIScreen mainScreen].bounds.size.height;
    UIButton *delete = [[UIButton alloc]initWithFrame:CGRectMake(width*0.325, height - height * 0.15, width * 0.35, height * 0.06)];
    delete.backgroundColor = [UIColor colorWithRed:1 green:0 blue:0 alpha:0.6];
    [delete setTitle:NSLocalizedString(@"删除", nil) forState:UIControlStateNormal];
    [delete addTarget:self action:@selector(deleteUser:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:delete];
	
    
	// 本地数据库操作
//	NSArray *array = [Member MR_findByAttribute:@"name" withValue:user.name];
//	if ([array count] == 1) {
//		Member *editMember = array[0];
//		_name.text = editMember.name;
//		sexSegmentedControl.selectedSegmentIndex = [editMember.sex integerValue];
//		_height.text = [editMember.height stringValue];
//		if ([editMember.heightUnit isEqual:@"cm"]) {
//			heightUnitSegmentedControl.selectedSegmentIndex = 0;
//		} else {
//			heightUnitSegmentedControl.selectedSegmentIndex = 1;
//		}
//		_birthdayDatePicker.date = editMember.birthday;
//		
//		NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
//		[dateFormat setDateStyle:NSDateFormatterShortStyle];
//		NSString *dateString = [dateFormat stringFromDate:editMember.birthday];
//	    _birthday.text = [NSString stringWithFormat:@"%@", dateString];
//	}
}

#pragma mark - 用户数据绑定在控件上

-(void)upDateUI {
    
}

#pragma mark - 删除按钮方法

-(void)deleteUser:(id)sender {
    if([self.delegate respondsToSelector:@selector(deleteButtonClicked:WithIndex:)]) {
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
