//
//  ProcedureManageTableViewCell.m
//  rongtai
//
//  Created by William-zhang on 15/6/19.
//  Copyright (c) 2015年 William-zhang. All rights reserved.
//

#import "ProcedureManageTableViewCell.h"
#import "CustomProgram.h"

@interface ProcedureManageTableViewCell ()
{
    UIButton* _btn;
    UIView* _line;
}
@end

@implementation ProcedureManageTableViewCell


- (void)awakeFromNib {
    // Initialization code
}

-(void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    CGFloat w = self.frame.size.width;
    CGFloat h = self.frame.size.height;
    _btn.frame = CGRectMake(0.1*w, 0.15*h, 0.4*w, 0.7*h);
    _line.frame = CGRectMake(0, h-0.5, w, 0.5);
}

-(void)setCustomProgram:(CustomProgram *)customProgram
{
    _customProgram = customProgram;
    [_btn setTitle:_customProgram.name forState:UIControlStateNormal];
    
}

-(void)setIsEdit:(BOOL)isEdit
{
    _isEdit = isEdit;
    if (_isEdit) {
        _btn.layer.borderColor = [UIColor lightGrayColor].CGColor;
        _btn.layer.borderWidth = 0.5;
    }
    else
    {
        _btn.layer.borderColor = [UIColor clearColor].CGColor;
    }
}


#pragma mark - 初始化
-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        CGFloat w = self.frame.size.width;
        CGFloat h = self.frame.size.height;
        _btn = [[UIButton alloc]initWithFrame:CGRectMake(0.1*w, 0.15*h, 0.4*w, 0.7*h)];
        _btn.backgroundColor = [UIColor redColor];
        [self.contentView addSubview:_btn];
        
        _line = [[UIView alloc]initWithFrame:CGRectMake(0, h-0.5, w, 0.5)];
        _line.backgroundColor = [UIColor lightGrayColor];
        [self addSubview:_line];
    }
    return self;
}

#pragma mark - 点击名称方法
-(void)clickName
{
    UIAlertView* alert = [[UIAlertView alloc]initWithTitle:@"名称" message:@"名称" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"保存", nil];
    
    [alert show];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
