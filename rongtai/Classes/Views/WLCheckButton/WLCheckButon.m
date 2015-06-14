//
//  WLCheckButon.m
//  UICheckButton
//
//  Created by William-zhang on 15/6/14.
//  Copyright (c) 2015年 William-zhang. All rights reserved.
//

#import "WLCheckButon.h"

@interface WLCheckButon ()
{
    UILabel* _leftLabel;
    UILabel* _rightLabel;
    UIButton* _leftBtn;
    UIButton* _rightBtn;
}
@end


@implementation WLCheckButon

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
    CGFloat h = self.frame.size.height;
    CGFloat w = self.frame.size.width - h;
    self.layer.borderWidth = 1;
    self.layer.cornerRadius = h/2;
    self.clipsToBounds = YES;
    
    _leftBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, (w+h)/2, h)];
    _leftBtn.tag = 1;
    [_leftBtn addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_leftBtn];
    
    _rightBtn = [[UIButton alloc]initWithFrame:CGRectMake((w+h)/2, 0, (w+h)/2, h)];
    [_rightBtn addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_rightBtn];
    
    _leftLabel = [[UILabel alloc]initWithFrame:CGRectMake(h/2, 0, w/2, h)];
    _leftLabel.textAlignment = NSTextAlignmentCenter;
    _leftLabel.adjustsFontSizeToFitWidth = YES;
    _leftLabel.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
    [self addSubview:_leftLabel];
    
    _rightLabel = [[UILabel alloc]initWithFrame:CGRectMake(w/2+h/2, 0, w/2, h)];
    _rightLabel.textAlignment = NSTextAlignmentCenter;
    _rightLabel.adjustsFontSizeToFitWidth = YES;
    _rightLabel.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
    [self addSubview:_rightLabel];
    
    self.selectColor = [UIColor whiteColor];
    self.unselectColor = [UIColor lightGrayColor];
    self.tintColor = [UIColor colorWithRed:0 green:0 blue:1 alpha:0.6];
    self.itemNames = @[@"left", @"right"];
    self.selectState = YES;
}

-(void)setSelectColor:(UIColor *)selectColor
{
    _selectColor = selectColor;
    if (_selectState) {
        _leftBtn.backgroundColor = self.selectColor;
    }
    else
    {
        _rightBtn.backgroundColor = self.selectColor;
    }
}

-(void)setUnselectColor:(UIColor *)unselectColor
{
    _unselectColor = unselectColor;
    if (_selectState) {
        _rightBtn.backgroundColor = self.unselectColor;
    }
    else
    {
        _leftBtn.backgroundColor = self.unselectColor;
    }
}

-(void)setTintColor:(UIColor *)tintColor
{
    _tintColor = tintColor;
    _leftLabel.textColor = tintColor;
    _rightLabel.textColor = tintColor;
    self.layer.borderColor = _tintColor.CGColor;
}

-(void)setItemNames:(NSArray *)itemNames
{
    if (itemNames.count > 0) {
        _itemNames = itemNames;
        _leftLabel.text = _itemNames[0];
        _rightLabel.text = _itemNames[1];
    }
}

-(void)setSelectState:(BOOL)selectState
{
    _selectState = selectState;
    if (_selectState) {
        _leftLabel.hidden = NO;
        _leftBtn.backgroundColor = self.selectColor;
        _rightLabel.hidden = YES;
        _rightBtn.backgroundColor = self.unselectColor;
    }
    else
    {
        _leftLabel.hidden = YES;
        _leftBtn.backgroundColor = self.unselectColor;
        _rightLabel.hidden = NO;
        _rightBtn.backgroundColor = self.selectColor;
    }
}

-(void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    CGFloat h = self.frame.size.height;
    CGFloat w = self.frame.size.width - h;
    self.layer.cornerRadius = self.frame.size.height/2;
    _leftLabel.frame = CGRectMake(0, 0, w/2, h);
    _rightLabel.frame = CGRectMake(w/2, 0, w/2, h);
    
    _leftBtn.frame = CGRectMake(0, 0, (w+h)/2, h);
    _rightBtn.frame = CGRectMake((w+h)/2, 0, (w+h)/2, h);
}

#pragma mark - 点击方法
-(void)buttonClick:(UIButton*)btn
{
    if (btn.tag == 1) {
        self.selectState = YES;
        if ([self.delegate respondsToSelector:@selector(checkButton:Clicked:)]) {
            [self.delegate checkButton:self Clicked:0];
        }
    }
    else
    {
        self.selectState = NO;
        if ([self.delegate respondsToSelector:@selector(checkButton:Clicked:)]) {
            [self.delegate checkButton:self Clicked:1];
        }
    }
}



/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
