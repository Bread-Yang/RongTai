//
//  UserInformationViewController.m
//  rongtai
//
//  Created by William-zhang on 15/6/2.
//  Copyright (c) 2015年 William-zhang. All rights reserved.
//
#import "NSString+RT.h"
#import "UserInformationViewController.h"
#import "MBProgressHUD.h"
#import "CoreData+MagicalRecord.h"
#import "Member.h"
#import "AFHTTPRequestOperationManager.h"
#import "RongTaiConstant.h"
#import "UIImage+ImageBlur.h"
#import "RFSegmentView.h"


@interface UserInformationViewController ()<UIPickerViewDataSource, UIPickerViewDelegate,UIImagePickerControllerDelegate, UINavigationControllerDelegate> {
    __weak IBOutlet UITextField *_name; //用户昵称TextField
    __weak IBOutlet UITextField *_height;  //身高TextField
    __weak IBOutlet UITextField *_birthday;  //生日年月TextFiled

    RFSegmentView *_sexSegmentView;
    
    __weak IBOutlet UIView *_sexView;
    
    __weak IBOutlet UIView *_heightUintView;
    RFSegmentView *_heightUnitSegmentView;
	
    __weak IBOutlet UIButton *_userIcon;
    __weak IBOutlet UIImageView *_bgImageView;
	
	UIDatePicker *_birthdayDatePicker;
    NSMutableArray* _heightArr;  //身高数组
    
    __weak IBOutlet UIView *_middleView;
    CGFloat _index; //记住编辑时传入的Index
    Member* _user;
    UIImage* _userImage;  //用户头像
    BOOL _isEdit;
    
    //约束
    
    __weak IBOutlet NSLayoutConstraint *_inputViewConstraint;
    
    __weak IBOutlet NSLayoutConstraint *_bottomConstraint;
    
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
    _userIcon.layer.borderWidth = 3;
    _userIcon.layer.cornerRadius = 0.125*[UIScreen mainScreen].bounds.size.width;
    
    //默认头像
    _userImage = [UIImage imageNamed:@"userDefaultIcon.jpg"];
    [_userIcon setImage:_userImage forState:UIControlStateNormal];
    _userIcon.clipsToBounds = YES;
    
    
    _bgImageView.image = [_userImage blurImage:15.0];
    _bgImageView.contentMode = UIViewContentModeScaleAspectFill;
    
    _sexSegmentView = [[RFSegmentView alloc]initWithFrame:CGRectMake(0, 0, 0.35*SCREENWIDTH, SCREENHEIGHT*0.2*0.6*0.45)];
    [_sexSegmentView setItems:@[NSLocalizedString(@"男", nil),NSLocalizedString(@"女", nil)]];
    [_sexView addSubview:_sexSegmentView];
    _heightUnitSegmentView = [[RFSegmentView alloc]initWithFrame:CGRectMake(0, 0, 0.35*SCREENWIDTH, SCREENHEIGHT*0.2*0.6*0.45)];
    [_heightUnitSegmentView setItems:@[NSLocalizedString(@"cm", nil),NSLocalizedString(@"unit", nil)]];
    [_heightUintView addSubview:_heightUnitSegmentView];

    
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
}

#pragma mark - 保存信息按钮方法

- (IBAction)save:(id)sender {
    
    if (_isEdit) {
        //编辑模式，执行删除
    }
    else
    {
        //不是编辑模式，添加新成员
        if ([self judgeMemberInformation]) {
            // 下面是本地数据库提交
            if ([self.title isEqual:NSLocalizedString(@"编辑", nil)]) {   // 编辑信息
                _user =[Member MR_findByAttribute:@"name" withValue:_user.name][0];
            } else if(!_user){													// 新增信息
                _user = [Member MR_createEntity];
            }
            [self saveMember];
            _user.status = [NSNumber numberWithInt:1];
            [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
            
            //    //照片保存到本地
            //    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            //        [_userImage saveImageByName:@"userIcon.png"];
            //    });
            
            
            //服务器提交
            NSString *requestURL;
            
            if ([self.title isEqual:NSLocalizedString(@"编辑", nil)]) {   // 编辑信息
                requestURL = [RongTaiDefaultDomain stringByAppendingString:@"updateMember"];
            } else {													// 新增信息
                requestURL = [RongTaiDefaultDomain stringByAppendingString:@"addMember"];
            }
            
            NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
            [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
            NSString *dateString = [dateFormat stringFromDate:_birthdayDatePicker.date];
            NSDictionary *parameters = @{@"uid" : @"15521377721",
                                         @"name" : _user.name,
                                         @"sex" : _user.sex,
                                         @"height" : _user.height,
                                         @"heightUnit" : _user.heightUnit,
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
#warning 服务器提交成功后要改变本地数据的状态
                
                
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
        }
    }
}

#pragma mark - 编辑模式
-(void)editMode:(Member *)user WithIndex:(NSUInteger)index
{
    self.title = NSLocalizedString(@"编辑", nil);
    _isEdit = YES;
    
    self.view.backgroundColor = [UIColor clearColor];
    _bottomConstraint.constant = SCREENHEIGHT*0.2*0.55;
    
    //保存按钮
    CGFloat h = MIN(SCREENHEIGHT*0.2*0.45, 44);
    CGFloat w = h*2.8;
    UIButton* saveBtn = [[UIButton alloc]initWithFrame:CGRectMake((SCREENWIDTH-w)/2, SCREENHEIGHT - h*1.05, w, h*0.8)];
    [saveBtn setBackgroundImage:[UIImage imageNamed:@"button"] forState:UIControlStateNormal];
    [saveBtn setTitle:@"保存" forState:UIControlStateNormal];
    [saveBtn addTarget:self action:@selector(saveButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:saveBtn];
    
    //删除按钮
    UIBarButtonItem* item = self.navigationItem.rightBarButtonItem;
    [item setImage:[UIImage imageNamed:@"icon_delete"]];
    
    
    //数据显示
    _user = user;
    NSLog(@"Member:%@",_user);
    [self upDateUI];
    
}


- (void)setEditUserInformation:(NSDictionary *)infoDictionary {
	self.title = NSLocalizedString(@"编辑", nil);
	CGFloat width = [UIScreen mainScreen].bounds.size.width;
	CGFloat height = [UIScreen mainScreen].bounds.size.height;
	UIButton *delete = [[UIButton alloc]initWithFrame:CGRectMake(width*0.325, height - height * 0.15, width * 0.35, height * 0.06)];
	delete.backgroundColor = [UIColor colorWithRed:1 green:0 blue:0 alpha:0.6];
	[delete setTitle:NSLocalizedString(@"删除", nil) forState:UIControlStateNormal];
	[delete addTarget:self action:@selector(deleteUser:) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:delete];
    
	_name.text = infoDictionary[@"name"];
	_sexSegmentView.selectIndex = [infoDictionary[@"sex"] integerValue];
	_height.text = infoDictionary[@"height"];
	if ([infoDictionary[@"heightUnit"] isEqualToString:@"cm"]) {
		_heightUnitSegmentView.selectIndex = 0;
	} else {
		_heightUnitSegmentView.selectIndex = 1;
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

#pragma mark - 保存按钮方法（编辑模式下）
-(void)saveButtonClicked
{
    if ([self judgeMemberInformation]) {
        [self saveMember];
        _user.status = [NSNumber numberWithInt:2];
        [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
        //服务器提交
        
        
        //更新本地数据
        
    }
}

#pragma mark - 数据保存到对象中
-(void)saveMember
{
    _user.name = [_name.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    _user.sex = [NSNumber numberWithInteger:_sexSegmentView.selectIndex];
    _user.height = [NSNumber numberWithFloat:[_height.text floatValue]];
    if (_heightUnitSegmentView.selectIndex == 0) {
        _user.heightUnit = @"cm";
    } else {
        _user.heightUnit = @"inch";
    }
    _user.birthday = _birthdayDatePicker.date;
}

#pragma mark - 信息正确性判断
-(BOOL)judgeMemberInformation
{
    BOOL result = NO;
    //用户名不能为空
    NSString *userName = _name.text;
    if ([NSString isBlankString:userName]) {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        
        // Configure for text only and offset down
        hud.mode = MBProgressHUDModeText;
        hud.labelText = @"昵称不能为空";
        hud.margin = 10.f;
        hud.removeFromSuperViewOnHide = YES;
        [hud hide:YES afterDelay:1];
        return result;
    }
    
    //用户名不能重复
    NSArray *existArray = [Member MR_findByAttribute:@"name" withValue:userName];
    if ([existArray count] != 0 && ![userName isEqual:_user.name]) {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        // Configure for text only and offset down
        hud.mode = MBProgressHUDModeText;
        hud.labelText = @"昵称已经存在";
        hud.margin = 10.f;
        hud.removeFromSuperViewOnHide = YES;
        [hud hide:YES afterDelay:3];
        return result;
    }

    //身高必须选择
    
    //生日必须选择
    
    result = YES;
    return result;
}

#pragma mark - 用户数据绑定在控件上
-(void)upDateUI {
    _name.text = _user.name;
    _sexSegmentView.selectIndex = [_user.sex integerValue];
    _height.text = [_user.height stringValue];
    if ([_user.heightUnit isEqual:@"cm"]) {
        _heightUnitSegmentView.selectIndex = 0;
    } else {
        _heightUnitSegmentView.selectIndex = 1;
    }
    if (_user.imageURL.length <1 ) {
        UIImage* img = [UIImage imageNamed:@"userIcon.jpg"];
        [_userIcon setImage:img forState:UIControlStateNormal];
        _bgImageView.image = [img blurImage:15];
    }
    else
    {
        //用网络请求来读取照片，或者从本地读取
    }
    _birthdayDatePicker.date = _user.birthday;
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy/MM/dd"];
    NSString *dateString = [dateFormat stringFromDate:_user.birthday];
    _birthday.text = [NSString stringWithFormat:@"%@", dateString];
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
