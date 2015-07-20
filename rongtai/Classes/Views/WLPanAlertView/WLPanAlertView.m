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
    float _w;
    float _h;
    CGPoint _startPoint;
    CGPoint _endPoint;
    float _dlt;
    CGFloat _hScale;
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
    _backgroundAlpha = 0.35;
    
    _isAlert = NO;
    _w = [UIScreen mainScreen].bounds.size.width;
    _h = [UIScreen mainScreen].bounds.size.height;
    _scale = 0.7;
    _hScale = 0.87;
    self.frame = CGRectMake(0, (_hScale+0.02)*_h, _w, _scale*_h);
    //背景View
    _bgView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, _w, _h)];
    _bgView.alpha = 0;
    _bgView.backgroundColor = [UIColor blackColor];
    [self addSubview:_bgView];
    
    //alertView
    _alertView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, _w, _scale*_h)];
    _alertView.backgroundColor = [UIColor clearColor];
    [self addSubview:_alertView];
    
    //buttonView
    CGFloat s = 0.30625*1.2;
    _buttonView = [[UIView alloc]initWithFrame:CGRectMake((1-s)/2*_w, 0, s*_w, (1-_hScale)*_h)];
    [_alertView addSubview:_buttonView];
    
    //contentView
    _contentView = [[UIView alloc]initWithFrame:CGRectMake(0, (1-_hScale)*_h, _w, _hScale*_h)];
    [_alertView addSubview:_contentView];
    
    //buttonView添加手势
    //拖拽手势
    UIPanGestureRecognizer* pan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(buttonViewPan:)];
    [_buttonView addGestureRecognizer:pan];
    
    //点击手势
    UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(buttonViewTap:)];
    [_buttonView addGestureRecognizer:tap];
    [pan requireGestureRecognizerToFail:tap];
    
    //背景添加点击手势
//    UITapGestureRecognizer* bgTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(bgTap:)];
//    [self addGestureRecognizer:bgTap];
}


#pragma mark - buttonView的Pan手势方法
-(void)buttonViewPan:(UIPanGestureRecognizer*)pan
{
    if (pan.state == UIGestureRecognizerStateBegan) {
        _startPoint = [pan locationInView:self];
        if (!_isAlert) {
            self.frame = CGRectMake(0, 0, _w, _h);
            self.alertView.frame = CGRectMake(0, (_hScale+0.02)*_h, _w, _scale*_h);
        }
    }
    else if (pan.state == UIGestureRecognizerStateChanged)
    {
        _endPoint = [pan locationInView:self];
        _dlt = _endPoint.y - _startPoint.y;
        CGRect f = self.alertView.frame;
        f.origin.y += _dlt;
        if (f.origin.y >= (_hScale+0.02)*_h) {
            f.origin.y = (_hScale+0.02)*_h;
        }
        else if (f.origin.y <= (1-_scale)*_h)
        {
            f.origin.y = (1-_scale)*_h;
        }
        else
        {
            _bgView.alpha -= _backgroundAlpha*(_dlt/((_hScale-(1-_scale))*_h));
        }
        self.alertView.frame = f;
        if ([self.delegate respondsToSelector:@selector(wlPanAlertViewDidPan:ByDirection:)]) {
            BOOL direction = _dlt >0;
            [self.delegate wlPanAlertViewDidPan:self ByDirection:direction];
        }
        _startPoint = _endPoint;
    }
    else if (pan.state == UIGestureRecognizerStateEnded)
    {
        CGFloat y = self.alertView.frame.origin.y;
        if ((y-(_hScale+0.02)*_h)< -0.0001 && (y - (1-_scale)*_h)>0.0001) {
            if (_dlt > 0 ) {
                [self alertDown];
            }
            else
            {
                [self alertUp];
            }
        }
        else if ((y-(_hScale+0.02)*_h)>= -0.0001)
        {
            self.frame = CGRectMake(0, (_hScale+0.02)*_h, _w, _h);
            self.alertView.frame = CGRectMake(0, 0, _w, _scale*_h);
            _bgView.alpha = 0;
            _isAlert = NO;
            if ([self.delegate respondsToSelector:@selector(wlPanAlertViewDidDown:)]) {
                [self.delegate wlPanAlertViewDidDown:self];
            }
        }
        else
        {
            self.alertView.frame = CGRectMake(0, (1-_scale)*_h, _w, _scale*_h);
            _isAlert = YES;
            if ([self.delegate respondsToSelector:@selector(wlPanAlertViewDidAlert:)]) {
                [self.delegate wlPanAlertViewDidAlert:self];
            }
        }
    }
}

#pragma mark - buttonView的Pan手势方法
-(void)buttonViewTap:(UITapGestureRecognizer*)tap
{
    if (_isAlert) {
        if ([self.delegate respondsToSelector:@selector(wlPanAlertViewWillDown:)]) {
            [self.delegate wlPanAlertViewWillDown:self];
        }
        [self alertDown];
    }
    else
    {
        self.frame = CGRectMake(0, 0, _w, _h);
        self.alertView.frame = CGRectMake(0, (_hScale+0.02)*_h, _w, _scale*_h);
        if ([self.delegate respondsToSelector:@selector(wlPanAlertViewWillAlert:)]) {
            [self.delegate wlPanAlertViewWillAlert:self];
        }
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
    [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        _bgView.alpha = _backgroundAlpha;
        _alertView.frame = CGRectMake(0, (1-_scale)*_h-15, _w, _scale*_h);
    } completion:^(BOOL finished){
        [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            _alertView.frame = CGRectMake(0, (1-_scale)*_h, _w, _scale*_h);
            _isAlert = YES;
            if ([self.delegate respondsToSelector:@selector(wlPanAlertViewDidAlert:)]) {
                [self.delegate wlPanAlertViewDidAlert:self];
            }
        } completion:nil];
    }];
    
}

#pragma mark - 弹下
-(void)alertDown
{
    [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        _bgView.alpha = 0;
        _alertView.frame = CGRectMake(0, (_hScale+0.02)*_h+15, _w, _scale*_h);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            _alertView.frame = CGRectMake(0, (_hScale+0.02)*_h, _w, _scale*_h);
        } completion:^(BOOL finished) {
            self.frame = CGRectMake(0, (_hScale+0.02)*_h, _w, _h);
            self.alertView.frame = CGRectMake(0, 0, _w, _scale*_h);
            _isAlert = NO;
            if ([self.delegate respondsToSelector:@selector(wlPanAlertViewDidDown:)]) {
                [self.delegate wlPanAlertViewDidDown:self];
            }
        }];
    }];
}

#pragma mark - set方法



@end
