//
//  SegmentTableViewCell.m
//  rongtai
//
//  Created by William-zhang on 15/7/15.
//  Copyright (c) 2015年 William-zhang. All rights reserved.
//

#import "SegmentTableViewCell.h"
#import "RFSegmentView.h"

@interface SegmentTableViewCell ()<RFSegmentViewDelegate>
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
        [self setUp];
    }
    return self;
}

-(instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self setUp];
    }
    return self;
}

-(void)setUp
{
    _titleLabel = [[UILabel alloc]init];
    _titleLabel.adjustsFontSizeToFitWidth = YES;
    _titleLabel.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
    _segmentView = [[RFSegmentView alloc]init];
    _segmentView.delegate = self;
    _line = [[UIView alloc]init];
    _line.backgroundColor = [UIColor grayColor];
    _line.alpha = 0.2;
    _segmentViewScale = 0.92;
    [self addSubview:_line];
    [self addSubview:_titleLabel];
    [self addSubview:_segmentView];
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
}

-(void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    [self updateUI];
}

-(void)setItemFont:(UIFont *)itemFont
{
    _itemFont = itemFont;
    _segmentView.font = itemFont;
}

-(void)setSegmentViewScale:(CGFloat)segmentViewScale
{
    _segmentViewScale = segmentViewScale;
    [self updateUI];
}

-(void)setSelectedIndex:(NSUInteger)selectedIndex
{
    _selectedIndex = selectedIndex;
    _segmentView.selectIndex = _selectedIndex;
}

#pragma mark - 界面调整
-(void)updateUI
{
    CGFloat w = CGRectGetWidth(self.frame);
    CGFloat h = CGRectGetHeight(self.frame);
    _line.frame = CGRectMake(0, h-1, w, 1);
    CGFloat xDlt = w*(1-0.92)/2;
//    CGFloat yDlt = h*(1-scale)/2;
    if (_count<3) {
        //label和SegmentView横向并排
        h = h-2*xDlt;
        _titleLabel.frame = CGRectMake(xDlt, xDlt, w*0.3, h);
        _segmentView.frame = CGRectMake(w-xDlt-w*0.4, xDlt, w*0.4, h);
    }
    else
    {
        //label和SegmentView竖向并排
        h = h-2*xDlt;
        _titleLabel.frame = CGRectMake(xDlt, xDlt, _segmentViewScale*w, h*0.3);
        _segmentView.frame = CGRectMake(xDlt, xDlt+h*0.3+8, _segmentViewScale*w, h*(0.92-0.3));
    }
}

#pragma mark - segmentView代理
-(void)segmentViewSelectIndex:(NSInteger)index
{
    _selectedIndex = index;
    if ([self.delegate respondsToSelector:@selector(segmentTableViewCell:Clicked:)]) {
        [self.delegate segmentTableViewCell:self Clicked:index];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
