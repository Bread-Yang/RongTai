//
//  AdjustTableViewCell.m
//  rongtai
//
//  Created by William-zhang on 15/7/20.
//  Copyright (c) 2015年 William-zhang. All rights reserved.
//

#import "AdjustTableViewCell.h"

@implementation AdjustTableViewCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setUp];
        
    }
    return self;
}

#pragma mark - 初始化
-(void)setUp
{
    _titleLable = [[UILabel alloc]init];
    _leftButton = [[UIButton alloc]init];
    _rightButton = [[UIButton alloc]init];
}

-(void)updateUI
{
    CGFloat w = CGRectGetWidth(self.frame);
    CGFloat h = CGRectGetHeight(self.frame);
//    _titleLable.frame = CGRectMake(<#CGFloat x#>, <#CGFloat y#>, <#CGFloat width#>, <#CGFloat height#>)
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
