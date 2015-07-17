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

@interface ManualViewController ()<WLPanAlertViewDelegate>
{
    WLPanAlertView* _panAlertView;
    UIImageView* _arrow;
    UIImageView* _bgCircle;
    UILabel* _titleLabel;
    UIImageView* _contentImageView;
}
@end

@implementation ManualViewController

-(void)viewDidLoad
{
    [super viewDidLoad];
    self.title = NSLocalizedString(@"手动按摩", nil);
    
    //
    _panAlertView = [[WLPanAlertView alloc]init];
    _panAlertView.delegate = self;
    CGRect f = _panAlertView.buttonView.frame;
    f.origin.x = 0;
    f.origin.y = 0;
    f.size.height *= 0.2;
    _arrow = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"arrow_up"]];
    _arrow.frame = f;
    _arrow.contentMode = UIViewContentModeScaleAspectFit;
    [_panAlertView.buttonView addSubview:_arrow];
    
    _bgCircle = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"button_set_bg2"]];
    f.size.height *= 5;
    f.size.height *= 0.8;
    f.origin.y = 0.4*f.size.height;
    _bgCircle.frame = f;
    _bgCircle.contentMode = UIViewContentModeScaleAspectFit;
    [_panAlertView.buttonView addSubview:_bgCircle];
    
    
    f = _panAlertView.contentView.frame;
    f.origin.x = 0;
    f.origin.y = 0;
    _contentImageView = [[UIImageView alloc]initWithFrame:f];
    _contentImageView.image = [UIImage imageNamed:@"set_bg"];
    [_panAlertView.contentView addSubview:_contentImageView];
    
    AppDelegate* app = [UIApplication sharedApplication].delegate;
    UIWindow* appWindow = app.window;
    [appWindow addSubview:_panAlertView];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [_panAlertView removeFromSuperview];
}

@end
