//
//  WLPanAlertView.m
//  WLPanAlertView
//
//  Created by William-zhang on 15/7/17.
//  Copyright (c) 2015年 William-zhang. All rights reserved.
//

#import "WLPanAlertView.h"

@interface WLPanAlertView ()
{
    UIView* _bgView;
    CGFloat _scale;
    BOOL _isAlert;
    CGPoint savePosition;
    CGFloat w;
    CGFloat h;
}

@end

@implementation WLPanAlertView

-(instancetype)init
{
    if (self = [super init]) {
        [self setUp];
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        [self setUp];
    }
    return self;
}

-(instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self setUp];
    }
    return self;
}


#pragma mark - 初始化
-(void)setUp
{
    
    self.backgroundColor = [UIColor clearColor];
    
    _isAlert = NO;
    w = [UIScreen mainScreen].bounds.size.width;
    h = [UIScreen mainScreen].bounds.size.height;
    _scale = 0.7;
    self.frame = CGRectMake(0, 0.85*h, w, _scale*h);
    //背景View
    _bgView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, w, h)];
    _bgView.alpha = 0;
    _bgView.backgroundColor = [UIColor blackColor];
    [self addSubview:_bgView];
    
    //alertView
    _alertView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, w, _scale*h)];
    _alertView.backgroundColor = [UIColor clearColor];
    [self addSubview:_alertView];
    
    
    //buttonView
    _buttonView = [[UIView alloc]initWithFrame:CGRectMake(_scale*w/2, 0, (1-_scale)*w, 0.15*h)];
    [_alertView addSubview:_buttonView];
    
    //contentView
    _contentView = [[UIView alloc]initWithFrame:CGRectMake(0, 0.15*h, w, 0.85*h)];
    [_alertView addSubview:_contentView];
    
    //buttonView添加手势
     //拖拽手势
    UIPanGestureRecognizer* pan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(buttonViewPan:)];
    [_buttonView addGestureRecognizer:pan];
     //点击手势
    UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(buttonViewTap:)];
    [_buttonView addGestureRecognizer:tap];
    
    //背景添加点击手势
    UITapGestureRecognizer* bgTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(bgTap:)];
    [self addGestureRecognizer:bgTap];
    
    //
    
    
}


#pragma mark - buttonView的Pan手势方法
-(void)buttonViewPan:(UIPanGestureRecognizer*)pan
{
    
}

#pragma mark - buttonView的Pan手势方法
-(void)buttonViewTap:(UITapGestureRecognizer*)tap
{
    if (_isAlert) {
        [self alertDown];
    }
    else
    {
        [self alertUp];
    }
}

#pragma mark - 背景Tap方法
-(void)bgTap:(UITapGestureRecognizer*)tap
{
    if (_isAlert) {
        [self alertDown];
    }
}

#pragma mark - 弹出
-(void)alertUp
{
    if ([self.delegate respondsToSelector:@selector(wlPanAlertViewWillAlert:)]) {
        [self.delegate wlPanAlertViewWillAlert:self];
    }
    self.frame = CGRectMake(0, 0, w, h);
    self.alertView.frame = CGRectMake(0, 0.85*h, w, _scale*h);
    _bgView.alpha = 0;
    [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        _bgView.alpha = 0.08;
        _alertView.frame = CGRectMake(0, (1-_scale)*h-15, w, _scale*h);
    } completion:^(BOOL finished){
        [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            _bgView.alpha = 0.1;
            _alertView.frame = CGRectMake(0, (1-_scale)*h, w, _scale*h);
            _isAlert = YES;
        } completion:nil];
    }];
    
}

#pragma mark - 弹下
-(void)alertDown
{
    if ([self.delegate respondsToSelector:@selector(wlPanAlertViewWillDown:)]) {
        [self.delegate wlPanAlertViewWillDown:self];
    }
    [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        _bgView.alpha = 0;
        _alertView.frame = CGRectMake(0, 0.85*h+15, w, _scale*h);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            _alertView.frame = CGRectMake(0, 0.85*h, w, _scale*h);
        } completion:^(BOOL finished) {
            self.frame = CGRectMake(0, 0.85*h, w, h);
            self.alertView.frame = CGRectMake(0, 0, w, _scale*h);
            _isAlert = NO;
//            [_bgView removeFromSuperview];
        }];
    }];
}


@end
