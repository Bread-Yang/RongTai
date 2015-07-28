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
    WLPanAlertView* _panAlertView;
    UIImageView* _arrow;
    UIImageView* _bgCircle;
    UILabel* _titleLabel;
    UIImageView* _contentImageView;
    UITableView* _adjustTable;
    NSArray* _menu;
    NSString* _reuseIdentifier;
    NSArray* _images;
    CGFloat _cH;
    
   
    ManualHumanView* _humanView;
    WLPolar* _polar;
    __weak IBOutlet UIView *_addPageControl;
    SMPageControl* _pageControl;
    UIView* _testView;
    
    //
    NSArray* _skillsPreferenceArray;
    NAPickerView *_skillsPreferencePickerView;  //技法偏好选择器
    
    __weak IBOutlet UILabel *_skillsPreferenceLabel;
    __weak IBOutlet UIView *_skillsPreferenceView;
    NSInteger _pickerSelectedItem;
    
    //
    
    __weak IBOutlet UIView *_addScrollView;
    UIScrollView* _scroll;
    
    //
    BOOL _enableSwipeGesture;
}
@end

@implementation ManualViewController

-(void)viewDidLoad
{
    [super viewDidLoad];
    self.title = NSLocalizedString(@"手动按摩", nil);
    
    //关闭SlideNavigationController的滑动手势，不然会影响WLPolar
    SlideNavigationController* sl = (SlideNavigationController*)self.navigationController;
    _enableSwipeGesture = sl.enableSwipeGesture;
    sl.enableSwipeGesture = NO;
    
    
    //
    _skillsPreferenceArray = @[@"揉捏",@"推拿",@"敲打",@"组合"];
    
//    _addScrollView.backgroundColor = [UIColor yellowColor];
    //
    _scroll = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHT*0.57)];
    _scroll.pagingEnabled = YES;
    _scroll.contentSize = CGSizeMake(SCREENWIDTH*2, SCREENHEIGHT*0.57);
    _scroll.bounces = NO;
    _scroll.delegate = self;
//    _scroll.backgroundColor = [UIColor redColor];
    _scroll.showsHorizontalScrollIndicator = NO;
    _scroll.showsVerticalScrollIndicator = NO;
    [_addScrollView addSubview:_scroll];
    
    //
    UIBarButtonItem* right = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"icon_set"] style:UIBarButtonItemStylePlain target:self action:@selector(rightItemClicked:)];
    self.navigationItem.rightBarButtonItem = right;
    
    //
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem goBackItemByTarget:self Action:@selector(goBack)];
    
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
//    _humanView.backgroundColor = [UIColor blueColor];
    [_scroll addSubview:_humanView];
    
    //
    
    _polar = [[WLPolar alloc]initWithFrame:CGRectMake(SCREENWIDTH*1.1, SCREENHEIGHT*0.57*0.1, SCREENWIDTH*0.8, SCREENHEIGHT*0.57*0.8)];
//    _polar.backgroundColor = [UIColor blueColor];
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
    
    
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    SlideNavigationController* sl = (SlideNavigationController*)self.navigationController;
    sl.enableSwipeGesture = _enableSwipeGesture;
    
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
    
    // Add some custom content to the alert view
    [skillPreferenceAlerView setContainerView:_skillsPreferencePickerView];
    
    //	timingAlerView.dialogBackgroundColor = [UIColor colorWithRed:36.0 / 255.0 green:142.0 / 255.0 blue:215.5/ 255.0 alpha:1];
    
    // Modify the parameters
    [skillPreferenceAlerView setTitleString:@"模式"];
    [skillPreferenceAlerView setButtonTitles:[NSMutableArray arrayWithObjects:@"取消", @"保存", nil]];
    // You may use a Block, rather than a delegate.
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
- (UIView *)createMinuteView
{
    NSMutableArray *leftItems = [[NSMutableArray alloc] init];
    for (int i = 0; i < 30;  i++) {
        [leftItems addObject:[NSString stringWithFormat:@"%d", i]];
    }
    //
    NAPickerView *pickerView = [[NAPickerView alloc] initWithFrame:CGRectMake(0, 0, 270, 200) andItems:leftItems andDelegate:self];
    pickerView.overlayColor = [UIColor colorWithRed:223.0 / 255.0 green:1 blue:1 alpha:1];
    
    pickerView.infiniteScrolling = YES;
    pickerView.overlayLeftImage = [UIImage imageNamed:@"icon_set_time"];
    pickerView.overlayRightString = @"分钟";
    pickerView.showOverlay = YES;
    
    pickerView.highlightBlock = ^(NALabelCell *cell) {
        cell.textView.textColor = [UIColor whiteColor];
        cell.textView.font = [UIFont systemFontOfSize:30];
    };
    pickerView.unhighlightBlock = ^(NALabelCell *cell) {
        cell.textView.textColor = [UIColor blackColor];
        cell.textView.font = [UIFont systemFontOfSize:18];
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
-(void)manualTableViewCell:(ManualTableViewCell *)cell Clicked:(NSInteger)index
{
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
