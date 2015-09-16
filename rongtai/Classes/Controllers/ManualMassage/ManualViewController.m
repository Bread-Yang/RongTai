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
#import "CoreData+MagicalRecord.h"

@interface ManualViewController ()<NAPickerViewDelegate,WLPolarDelegate, RTBleConnectorDelegate, ManualHumanViewDelegate,UIScrollViewDelegate,UIAlertViewDelegate> {
    
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
    NSArray* _skillsPreferenceName;  //技法偏好数组
    NAPickerView *_skillsPreferencePickerView;  //技法偏好选择器
    
    __weak IBOutlet UILabel *_skillsPreferenceLabel;
    __weak IBOutlet UIImageView *_skillsPreferenceImageView;
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
    NSUInteger _delayOfBackWarm;  //背部加热延迟更新标识
    NSUInteger _delayOfFootWheel; //脚部滚轮延迟更新标识
    NSUInteger _delayOfHumanView; //气囊人体图延迟更新标识
    
    BOOL _isTouch;  //记录PolarView是否被触摸
    BOOL _isMoving; //记录PolarView是否在移动
    NSInteger _delayCount;  //倒数延迟更新，对于“机芯幅度”调节才使用
    
    //
    NSInteger _massageWay;  //按摩方式
    NSInteger _massageFlag;
    NSString* _programName;
    
    NSInteger flag;
    
    ProgramCount* _programCount;
    
    BOOL _isJumpFinish;
    
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
//	_footWheelArray = @[@"滚轮速度慢", @"滚轮速度中", @"滚轮速度快", @"滚轮关"];
	
    //技法偏好类型数组
    _skillsPreferenceArray = @[NSLocalizedString(@"揉捏", nil), NSLocalizedString(@"叩击", nil), NSLocalizedString(@"敲击", nil), NSLocalizedString(@"指压", nil), NSLocalizedString(@"揉敲", nil), NSLocalizedString(@"韵律", nil)];
    
    _skillsPreferenceName = @[NSLocalizedString(@"揉捏", nil), NSLocalizedString(@"敲击", nil), NSLocalizedString(@"揉敲", nil), NSLocalizedString(@"叩击", nil), NSLocalizedString(@"指压", nil), NSLocalizedString(@"韵律", nil)];
    
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
    _polar.steps = 4;
    _polar.r = h*0.3;
    _polar.minValue = 0;
    _polar.maxValue = 12;
    _polar.drawPoints = YES;
    _polar.fillArea = YES;
    _polar.delegate = self;
    _polar.backgroundLineColorRadial = [UIColor colorWithRed:200/255.0 green:225/255.0 blue:233/255.0 alpha:1];
    _polar.fillColor = [UIColor colorWithRed:0 green:230/255.0 blue:0 alpha:0.3];
    _polar.lineColor = [UIColor colorWithRed:0 green:230/255.0 blue:0 alpha:0.8];
    _polar.attributes = @[@"机芯幅度", @"气囊强度",@"滚轮速度",@"按摩力度"];
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
    _delayCount = 0;
    _delayOfBackWarm = 0;
    _delayOfFootWheel = 0;
    _delayOfHumanView = 0;
    
    _isJumpFinish = YES;
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
    
    //按摩调节View出现
    [[AdjustView shareView] show];
    
    //
    [self updateUI];
    
    if (_bleConnector.rtMassageChairStatus.deviceStatus == RtMassageChairStatusMassaging) {
         _massageFlag = _bleConnector.rtMassageChairStatus.massageProgramFlag;
    }
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
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - 技法偏好点击方法
-(void)skillsPreferenceTap {
    CustomIOSAlertView* skillPreferenceAlerView = [[CustomIOSAlertView alloc] init];
    [skillPreferenceAlerView setContainerView:_skillsPreferencePickerView];
    [skillPreferenceAlerView setTitleString:NSLocalizedString(@"模式", nil)];
    [skillPreferenceAlerView setButtonTitles:[NSMutableArray arrayWithObjects:NSLocalizedString(@"取消", nil), NSLocalizedString(@"保存", nil), nil]];
    [skillPreferenceAlerView setOnButtonTouchUpInside:^(CustomIOSAlertView *alertView, int buttonIndex) {
        if (buttonIndex == 0) {
            [alertView close];
        } else if (buttonIndex == 1) {
            //保存方法
//            NSString* sp = _skillsPreferenceArray[_pickerSelectedItem];
//            _skillsPreferenceLabel.text = sp;
            NSLog(@"发生按摩指令");
			switch ([_skillsPreferencePickerView getHighlightIndex]) {
				case 0:  // 揉捏
					[_bleConnector sendControlMode:H10_KEY_KNEAD];
					break;
                case 1:  // 叩击
                    [_bleConnector sendControlMode:H10_KEY_SOFT_KNOCK];
					break;
				case 2:  //敲击
					[_bleConnector sendControlMode: H10_KEY_KNOCK];
					break;
                case 3: // 指压
                    [_bleConnector sendControlMode:H10_KEY_PRESS];
                    break;
                case 4:  //揉敲
                    [_bleConnector sendControlMode:H10_KEY_WAVELET];
					break;
				case 5:  // 韵律
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
    [skillPreferenceAlerView setTitleString:NSLocalizedString(@"定时", nil)];
    [skillPreferenceAlerView setButtonTitles:[NSMutableArray arrayWithObjects:NSLocalizedString(@"取消", nil), NSLocalizedString(@"保存", nil), nil]];
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
    _delayOfBackWarm = 5;
    [_bleConnector sendControlMode:H10_KEY_HEAT_ON];
    _backWarmOn = !_backWarmOn;
    [self updateBcakWarmView];
}

#pragma mark - 脚步滚轮点击方法
-(void)footWheelTap {
    _delayOfFootWheel = 3;
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
    pickerView.overlayRightString = NSLocalizedString(@"分钟", nil);
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
-(void)didSelectedItemAtIndex:(NAPickerView *)pickerView andIndex:(NSInteger)index
{
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
        _delayCount = 8;  //当调节机芯幅度时，设置延迟更新次数，_delayCount会开始递减，直到小于1时才更新WLPolarView的“机芯幅度”轴
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
//        滚轮速度，有三档，可开关
        if (value <= 0) {
            [_bleConnector sendControlMode:H10_KEY_WHEEL_SPEED_OFF];
        }
        else
        if (value<=4) {
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
	[[RTBleConnector shareManager] sendControlMode:H10_KEY_OZON_SWITCH];
    
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

#pragma mark - 更新手动按摩模式颜色
-(void)updateSkillsPreferenceView:(BOOL)isManual
{
    if (isManual) {
        [_skillsPreferenceImageView setImage:[UIImage imageNamed:@"function_3_select"]];
        _skillsPreferenceLabel.textColor = ORANGE;
    }
    else
    {
        [_skillsPreferenceImageView setImage:[UIImage imageNamed:@"function_3"]];
        _skillsPreferenceLabel.textColor = [UIColor colorWithRed:202/255.0 green:202/255.0 blue:202/255.0 alpha:1.0];
        _skillsPreferenceLabel.text = NSLocalizedString(@"请选择", nil);
    }
}

#pragma mark - 更新机芯幅度和按摩力度的极线图
-(void)updateWidthAndPowerInPolarView
{
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
    if (_delayCount <1) {
        //_delayCount小于1更新
        [self setPolarValue:_bleConnector.rtMassageChairStatus.kneadWidthFlag
                  stepValue:4 ByIndex:0];
    }
    
    [self setPolarValue:_bleConnector.rtMassageChairStatus.movementSpeedFlag stepValue:2 ByIndex:3];
}

#pragma mark - 设置PolarView的值
-(void)setPolarValue:(NSInteger)level stepValue:(float)stepValue ByIndex:(NSUInteger)index
{
    NSNumber* n = _polar.dataSeries[index];
    float currentValue = [n floatValue];
    if (currentValue>level*stepValue || currentValue<=(level-1)*stepValue) {
//        NSLog(@"%ld调节值",index);
        [_polar setValue:level*stepValue ByIndex:index];
    }
}

#pragma mark - ManualHumanViewDelegate
-(void)maualHumanViewClicked:(ManualHumanView *)view
{
//    NSLog(@"HumanView被点击");
    _delayOfHumanView = 4;
}

#pragma mark - RTBleConnectorDelegate

- (void)didUpdateMassageChairStatus:(RTMassageChairStatus *)rtMassageChairStatus
{
//    NSLog(@"didUpdateMassageChairStatus:%@",[NSDate date]);
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
    
    if (_bleConnector.rtMassageChairStatus.deviceStatus == RtMassageChairStatusMassaging)
    {
        //按摩中
        if (_bleConnector.rtMassageChairStatus.programType == RtMassageChairProgramManual)
        {
            if (_massageFlag != 7) {
                
                NSLog(@"切换到手动按摩");
                //从自动按摩切换过来的话，需要进行按摩时间和次数统计
                [self countMassageTime];
                _bleConnector.startTime = [NSDate date];
                _massageFlag = rtMassageChairStatus.massageProgramFlag;
            }
            //手动按摩
            _stopBtn.hidden = NO;
            if (!_isTouch) {
                //极线图不被用户触摸才更新状态
                //更新极线图中的机芯幅度和按摩力度
                if (_delayCount>0) {
                    _delayCount--;
                }
                [self updateWidthAndPowerInPolarView];
            }
            
            //按摩模式
            flag = _bleConnector.rtMassageChairStatus.massageTechniqueFlag;
            if (flag>0&&flag<7) {
                _skillsPreferenceLabel.text = _skillsPreferenceName[flag-1];
                [self updateSkillsPreferenceView:YES];
            }
            
            //定时
            NSInteger minutes = _bleConnector.rtMassageChairStatus.remainingTime / 60;
            NSInteger seconds = _bleConnector.rtMassageChairStatus.remainingTime % 60;
            _timeLabel.text = [NSString stringWithFormat:@"%02zd:%02zd", minutes, seconds];
            
            //手动按摩中，滚轮可调节速度
            [_polar setPoint:2 ableMove:YES];
        }
        else if (_bleConnector.rtMassageChairStatus.programType == RtMassageChairProgramAuto ||_bleConnector.rtMassageChairStatus.programType == RtMassageChairProgramNetwork)
        {
            //自动按摩
            if (_massageFlag != rtMassageChairStatus.massageProgramFlag) {
                if (_massageFlag == 7 || _massageFlag == 0) {
                    //每次切换到自动按摩程序的时候，就设置开始按摩时间
                    [self countMassageTime];
                    
                    _bleConnector.startTime = [NSDate date];
                    NSLog(@"切换到自动按摩");
                    NSLog(@"设置开始时间");
                    if (_massageFlag == 7) {
                        //手动切换要弹框
                        //自动切换到手动，弹出提示框
                        NSLog(@"切换到自动了");
                        _isJumpFinish = NO;
                        CustomIOSAlertView* alert = [[CustomIOSAlertView alloc]init];
                        [alert setTitleString:@"提示"];
                        UILabel* l = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, SCREENWIDTH*0.8, SCREENHEIGHT*0.15)];
                        l.text = @"已切换到自动模式";
                        l.textAlignment = NSTextAlignmentCenter;
                        l.textColor = [UIColor lightGrayColor];
                        [alert setContainerView:l];
                        
                        [alert setButtonTitles:@[NSLocalizedString(@"确定", nil)]];
                        [alert setOnButtonTouchUpInside:^(CustomIOSAlertView *alertView, int buttonIndex) {
                            [self.navigationController popViewControllerAnimated:YES];
                        }];
                        [alert setUseMotionEffects:true];
                        [alert show];
                    }
                }
                else
                {
                    NSLog(@"更换自动按摩种类:%ld",_massageFlag);
                    //切换自动按摩程序种类，需要进行按摩时间和次数统计
                    [self countMassageTime];
                    //再次设置开始时间
                    _bleConnector.startTime = [NSDate date];
                }
                _massageFlag = rtMassageChairStatus.massageProgramFlag;
            }
            //自动按摩 或 网络按摩
            [self unManualMassageUI];
            [self setPolarValue:_bleConnector.rtMassageChairStatus.kneadWidthFlag
                      stepValue:4 ByIndex:0];
            [self setPolarValue:_bleConnector.rtMassageChairStatus.movementSpeedFlag stepValue:2 ByIndex:3];
            
            //自动按摩中，滚轮不可调节速度
            [_polar setPoint:2 ableMove:NO];
        }
        else
        {
            //未知情况
            NSLog(@"按摩中，但出现了按摩状态");
            [self unManualMassageUI];
        }
        
        //更新脚部滚轮
        if (_delayOfFootWheel<1) {
            _footWheelOn = _bleConnector.rtMassageChairStatus.isRollerOn;
            [self updateFootWheelView];
        }
        else
        {
            _delayOfFootWheel--;
        }
        
        if (!_isTouch) {
//            NSLog(@"脚步滚轮:%ld",_bleConnector.rtMassageChairStatus.rollerSpeedFlag);
            [self setPolarValue:_bleConnector.rtMassageChairStatus.rollerSpeedFlag stepValue:4 ByIndex:2];
        }
        
        //更新背部加热
        if (_delayOfBackWarm < 1) {
            _backWarmOn = _bleConnector.rtMassageChairStatus.isHeating;
            [self updateBcakWarmView];
        }
        else
        {
            _delayOfBackWarm--;
        }
        
        //更新气囊状态
        if (_delayOfHumanView<1) {
            [_humanView checkButtonByAirBagProgram:_bleConnector.rtMassageChairStatus.airBagProgram];
        }
        else
        {
            _delayOfHumanView--;
        }
        
        if (_humanView.isSelected) {
            [_polar setPoint:1 ableMove:YES];
            if (!_isTouch) {
                [self setPolarValue:_bleConnector.rtMassageChairStatus.airPressureFlag stepValue:2.4 ByIndex:1];
            }
        }
        else
        {
            [_polar setPoint:1 ableMove:NO];
            [self setPolarValue:_bleConnector.rtMassageChairStatus.airPressureFlag stepValue:2.4 ByIndex:1];
        }
        
        //
        [self.resettingDialog close];
        
    }
    else if (_bleConnector.rtMassageChairStatus.deviceStatus == RtMassageChairStatusResetting)
    {
        //复位中
        [self unManualMassageUI];
        [self unAirBagProgram];
        [self.resettingDialog show];
        [self countMassageTime];
    }
    else
    {
        //其他状态
        [self unManualMassageUI];
        [self unAirBagProgram];
        if (self.resettingDialog.isShowing) {
            [self.resettingDialog close];
            if (_isJumpFinish&&_massageFlag!=7) {
                [self jumpToFinishMassageViewConroller];
            }
        }
    }
}

#pragma mark - 更新界面
-(void)updateUI
{
    if (_bleConnector.rtMassageChairStatus.deviceStatus == RtMassageChairStatusMassaging)
    {
        //按摩中
        _massageFlag = _bleConnector.rtMassageChairStatus.massageProgramFlag;
        if (_bleConnector.rtMassageChairStatus.programType == RtMassageChairProgramManual)
        {
            //手动按摩
            _stopBtn.hidden = NO;
            if (!_isTouch) {
                //极线图不被用户触摸才更新状态
                //更新极线图中的机芯幅度和按摩力度
                if (_delayCount>0) {
                    _delayCount--;
                }
                [self updateWidthAndPowerInPolarView];
            }
            
            //按摩模式
            NSInteger flag = _bleConnector.rtMassageChairStatus.massageTechniqueFlag;
            if (flag>0&&flag<7) {
                _skillsPreferenceLabel.text = _skillsPreferenceName[flag-1];
                [self updateSkillsPreferenceView:YES];
            }
            
            //定时
            NSInteger minutes = _bleConnector.rtMassageChairStatus.remainingTime / 60;
            NSInteger seconds = _bleConnector.rtMassageChairStatus.remainingTime % 60;
            _timeLabel.text = [NSString stringWithFormat:@"%02zd:%02zd", minutes, seconds];
            
            //手动按摩中，滚轮可调节速度
            [_polar setPoint:2 ableMove:NO];

        }
        else if (_bleConnector.rtMassageChairStatus.programType == RtMassageChairProgramAuto ||_bleConnector.rtMassageChairStatus.programType == RtMassageChairProgramNetwork)
        {
            //自动按摩 或 网络按摩
            [self unManualMassageUI];
            [self setPolarValue:_bleConnector.rtMassageChairStatus.kneadWidthFlag
                      stepValue:4 ByIndex:0];
            [self setPolarValue:_bleConnector.rtMassageChairStatus.movementSpeedFlag stepValue:2 ByIndex:3];
            
            //自动按摩中，滚轮不可调节速度
            [_polar setPoint:2 ableMove:NO];
        }
        else
        {
            //未知情况
            NSLog(@"按摩中，但出现了按摩状态");
            [self unManualMassageUI];
        }
        
        //更新脚部滚轮
        if (_delayOfFootWheel<1) {
            _footWheelOn = _bleConnector.rtMassageChairStatus.isRollerOn;
            [self updateFootWheelView];
        }
        else
        {
            _delayOfFootWheel--;
        }
        
        if (_footWheelOn) {
            if (!_isTouch) {
                [self setPolarValue:_bleConnector.rtMassageChairStatus.rollerSpeedFlag stepValue:4 ByIndex:2];
            }
        }
        else
        {
            [_polar setPoint:2 ableMove:NO];
            [_polar setValue:0 ByIndex:2];
        }
        
        
        //更新背部加热
        if (_delayOfBackWarm < 1) {
            _backWarmOn = _bleConnector.rtMassageChairStatus.isHeating;
            [self updateBcakWarmView];
        }
        else
        {
            _delayOfBackWarm--;
        }
        
        //更新气囊状态
        if (_delayOfHumanView<1) {
            [_humanView checkButtonByAirBagProgram:_bleConnector.rtMassageChairStatus.airBagProgram];
        }
        else
        {
            _delayOfHumanView--;
        }
        
        if (_humanView.isSelected) {
            [_polar setPoint:1 ableMove:YES];
            if (!_isTouch) {
                [self setPolarValue:_bleConnector.rtMassageChairStatus.airPressureFlag stepValue:2.4 ByIndex:1];
            }
        }
        else
        {
            [_polar setPoint:1 ableMove:NO];
        }
        
        //
        [self.resettingDialog close];
        
    }
    else if (_bleConnector.rtMassageChairStatus.deviceStatus == RtMassageChairStatusResetting)
    {
        //复位中
        [self unManualMassageUI];
        [self unAirBagProgram];
        [self.resettingDialog show];
        
    }
    else
    {
        //其他状态
        [self unManualMassageUI];
        [self unAirBagProgram];
        [self.resettingDialog close];
    }
}

-(void)touchNo
{
    if (!_isMoving) {
        //不是移动中才允许修改成NO，避免延迟调用该方法的时候，正好是用户在操作极线图
        _isTouch = NO;
    }
}

#pragma mark - 非手动按摩UI固定设置
-(void)unManualMassageUI
{
    //停止按钮隐藏
    _stopBtn.hidden = YES;
    //把手动按摩模式改成灰色
    [self updateSkillsPreferenceView:NO];
    //手动时间设置为零
    _timeLabel.text = [NSString stringWithFormat:@"%02zd:%02zd", _bleConnector.rtMassageChairStatus.preprogrammedTime, 0];
    //极线图设置不能移动
    [_polar setPoint:0 ableMove:NO];
    [_polar setPoint:3 ableMove:NO];
}

#pragma mark - 没有脚部滚轮，没有背部加热， 没有打开气囊
-(void)unAirBagProgram
{
    _footWheelOn = NO;
    [self updateFootWheelView];
    [_polar setPoint:2 ableMove:NO];
    [self setPolarValue:0 stepValue:2 ByIndex:2];
    
    _backWarmOn = NO;
    [self updateBcakWarmView];
    
    [_humanView checkButtonByAirBagProgram:RTMassageChairAirBagProgramNone];
    [_polar setPoint:1 ableMove:NO];
    [self setPolarValue:0 stepValue:2 ByIndex:1];
    
    [self setPolarValue:0 stepValue:2 ByIndex:0];
    [self setPolarValue:0 stepValue:2 ByIndex:3];
}

#pragma mark - 计算按摩时间
-(void)countMassageTime
{
    //计算按摩时间
    NSDate* end = [NSDate date];
    NSDate* start = _bleConnector.startTime;
    NSLog(@"开始时间:%@",start);
    if (start) {
        NSLog(@"进入统计");
        NSTimeInterval time = [end timeIntervalSinceDate:start];
        //把按摩信息保存到RTBleConnector里面
        //将开始按摩的日期转成字符串
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"YYYY-MM-dd"];
        NSString* date = [dateFormatter stringFromDate:start];
        NSInteger programId = -1;
        NSString* function;
        if (_massageFlag<7&&_massageFlag>0) {
            //属于自动按摩的统计
            NSLog(@"自动按摩统计");
            _programName = [_bleConnector.rtMassageChairStatus autoMassageNameByIndex:_massageFlag];
            programId = _massageFlag;
            function = [_bleConnector.rtMassageChairStatus autoMassageFunctionByIndex:_massageFlag];;
        }
        else if (_massageFlag<11&&_massageFlag>7)
        {
            //属于网络按摩的统计
            NSLog(@"网络按摩统计");
            MassageProgram* p = [_bleConnector.rtNetworkProgramStatus getNetworkProgramNameBySlotIndex:_massageFlag-8];
            programId = [p.commandId integerValue];
            _programName = p.name;
            function = p.mDescription;
        }
        else
        {
            if (flag>0&&flag<7) {
                _programName = _skillsPreferenceName[flag-1];
                programId = -flag;
                function = _programName;
            }
            else
            {
                 _programName = @"手动按摩";
                function = _programName;
            }
        }
        NSNumber* pId = [NSNumber numberWithInteger:programId];
        NSNumber* useTime = [NSNumber numberWithInt:(int)time];
        NSDictionary* dic = @{@"name":_programName,@"useTime":useTime,@"programId":pId,@"useDate":date,@"startTime":start,@"endTime":end,@"function":function};
        _bleConnector.massageRecord = dic;
        
        if (_massageFlag != 7) {
            //非手动按摩需要统计时间
            NSLog(@"此次按摩了%f秒",time);
            if (time>30) {
                //时间大于30秒才开始统计
                NSUInteger min;
                if (time<=60) {
                    min = 1;
                }
                else
                {
                    min = (int)round(time/60);
                }
                NSLog(@"此次按摩了%ld分钟",min);
            
                if (programId>0)
                {
                    NSLog(@"统计一次");
                    NSArray* result = [ProgramCount MR_findAllWithPredicate:[NSPredicate predicateWithFormat:@"(programId == %ld) AND (uid == %@)",programId,self.uid]];
                    
                    //按摩次数统计
                    if (result.count >0) {
                        _programCount = result[0];
                        NSUInteger count = [_programCount.unUpdateCount integerValue];
                        count++;
                        _programCount.unUpdateCount = [NSNumber numberWithUnsignedInteger:count];
                        _programCount.programId = [NSNumber numberWithInteger:programId];
                    }
                    else
                    {
                        _programCount = [ProgramCount MR_createEntity];
                        _programCount.name = _programName;
                        _programCount.uid = self.uid;
                        _programCount.unUpdateCount = [NSNumber numberWithInt:1];
                        _programCount.programId = [NSNumber numberWithInteger:programId];
                    }
                    
                    //开始统计次数的网络数据同步
                    [ProgramCount synchroUseCountDataFormServer:YES Success:nil Fail:nil];
                    
                    //按摩记录
                    MassageRecord* massageRecord;
                    NSArray* records = [MassageRecord MR_findAllWithPredicate:[NSPredicate predicateWithFormat:@"(programId == %ld) AND (date == %@) AND (uid == %@) AND (state == 1)",programId,date,self.uid]];
                    if (records.count > 1) {
                        NSLog(@"查找数组:%@",records);
                        massageRecord = records[0];
                    }
                    if (massageRecord) {
                        NSUInteger oldTime = [massageRecord.useTime integerValue];
                        oldTime += min;
                        massageRecord.useTime = [NSNumber numberWithUnsignedInteger:oldTime];
                    }
                    else
                    {
                        //创建一条按摩记录
                        massageRecord = [MassageRecord MR_createEntity];
                        massageRecord.useTime = [NSNumber numberWithUnsignedInteger:min];
                        massageRecord.name = _programName;
                        massageRecord.date = date;
                        massageRecord.uid = self.uid;
                        massageRecord.programId = [NSNumber numberWithInteger:programId];
                        massageRecord.state = [NSNumber numberWithInt:1];
                    }
                     [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
                    //把本地所有未同步到服务器的按摩记录都推到服务器
                    [DataRequest synchroMassageRecord];
                }
            }
            else
            {
                NSLog(@"不统计");
            }
        }
        //统计完成要把开始时间置空，表示此次按摩已结束
        _bleConnector.startTime = nil;
        NSLog(@"设置开始时间为空");
    }
}

#pragma mark - alertView代理
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"确定"]) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}


@end
