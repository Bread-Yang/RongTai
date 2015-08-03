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


@interface ManualViewController ()<WLPanAlertViewDelegate, UITableViewDataSource, UITableViewDelegate, ManualTableViewCellDelegate,NAPickerViewDelegate,WLPolarDelegate>
{
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
    
    //背部加热
    
    __weak IBOutlet UIView *_backWarm;
    __weak IBOutlet UIImageView *_backWarmImagaView;
    __weak IBOutlet UILabel *_backWarmLabel;
    BOOL _backWarmOn;
    
    //脚步滚轮
    
    __weak IBOutlet UIView *_footWheel;
    __weak IBOutlet UIImageView *_footWheelImageView;
    __weak IBOutlet UILabel *_footWheelLabel;
    BOOL _footWheelOn;
    
    //
    __weak IBOutlet UIView *_addScrollView;
    UIScrollView* _scroll;

}
@end

@implementation ManualViewController

-(void)viewDidLoad
{
    [super viewDidLoad];
    self.title = NSLocalizedString(@"手动按摩", nil);
    
    //
    _skillsPreferenceArray = @[@"揉捏",@"推拿",@"敲打",@"组合"];
    
    //
    _scroll = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHT*0.57)];
    _scroll.pagingEnabled = YES;
    _scroll.contentSize = CGSizeMake(SCREENWIDTH*2, SCREENHEIGHT*0.57);
    _scroll.bounces = NO;
    _scroll.delegate = self;
    _scroll.showsHorizontalScrollIndicator = NO;
    _scroll.showsVerticalScrollIndicator = NO;
    [_addScrollView addSubview:_scroll];
    
    //
    UIBarButtonItem* right = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"icon_set"] style:UIBarButtonItemStylePlain target:self action:@selector(rightItemClicked:)];
    self.navigationItem.rightBarButtonItem = right;

    
//    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    //
//    self.navigationItem.leftBarButtonItem = [UIBarButtonItem goBackItemByTarget:self Action:@selector(goBack)];
    
   
    
    //
    _menu = @[NSLocalizedString(@"肩部位置:", nil),NSLocalizedString(@"背部升降:",nil),NSLocalizedString(@"小腿升降:",nil),NSLocalizedString(@"小腿伸缩:",nil),NSLocalizedString(@"零重力:",nil)];
    _reuseIdentifier = @"manualCell";
    
    //
    _images = @[@"set_button_up",@"set_button_down",@"set_rear_down",@"set_rear_up",@"set_leg_down",@"set_leg_up",@"set_leg_long",@"set_leg_short",@"set_zero"];
    
    //
    _panAlertView = [[WLPanAlertView alloc]init];
    _panAlertView.delegate = self;
    CGRect f = _panAlertView.buttonView.frame;
    CGFloat h = _panAlertView.buttonView.frame.size.height;
    f.origin.x = 0;
    f.origin.y = 0;
    f.size.height  = h*0.17;
    
    //
    _arrow = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"arrow_up"]];
    _arrow.frame = f;
    _arrow.contentMode = UIViewContentModeScaleAspectFit;
    [_panAlertView.buttonView addSubview:_arrow];
    
    //
    _bgCircle = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"button_set_bg"]];
    f.size.height  = h*0.83;
    f.origin.y = h*0.21;
    _bgCircle.frame = f;
    _bgCircle.contentMode = UIViewContentModeScaleAspectFit;
    [_panAlertView.buttonView addSubview:_bgCircle];
    
    
    //
    h = _bgCircle.frame.size.height;
    UILabel* label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0.3*h, CGRectGetWidth(_bgCircle.frame), h*0.4)];
    label.text = NSLocalizedString(@"按摩调整", nil);
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont systemFontOfSize:14];
    label.textColor = [UIColor whiteColor];
    [_bgCircle addSubview:label];
    
    f = _panAlertView.contentView.frame;
    f.origin.x = 0;
    f.origin.y = 0;
    _contentImageView = [[UIImageView alloc]initWithFrame:f];
    _contentImageView.image = [UIImage imageNamed:@"set_bg"];
    [_panAlertView.contentView addSubview:_contentImageView];
    
    AppDelegate* app = [UIApplication sharedApplication].delegate;
    UIWindow* appWindow = app.window;
    [appWindow addSubview:_panAlertView];
    
    //
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
    
    
    
    //
    _humanView = [[ManualHumanView alloc]initWithFrame:CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHT*0.57)];
    [_scroll addSubview:_humanView];
    
    //
    
    _polar = [[WLPolar alloc]initWithFrame:CGRectMake(SCREENWIDTH, 0, SCREENWIDTH, SCREENHEIGHT*0.57)];
    _polar.dataSeries = @[@(120), @(87), @(60), @(78)];
    _polar.steps = 3;
    _polar.r = SCREENHEIGHT*0.57*0.3;
    _polar.minValue = 20;
    _polar.maxValue = 120;
    _polar.drawPoints = YES;
    _polar.fillArea = YES;
    _polar.delegate = self;
    _polar.backgroundLineColorRadial = [UIColor colorWithRed:200/255.0 green:225/255.0 blue:233/255.0 alpha:1];
    _polar.fillColor = [UIColor colorWithRed:0 green:230/255.0 blue:0 alpha:0.3];
    _polar.lineColor = [UIColor colorWithRed:0 green:230/255.0 blue:0 alpha:0.8];
    _polar.attributes = @[@"速度", @"宽度", @"气压", @"力度"];
    _polar.scaleFont = [UIFont systemFontOfSize:14];
    [_scroll addSubview:_polar];

    
    //
    _pageControl = [[SMPageControl alloc]initWithFrame:CGRectMake(0, 0, 30, SCREENHEIGHT*0.03)];
    _pageControl.numberOfPages = 2;
    _pageControl.currentPageIndicatorImage = [UIImage imageNamed:@"page_piont_1"];
    _pageControl.pageIndicatorImage = [UIImage imageNamed:@"page_piont_2"];
    [_pageControl addTarget:self action:@selector(pageControlChange:) forControlEvents:UIControlEventValueChanged];
    [_addPageControl addSubview:_pageControl];
    
    //
    UITapGestureRecognizer* sTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(skillsPreferenceTap)];
    [_skillsPreferenceView addGestureRecognizer:sTap];
    
    _skillsPreferencePickerView = [self createskillsPreferencePickerView];
    
    //
    UITapGestureRecognizer* tTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(timeViewTap)];
    [_timeView addGestureRecognizer:tTap];
    
     _timePickerView = [self createMinutePickerView];
    
    //
    _backWarmOn = NO;
    UITapGestureRecognizer* bTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(backWarmTap)];
    [_backWarm addGestureRecognizer:bTap];
    
    //
    _footWheelOn = NO;
    UITapGestureRecognizer* fTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(footWheelTap)];
    [_footWheel addGestureRecognizer:fTap];
    
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [_panAlertView removeFromSuperview];
}

#pragma mark - 返回
-(void)goBack
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - 技法偏好点击方法
-(void)skillsPreferenceTap
{
    CustomIOSAlertView* skillPreferenceAlerView = [[CustomIOSAlertView alloc] init];
    
    [skillPreferenceAlerView setContainerView:_skillsPreferencePickerView];
    
    //	timingAlerView.dialogBackgroundColor = [UIColor colorWithRed:36.0 / 255.0 green:142.0 / 255.0 blue:215.5/ 255.0 alpha:1];
    

    [skillPreferenceAlerView setTitleString:@"模式"];
    [skillPreferenceAlerView setButtonTitles:[NSMutableArray arrayWithObjects:@"取消", @"保存", nil]];
    
    [skillPreferenceAlerView setOnButtonTouchUpInside:^(CustomIOSAlertView *alertView, int buttonIndex) {
        if (buttonIndex == 0) {
            [alertView close];
        }
        else if (buttonIndex == 1)
        {
            //保存方法
            NSString* sp = _skillsPreferenceArray[_pickerSelectedItem];
            _skillsPreferenceLabel.text = sp;
        }
    }];
    
    [skillPreferenceAlerView setUseMotionEffects:true];
    [skillPreferenceAlerView show];
}


#pragma mark - 时间选择点击方法
-(void)timeViewTap
{
    CustomIOSAlertView* skillPreferenceAlerView = [[CustomIOSAlertView alloc] init];
    
    [skillPreferenceAlerView setContainerView:_timePickerView];
    
    //	timingAlerView.dialogBackgroundColor = [UIColor colorWithRed:36.0 / 255.0 green:142.0 / 255.0 blue:215.5/ 255.0 alpha:1];
    
    
    [skillPreferenceAlerView setTitleString:@"定时"];
    [skillPreferenceAlerView setButtonTitles:[NSMutableArray arrayWithObjects:@"取消", @"保存", nil]];
    
    [skillPreferenceAlerView setOnButtonTouchUpInside:^(CustomIOSAlertView *alertView, int buttonIndex) {
        if (buttonIndex == 0) {
            [alertView close];
        }
        else if (buttonIndex == 1)
        {
            //保存方法
          
        }
    }];
    
    [skillPreferenceAlerView setUseMotionEffects:true];
    [skillPreferenceAlerView show];
}

#pragma mark - 背部加热方法
-(void)backWarmTap
{
    _backWarmOn = !_backWarmOn;
    if (_backWarmOn) {
        _backWarmImagaView.image = [UIImage imageNamed:@"function_1_select"];
        _backWarmLabel.textColor = ORANGE;
    }
    else
    {
        _backWarmImagaView.image = [UIImage imageNamed:@"function_1"];
        _backWarmLabel.textColor = [UIColor lightGrayColor];
    }
}

#pragma mark - 脚步滚轮方法
-(void)footWheelTap
{
    _footWheelOn = !_footWheelOn;
    if (_footWheelOn) {
        _footWheelImageView.image = [UIImage imageNamed:@"function_2_select"];
        _footWheelLabel.textColor = ORANGE;
    }
    else
    {
        _footWheelImageView.image = [UIImage imageNamed:@"function_2"];
        _footWheelLabel.textColor = [UIColor lightGrayColor];
    }
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
    for (int i = 1; i < 20;  i++) {
        [leftItems addObject:[NSString stringWithFormat:@"%d", i*10]];
    }
    //
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

#pragma mark - NAPickerView代理
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
}

-(void)WLPolarDidMove:(WLPolar *)polar
{
    
}

-(void)WLPolarMoveFinished:(WLPolar *)polar
{
    NSLog(@"滑动结束");
    _scroll.scrollEnabled = YES;
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
    if (cell.tag == 1)
    {
        NSLog(@"肩部位置");
    }
    else if (cell.tag == 2)
    {
        NSLog(@"背部升降");
    }
    else if (cell.tag == 3)
    {
        NSLog(@"小腿升降");
    }
    else if (cell.tag == 4)
    {
        NSLog(@"小腿伸缩");
    }
    else if (cell.tag == 5)
    {
        NSLog(@"零重力");
    }
}

#pragma mark - 导航栏右边按钮方法
-(void)rightItemClicked:(id)sender
{
    
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

@end
