//
//  ManualTableViewCell.m
//  rongtai
//
//  Created by William-zhang on 15/7/20.
//  Copyright (c) 2015年 William-zhang. All rights reserved.
//

#import "ManualTableViewCell.h"

@implementation ManualTableViewCell

- (void)awakeFromNib {
    // Initialization code
    [_rightButton setTitle:@"" forState:0];
    [_leftButton setTitle:@"" forState:0];
    [self layoutSubviews];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    CGFloat w = CGRectGetWidth(self.frame)/20;
    CGFloat h = CGRectGetHeight(self.frame);
    _titleLabel.frame = CGRectMake(w, 0, w*5, h);
}

@end
