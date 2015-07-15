//
//  SegmentTableViewCell.m
//  rongtai
//
//  Created by William-zhang on 15/7/15.
//  Copyright (c) 2015年 William-zhang. All rights reserved.
//

#import "SegmentTableViewCell.h"
#import "RFSegmentView.h"

@interface SegmentTableViewCell ()
{
    RFSegmentView* _segmentView;
    NSUInteger _count;
}
@end

@implementation SegmentTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        _titleLabel = [[UILabel alloc]init];
        _segmentView = [[RFSegmentView alloc]init];
        UIView* line = [[UIView alloc]init];
        line.backgroundColor = [UIColor grayColor];
        line.alpha = 0.2;
        [self addSubview:line];
    }
    return self;
}

-(void)setNames:(NSArray *)names
{
    _names = names;
    [_segmentView setItems:_names];
    _count = _names.count;
}

-(void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    CGRect f;
    CGFloat w = CGRectGetWidth(self.frame);
    CGFloat h = CGRectGetHeight(self.frame);
//    _titleLabel.frame = CGRectMake(<#CGFloat x#>, <#CGFloat y#>, <#CGFloat width#>, CGFloat height)
    if (_count<3) {
//        f = CGRectMake(<#CGFloat x#>, <#CGFloat y#>, <#CGFloat width#>, <#CGFloat height#>)
    }
    else
    {
        
    }
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
