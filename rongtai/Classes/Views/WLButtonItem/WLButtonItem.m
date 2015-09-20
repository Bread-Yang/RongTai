//
//  WLButtonItem.m
//  rongtai
//
//  Created by William-zhang on 15/9/20.
//  Copyright (c) 2015年 William-zhang. All rights reserved.
//

#import "WLButtonItem.h"

@interface WLButtonItem ()
{
    BOOL _selected;
    UILabel* _titleLabel;
    UIImageView* _imageView;
    UIColor* _selectedColor;  //文字选中时颜色
    UIColor* _color;  //文字正常颜色
}

@end

@implementation WLButtonItem

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
        [self setUp];
    }
    return self;
}

-(void)setUp
{
    CGFloat w = self.frame.size.width;
    CGFloat h = self.frame.size.height;
    _ImageScale = 0.6;
    _edge = 0.05*h;
    _dlt = 0;
    _title = @"Button";
    _selected = NO;
    _color = [UIColor whiteColor];
    _selectedColor = [UIColor blueColor];
    _font = [UIFont systemFontOfSize:11];
    
    _imageView = [[UIImageView alloc]initWithFrame:CGRectMake(_edge, _edge, w-2*_edge,h*0.9*_ImageScale)];
    _imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self addSubview:_imageView];
    
    _titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(_edge, _edge+_dlt+h*0.9*_ImageScale, w-2*_edge, h*0.9*(1-_ImageScale))];
    _titleLabel.text = _title;
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    _titleLabel.font = _font;
    [self addSubview:_titleLabel];
}

-(void)setSelected:(BOOL)selected
{
    _selected = selected;
    if (_selected) {
        _titleLabel.textColor = _selectedColor;
        [_imageView setImage:_selectedImage];
    }
    else
    {
        _titleLabel.textColor = _color;
        [_imageView setImage:_image];
    }
}

-(void)setTitle:(NSString *)title
{
    _title = title;
    _titleLabel.text = _title;
}

-(void)setTitleColor:(UIColor *)color
{
    _color = color;
    if (!_selected) {
        _titleLabel.textColor = _color;
    }
}

-(void)setTitleSelectedColor:(UIColor *)color
{
    _selectedColor = color;
    if (_selected) {
        _titleLabel.textColor = _selectedColor;
    }
}

-(void)setImage:(UIImage *)image
{
    _image = image;
    if (!_selected) {
        [_imageView setImage:_image];
    }
}

-(void)setSelectedImage:(UIImage *)selectedImage
{
    _selectedImage = selectedImage;
    if (_selected) {
        [_imageView setImage:_selectedImage];
    }
}

@end
