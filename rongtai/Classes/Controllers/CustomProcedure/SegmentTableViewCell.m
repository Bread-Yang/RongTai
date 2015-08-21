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
    UIView* _line;
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
        _line = [[UIView alloc]init];
        _line.backgroundColor = [UIColor grayColor];
        _line.alpha = 0.2;
        [self addSubview:_line];
        [self addSubview:_titleLabel];
        [self addSubview:_segmentView];
    }
    return self;
}

-(void)setTitle:(NSString *)title
{
    _title = title;
    _titleLabel.text = title;
}

-(void)setNames:(NSArray *)names
{
    _names = names;
    [_segmentView setItems:_names];
    _count = _names.count;
    [self updateUI];
    NSLog(@"cellF-Name:%@",NSStringFromCGRect(self.frame));
}

-(void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    [_segmentView setItems:self.names];
    [self updateUI];
    NSLog(@"cellF:%@",NSStringFromCGRect(self.frame));
}

#pragma mark - 界面调整
-(void)updateUI
{
    CGFloat w = CGRectGetWidth(self.frame);
    CGFloat h = CGRectGetHeight(self.frame);
    _line.frame = CGRectMake(0, h-1, w, 1);
    CGFloat scale = 0.9;
    CGFloat xDlt = w*(1-scale)/2;
    CGFloat yDlt = h*(1-scale)/2;
    if (_count<3) {
        //label和SegmentView横向并排
        
        _titleLabel.frame = CGRectMake(xDlt, xDlt, w*0.3, h-2*xDlt);
        _segmentView.frame = CGRectMake(w-xDlt-w*0.4, xDlt, w*0.4, h-2*xDlt);
    }
    else
    {
        //label和SegmentView竖向并排
        h = h-2*xDlt;
        _titleLabel.frame = CGRectMake(xDlt, xDlt, scale*w, h*0.3);
        _segmentView.frame = CGRectMake(xDlt, xDlt+h*0.3+10, scale*w, h*(scale-0.3));
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
