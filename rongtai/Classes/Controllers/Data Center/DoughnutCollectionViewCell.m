//
//  DoughnutCollectionViewCell.m
//  rongtai
//
//  Created by William-zhang on 15/6/11.
//  Copyright (c) 2015年 William-zhang. All rights reserved.
//

#import "DoughnutCollectionViewCell.h"
#import "WLDoughnut.h"

@interface DoughnutCollectionViewCell ()
{
   WLDoughnut* _doughnut;  //圆环比例图
    
   UILabel *_nameLabel;  //按摩名称Label
   UILabel *_countLabel; //次数Label
}
@end


@implementation DoughnutCollectionViewCell

- (void)awakeFromNib {
    // Initialization code
    [self setUp];
}

-(void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    [self updateFrame];
}

#pragma mark - 初始化
-(void)setUp
{
    self.backgroundColor = [UIColor clearColor];
    _percent = 0.5;
    CGRect f = self.frame;
    f.size.width = 0.8;
    f.size.height = 0.8;
    f.origin = CGPointMake(f.size.width*0.1, _nameLabel.frame.size.width+15);
    _doughnut = [[WLDoughnut alloc]initWithFrame:f];
    _doughnut.percent = _percent;
    [self addSubview:_doughnut];
    _countLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, _doughnut.r-_doughnut.lineWidth*2, _doughnut.r/4)];
    _countLabel.textAlignment = NSTextAlignmentCenter;
    _countLabel.backgroundColor = [UIColor blueColor];
    [self addSubview:_countLabel];
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

#pragma mark - 更新圆环图大小
-(void)updateFrame
{
    CGRect f = self.frame;
    f.size.width *= 0.8;
    f.size.height *= 0.8;
    f.origin = CGPointMake(self.frame.size.width*0.1, _nameLabel.frame.size.height+15);
    _doughnut.frame = f;
//    [self addSubview:_doughnut];
//    CGRect f = self.frame;
////    NSLog(@"cell:%@",NSStringFromCGRect(self.frame));
//    f.origin = CGPointZero;
//    f.size.width -= 40;
//    f.size.height -= 40;
//    _doughnut.frame = f;
    
    NSLog(@"countLabel:%@",NSStringFromCGRect(_countLabel.frame));
    _countLabel.frame = CGRectMake(0, 0, _doughnut.r-_doughnut.lineWidth*2, _doughnut.r/4);
//    _countLabel.center = self.center;
    _countLabel.adjustsFontSizeToFitWidth = YES;
    _countLabel.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
}



@end
