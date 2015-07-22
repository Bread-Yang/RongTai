//
//  LineLabel.m
//  rongtai
//
//  Created by William-zhang on 15/7/21.
//  Copyright (c) 2015年 William-zhang. All rights reserved.
//

#import "LineLabel.h"
#import "RongTaiConstant.h"

#if __IPHONE_OS_VERSION_MIN_REQUIRED >= 70000
#define JY_TEXT_SIZE(text, font) [text length] > 0 ? [text sizeWithAttributes : @{ NSFontAttributeName : font }] : CGSizeZero;
#else
#define JY_TEXT_SIZE(text, font) [text length] > 0 ? [text sizeWithFont : font] : CGSizeZero;
#endif

@implementation LineLabel

-(instancetype)init
{
    if (self = [super init]) {
        [self setUp];
    }
    return self;
}

-(instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self adjustPosition];
    }
    return self;
}

#pragma mark - 初始化
-(void)setUp
{
//    self.backgroundColor = [UIColor redColor];
    _title = @"全身";
    _unselectedColor = [UIColor colorWithRed:0.75 green:0.75 blue:0.75 alpha:1];
    _selectedColor = ORANGE;
    _isSelected = NO;
    _labelType = LineLeftLabel;
    _font = [UIFont systemFontOfSize:14];
    _titleLabel = [[UILabel alloc]init];
    _titleLabel.text = _title;
    _titleLabel.font = _font;
    _line = [[UIView alloc]init];
    _line.backgroundColor = _unselectedColor;
    _line.alpha = 0.6;
    _titleLabel.textColor = _unselectedColor;
    [self addSubview:_line];
    [self addSubview:_titleLabel];
}


-(void)adjustPosition
{
    CGRect f = self.bounds;
    CGSize size =  JY_TEXT_SIZE(_title, _font);
    CGFloat lw = CGRectGetWidth(self.bounds)-size.width;
    CGFloat ly = (f.size.height - 1)/2;
    if (_labelType == LineLeftLabel)
    {
        f.size.width = size.width;
        _titleLabel.frame = f;
        
        f.origin.x = size.width+0.1*lw;
        f.origin.y = ly;
        f.size.height = 1;
        f.size.width = lw*0.9;
        _line.frame = f;
    }
    else if (_labelType == LineRightLabel)
    {
        f.origin.x = lw;
        f.size.width = size.width;
        _titleLabel.frame = f;
        
        f.origin.x = 0;
        f.origin.y = ly;
        f.size.height = 1;
        f.size.width = lw*0.9;
        _line.frame = f;
    }
}

#pragma mark - set方法
-(void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    [self adjustPosition];
}

-(void)setLabelType:(LineLabelType)labelType
{
    _labelType = labelType;
    [self adjustPosition];
}

-(void)setTitle:(NSString *)title
{
    _title = title;
    _titleLabel.text = _title;
}

-(void)setUnselectedColor:(UIColor *)unselectedColor
{
    _unselectedColor = unselectedColor;
    self.isSelected = self.isSelected;
}

-(void)setSelectedColor:(UIColor *)selectedColor
{
    _selectedColor = selectedColor;
    self.isSelected = self.isSelected;
}

-(void)setIsSelected:(BOOL)isSelected
{
    _isSelected = isSelected;
    if (_isSelected) {
        _titleLabel.textColor = _selectedColor;
        _line.backgroundColor = _selectedColor;
    }
    else
    {
        _titleLabel.textColor = _unselectedColor;
        _line.backgroundColor = _unselectedColor;
    }
}

-(void)setFont:(UIFont *)font
{
    _font = font;
    _titleLabel.font = _font;
    [self adjustPosition];
}




@end
