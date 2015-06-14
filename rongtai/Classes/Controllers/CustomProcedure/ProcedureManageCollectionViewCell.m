//
//  ProcedureManageCollectionViewCell.m
//  rongtai
//
//  Created by William-zhang on 15/6/14.
//  Copyright (c) 2015年 William-zhang. All rights reserved.
//

#import "ProcedureManageCollectionViewCell.h"

@interface ProcedureManageCollectionViewCell ()
{
    UILabel* _nameLabel;  //名称Label
}
@end

@implementation ProcedureManageCollectionViewCell

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
    self.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.layer.borderWidth = 1;
    CGFloat w = self.frame.size.width;
    CGFloat h = self.frame.size.height;
    CGRect f = CGRectMake(0, (h-40)/2, w, 40);
    _nameLabel = [[UILabel alloc]initWithFrame:f];
    _nameLabel.textAlignment = NSTextAlignmentCenter;
    _nameLabel.text = @"自定义程序";
    [self addSubview:_nameLabel];
}

#pragma mark - set方法
-(void)setMassageMode:(MassageMode *)massageMode
{
    
}

@end
