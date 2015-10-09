//
//  AdjustView.m
//  rongtai
//
//  Created by William-zhang on 15/8/18.
//  Copyright (c) 2015年 William-zhang. All rights reserved.
//

#import "AdjustView.h"
#import "WLPanAlertView.h"
#import "AppDelegate.h"
#import "ManualTableViewCell.h"
#import "RTBleConnector.h"
#import "RTCommand.h"

@interface AdjustView ()<WLPanAlertViewDelegate, UITableViewDataSource, UITableViewDelegate,ManualTableViewCellDelegate>
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
    NSArray* _selectImage; //调整按钮的被点击图片名称数组
    CGFloat _cH;
    RTBleConnector* _bleConnector;
}
@end

@implementation AdjustView

static AdjustView* share;

+(instancetype)shareView
{
    if (share == nil) {
        share = [[AdjustView alloc]init];
    }
    return share;
}

-(instancetype)init
{
    if (self = [super init]) {
        [self setUp];
    }
    return self;
}

-(void)setUp
{
    _bleConnector = [RTBleConnector shareManager];
    
    //调节选项数组
    _menu = @[NSLocalizedString(@"肩部位置:", nil),NSLocalizedString(@"背部升降:",nil),NSLocalizedString(@"小腿升降:",nil),NSLocalizedString(@"小腿伸缩:",nil),NSLocalizedString(@"零重力:",nil)];
    
    _reuseIdentifier = @"manualCell";
    
    //调节选项按钮图片名称
    _images = @[@"set_button_up",@"set_button_down",@"set_rear_down",@"set_rear_up",@"set_leg_down",@"set_leg_up",@"set_leg_long",@"set_leg_short",@"set_zero"];
    
    _selectImage = @[@"set_button_up2",@"set_button_down2",@"set_rear_down2",@"set_rear_up2",@"set_leg_down2",@"set_leg_up2",@"set_leg_long2",@"set_leg_short2",@"set_zero2"];
    
    //创建 WLPanAlertView，即调节菜单
    _panAlertView = [[WLPanAlertView alloc]init];
    _panAlertView.delegate = self;
    CGRect f = _panAlertView.buttonView.frame;
    CGFloat h = _panAlertView.buttonView.frame.size.height;
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
}

#pragma mark - tableView代理
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ManualTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:_reuseIdentifier];
    cell.titleLabel.text = _menu[indexPath.row];
	cell.titleLabel.adjustsFontSizeToFitWidth = YES;
	cell.titleLabel.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
    cell.backgroundColor = [UIColor clearColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.delegate = self;
    cell.tag = indexPath.row+1;
    if (indexPath.row < _menu.count - 1) {
        NSInteger i = indexPath.row*2;
        [cell.leftButton setImage:[UIImage imageNamed:_images[i]] forState:UIControlStateNormal];
        [cell.leftButton setImage:[UIImage imageNamed:_selectImage[i]] forState:UIControlStateHighlighted];
        [cell.rightButton setImage:[UIImage imageNamed:_images[i+1]] forState:UIControlStateNormal];
        [cell.rightButton setImage:[UIImage imageNamed:_selectImage[i+1]] forState:UIControlStateHighlighted];
    }
    else
    {
        [cell.leftButton setImage:[UIImage imageNamed:_images[_images.count -1]] forState:0];
        [cell.leftButton setImage:[UIImage imageNamed:_selectImage[_images.count-1]] forState:UIControlStateHighlighted];
        [cell.leftButton setImage:[UIImage imageNamed:_selectImage[_images.count-1]] forState:UIControlStateSelected];
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

#pragma mark - PUBLIC
-(void)show
{
    //WLPanAlertView加入到UIWindow里面
    AppDelegate* app = [UIApplication sharedApplication].delegate;
    UIWindow* appWindow = app.window;
    [appWindow addSubview:_panAlertView];
}

-(void)hidden
{
    [_panAlertView removeFromSuperview];
}




@end
