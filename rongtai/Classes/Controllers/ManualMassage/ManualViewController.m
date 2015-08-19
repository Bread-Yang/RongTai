//
//  ManualViewController.m
//  rongtai
//
//  Created by William-zhang on 15/7/17.
//  Copyright (c) 2015年 William-zhang. All rights reserved.
//

#import "ManualViewController.h"
#import "ManualHumanView.h"
#import "WLPolar.h"
#import "RongTaiConstant.h"
#import "SMPageControl.h"
#import "CustomIOSAlertView.h"
#import "NAPickerView.h"
#import "SlideNavigationController.h"
#import "RTCommand.h"
#import "AdjustView.h"


@interface ManualViewController ()<NAPickerViewDelegate,WLPolarDelegate, RTBleConnectorDelegate, ManualHumanViewDelegate,UIScrollViewDelegate> {
    
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
    
    __weak IBOutlet UIButton *_stopBtn;
    //
    RTBleConnector* _bleConnector;
    
    //
    NSTimeInterval _delay; //延迟更新单位时间，默认200ms，即按摩椅主板信号更新一次的时间
    NSUInteger _delayMul;
    BOOL _isDelayUpdate;  //是否延迟更新
    BOOL _isTouch;  //记录PolarView是否被触摸
    BOOL _isMoving; //记录PolarView是否在移动

    //测试用
    NSInteger _scan;

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
    
    //停止按摩圆角
    _stopBtn.layer.cornerRadius = SCREENHEIGHT*0.05*0.5;
    
    //创建scrollView
    CGFloat w = SCREENWIDTH;
    CGFloat h = SCREENHEIGHT*0.5;
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
    _humanView.delegate = self;
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
    
    [_polar setPoint:3 MaxLimit:12 MinLimit:2];
    [_polar setPoint:0 MaxLimit:12 MinLimit:4];
    
    
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
    
    //
    _scan = 0;
    
    //
    _delay = 0.2;
    _delayMul = 2;

}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
    
    //按摩调节View出现
    [[AdjustView shareView] show];
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    //按摩调节View消失
    [[AdjustView shareView] hidden];
}

#pragma mark - 停止按钮方法
- (IBAction)stopMassage:(id)sender {
    if (_bleConnector.rtMassageChairStatus.deviceStatus == RtMassageChairStatusMassaging) {
        [_bleConnector sendControlMode:H10_KEY_POWER_SWITCH];
    }
}

#pragma mark - 返回
-(void)goBack
{
    //退出手动按摩的时候，发送复位命令
    if (_bleConnector.rtMassageChairStatus.deviceStatus == RtMassageChairStatusMassaging) {
        [_bleConnector sendControlMode:H10_KEY_POWER_SWITCH];
    }
    else
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
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
    _isDelayUpdate = YES;
    _delayMul = 5;
    [_bleConnector sendControlMode:H10_KEY_HEAT_ON];
    _backWarmOn = !_backWarmOn;
    [self updateBcakWarmView];
}

#pragma mark - 脚步滚轮点击方法
-(void)footWheelTap {
    _isDelayUpdate = YES;
    _delayMul = 3;
    _footWheelOn = !_footWheelOn;
    if (_footWheelOn) {
        [_bleConnector sendControlMode:H10_KEY_WHEEL_SPEED_MED];
        [_polar setPoint:2 ableMove:YES];
        [_polar setValue:2*4 ByIndex:2];
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
    _isTouch = YES;
    _delayMul = 1;
    _isMoving = YES;
}

-(void)WLPolarDidMove:(WLPolar *)polar
{
    _isMoving = YES;
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
        else if (value<=8)
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
        if (value <=0) {
            //等于0就关闭
            [_bleConnector sendControlMode:H10_KEY_AIRBAG_STRENGTH_OFF];
        }
        else if (value<=2.4) {
            [_bleConnector sendControlMode:H10_KEY_AIRBAG_STRENGTH_1];
        }
        else if (value<=4.8)
        {
            [_bleConnector sendControlMode:H10_KEY_AIRBAG_STRENGTH_2];
        }
        else if (value<=7.2)
        {
            [_bleConnector sendControlMode:H10_KEY_AIRBAG_STRENGTH_3];
        }
        else if (value<=9.8)
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
        if (value <= 0) {
            [_bleConnector sendControlMode:H10_KEY_WHEEL_SPEED_OFF];
        }
        else if (value<=4) {
            [_bleConnector sendControlMode:H10_KEY_WHEEL_SPEED_SLOW];
        }
        else if (value<=8)
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
    _isMoving = NO;
    [self performSelector:@selector(touchNo) withObject:nil afterDelay:0.2];
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
                [_polar setPoint:0 ableMove:NO];
                [_polar setPoint:3 ableMove:NO];
                break;
        }
    }
    else
    {
        [_polar setPoint:0 ableMove:NO];
        [_polar setPoint:3 ableMove:NO];
    }
    [self setPolarValue:_bleConnector.rtMassageChairStatus.kneadWidthFlag
              stepValue:4 ByIndex:0];
    [self setPolarValue:_bleConnector.rtMassageChairStatus.airPressureFlag stepValue:2.4 ByIndex:1];
    [self setPolarValue:_bleConnector.rtMassageChairStatus.movementSpeedFlag stepValue:2 ByIndex:3];
}

#pragma mark - 设置PolarView的值
-(void)setPolarValue:(NSInteger)level stepValue:(float)stepValue ByIndex:(NSUInteger)index
{
    NSNumber* n = _polar.dataSeries[index];
    float currentValue = [n floatValue];
    if (currentValue>level*stepValue || currentValue<=(level-1)*stepValue) {
        NSLog(@"😄%ld调节值",index);
        [_polar setValue:level*stepValue ByIndex:index];
    }
}

#pragma mark - ManualHumanViewDelegate
-(void)maualHumanViewClicked:(ManualHumanView *)view
{
//    NSLog(@"HumanView被点击");
    _isDelayUpdate = YES;
    _delayMul = 4;
}

#pragma mark - RTBleConnectorDelegate

- (void)didUpdateMassageChairStatus:(RTMassageChairStatus *)rtMassageChairStatus {
	
//	NSLog(@"didUpdateMassageChairStatus");
    
//    NSLog(@"负离子:%ld",rtMassageChairStatus.anionSwitchFlag);
  
    
//    NSLog(@"体型检测：%ld",rtMassageChairStatus.figureCheckFlag);
//    if (rtMassageChairStatus.figureCheckFlag == 0) {
//        _scan++;
//    }
//    else
//    {
//        NSLog(@"出现1了：%ld",_scan);
//        _scan=0;
//    }
    
//    NSLog(@"机芯位置：%ld",rtMassageChairStatus.kneadWidthFlag);
	
	// 以下是界面跳转
	
	if (rtMassageChairStatus.deviceStatus == RtMassageChairStatusMassaging) {
//		if (rtMassageChairStatus.figureCheckFlag == 1) {  // 执行体型检测程序
//			[self jumpToScanViewConroller];
//		}
		
		if (rtMassageChairStatus.programType == RtMassageChairProgramAuto) {
         // 跳到自动按摩界面
			[self jumpToAutoMassageViewConroller];
		}
	}
	
	if (rtMassageChairStatus.deviceStatus == RtMassageChairStatusResetting) {
		[self.resettingDialog show];
	} else {
		[self.resettingDialog close];
	}
    
	// 以下是界面状态更新
    if (_isDelayUpdate) {
        //延迟更新
        [self performSelector:@selector(dalayNO) withObject:nil afterDelay:_delay*_delayMul];
    }
    else
    {
        //即时更新
        [self updateUI];
    }
}

-(void)dalayNO
{
    _isDelayUpdate = NO;
}

-(void)touchNo
{
    if (!_isMoving) {
        //不是移动中才允许修改成NO，避免延迟调用该方法的时候，正好是用户在操作极线图
        _isTouch = NO;
    }
}

-(void)updateUI
{
    // 背部加热
    _backWarmOn = _bleConnector.rtMassageChairStatus.isHeating;
    [self updateBcakWarmView];
    
    // 脚部滚轮
    _footWheelOn = _bleConnector.rtMassageChairStatus.isRollerOn;
    if (_footWheelOn) {
        if (!_isTouch) {
            [self setPolarValue:_bleConnector.rtMassageChairStatus.rollerSpeedFlag stepValue:4 ByIndex:2];
            [_polar setPoint:2 ableMove:YES];
        }
    }
    else
    {
        [_polar setPoint:2 ableMove:NO];
        [_polar setValue:0 ByIndex:2];
    }
    [self updateFootWheelView];
    
    // 按摩模式
    if (_bleConnector.rtMassageChairStatus.massageTechniqueFlag != 0) {
//        NSLog(@"按摩手法:%ld",_bleConnector.rtMassageChairStatus.massageTechniqueFlag);
        if (_bleConnector.rtMassageChairStatus.massageTechniqueFlag == 7) {
            _skillsPreferenceLabel.text = @"搓背";
            UIAlertView* alert = [[UIAlertView alloc]initWithTitle:@"😱" message:@"居然出现搓背了" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles: nil];
            [alert show];
        } else {
            _skillsPreferenceLabel.text = _skillsPreferenceArray[_bleConnector.rtMassageChairStatus.massageTechniqueFlag - 1];
        }
    }
    
    //极线图更新
    if (!_isTouch) {
        //极线图在触摸移动时不更新
        [self updateWLPolarView];
    }
    
    if (_bleConnector.rtMassageChairStatus.deviceStatus == RtMassageChairStatusMassaging) {
        // 按摩剩余工作时间
        NSInteger minutes = _bleConnector.rtMassageChairStatus.remainingTime / 60;
        NSInteger seconds = _bleConnector.rtMassageChairStatus.remainingTime % 60;
        _timeLabel.text = [NSString stringWithFormat:@"%02zd:%02zd", minutes, seconds];
    } else {
        // 预设时间
        _timeLabel.text = [NSString stringWithFormat:@"%02zd:%02zd", _bleConnector.rtMassageChairStatus.preprogrammedTime, 0];
    }
    // 气囊程序
    [_humanView checkButtonByAirBagProgram:_bleConnector.rtMassageChairStatus.airBagProgram];
    
    if (_humanView.isSelected) {
        [_polar setPoint:1 ableMove:YES];
    }
    else
    {
        [_polar setPoint:1 ableMove:NO];
    }
}

@end
