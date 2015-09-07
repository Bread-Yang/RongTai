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
#import "AppDelegate.h"
#import "MemberRequest.h"
#import <UIButton+AFNetworking.h>
#import "MainViewController.h"
#import "UIBarButtonItem+goBack.h"

@interface UserInformationViewController ()<UIPickerViewDataSource, UIPickerViewDelegate,UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIAlertViewDelegate, RFSegmentViewDelegate> {
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
    NSArray* _decimals;  //单位为英寸时使用的小数部分的数组
    
    NSUInteger _component;  //选择器列数
    
    UIPickerView* _heightPicker;
    
    __weak IBOutlet UIView *_middleView;
    CGFloat _index; //记住编辑时传入的Index
    Member* _user;
    UIImage* _userImage;  //用户头像
    NSString* _imgUrl;
    BOOL _isNewImage;  //是否更改了用户头像
    BOOL _isEdit;
    
    MBProgressHUD* _loadingHUD;
    
    //约束
    
    __weak IBOutlet NSLayoutConstraint *_inputViewConstraint;
    
    __weak IBOutlet NSLayoutConstraint *_bottomConstraint;
    
    //网络
    AFNetworkReachabilityManager* _manager;
    MemberRequest* _memberRequest;
    
    NSDictionary* _tmp;
    
    NSString* _uid;
    
    NSUInteger _heightUnitSelectedIndex;
}
@end

@implementation UserInformationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //
    _manager = [AFNetworkReachabilityManager sharedManager];
    _memberRequest = [MemberRequest new];
    
    //由于是storyboard创建，身高的TextField比生日TextField跟晚加进View里面，导致使用IQKeyBoardManager时跳转顺序被打乱了
    [_middleView bringSubviewToFront:_birthday];
    
    //身高数组：范围为140~300cm
    _heightArr = [NSMutableArray new];
    for (int i = 140; i < 301; i++) {
        [_heightArr addObject:[NSString stringWithFormat:@"%d",i]];
    }
    
    //
    _decimals = @[@"0",@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9"];
    
    //
    _component = 1;
    
    CGRect f = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 216);
    
    //改写_hegiht的键盘为身高选择器
    UIView* inputView = [[UIView alloc]initWithFrame:f];
    inputView.backgroundColor = [UIColor whiteColor];
    _heightPicker = [[UIPickerView alloc]initWithFrame:f];
    _heightPicker.dataSource = self;
    _heightPicker.delegate = self;
    [_heightPicker selectRow:(174-140) inComponent:0 animated:NO];
    _heightPicker.tag = 1001;
    [inputView addSubview:_heightPicker];
    _height.inputView = inputView;
    _height.text = _heightArr[174-140];
    
    //改写_birthday的键盘为年月选择器
    UIView* inputView2 = [[UIView alloc]initWithFrame:f];
    inputView2.backgroundColor = [UIColor whiteColor];
    _birthdayDatePicker = [[UIDatePicker alloc] initWithFrame:f];
	_birthdayDatePicker.datePickerMode = UIDatePickerModeDate;
    _birthdayDatePicker.date = [NSDate dateWithTimeIntervalSince1970:3652*24*3600];
	[_birthdayDatePicker addTarget:self action:@selector(onDatePickerValueChanged:) forControlEvents:UIControlEventValueChanged];
	[inputView2 addSubview:_birthdayDatePicker];
    _birthday.inputView = inputView2;
    [self onDatePickerValueChanged:_birthdayDatePicker];
    
    //头像按钮设置白色边框
    _userIcon.layer.borderColor = [UIColor whiteColor].CGColor;
    _userIcon.layer.borderWidth = 3;
    _userIcon.layer.cornerRadius = 0.125*[UIScreen mainScreen].bounds.size.width;
    
    //默认头像
    _userImage = [UIImage imageNamed:@"userIcon"];
    [_userIcon setImage:_userImage forState:UIControlStateNormal];
    _userIcon.clipsToBounds = YES;
    _isNewImage = NO;
    _imgUrl = @"default";
    _isEdit = NO;
    
    //模糊背景
    _bgImageView.image = [_userImage blurImage:15.0];
    _bgImageView.contentMode = UIViewContentModeScaleAspectFill;
    
    //性别选择
    _sexSegmentView = [[RFSegmentView alloc]initWithFrame:CGRectMake(0, 0, 0.35*SCREENWIDTH, SCREENHEIGHT*0.2*0.6*0.45)];
    _sexSegmentView.tag = 3201;
    [_sexSegmentView setItems:@[NSLocalizedString(@"男", nil),NSLocalizedString(@"女", nil)]];
    _sexSegmentView.delegate = self;
    [_sexView addSubview:_sexSegmentView];
    
    //身高单位选择
    _heightUnitSegmentView = [[RFSegmentView alloc]initWithFrame:CGRectMake(0, 0, 0.35*SCREENWIDTH, SCREENHEIGHT*0.2*0.6*0.45)];
    _heightUnitSegmentView.tag = 3202;
    [_heightUnitSegmentView setItems:@[NSLocalizedString(@"cm", nil),NSLocalizedString(@"inch", nil)]];
    _heightUnitSegmentView.delegate = self;
    [_heightUintView addSubview:_heightUnitSegmentView];
    
    //
    _heightUnitSelectedIndex = 0;
    
    //
    _loadingHUD = [[MBProgressHUD alloc]initWithView:self.view];
    _loadingHUD.labelText = NSLocalizedString(@"读取中...", nil);
    [self.view addSubview:_loadingHUD];
    
    
    //
    _uid = [[NSUserDefaults standardUserDefaults] objectForKey:@"uid"];
    
    //
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem goBackItemByTarget:self Action:@selector(back)];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return _component;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if (component == 0) {
        return _heightArr.count;
    }
    else
    {
        return _decimals.count;
    }
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if (component == 0) {
        return _heightArr[row];
    }
    else
    {
        return _decimals[row];
    }
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if (_heightUnitSelectedIndex == 0) {
        _height.text = _heightArr[row];
    }
    else
    {
        NSString* integer = _heightArr[[pickerView selectedRowInComponent:0]];
        NSString* decimal = _decimals[[pickerView selectedRowInComponent:1]];
        NSString* height = [NSString stringWithFormat:@"%@.%@",integer,decimal];
        _height.text = height;
    }
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
        [self showProgressHUDByString:NSLocalizedString(@"访问相册失败", nil)];
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
        [self showProgressHUDByString:NSLocalizedString(@"访问相机失败", nil)];
    }
}

#pragma mark - UIImagePickerController代理实现
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    _userImage = [info objectForKey:@"UIImagePickerControllerEditedImage"];
    _userImage = [_userImage autoCompress];
    [_userIcon setImage:_userImage forState:UIControlStateNormal];
    _bgImageView.image = [_userImage blurImage:15.0];
    _isNewImage = YES;
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - 保存信息按钮方法
- (IBAction)save:(id)sender {
    
    if (_manager.reachable) {
        NSLog(@"联网成功");
        __weak UserInformationViewController* uVC = self;
        if (_isEdit) {
            //编辑模式，执行删除
            
            UIAlertView* alert = [[UIAlertView alloc]initWithTitle:@"删除成员" message:@"确认删除该成员吗" delegate:self cancelButtonTitle:@"否" otherButtonTitles:@"是", nil];
            [alert show];
            
        }
        else
        {
            //不是编辑模式，添加新成员
            if ([self judgeMemberInformation]) {
                [_loadingHUD show:YES];
                _user = [Member MR_createEntity];
                //提交图片
                if (_isNewImage) {
                    
                    [_memberRequest uploadImage:_userImage success:^(NSString *urlKey) {
                        _imgUrl = urlKey;
                        _isNewImage = NO;
                        //照片保存到本地
                        [uVC saveImage:_imgUrl];

                        [uVC uploadMember];
                    } failure:^(id responseObject) {
                        [_loadingHUD hide:YES];
                        [uVC showProgressHUDByString:NSLocalizedString(@"头像上传失败，请检测网络", nil)];
                        return ;
                    }];
                }
                else
                {
                    [self uploadMember];
                }
            }
        }
    }
    else
    {
        NSLog(@"无法连接到互联网");
        [self showProgressHUDByString:NSLocalizedString(@"无法连接到互联网", nil)];
    }
}

#pragma mark - 添加用户信息
-(void)uploadMember
{
    //用户信息保存
    [self saveMember];
    __weak UserInformationViewController* uVC = self;
    [_memberRequest addMember:_user success:^(NSString *memberId) {
        NSNumber* mid = [NSNumber numberWithInt:[memberId intValue]];
        _user.memberId = mid;
        
        if (_isRegister) {
            //是注册页面跳转过来的，在添加好用户信息后要设置当前用户的id
            NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
            [defaults setObject:mid forKey:@"currentMemberId"];
        }
        
        [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
        [_loadingHUD hide:YES];
        [uVC showProgressHUDByString:NSLocalizedString(@"添加成员成功", nil)];
        [uVC performSelector:@selector(back) withObject:nil afterDelay:1];
    } failure:^(id responseObject) {
        [_loadingHUD hide:YES];
        [_user MR_deleteEntity];
        NSString* str = [NSString stringWithFormat:@"%@:%@",NSLocalizedString(@"添加成员失败", nil),responseObject];
        [uVC showProgressHUDByString:str];
    }];
}

#pragma mark - 快速提示
-(void)showProgressHUDByString:(NSString*)message
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.labelText = message;
    hud.margin = 10.f;
    hud.removeFromSuperViewOnHide = YES;
    [hud hide:YES afterDelay:0.7];
}

#pragma mark - 返回
-(void)back
{
    if (_isRegister) {
        [self.navigationController pushViewController:[MainViewController new] animated:YES];
    }
    else
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - 编辑模式
-(void)editMode:(Member *)user WithIndex:(NSUInteger)index
{
    self.title = NSLocalizedString(@"编辑", nil);
    self.view.backgroundColor = [UIColor clearColor];
    _bottomConstraint.constant = SCREENHEIGHT*0.2*0.55;
    _isEdit = YES;
    _tmp = [user memberToDictionary];  //便于数据提交不成功时，进行数据恢复
    
    //保存按钮
    CGFloat h = MIN(SCREENHEIGHT*0.2*0.45, 44);
    CGFloat w = h*2.8;
    UIButton* saveBtn = [[UIButton alloc]initWithFrame:CGRectMake((SCREENWIDTH-w)/2, SCREENHEIGHT - h*1.05-64, w, h*0.8)];
    [saveBtn setBackgroundImage:[UIImage imageNamed:@"button"] forState:UIControlStateNormal];
    [saveBtn setTitle:NSLocalizedString(@"保存", nil) forState:UIControlStateNormal];
    [saveBtn addTarget:self action:@selector(saveButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:saveBtn];
    
    //删除按钮
    UIBarButtonItem* item = self.navigationItem.rightBarButtonItem;
    [item setImage:[UIImage imageNamed:@"icon_delete"]];
    
    //数据显示
    _user = user;
    _imgUrl = user.imageURL;
    [self upDateUI];
}

#pragma mark - 保存按钮方法（编辑模式下）
-(void)saveButtonClicked
{
    if (_manager.reachable) {
        if ([self judgeMemberInformation]) {
            _loadingHUD.labelText = NSLocalizedString(@"保存中...", nil);
            [_loadingHUD show:YES];
            
            //提交图片
            if (_isNewImage) {
                __weak UserInformationViewController* uVC = self;
                [_memberRequest uploadImage:_userImage success:^(NSString *urlKey) {
                    _imgUrl = urlKey;
                    _isNewImage = NO;
                    //照片保存到本地
                    [uVC saveImage:_imgUrl];
                    
                    //编辑成员（服务器请求）
                    [uVC editMember];
                } failure:^(id responseObject) {
                    [_loadingHUD hide:YES];
                    [uVC showProgressHUDByString:NSLocalizedString(@"头像上传失败，请检测网络", nil)];
                    return ;
                }];
            }
            else
            {
                //不需要更新头像，则直接编辑成员服务器请求）
                [self editMember];
            }
        }
    }
    else
    {
        NSLog(@"无法连接到互联网");
        [self showProgressHUDByString:NSLocalizedString(@"无法连接到互联网", nil)];
    }
}

#pragma mark - 保存图片
-(void)saveImage:(NSString*)newName
{
    NSString* old = _user.imageURL;
    [_userImage saveImageByName:[NSString stringWithFormat:@"%@.jpg",newName]];
    NSString* doc = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    NSString* path = [doc stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.jpg",old]];
    NSLog(@"头像路径:%@",path);
    BOOL result = [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
    if (!result) {
        NSLog(@"图片删除失败");
    }
}

#pragma mark - 编辑成员对象
-(void)editMember
{
    [self saveMember];
    __weak UserInformationViewController* uVC = self;
    [_memberRequest editMember:_user success:^(id responseObject) {
        [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
        [_loadingHUD hide:YES];
        [uVC showProgressHUDByString:NSLocalizedString(@"保存成功", nil)];
        [uVC performSelector:@selector(back) withObject:nil afterDelay:1];
    } failure:^(id responseObject) {
        [_user setValueBy:_tmp];
        NSLog(@"复原数据：%@",[_user memberToDictionary]);
        [_loadingHUD hide:YES];
        NSString* str = [NSString stringWithFormat:@"%@:%@",NSLocalizedString(@"编辑成员失败", nil),responseObject];
        [uVC showProgressHUDByString:str];
    }];
}

#pragma mark - 设置cm选择器
-(void)setSelectedCMUnit
{
    _component = 1;
    _heightArr = [NSMutableArray new];
    for (int i = 140; i < 301; i++) {
        [_heightArr addObject:[NSString stringWithFormat:@"%d",i]];
    }
    [_heightPicker reloadAllComponents];
}

#pragma mark - 设置inch选择器
-(void)setSelectedInchUnit
{
    _component = 2;
    _heightArr = [NSMutableArray new];
    for (int i = 55; i < 119; i++) {
        [_heightArr addObject:[NSString stringWithFormat:@"%d",i]];
    }
    [_heightPicker reloadAllComponents];
}

#pragma mark - 数据保存到对象中
-(void)saveMember
{
    _user.uid = _uid;
    _user.name = [_name.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    _user.sex = [NSNumber numberWithInteger:_sexSegmentView.selectIndex];
    if (_heightUnitSelectedIndex == 0) {
        _user.height = [NSNumber numberWithFloat:[_height.text floatValue]];
    }
    else
    {
        NSUInteger integer = [_heightPicker selectedRowInComponent:0];
        NSUInteger decimal = [_heightPicker selectedRowInComponent:1];
        _user.height = [NSNumber numberWithFloat:(integer+55+0.1*decimal)];
    }
    
    if (_heightUnitSegmentView.selectIndex == 0) {
        _user.heightUnit = @"cm";
    } else {
        _user.heightUnit = @"inch";
    }
    _user.birthday = _birthdayDatePicker.date;
    _user.imageURL = _imgUrl;
}

#pragma mark - 信息正确性判断
-(BOOL)judgeMemberInformation
{
    //用户名不能为空
    NSString *userName = _name.text;
    if ([NSString isBlankString:userName]) {
        [self showProgressHUDByString:NSLocalizedString(@"昵称不能为空", nil)];
        return NO;
    }
    
    //用户名不能重复
    NSArray *existArray = [Member MR_findByAttribute:@"name" withValue:userName];
    if ([existArray count] != 0 && ![userName isEqual:_user.name]) {
        [self showProgressHUDByString:NSLocalizedString(@"昵称已经存在", nil)];
        return NO;
    }

    //身高必须选择
    if (_height.text.length < 1) {
        [self showProgressHUDByString:NSLocalizedString(@"请选择身高", nil)];
        return NO;
    }
    
    //生日必须选择
    if (_birthday.text.length < 1 ) {
        [self showProgressHUDByString:NSLocalizedString(@"请选择生日", nil)];
        return NO;
    }
    return YES;
}

#pragma mark - 用户数据绑定在控件上
-(void)upDateUI {
    _name.text = _user.name;
    _sexSegmentView.selectIndex = [_user.sex integerValue];
    _height.text = [_user.height stringValue];
    if ([_user.heightUnit isEqual:@"cm"]) {
        _heightUnitSegmentView.selectIndex = 0;
        NSUInteger height = [_user.height integerValue];
        [_heightPicker selectRow:(height-140) inComponent:0 animated:NO];
    } else {
        _heightUnitSegmentView.selectIndex = 1;
        float height = [_user.height floatValue];
        NSUInteger integer = (int)height;
        NSUInteger decimal = (int)((height - integer)*10); //取小数点后1位
        [_heightPicker selectRow:(integer-55) inComponent:0 animated:NO];
        [_heightPicker selectRow:(decimal-0) inComponent:1 animated:NO];
    }
    _heightUnitSelectedIndex = _heightUnitSegmentView.selectIndex;
    _birthdayDatePicker.date = _user.birthday;
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy/MM/dd"];
    NSString *dateString = [dateFormat stringFromDate:_user.birthday];
    _birthday.text = [NSString stringWithFormat:@"%@", dateString];

    UIImage* img;
    if ([_user.imageURL isEqualToString:@"default"] ) {
        img = [UIImage imageNamed:@"userIcon"];
    }
    else
    {
        //用网络请求来读取照片，或者从本地读取
        img = [UIImage imageInLocalByName:[NSString stringWithFormat:@"%@.jpg",_user.imageURL]];
        if (!img) {
            NSLog(@"网络读取头像");
            __weak UserInformationViewController* uVC = self;
            NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://recipe.xtremeprog.com/file/g/%@",_user.imageURL]];
            NSURLRequest *request = [NSURLRequest requestWithURL:url];
            UIImage *placeholderImage = [UIImage imageNamed:@"placeholder"];
            [_userIcon setImageForState:UIControlStateNormal withURLRequest:request placeholderImage:placeholderImage success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                [_userIcon setImage:image forState:UIControlStateNormal];
                _bgImageView.image = [image blurImage:15];
                
            } failure:^(NSError *error) {
                //网络读取失败
                [uVC showProgressHUDByString:NSLocalizedString(@"用户头像下载失败", nil)];
            }];
            return;
         }
        [_userIcon setImage:img forState:UIControlStateNormal];
        _bgImageView.image = [img blurImage:15];
   }
}

#pragma mark - 删除按钮方法
-(void)deleteUser:(id)sender {
    if([self.delegate respondsToSelector:@selector(deleteButtonClicked:WithIndex:)]) {
        [self.delegate deleteButtonClicked:_user WithIndex:_index];
    }
}

#pragma mark - alertView代理
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString* btn = [alertView buttonTitleAtIndex:buttonIndex];
    if ([btn isEqualToString:@"是"]) {
        __weak UserInformationViewController* uVC = self;
        [_memberRequest deleteMember:_user success:^(id responseObject) {
            [_user MR_deleteEntity];
            [uVC showProgressHUDByString:NSLocalizedString(@"删除成员成功", nil)];
            [uVC performSelector:@selector(back) withObject:nil afterDelay:1];
        } failure:^(id responseObject) {
            [_loadingHUD hide:YES];
            NSString* str = [NSString stringWithFormat:@"%@：%@",NSLocalizedString(@"删除成员失败", nil),responseObject];
            NSLog(@"%@",str);
            [uVC showProgressHUDByString:str];
        }];
    }
}

#pragma mark - RFSegmentView代理
-(void)segmentView:(RFSegmentView*)segmentView SelectIndex:(NSInteger)index
{
    if (segmentView.tag == 3201) {
        //性别选项改变时，需要改变身高的默认值
        if (index == 0) {
            //男
            if (_heightUnitSegmentView.selectIndex == 0) {
                [_heightPicker selectRow:(174-140) inComponent:0 animated:NO];
            }
            else
            {
                [_heightPicker selectRow:(69-55) inComponent:0 animated:NO];
                [_heightPicker selectRow:0 inComponent:1 animated:NO];
            }
        }
        else
        {
            //女
            if (_heightUnitSegmentView.selectIndex == 0) {
                [_heightPicker selectRow:(160-140) inComponent:0 animated:NO];
            }
            else
            {
                [_heightPicker selectRow:(63-55) inComponent:0 animated:NO];
                [_heightPicker selectRow:0 inComponent:1 animated:NO];
            }
        }
         _height.text = _heightArr[[_heightPicker selectedRowInComponent:0]];
    }
    else if (segmentView.tag == 3202)
    {
        if (index != _heightUnitSelectedIndex) {
            //单位改变时，身高数值要改变
            _heightUnitSelectedIndex = index;
            NSUInteger selectedInedx = [_heightPicker selectedRowInComponent:0];
            if (index == 0) {
                //cm
                NSUInteger decimal = [_heightPicker selectedRowInComponent:1];
                
                [self setSelectedCMUnit];
                int index = (int)round((55+selectedInedx+0.1*decimal)*2.54);
                if (index<140) {
                    index = 140;
                }
                else if (index>300)
                {
                    index = 300;
                }
                [_heightPicker selectRow:(index-140) inComponent:0 animated:NO];
                _height.text = _heightArr[[_heightPicker selectedRowInComponent:0]];
            }
            else
            {
                //inch
                [self setSelectedInchUnit];
                float height = (float)((140+selectedInedx)/2.54);
                int integer = (int)height;
                int decimal = (int)((height-integer)*10);
                if (integer<55) {
                    integer = 55;
                }
                else if (integer>119)
                {
                    integer = 119;
                }
                
                [_heightPicker selectRow:(integer-55) inComponent:0 animated:NO];
                [_heightPicker selectRow:(decimal-0) inComponent:1 animated:NO];
                _height.text = [NSString stringWithFormat:@"%d.%d",integer,decimal];
            }
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
