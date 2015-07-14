//
//  RFSegmentView.m
//  RFSegmentView
//
//  Created by 王若风 on 1/15/15.
//  Copyright (c) 2015 王若风. All rights reserved.
//

#import "RFSegmentView.h"

#define RGB_Color(r,g,b)    RGBA_Color(r,g,b,1)
#define RGBA_Color(r,g,b,a) ([UIColor colorWithRed:r/255 green:g/255 blue:b/255 alpha:a])
#define kDefaultTintColor   RGB_Color(3, 116, 255)
#define kLeftMargin         15
#define kItemHeight         30
#define kBorderLineWidth    0.5
@class RFSegmentItem;
@protocol RFSegmentItemDelegate
- (void)ItemStateChanged:(RFSegmentItem *)item index:(NSInteger)index isSelected:(BOOL)isSelected;
@end

@interface RFSegmentItem : UIView
@property(nonatomic ,strong) UIColor *norFontColor;
@property(nonatomic ,strong) UIColor *selFontColor;
@property(nonatomic ,strong) UIColor *norBgColor;
@property(nonatomic ,strong) UIColor *selBgColor;
@property(nonatomic ,strong) UILabel *titleLabel;
@property(nonatomic)         NSInteger index;
@property(nonatomic)         BOOL isSelected;
@property(nonatomic)         id   delegate;

@end

@implementation RFSegmentItem
- (id)initWithFrame:(CGRect)frame index:(NSInteger)index title:(NSString *)title norFontColor:(UIColor *)norFontColor selFontColor:(UIColor *)selFontColor norBgColor:(UIColor *)norBgColor selBgColor:(UIColor *)selBgColor isSelected:(BOOL)isSelected;
{
    self = [super initWithFrame:frame];
    if (self) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 2, frame.size.width-10, frame.size.height-4)];
        _titleLabel.textAlignment   = NSTextAlignmentCenter;
        _titleLabel.backgroundColor = [UIColor clearColor];
//        _titleLabel.numberOfLines = 0;
        _titleLabel.adjustsFontSizeToFitWidth = YES;
        _titleLabel.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
//        _titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        [self addSubview:_titleLabel];
        
        self.norFontColor        = norFontColor;
        self.selFontColor        = selFontColor;
        self.norBgColor = norBgColor;
        self.selBgColor = selBgColor;
        self.titleLabel.text = title;
        self.index           = index;
        self.isSelected      = isSelected;
    }
    return self;
}

- (void)setIsSelected:(BOOL)isSelected
{
    _isSelected = isSelected;
    if (_isSelected) {
        self.titleLabel.textColor = self.selFontColor;
        self.backgroundColor = self.selBgColor;
    }
    else
    {
        self.titleLabel.textColor = self.norFontColor;
        self.backgroundColor = self.norBgColor;
    }
    
}
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    
    self.isSelected = !_isSelected;
    
    if (_delegate) {
        [_delegate ItemStateChanged:self index:self.index isSelected:self.isSelected];
    }
    
    
}

@end
#pragma mark - RFSegmentView
@interface RFSegmentView()

@property(nonatomic ,strong) UIView *bgView;
@property(nonatomic ,strong) NSMutableArray *titlesArray;
@property(nonatomic ,strong) NSMutableArray *itemsArray;
@property(nonatomic ,strong) NSMutableArray *linesArray;

@end
@implementation RFSegmentView

-(id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        [self setUp];
        NSLog(@"Sframe：%@",NSStringFromCGRect(self.frame));
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

-(void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    NSLog(@"设置Sframe");
}

- (id)initWithFrame:(CGRect)frame items:(NSArray *)items;
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setUp];
        self.items = items;
    }
    return self;
}

-(void)setUp
{
    
    self.backgroundColor  = [UIColor clearColor];
    float viewWidth       = CGRectGetWidth(self.frame);
    float viewHeight      = CGRectGetHeight(self.frame);
    self.selectIndex = 0;
    //
    self.bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, viewWidth, viewHeight)];
    self.bgView.backgroundColor    = [UIColor clearColor];
    self.bgView.clipsToBounds      = YES;
    //        self.bgView.layer.cornerRadius = 5;
    self.lineWidth = 1;
    self.cornerRadius = 5;
    self.bgView.clipsToBounds = YES;
    self.bgView.layer.cornerRadius = self.cornerRadius;
    
    [self addSubview:self.bgView];
    self.selBgColor = [UIColor colorWithRed:82/255.0 green:203/255.0 blue:82/255.0 alpha:1];
    self.selFontColor = [UIColor whiteColor];
    self.LineColor = [UIColor colorWithRed:116/255.0 green:154/255.0 blue:180/255.0 alpha:1];
    self.norFontColor = [UIColor colorWithRed:116/255.0 green:154/255.0 blue:180/255.0 alpha:1];
    self.norBgColor = [UIColor clearColor];
    self.bgView.layer.borderWidth  = self.lineWidth;
    self.bgView.layer.borderColor  = self.LineColor.CGColor;
}

-(void)setItems:(NSArray *)items
{
    CGFloat init_x = 0;
    CGFloat init_y = 0;
    float itemWidth = CGRectGetWidth(self.bgView.frame)/items.count;
    float itemHeight = CGRectGetHeight(self.bgView.frame);
    if (items.count >= 2) {
        for (NSInteger i =0; i<items.count; i++) {
            RFSegmentItem *item = [[RFSegmentItem alloc] initWithFrame:CGRectMake(init_x, init_y, itemWidth, itemHeight)
                                                                 index:i title:items[i]
                                                          norFontColor:self.norFontColor selFontColor:self.selFontColor norBgColor:self.norBgColor selBgColor:self.selBgColor isSelected:(i == 0)? YES: NO];
            
            init_x += itemWidth;
            [self.bgView addSubview:item];
            item.delegate = self;
            
            //save all items
            if (!self.itemsArray) {
                self.itemsArray = [[NSMutableArray alloc] initWithCapacity:items.count];
            }
            [self.itemsArray setObject:item atIndexedSubscript:i];
        }
        
        //add Ver lines
        init_x = 0;
        for (NSInteger i = 0; i<items.count-1; i++) {
            init_x += itemWidth;
            UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(init_x, 0, self.lineWidth, itemHeight)];
            lineView.backgroundColor = self.LineColor;
            [self.bgView addSubview:lineView];
            
            //save all lines
            if (!self.linesArray) {
                self.linesArray = [[NSMutableArray alloc] initWithCapacity:items.count];
            }
            [self.linesArray setObject:lineView atIndexedSubscript:i];
        }
    }
    else
    {
        NSException *exc = [[NSException alloc] initWithName:@"items count error"
                                                      reason:@"items count at least 2"
                                                    userInfo:nil];
        @throw exc;
    }
}


#pragma mark - set方法
-(void)setNumberOfLines:(NSInteger)numberOfLines
{
    _numberOfLines = numberOfLines;
    for (int i = 0; i<_itemsArray.count; i++) {
        RFSegmentItem *item = _itemsArray[i];
        item.titleLabel.numberOfLines = _numberOfLines;
    }
}

-(void)setSelectIndex:(NSUInteger)selectIndex
{
    _selectIndex = selectIndex;
    for (int i = 0; i<_itemsArray.count; i++) {
        RFSegmentItem* item = _itemsArray[i];
        if (i == _selectIndex) {
            item.isSelected = YES;
        }
        else
        {
            item.isSelected = NO;
        }
    }
}

-(void)setCornerRadius:(CGFloat)cornerRadius
{
    _cornerRadius = cornerRadius;
    self.bgView.layer.cornerRadius = cornerRadius;
}

-(void)setLineColor:(UIColor *)LineColor
{
    _LineColor = LineColor;
    self.bgView.layer.borderColor = self.LineColor.CGColor;
}

-(void)setLineWidth:(CGFloat)lineWidth
{
    _lineWidth = lineWidth;
    self.bgView.layer.borderWidth = lineWidth;
}

#pragma mark - RFSegmentItemDelegate
- (void)ItemStateChanged:(RFSegmentItem *)currentItem index:(NSInteger)index isSelected:(BOOL)isSelected
{
    _selectIndex = index;
    
    for (int i =0; i<self.itemsArray.count; i++) {
        RFSegmentItem *item = self.itemsArray[i];
        item.isSelected = NO;
    }
    currentItem.isSelected = YES;
    
    if (_delegate && [_delegate respondsToSelector:@selector(segmentViewSelectIndex:)])
    {
        [_delegate segmentViewSelectIndex:index];
    }
}

@end
