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

@interface ManualViewController ()<WLPanAlertViewDelegate, UITableViewDataSource, UITableViewDelegate>
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
}
@end

@implementation ManualViewController

-(void)viewDidLoad
{
    [super viewDidLoad];
    self.title = NSLocalizedString(@"手动按摩:", nil);
    
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
    f.origin = CGPointZero;
    f.size.width *= 0.8;
    f.size.height *= 0.8;
    f.origin.x = f.size.width*0.25/2;
    _adjustTable = [[UITableView alloc]initWithFrame:f];
    _adjustTable.backgroundColor = [UIColor clearColor];
    _adjustTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    _adjustTable.delegate = self;
    _adjustTable.dataSource = self;
    _adjustTable.scrollEnabled = NO;
    [_adjustTable registerNib:[UINib nibWithNibName:@"ManualTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:_reuseIdentifier];
    [_panAlertView.contentView addSubview:_adjustTable];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [_panAlertView removeFromSuperview];
}

#pragma mark - tableView代理
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ManualTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:_reuseIdentifier];
    cell.titleLabel.text = _menu[indexPath.row];
    cell.backgroundColor = [UIColor clearColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if (indexPath.row < _menu.count - 1) {
        NSInteger i = indexPath.row*2;
        [cell.leftButton setImage:[UIImage imageNamed:_images[i]] forState:0];
        [cell.rightButton setImage:[UIImage imageNamed:_images[i+1]] forState:0];
    }
    else
    {
        [cell.leftButton setImage:[UIImage imageNamed:_images[_images.count -1]] forState:0];
    }
    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _menu.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 54;
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
