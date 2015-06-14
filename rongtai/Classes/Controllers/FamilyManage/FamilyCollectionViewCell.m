//
//  FamilyCollectionViewCell.m
//  rongtai
//
//  Created by William-zhang on 15/6/12.
//  Copyright (c) 2015年 William-zhang. All rights reserved.
//

#import "FamilyCollectionViewCell.h"

@interface FamilyCollectionViewCell ()
{
    UIImageView* _userIconView; //用户头像IamgeView
    UILabel* _userNameLabel;  //用户名称Label
}
@end

@implementation FamilyCollectionViewCell


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
    CGFloat w = self.frame.size.width;
    CGFloat h = self.frame.size.height;
    self.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.layer.borderWidth = 1;
    self.layer.cornerRadius = w/2;
    self.clipsToBounds = YES;
    
    UILabel* add = [[UILabel alloc]initWithFrame:CGRectMake(0.1*w, 0.4*h, 0.8*w, 0.2*h)];
    add.textAlignment = NSTextAlignmentCenter;
    add.adjustsFontSizeToFitWidth = YES;
    add.text = @"+ 添加成员";
    add.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
    [self.contentView addSubview:add];
    
    CGRect f = self.frame;
    f.origin = CGPointZero;
    _userIconView = [[UIImageView alloc]initWithFrame:f];
    _userIconView.backgroundColor = [UIColor greenColor];
    [self.contentView addSubview:_userIconView];
    
    _userNameLabel = [[UILabel alloc]initWithFrame:CGRectMake(0.25*w, 0.7*h, 0.5*w, 0.2*h)];
    _userNameLabel.textAlignment = NSTextAlignmentCenter;
    _userNameLabel.adjustsFontSizeToFitWidth = YES;
    _userNameLabel.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
    _userNameLabel.textColor = [UIColor whiteColor];
    [self.contentView addSubview:_userNameLabel];
}

#pragma mark - set方法
-(void)setIsAdd:(BOOL)isAdd
{
    _isAdd = isAdd;
    _userIconView.hidden = _isAdd;
    _userNameLabel.hidden = _isAdd;
}

-(void)setUser:(User *)user
{
    _user = user;
    _userIconView.image = [UIImage imageNamed:_user.imageUrl];
    _userNameLabel.text = _user.name;
}

@end
