//
//  DoughnutCollectionViewCell.m
//  rongtai
//
//  Created by William-zhang on 15/6/12.
//  Copyright (c) 2015年 William-zhang. All rights reserved.
//

#import "DoughnutCollectionViewCell.h"
#import "UIView+AddBorder.h"


@interface DoughnutCollectionViewCell ()

@end

@implementation DoughnutCollectionViewCell

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
    
    CGFloat w = self.frame.size.width;
    CGFloat h = self.frame.size.height;
    
    _nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(0.34*w, 1+0.05*h, 0.32*w, 0.1*h-1)];
    _nameLabel.text = @"工作减压";
    _nameLabel.textAlignment = NSTextAlignmentCenter;
    _nameLabel.adjustsFontSizeToFitWidth = YES;
    _nameLabel.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
    [self addSubview:_nameLabel];
    
    _doughnut = [[WLDoughnut alloc]initWithFrame:CGRectMake(w*0.15, 0.2*h, w*0.7, 0.7*h)];
    _doughnut.percent = 0.5;
    _doughnut.unFinishLineWidth = 2;
    [self addSubview:_doughnut];
    
    _countLabel = [[UILabel alloc]initWithFrame:CGRectMake(0.25*w, 0.3*h+1, 0.5*w, 0.3*h)];
    _countLabel.text = @"120";
    _countLabel.font  = [UIFont fontWithName:@"Helvetica-Light" size:40];
    _countLabel.textColor = [UIColor lightGrayColor];
    _countLabel.textAlignment = NSTextAlignmentCenter;
    _countLabel.adjustsFontSizeToFitWidth = YES;
    _countLabel.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
//    _countLabel.backgroundColor = [UIColor blueColor];
    [self addSubview:_countLabel];
    
    _detailLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0.6*h, w, 0.1*h-1)];
    _detailLabel.text = NSLocalizedString(@"次", nil);
    _detailLabel.textAlignment = NSTextAlignmentCenter;
    _detailLabel.adjustsFontSizeToFitWidth = YES;
    _detailLabel.font = [UIFont systemFontOfSize:12];
    _detailLabel.textColor = [UIColor lightGrayColor];
    _detailLabel.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
    [self addSubview:_detailLabel];
    
    _isHiddenDougnut = NO;
    [self addLineBorder];
}

#pragma mark - set方法

-(void)setName:(NSString *)name
{
    _name = name;
    _nameLabel.text = _name;
}

-(void)setCount:(NSUInteger)count
{
    _count = count;
    _countLabel.text = [NSString stringWithFormat:@"%lu",_count];
}

-(void)setIsHiddenDougnut:(BOOL)isHiddenDougnut
{
    _isHiddenDougnut = isHiddenDougnut;
    if (_isHiddenDougnut) {
        _nameLabel.hidden = YES;
        _detailLabel.hidden = YES;
        _countLabel.hidden = YES;
        _doughnut.hidden = YES;
    }
    else
    {
        _nameLabel.hidden = NO;
        _detailLabel.hidden = NO;
        _countLabel.hidden = NO;
        _doughnut.hidden = NO;
    }
}

#pragma mark - 变换大小
-(void)changeUIFrame
{
    UIColor* gray = [UIColor colorWithRed:0.7 green:0.7 blue:0.7 alpha:1];
    CGFloat w = CGRectGetWidth(self.frame);
    CGFloat h = CGRectGetHeight(self.frame);
    self.countLabel.textColor = gray;
    self.countLabel.font = [UIFont systemFontOfSize:20];
    CGRect f = self.countLabel.frame;
    f.origin.y += 0.05*h;
    self.countLabel.frame = f;
    f = self.nameLabel.frame;
    f.size.width = w*0.5;
    f.origin.x = w*0.25;
    self.nameLabel.frame = f;
    self.detailLabel.textColor = gray;
}

@end
