//
//  BasicTableViewCell.m
//  rongtai
//
//  Created by William-zhang on 15/7/14.
//  Copyright (c) 2015年 William-zhang. All rights reserved.
//

#import "BasicTableViewCell.h"

@implementation BasicTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    CGFloat h = CGRectGetHeight(self.frame);
//    CGFloat w = CGRectGetWidth(self.frame);
    CGRect f = self.imageView.frame;
    f.size.height = 0.7*h;
    f.size.width = 0.7*h;
    f.origin.y = 0.15*h;
    self.imageView.frame = f;
    
}

@end
