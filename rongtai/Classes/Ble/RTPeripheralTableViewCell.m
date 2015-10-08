//
//  RTPeripheralTableViewCell.m
//  rongtai
//
//  Created by William-zhang on 15/10/8.
//  Copyright (c) 2015年 William-zhang. All rights reserved.
//

#import "RTPeripheralTableViewCell.h"

@implementation RTPeripheralTableViewCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        _stateLabel = [[UILabel alloc]init];
        _stateLabel.textAlignment = NSTextAlignmentRight;
        _stateLabel.textColor = [UIColor lightGrayColor];
        _stateLabel.adjustsFontSizeToFitWidth = YES;
        _stateLabel.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
        [self addSubview:_stateLabel];
    }
    return self;
}

//-(void)setFrame:(CGRect)frame
//{
//    [super setFrame:frame];
//    CGRect f = self.textLabel.frame;
//    f.origin.x = f.size.width*0.6;
//    f.size.width = f.size.width*0.3;
//    _stateLabel.frame = f;
//}

- (void)awakeFromNib {
    // Initialization code
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    CGRect frame = self.frame;
    CGRect f = self.textLabel.frame;
    f.origin.x = frame.size.width*0.6;
    f.size.width = frame.size.width*0.3;
    _stateLabel.frame = f;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
