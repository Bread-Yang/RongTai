//
//  CustomProcedureViewController.m
//  rongtai
//
//  Created by William-zhang on 15/6/14.
//  Copyright (c) 2015年 William-zhang. All rights reserved.
//

#define SCREENWIDTH [UIScreen mainScreen].bounds.size.width
#define SCREENHEIGHT [UIScreen mainScreen].bounds.size.height

#import "CustomProcedureViewController.h"
#import "ProcedureManageViewController.h"
#import "RFSegmentView.h"
#import "WLCheckButton.h"
#import "CustomMassageViewController.h"

@interface CustomProcedureViewController ()
{
    __weak IBOutlet UIScrollView *_scrollView;
    __weak IBOutlet UIView *_topView;
    __weak IBOutlet UIView *_bottomView;
    
    //标题
    __weak IBOutlet UILabel *_useTiming;  // 使用时机
    __weak IBOutlet UILabel *_usePurpose;  // 使用目的
    __weak IBOutlet UILabel *_importantPart;  //重点部位
    __weak IBOutlet UILabel *_massageWay;  //按摩手法
    __weak IBOutlet UILabel *_skillPreference;  //技法偏好
    
    //放分段控制器的View
    __weak IBOutlet UIView *_useTimingView;
    __weak IBOutlet UIView *_usePurposeView;
    __weak IBOutlet UIView *_importantPartView;
    __weak IBOutlet UIView *_massageWayView;
    __weak IBOutlet UIView *_skillPreferenceView;
    
    //分段控制器
    RFSegmentView* _useTimingSegmentView;
    RFSegmentView* _usePurposeSegmentView;
    RFSegmentView* _importantPartSegmentView;
    RFSegmentView* _massageWaySegmentView;
    RFSegmentView* _skillPreferenceSegmentView;
    
    //按摩对象
    MassageMode* _massageMode;
    
    //名称textField
    UITextField* _nameField;
    
    //开始按摩按钮
    __weak IBOutlet UIButton *_stastMassageBtn;
    
    BOOL _isEdit;
    
    __weak IBOutlet NSLayoutConstraint *_topConstraint;
    
    //放单选按钮的View
    __weak IBOutlet UIView *_speedView;
    __weak IBOutlet UIView *_pressureView;
    __weak IBOutlet UIView *_dynamicsView;
    __weak IBOutlet UIView *_widthView;
    
    //单选按钮
    WLCheckButton* _speedCheckButton;
    WLCheckButton* _pressureCheckButton;
    WLCheckButton* _dynamicsCheckButton;
    WLCheckButton* _widthCheckButton;
}
@end

@implementation CustomProcedureViewController

-(void)viewDidLoad
{
    self.title = NSLocalizedString(@"自定义程序", nil);
    _scrollView.showsVerticalScrollIndicator = NO;
    
    _bottomView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    _bottomView.layer.borderWidth = 1;
    
    //添加导航栏右边按钮
    UIBarButtonItem* select = [[UIBarButtonItem alloc]initWithTitle:NSLocalizedString(@"选择已有程序", nil) style:UIBarButtonItemStylePlain target:self action:@selector(selectEsxistingProcedure)];
    self.navigationItem.rightBarButtonItem = select;
	
    
    //调整各标题字体
    _useTiming.adjustsFontSizeToFitWidth = YES;
    _usePurpose.adjustsFontSizeToFitWidth = YES;
    _importantPart.adjustsFontSizeToFitWidth = YES;
    _massageWay.adjustsFontSizeToFitWidth = YES;
    _skillPreference.adjustsFontSizeToFitWidth = YES;
    
    //初始化各个分段控制器
    [self setUpSegmentedControl];
    
    //初始化各个单选按钮
    [self setUpCheckBox];
    
    _isEdit = NO;
}

-(void)viewDidAppear:(BOOL)animated
{
    //设置_scrollView的滑动内容大小
    _scrollView.contentSize = CGSizeMake(_scrollView.frame.size.width, _topView.frame.size.height+_bottomView.frame.size.height+15);
}

#pragma mark - 选择以后程序
-(void)selectEsxistingProcedure
{
    [self.navigationController pushViewController:[ProcedureManageViewController new] animated:YES];
}

#pragma mark - 初始化分段控制器
-(void)setUpSegmentedControl
{
    CGRect f = CGRectMake(0, 0, (SCREENWIDTH-32)*0.7, 44);
    _useTimingSegmentView = [[RFSegmentView alloc]initWithFrame:f items:@[NSLocalizedString(@"工作后", nil),NSLocalizedString(@"出差后", nil),NSLocalizedString(@"运动后", nil),NSLocalizedString(@"逛街后", nil)]];
    [_useTimingView addSubview:_useTimingSegmentView];
    
    _usePurposeSegmentView = [[RFSegmentView alloc]initWithFrame:f items:@[NSLocalizedString(@"缓解疲劳", nil),NSLocalizedString(@"肌肉放松", nil),NSLocalizedString(@"改善睡眠", nil),NSLocalizedString(@"日常保健", nil)]];
    _usePurposeSegmentView.numberOfLines = 0;
    [_usePurposeView addSubview:_usePurposeSegmentView];
    
    _importantPartSegmentView = [[RFSegmentView alloc]initWithFrame:f items:@[NSLocalizedString(@"肩部", nil),NSLocalizedString(@"背部", nil),NSLocalizedString(@"腰部", nil),NSLocalizedString(@"臀部", nil)]];
    [_importantPartView addSubview:_importantPartSegmentView];
    
    _massageWaySegmentView = [[RFSegmentView alloc]initWithFrame:CGRectMake(0, 0, 0.7*0.75*(SCREENWIDTH-32), 44) items:@[NSLocalizedString(@"泰式", nil),NSLocalizedString(@"日式", nil),NSLocalizedString(@"中式", nil)]];
    [_massageWayView addSubview:_massageWaySegmentView];
    
    _skillPreferenceSegmentView = [[RFSegmentView alloc]initWithFrame:f items:@[NSLocalizedString(@"揉捏", nil),NSLocalizedString(@"推拿", nil),NSLocalizedString(@"敲打", nil),NSLocalizedString(@"组合", nil)]];
    [_skillPreferenceView addSubview:_skillPreferenceSegmentView];
}


#pragma mark - 初始化单选按钮
-(void)setUpCheckBox
{
    CGRect f = CGRectMake(0, 0, (SCREENWIDTH-32)*0.3, (SCREENWIDTH-32)*0.3*3/8);
    _speedCheckButton = [[WLCheckButton alloc]initWithFrame:f];
    _speedCheckButton.itemNames = @[NSLocalizedString(@"偏快", nil),NSLocalizedString(@"偏慢", nil)];
    [_speedView addSubview:_speedCheckButton];
    
    _pressureCheckButton = [[WLCheckButton alloc]initWithFrame:f];
    _pressureCheckButton.itemNames = @[NSLocalizedString(@"偏大", nil),NSLocalizedString(@"偏小", nil)];
    [_pressureView addSubview:_pressureCheckButton];
    
    _dynamicsCheckButton = [[WLCheckButton alloc]initWithFrame:f];
    _dynamicsCheckButton.itemNames = @[NSLocalizedString(@"偏重", nil),NSLocalizedString(@"偏轻", nil)];
    [_dynamicsView addSubview:_dynamicsCheckButton];
    
    _widthCheckButton = [[WLCheckButton alloc]initWithFrame:f];
    _widthCheckButton.itemNames = @[NSLocalizedString(@"偏宽", nil),NSLocalizedString(@"偏窄", nil)];
    [_widthView addSubview:_widthCheckButton];
}



#pragma mark - 开始按摩按钮
- (IBAction)startMassage:(UIButton *)sender {
    UIStoryboard* s = [UIStoryboard storyboardWithName:@"Login" bundle:nil];
    CustomMassageViewController* c = (CustomMassageViewController*)[s instantiateViewControllerWithIdentifier:@"CustomMassageVC"];
    [self.navigationController pushViewController:c animated:YES];
}


#pragma mark - 编辑模式
-(void)editModeWithMassageMode:(MassageMode*)massageMode Index:(NSUInteger)index;
{
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"编辑";
    _isEdit = YES;
    UIBarButtonItem* save = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveMassageMode)];
    self.navigationItem.rightBarButtonItem = save;
    
    UILabel* nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(8, 8, 60, 44)];
    nameLabel.textAlignment = NSTextAlignmentCenter;
    nameLabel.adjustsFontSizeToFitWidth = YES;
    nameLabel.text = @"名称";
    [_scrollView addSubview:nameLabel];
    
    CGRect f = CGRectMake(SCREENWIDTH - (SCREENWIDTH-32)*0.7-32, 8, (SCREENWIDTH-32)*0.7, 44);
    _nameField = [[UITextField alloc]initWithFrame:f];
    _nameField.borderStyle = UITextBorderStyleLine;
    [_scrollView addSubview:_nameField];
    
    [_stastMassageBtn setTitle:@"删除" forState:UIControlStateNormal];
    _stastMassageBtn.backgroundColor = [UIColor colorWithRed:1 green:0 blue:0 alpha:0.6];
    _topConstraint.constant = 59;
}

#pragma mark - 保存按摩模式
-(void)saveMassageMode
{
    
}











@end
