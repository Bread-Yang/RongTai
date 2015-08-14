//
//  ManualViewController.m
//  rongtai
//
//  Created by William-zhang on 15/7/17.
//  Copyright (c) 2015年 William-zhang. All rights reserved.
//

#import "ManualViewController.h"
#import "WLPanAlertView.h"
#import "AppDelegate.h"
#import "ManualTableViewCell.h"
#import "ManualHumanView.h"
#import "WLPolar.h"
#import "RongTaiConstant.h"
#import "SMPageControl.h"
#import "CustomIOSAlertView.h"
#import "NAPickerView.h"
#import "SlideNavigationController.h"
#import "RTCommand.h"


@interface ManualViewController ()<WLPanAlertViewDelegate, UITableViewDataSource, UITableViewDelegate, ManualTableViewCellDelegate,NAPickerViewDelegate,WLPolarDelegate, RTBleConnectorDelegate> {
    WLPanAlertView* _panAlertView;  //按摩调整
    UIImageView* _arrow;  //剪头
    UIImageView* _bgCircle;  //半圆
    UILabel* _titleLabel;   //半圆内的Label
    UIImageView* _contentImageView;   //蓝色背景图片
    UITableView* _adjustTable;  //所有调整按钮的TableView
    NSArray* _menu;  //调整选项名称数组
    NSString* _reuseIdentifier;   //cell重用标识符
    NSArray* _images;  //调整按钮的图片名称数组
    CGFloat _cH;
    
    ManualHumanView* _humanView;  //人体部位选择View
    WLPolar* _polar;   //极限图
    __weak IBOutlet UIView *_addPageControl;  //添加分页控制器的View
    SMPageControl* _pageControl;  //分页控制器
	
	//背部加热
	__weak IBOutlet UIView *_backWarm;
	__weak IBOutlet UIImageView *_backWarmImagaView;
	__weak IBOutlet UILabel *_backWarmLabel;
	BOOL _backWarmOn;  //是否开启背部加热
	
	// 脚部滚轮
	NSArray *_footWheelArray;
	NAPickerView *_footWheelPickerView;
	
	__weak IBOutlet UIView *_footWheel;
	__weak IBOutlet UIImageView *_footWheelImageView;
	__weak IBOutlet UILabel *_footWheelLabel;
	BOOL _footWheelOn;   //是否开启脚步滚轮
    
    //技法偏好
    NSArray* _skillsPreferenceArray;    //技法偏好选项数组
    NAPickerView *_skillsPreferencePickerView;  //技法偏好选择器
    
    __weak IBOutlet UILabel *_skillsPreferenceLabel;
    __weak IBOutlet UIView *_skillsPreferenceView;
    NSInteger _pickerSelectedItem;  //记录picker选项
    
    //定时
    NAPickerView* _timePickerView;   //时间选择器
    __weak IBOutlet UILabel *_timeLabel;
    __weak IBOutlet UIView *_timeView;
	
    __weak IBOutlet UIView *_addScrollView;
    UIScrollView* _scroll;
    
    //
    RTBleConnector* _bleConnector;

}
@end

@implementation ManualViewController

-(void)viewDidLoad
{
    [super viewDidLoad];
	self.isListenBluetoothStatus = YES;
	
    self.title = NSLocalizedString(@"手动按摩", nil);
	
	// 脚步滚轮数组
	_footWheelArray = @[@"滚轮速度慢", @"滚轮速度中", @"滚轮速度快", @"滚轮关"];
	
    //技法偏好类型数组
    _skillsPreferenceArray = @[@"揉捏", @"敲击", @"揉敲同步", @"叩击", @"指压", @"韵律按摩"];
    
    //创建scrollView
    CGFloat w = SCREENWIDTH;
    CGFloat h = SCREENHEIGHT*0.57;
    _scroll = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, w, h)];
    _scroll.pagingEnabled = YES;
    _scroll.contentSize = CGSizeMake(w*2, h);
    _scroll.bounces = NO;
    _scroll.delegate = self;
    _scroll.showsHorizontalScrollIndicator = NO;
    _scroll.showsVerticalScrollIndicator = NO;
    [_addScrollView addSubview:_scroll];
    
    //创建 人体图
    _humanView = [[ManualHumanView alloc]initWithFrame:CGRectMake(0, 0, w, h)];
    [_scroll addSubview:_humanView];
    
    //创建 极线图
    _polar = [[WLPolar alloc]initWithFrame:CGRectMake(w, 0, w, h)];
    _polar.dataSeries = @[@(6), @(6), @(6), @(6)];
    _polar.steps = 3;
    _polar.r = h*0.3;
    _polar.minValue = 0;
    _polar.maxValue = 12;
    _polar.drawPoints = YES;
    _polar.fillArea = YES;
    _polar.delegate = self;
    _polar.backgroundLineColorRadial = [UIColor colorWithRed:200/255.0 green:225/255.0 blue:233/255.0 alpha:1];
    _polar.fillColor = [UIColor colorWithRed:0 green:230/255.0 blue:0 alpha:0.3];
    _polar.lineColor = [UIColor colorWithRed:0 green:230/255.0 blue:0 alpha:0.8];
    _polar.attributes = @[@"机芯幅度", @"气囊强度",@"滚轮速度" , @"按摩力度"];
    _polar.scaleFont = [UIFont systemFontOfSize:14];
	_scroll.delaysContentTouches = NO;
    [_scroll addSubview:_polar];
    
    
    //创建 自定义分页控制器
    _pageControl = [[SMPageControl alloc]initWithFrame:CGRectMake(0, 0, 30, SCREENHEIGHT*0.03)];
    _pageControl.numberOfPages = 2;
    _pageControl.currentPageIndicatorImage = [UIImage imageNamed:@"page_piont_1"];
    _pageControl.pageIndicatorImage = [UIImage imageNamed:@"page_piont_2"];
    [_pageControl addTarget:self action:@selector(pageControlChange:) forControlEvents:UIControlEventValueChanged];
    [_addPageControl addSubview:_pageControl];
    
    //导航栏右边按钮
    UIBarButtonItem* right = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"icon_set"] style:UIBarButtonItemStylePlain target:self action:@selector(rightItemClicked:)];
    self.navigationItem.rightBarButtonItem = right;
 
    //返回按钮设置
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem goBackItemByTarget:self Action:@selector(goBack)];
    
    //调节选项数组
    _menu = @[NSLocalizedString(@"肩部位置:", nil),NSLocalizedString(@"背部升降:",nil),NSLocalizedString(@"小腿升降:",nil),NSLocalizedString(@"小腿伸缩:",nil),NSLocalizedString(@"零重力:",nil)];
    
    _reuseIdentifier = @"manualCell";
    
    //调节选项按钮图片名称
    _images = @[@"set_button_up",@"set_button_down",@"set_rear_down",@"set_rear_up",@"set_leg_down",@"set_leg_up",@"set_leg_long",@"set_leg_short",@"set_zero"];
    
    //创建 WLPanAlertView，即调节菜单
    _panAlertView = [[WLPanAlertView alloc]init];
    _panAlertView.delegate = self;
    CGRect f = _panAlertView.buttonView.frame;
    h = _panAlertView.buttonView.frame.size.height;
    f.origin.x = 0;
    f.origin.y = 0;
    f.size.height  = h*0.17;
    
    // 菜单蓝色箭头
    _arrow = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"arrow_up"]];
    _arrow.frame = f;
    _arrow.contentMode = UIViewContentModeScaleAspectFit;
    [_panAlertView.buttonView addSubview:_arrow];
    
    // 菜单蓝色半圆
    _bgCircle = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"button_set_bg"]];
    f.size.height  = h*0.83;
    f.origin.y = h*0.21;
    _bgCircle.frame = f;
    _bgCircle.contentMode = UIViewContentModeScaleAspectFit;
    [_panAlertView.buttonView addSubview:_bgCircle];
    
    
    // 菜单标题Label
    h = _bgCircle.frame.size.height;
    UILabel* label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0.3*h, CGRectGetWidth(_bgCircle.frame), h*0.4)];
    label.text = NSLocalizedString(@"按摩调整", nil);
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont systemFontOfSize:14];
    label.textColor = [UIColor whiteColor];
    [_bgCircle addSubview:label];
    
    //设置WLPanAlertView背景
    f = _panAlertView.contentView.frame;
    f.origin.x = 0;
    f.origin.y = 0;
    _contentImageView = [[UIImageView alloc]initWithFrame:f];
    _contentImageView.image = [UIImage imageNamed:@"set_bg"];
    [_panAlertView.contentView addSubview:_contentImageView];
    
    //WLPanAlertView加入到UIWindow里面
    AppDelegate* app = [UIApplication sharedApplication].delegate;
    UIWindow* appWindow = app.window;
    [appWindow addSubview:_panAlertView];
    
    // 菜单选项TableView
    f =_panAlertView.contentView.frame;
    _cH = CGRectGetHeight(f);
    f.origin = CGPointZero;
    f.size.width *= 0.8;
    f.size.height = 0.7*_cH;
    f.origin.x = f.size.width*0.25/2;
    f.origin.y = _cH*0.03;
    _adjustTable = [[UITableView alloc]initWithFrame:f];
    _adjustTable.backgroundColor = [UIColor clearColor];
    _adjustTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    _adjustTable.delegate = self;
    _adjustTable.dataSource = self;
    _adjustTable.scrollEnabled = NO;
    [_adjustTable registerNib:[UINib nibWithNibName:@"ManualTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:_reuseIdentifier];
    [_panAlertView.contentView addSubview:_adjustTable];
    
    
    // 技法偏好View加入单击手势
    UITapGestureRecognizer* sTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(skillsPreferenceTap)];
    [_skillsPreferenceView addGestureRecognizer:sTap];
    
    _skillsPreferencePickerView = [self createskillsPreferencePickerView];
	
	_footWheelPickerView = [self createFootWheelPickerView];
    
    // 定时View加入单击手势
    UITapGestureRecognizer* tTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(timeViewTap)];
    [_timeView addGestureRecognizer:tTap];

     _timePickerView = [self createMinutePickerView];
    
    //背部加热View加入单击手势
    _backWarmOn = NO;
    UITapGestureRecognizer* bTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(backWarmTap)];
    [_backWarm addGestureRecognizer:bTap];
    
    //脚步滚轮View加入单击手势
    _footWheelOn = NO;
    UITapGestureRecognizer* fTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(footWheelTap)];
    [_footWheel addGestureRecognizer:fTap];
    
    //
    _bleConnector = [RTBleConnector shareManager];
//    _bleConnector.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    //页面消失时，要把WLPanAlertView移除掉
    [_panAlertView removeFromSuperview];
}

#pragma mark - 返回
-(void)goBack
{
    //退出手动按摩的时候，发送复位命令
    if (_bleConnector.rtMassageChairStatus.deviceStatus == RtMassageChairStatusMassaging) {
        NSLog(@"复位");
        [_bleConnector sendControlMode:H10_KEY_POWER_SWITCH];
    }
//    [self.navigationCo ntroller popViewControllerAnimated:YES];
}

#pragma mark - 技法偏好点击方法
-(void)skillsPreferenceTap {
    CustomIOSAlertView* skillPreferenceAlerView = [[CustomIOSAlertView alloc] init];
    [skillPreferenceAlerView setContainerView:_skillsPreferencePickerView];
    [skillPreferenceAlerView setTitleString:@"模式"];
    [skillPreferenceAlerView setButtonTitles:[NSMutableArray arrayWithObjects:@"取消", @"保存", nil]];
    [skillPreferenceAlerView setOnButtonTouchUpInside:^(CustomIOSAlertView *alertView, int buttonIndex) {
        if (buttonIndex == 0) {
            [alertView close];
        } else if (buttonIndex == 1) {
            //保存方法
//            NSString* sp = _skillsPreferenceArray[_pickerSelectedItem];
//            _skillsPreferenceLabel.text = sp;
			
			switch ([_skillsPreferencePickerView getHighlightIndex]) {
				case 0:  // 揉捏
					[_bleConnector sendControlMode:H10_KEY_KNEAD];
					break;
				case 1:  // 敲击
					[_bleConnector sendControlMode:H10_KEY_KNOCK];
					break;
				case 2:  // 揉敲同步
					[_bleConnector sendControlMode:H10_KEY_WAVELET];
					break;
				case 3:  // 叩击
					[_bleConnector sendControlMode:H10_KEY_SOFT_KNOCK];
					break;
				case 4:  // 指压
					[_bleConnector sendControlMode:H10_KEY_PRESS];
					break;
				case 5:  // 韵律按摩
					[_bleConnector sendControlMode:H10_KEY_MUSIC];
					break;
			}
        }
    }];
    [skillPreferenceAlerView setUseMotionEffects:true];
    [skillPreferenceAlerView show];
}


#pragma mark - 时间选择点击方法
-(void)timeViewTap {
    CustomIOSAlertView* skillPreferenceAlerView = [[CustomIOSAlertView alloc] init];
    [skillPreferenceAlerView setContainerView:_timePickerView];
    [skillPreferenceAlerView setTitleString:@"定时"];
    [skillPreferenceAlerView setButtonTitles:[NSMutableArray arrayWithObjects:@"取消", @"保存", nil]];
    [skillPreferenceAlerView setOnButtonTouchUpInside:^(CustomIOSAlertView *alertView, int buttonIndex) {
        if (buttonIndex == 0) {
            [alertView close];
        } else if (buttonIndex == 1) {
			switch ([_timePickerView getHighlightIndex]) {
				case 0:  // 10分钟
					[_bleConnector sendControlMode:H10_KEY_WORK_TIME_10MIN];
					break;
				case 1:  // 20分钟
					[_bleConnector sendControlMode:H10_KEY_WORK_TIME_20MIN];
					break;
				case 2:  // 30分钟
					[_bleConnector sendControlMode:H10_KEY_WORK_TIME_30MIN];
					break;
			}
        }
    }];
    [skillPreferenceAlerView setUseMotionEffects:true];
    [skillPreferenceAlerView show];
}

#pragma mark - 背部加热方法
-(void)backWarmTap
{
    [_bleConnector sendControlMode:H10_KEY_HEAT_ON];
    _backWarmOn = !_backWarmOn;
    [self updateBcakWarmView];
}

#pragma mark - 脚步滚轮点击方法
-(void)footWheelTap {
//	CustomIOSAlertView *footWheelAlerView = [[CustomIOSAlertView alloc] init];
//	[footWheelAlerView setContainerView:_footWheelPickerView];
//	[footWheelAlerView setTitleString:@"脚部滚轮"];
//	[footWheelAlerView setButtonTitles:[NSMutableArray arrayWithObjects:@"取消", @"保存", nil]];
//	[footWheelAlerView setOnButtonTouchUpInside:^(CustomIOSAlertView *alertView, int buttonIndex) {
//		if (buttonIndex == 0) {
//			[alertView close];
//		} else if (buttonIndex == 1) {
//			
//			switch ([_skillsPreferencePickerView getHighlightIndex]) {
//				case 0:  // 滚轮速度慢
//					[_bleConnector sendControlMode:H10_KEY_WHEEL_SPEED_SLOW];
//					break;
//				case 1:  // 滚轮速度中
//					[_bleConnector sendControlMode:H10_KEY_WHEEL_SPEED_MED];
//					break;
//				case 2:  // 滚轮速度快
//					[_bleConnector sendControlMode:H10_KEY_WHEEL_SPEED_FAST];
//					break;
//				case 3:  // 滚轮关
//					[_bleConnector sendControlMode:H10_KEY_WHEEL_SPEED_OFF];
//					break;
//			}
//		}
//	}];
//	[footWheelAlerView setUseMotionEffects:true];
//	[footWheelAlerView show];
    
    _footWheelOn = !_footWheelOn;
    if (_footWheelOn) {
        [_bleConnector sendControlMode:H10_KEY_WHEEL_SPEED_MED];
        [_polar setPoint:2 ableMove:YES];
        [_polar setValue:6 ByIndex:2];
    }
    else
    {
        [_bleConnector sendControlMode:H10_KEY_WHEEL_SPEED_OFF];
        [_polar setPoint:2 ableMove:NO];
        [_polar setValue:0 ByIndex:2];
    }
    [self updateFootWheelView];
}

#pragma mark - 创建滚轮选择器
- (NAPickerView *)createFootWheelPickerView {
	NAPickerView *pickerView = [[NAPickerView alloc] initWithFrame:CGRectMake(0, 0, 270, 200) andItems:_footWheelArray andDelegate:self];
	pickerView.overlayColor = [UIColor colorWithRed:223.0 / 255.0 green:1 blue:1 alpha:1];
	pickerView.showOverlay = YES;
	pickerView.overlayColor = [UIColor colorWithRed:0 green:0.5 blue:1 alpha:0.5];
	pickerView.delegate = self;
	pickerView.highlightBlock = ^(NALabelCell *cell) {
		cell.textView.textColor = BLUE;
		cell.textView.font = [UIFont systemFontOfSize:30];
	};
	pickerView.unhighlightBlock = ^(NALabelCell *cell) {
		cell.textView.textColor = [UIColor colorWithRed:26/255.0 green:154/255.0 blue:222/255.0 alpha:0.6];
		;
		cell.textView.font = [UIFont systemFontOfSize:18];
	};
	return pickerView;
}

#pragma mark - 创建技法偏好选择器
- (NAPickerView *)createskillsPreferencePickerView
{
    NAPickerView *pickerView = [[NAPickerView alloc] initWithFrame:CGRectMake(0, 0, 270, 200) andItems:_skillsPreferenceArray andDelegate:self];
    pickerView.overlayColor = [UIColor colorWithRed:223.0 / 255.0 green:1 blue:1 alpha:1];
    pickerView.showOverlay = YES;
    pickerView.overlayColor = [UIColor colorWithRed:0 green:0.5 blue:1 alpha:0.5];
    pickerView.delegate = self;
    pickerView.highlightBlock = ^(NALabelCell *cell) {
        cell.textView.textColor = BLUE;
        cell.textView.font = [UIFont systemFontOfSize:30];
    };
    pickerView.unhighlightBlock = ^(NALabelCell *cell) {
        cell.textView.textColor = [UIColor colorWithRed:26/255.0 green:154/255.0 blue:222/255.0 alpha:0.6];
;
        cell.textView.font = [UIFont systemFontOfSize:18];
    };
    return pickerView;
}

#pragma mark - 创建时间选择器
- (NAPickerView *)createMinutePickerView
{
    NSMutableArray *leftItems = [[NSMutableArray alloc] init];
    for (int i = 1; i < 4;  i++) {
        [leftItems addObject:[NSString stringWithFormat:@"%d", i*10]];
    }
    NAPickerView *pickerView = [[NAPickerView alloc] initWithFrame:CGRectMake(0, 0, 270, 200) andItems:leftItems andDelegate:self];
    pickerView.overlayColor = [UIColor colorWithRed:223.0 / 255.0 green:1 blue:1 alpha:1];
    
    pickerView.infiniteScrolling = YES;
    pickerView.overlayLeftImage = [UIImage imageNamed:@"icon_set_time"];
    pickerView.overlayRightString = @"分钟";
    pickerView.showOverlay = YES;
    
    pickerView.highlightBlock = ^(NALabelCell *cell) {
        cell.textView.textColor = BLUE;
        cell.textView.font = [UIFont fontWithName:@"DS-Digital-Bold" size:30];
    };
    pickerView.unhighlightBlock = ^(NALabelCell *cell) {
        cell.textView.textColor = [UIColor colorWithRed:26/255.0 green:154/255.0 blue:222/255.0 alpha:0.6];
        cell.textView.font = [UIFont fontWithName:@"DS-Digital-Bold" size:18];
    };
    return pickerView;
}

#pragma mark - NAPickerViewDelegate

-(void)didSelectedItemAtIndex:(NAPickerView *)pickerView andIndex:(NSInteger)index {
    _pickerSelectedItem = index;
}

#pragma mark - pageControl方法
-(void)pageControlChange:(SMPageControl*)pageControl
{
    CGFloat w = CGRectGetWidth(_scroll.frame);
    CGFloat h = CGRectGetHeight(_scroll.frame);
    if (pageControl.currentPage == 0) {
        [_scroll scrollRectToVisible:CGRectMake(0, 0, w, h) animated:YES];
    }
    else
    {
        [_scroll scrollRectToVisible:CGRectMake(w, 0, w, h) animated:YES];
    }
}

#pragma mark - PolarView代理
-(void)WLPolarWillStartTouch:(WLPolar *)polar
{
    NSLog(@"滑动开始");
    _scroll.scrollEnabled = NO;
    if (_humanView.isSelected) {
        [polar setPoint:1 ableMove:YES];
    }
    else
    {
        [polar setPoint:1 ableMove:NO];
    }
}

-(void)WLPolarDidMove:(WLPolar *)polar
{
    
}

-(void)WLPolarMoveFinished:(WLPolar *)polar index:(NSUInteger)index
{
    NSLog(@"滑动结束");
    _scroll.scrollEnabled = YES;
    NSNumber* n = polar.dataSeries[index];
    float value = [n floatValue];
    if (index == 0)
    {
        //机芯幅度：有三档，宽，中，窄
        if (value<=4) {
            [_bleConnector sendControlMode:H10_KEY_WIDTH_MIN];
        }
        else if (value>4 && value<=8)
        {
            [_bleConnector sendControlMode:H10_KEY_WIDTH_MED];
        }
        else
        {
            [_bleConnector sendControlMode:H10_KEY_WIDTH_MAX];
        }
        
    }
    else if (index == 1)
    {
        //气囊强度，有5档
        if (value<=2.4) {
            [_bleConnector sendControlMode:H10_KEY_AIRBAG_STRENGTH_1];
        }
        else if (value>2.4 && value<=4.8)
        {
            [_bleConnector sendControlMode:H10_KEY_AIRBAG_STRENGTH_2];
        }
        else if (value>4.8 && value<=7.2)
        {
            [_bleConnector sendControlMode:H10_KEY_AIRBAG_STRENGTH_3];
        }
        else if (value>7.2 && value<=9.8)
        {
            [_bleConnector sendControlMode:H10_KEY_AIRBAG_STRENGTH_4];
        }
        else
        {
            [_bleConnector sendControlMode:H10_KEY_AIRBAG_STRENGTH_5];
        }
        
    }
    else if (index == 2)
    {
        //滚轮速度，有三档，可开关
        if (value == 0) {
            [_bleConnector sendControlMode:H10_KEY_WHEEL_SPEED_OFF];
        }
        else if (value<=2) {
            [_bleConnector sendControlMode:H10_KEY_WHEEL_SPEED_SLOW];
        }
        else if (value>2 && value<=4)
        {
            [_bleConnector sendControlMode:H10_KEY_WHEEL_SPEED_MED];
        }
        else
        {
            [_bleConnector sendControlMode:H10_KEY_WHEEL_SPEED_FAST];
        }
    }
    else
    {
        //按摩力度，有6档
        if (value<=2) {
            [_bleConnector sendControlMode:H10_KEY_SPEED_1];
        }
        else if (value>2 && value<=4)
        {
            [_bleConnector sendControlMode:H10_KEY_SPEED_2];
        }
        else if (value>4 && value<=6)
        {
            [_bleConnector sendControlMode:H10_KEY_SPEED_3];
        }
        else if (value>6 && value<=8)
        {
            [_bleConnector sendControlMode:H10_KEY_SPEED_4];
        }
        else if (value>8 && value<=10)
        {
            [_bleConnector sendControlMode:H10_KEY_SPEED_5];
        }
        else
        {
            [_bleConnector sendControlMode:H10_KEY_SPEED_6];
        }
    }
    
}


#pragma mark - scroll代理
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (_scroll.contentOffset.x==0) {
        _pageControl.currentPage = 0;
    }
    else
    {
        _pageControl.currentPage = 1;
    }
}

-(void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    if (_scroll.contentOffset.x==0) {
        _pageControl.currentPage = 0;
    }
    else
    {
        _pageControl.currentPage = 1;
    }
}

#pragma mark - 导航栏右边按钮方法
-(void)rightItemClicked:(id)sender {
    [_bleConnector sendControlMode:H10_KEY_POWER_SWITCH];
}


#pragma mark - tableView代理
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ManualTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:_reuseIdentifier];
    cell.titleLabel.text = _menu[indexPath.row];
    cell.backgroundColor = [UIColor clearColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.delegate = self;
    cell.tag = indexPath.row+1;
    if (indexPath.row < _menu.count - 1) {
        NSInteger i = indexPath.row*2;
        [cell.leftButton setImage:[UIImage imageNamed:_images[i]] forState:0];
        [cell.rightButton setImage:[UIImage imageNamed:_images[i+1]] forState:0];
    }
    else
    {
        [cell.leftButton setImage:[UIImage imageNamed:_images[_images.count -1]] forState:0];
        [cell.rightButton setHidden:YES];
    }
    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _menu.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return _cH*0.6/_menu.count;
}

#pragma mark - cell代理
-(void)manualTableViewCell:(ManualTableViewCell *)cell Clicked:(NSInteger)index UIControlEvents:(UIControlEvents)controlEvent {
	NSLog(@"manualTableViewCell");
	switch (cell.tag) {
		case 1:		// 肩部位置
			if (index == 0) {
				if (controlEvent == UIControlEventTouchDown) {
					NSLog(@"肩部开始");
					[_bleConnector sendControlMode:H10_KEY_WALK_UP_START];
				} else {
					[_bleConnector sendControlMode:H10_KEY_WALK_UP_STOP];
				}
			} else {
				if (controlEvent == UIControlEventTouchDown) {
					[_bleConnector sendControlMode:H10_KEY_WALK_DOWN_START];
				} else {
					[_bleConnector sendControlMode:H10_KEY_WALK_DOWN_STOP];
				}
			}
			break;
		case 2:		// 背部升降
			if (index == 0) {
				if (controlEvent == UIControlEventTouchDown) {
					[_bleConnector sendControlMode:H10_KEY_BACKPAD_DOWN_START];
				} else {
					[_bleConnector sendControlMode:H10_KEY_BACKPAD_DOWN_STOP];
				}
			} else {
				if (controlEvent == UIControlEventTouchDown) {
					[_bleConnector sendControlMode:H10_KEY_BACKPAD_UP_START];
				} else {
					[_bleConnector sendControlMode:H10_KEY_BACKPAD_UP_STOP];
				}
			}
			break;
		case 3:		// 小腿升降
			if (index == 0) {
				if (controlEvent == UIControlEventTouchDown) {
					[_bleConnector sendControlMode:H10_KEY_LEGPAD_DOWN_START];
				} else {
					[_bleConnector sendControlMode:H10_KEY_LEGPAD_DOWN_STOP];
				}
			} else {
				if (controlEvent == UIControlEventTouchDown) {
					[_bleConnector sendControlMode:H10_KEY_LEGPAD_UP_START];
				} else {
					[_bleConnector sendControlMode:H10_KEY_LEGPAD_UP_STOP];
				}
			}
			break;
		case 4:		// 小腿伸缩
			if (index == 0) {
				if (controlEvent == UIControlEventTouchDown) {
					[_bleConnector sendControlMode:H10_KEY_LEGPAD_EXTEND_START];
				} else {
					[_bleConnector sendControlMode:H10_KEY_LEGPAD_EXTEND_STOP];
				}
			} else {
				if (controlEvent == UIControlEventTouchDown) {
					[_bleConnector sendControlMode:H10_KEY_LEGPAD_CONTRACT_START];
				} else {
					[_bleConnector sendControlMode:H10_KEY_LEGPAD_CONTRACT_STOP];
				}
			}
			break;
		case 5:		// 零重力
			[_bleConnector sendControlMode:H10_KEY_ZERO_START];
			break;
	}
}

#pragma mark - 剪头向下旋转
-(void)arrowTurnDown
{
    [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        _arrow.transform = CGAffineTransformMakeRotation(M_PI);
    } completion:^(BOOL finished) {
        
    }];
}

#pragma mark - 剪头向上旋转
-(void)arrowTurnUp
{
    [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        _arrow.transform = CGAffineTransformMakeRotation(0);
    } completion:^(BOOL finished) {
        
    }];
}

#pragma mark - panAlertView代理

-(void)wlPanAlertViewDidPan:(WLPanAlertView *)panAlertView ByDirection:(BOOL)isDown
{
    _bgCircle.image = [UIImage imageNamed:@"button_set_bg2"];
}

-(void)wlPanAlertViewDidDown:(WLPanAlertView *)panAlertView
{
    _bgCircle.image = [UIImage imageNamed:@"button_set_bg"];
    [self arrowTurnUp];
}

-(void)wlPanAlertViewDidAlert:(WLPanAlertView *)panAlertView
{
    [self arrowTurnDown];
}

-(void)wlPanAlertViewWillAlert:(WLPanAlertView *)panAlertView
{
    _bgCircle.image = [UIImage imageNamed:@"button_set_bg2"];
}

#pragma mark - 更新背部加热View
-(void)updateBcakWarmView
{
    if (_backWarmOn) {
        _backWarmImagaView.image = [UIImage imageNamed:@"function_1_select"];
        _backWarmLabel.textColor = ORANGE;
    }
    else
    {
        _backWarmImagaView.image = [UIImage imageNamed:@"function_1"];
        _backWarmLabel.textColor = [UIColor colorWithRed:202/255.0 green:202/255.0 blue:202/255.0 alpha:1.0];
    }
}

#pragma mark - 更新脚步滚轮View
-(void)updateFootWheelView
{
    if (_footWheelOn) {
        [_footWheelImageView setImage:[UIImage imageNamed:@"function_2_select"]];
        _footWheelLabel.textColor = ORANGE;
    }
    else
    {
        [_footWheelImageView setImage:[UIImage imageNamed:@"function_2"]];
        _footWheelLabel.textColor = [UIColor colorWithRed:202/255.0 green:202/255.0 blue:202/255.0 alpha:1.0];
    }
}

#pragma mark - 根据按摩状态更新极线图
-(void)updateWLPolarView
{
    if (_bleConnector.rtMassageChairStatus.deviceStatus == RtMassageChairStatusMassaging) {
        switch (_bleConnector.rtMassageChairStatus.massageTechnique) {
            case RTMassageChairMassageTechniqueKnead:
                //揉捏
                [_polar setPoint:0 ableMove:NO];
                [_polar setPoint:3 ableMove:YES];
                break;
            case RTMassageChairMassageTechniqueKnock:
                //敲击
                [_polar setPoint:0 ableMove:YES];
                [_polar setPoint:3 ableMove:YES];
                break;
            case RTMassageChairMassageTechniqueSync:
                //揉敲
                [_polar setPoint:0 ableMove:NO];
                [_polar setPoint:3 ableMove:YES];
                break;
            case RTMassageChairMassageTechniqueTapping:
                //叩击
                [_polar setPoint:0 ableMove:YES];
                [_polar setPoint:3 ableMove:YES];
                break;
            case RTMassageChairMassageTechniqueShiatsu:
                //指压
                [_polar setPoint:0 ableMove:YES];
                [_polar setPoint:3 ableMove:NO];
                break;
            case RTMassageChairMassageTechniqueRhythm:
                //韵律
                [_polar setPoint:0 ableMove:NO];
                [_polar setPoint:3 ableMove:NO];
                break;
            case RTMassageChairMassageTechniqueStop:
                //停止
                [_polar setPoint:0 ableMove:NO];
                [_polar setPoint:3 ableMove:NO];
                break;
            default:
                break;
        }
    }
    else
    {
        [_polar setPoint:0 ableMove:NO];
        [_polar setPoint:3 ableMove:NO];
    }
    
    [_polar setValue:_bleConnector.rtMassageChairStatus.kneadWidthFlag*4 ByIndex:0];
    [_polar setValue:_bleConnector.rtMassageChairStatus.airPressureFlag*2.4 ByIndex:1];
    [_polar setValue:_bleConnector.rtMassageChairStatus.movementSpeedFlag*2 ByIndex:3];
}

#pragma mark - RTBleConnectorDelegate

- (void)didUpdateMassageChairStatus:(RTMassageChairStatus *)rtMassageChairStatus {
	
//	NSLog(@"didUpdateMassageChairStatus");
	
	// 以下是界面跳转
	
	if (rtMassageChairStatus.deviceStatus == RtMassageChairStatusMassaging) {
//		if (rtMassageChairStatus.figureCheckFlag == 1) {  // 执行体型检测程序
//			[self jumpToScanViewConroller];
//		}
		
		if (rtMassageChairStatus.programType == RtMassageChairProgramAuto) {  // 跳到自动按摩界面
			[self jumpToAutoMassageViewConroller];
		}
	}
	
	if (rtMassageChairStatus.deviceStatus == RtMassageChairStatusResetting) {
		[self.resettingDialog show];
	} else {
		[self.resettingDialog close];
	}
    
	
	// 以下是界面状态更新
	
	// 背部加热
    _backWarmOn = rtMassageChairStatus.isHeating;
    [self updateBcakWarmView];
	
	// 脚部滚轮
    _footWheelOn = rtMassageChairStatus.isRollerOn;
    if (_footWheelOn) {
        [_polar setValue:_bleConnector.rtMassageChairStatus.footAirBagFlag*4 ByIndex:2];
        [_polar setPoint:2 ableMove:YES];
    }
    else
    {
        [_polar setPoint:2 ableMove:NO];
        [_polar setValue:0 ByIndex:2];
    }
    [self updateFootWheelView];
	
	// 按摩模式
	if (rtMassageChairStatus.massageTechniqueFlag != 0) {
		if (rtMassageChairStatus.massageTechniqueFlag == 7) {
			_skillsPreferenceLabel.text = @"搓背";
		} else {
			_skillsPreferenceLabel.text = _skillsPreferenceArray[rtMassageChairStatus.massageTechniqueFlag - 1];
		}
	}
	
	if (rtMassageChairStatus.deviceStatus == RtMassageChairStatusMassaging) {
		// 按摩剩余工作时间
		NSInteger minutes = rtMassageChairStatus.remainingTime / 60;
		NSInteger seconds = rtMassageChairStatus.remainingTime % 60;
		_timeLabel.text = [NSString stringWithFormat:@"%02zd:%02zd", minutes, seconds];
        
        //极线图更新
        [self updateWLPolarView];
        
    
	} else {
		// 预设时间
		_timeLabel.text = [NSString stringWithFormat:@"%02zd:%02zd", rtMassageChairStatus.preprogrammedTime, 0];
	}
	// 气囊程序
	[_humanView checkButtonByAirBagProgram:rtMassageChairStatus.airBagProgram];
	
}

@end
