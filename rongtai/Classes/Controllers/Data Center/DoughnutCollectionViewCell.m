//
//  DoughnutCollectionViewCell.m
//  rongtai
//
//  Created by William-zhang on 15/6/12.
//  Copyright (c) 2015年 William-zhang. All rights reserved.
//

#import "DoughnutCollectionViewCell.h"
#import "WLDoughnut.h"

@interface DoughnutCollectionViewCell ()
{
    UILabel *_nameLabel;  //按摩名称Label
    WLDoughnut* _doughnut;  //圆环比例图
    UILabel *_countLabel; //次数Label
}
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
//    self.backgroundColor = [UIColor greenColor];
    
    CGFloat w = self.frame.size.width;
    CGFloat h = self.frame.size.height;
    UIView* line = [[UIView alloc]initWithFrame:CGRectMake(0, 0, w, 1)];
    line.backgroundColor = [UIColor lightGrayColor];
    [self addSubview:line];
    
    _nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(0.2*w, 1+0.05*h, 0.6*w, 0.1*h-1)];
    _nameLabel.text = @"工作减压";
    _nameLabel.textAlignment = NSTextAlignmentCenter;
    _nameLabel.adjustsFontSizeToFitWidth = YES;
    _nameLabel.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
    [self addSubview:_nameLabel];
    
    _doughnut = [[WLDoughnut alloc]initWithFrame:CGRectMake(w*0.1, 0.2*h+1, w*0.8, 0.8*h)];
    _doughnut.percent = 0.5;
    [self addSubview:_doughnut];
    
    _countLabel = [[UILabel alloc]initWithFrame:CGRectMake(0.25*w, 0.4*h+1, 0.5*w, 0.3*h)];
    _countLabel.text = @"120";
    _countLabel.font  = [UIFont systemFontOfSize:45];
    _countLabel.textColor = [UIColor lightGrayColor];
    _countLabel.textAlignment = NSTextAlignmentCenter;
    _countLabel.adjustsFontSizeToFitWidth = YES;
    _countLabel.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
//    _countLabel.backgroundColor = [UIColor blueColor];
    [self addSubview:_countLabel];
    
    UILabel* l = [[UILabel alloc]initWithFrame:CGRectMake(0, 0.7*h+8, w, 0.1*h-1)];
    l.text = @"次";
    l.textAlignment = NSTextAlignmentCenter;
    l.adjustsFontSizeToFitWidth = YES;
    l.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
    [self addSubview:l];
}

#pragma mark - set方法
-(void)setPercent:(CGFloat)percent
{
    _percent = percent;
    _doughnut.percent = _percent;
}

-(void)setName:(NSString *)name
{
    _name = name;
    _nameLabel.text = _name;
}

-(void)setCount:(NSUInteger)count
{
    _count = count;
    _countLabel.text = [NSString stringWithFormat:@"%d",_count];
}

@end
