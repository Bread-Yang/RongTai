//
//  ManualHumanView.m
//  rongtai
//
//  Created by William-zhang on 15/7/21.
//  Copyright (c) 2015年 William-zhang. All rights reserved.
//

#import "ManualHumanView.h"
#import "LineLabel.h"
#import "RTCommand.h"
#import "RTBleConnector.h"

@interface ManualHumanView ()
{
    UIImageView* _humanImage;
    UILabel* _partLabel;
    UIButton* _bodyBtn;  //全身按钮
    UIButton* _shoulderBtn;  //肩部按钮
    UIButton* _waistBtn;  //背腰按钮
    UIButton* _hipBtn;   //臀部按钮
    UIButton* _footBtn;  //腿足按钮
    
    NSArray* _parts;  //部位名称
    
    LineLabel* _bodyLabel;  //全身标题
    LineLabel* _shoulderLabel;  //肩部标题
    LineLabel* _waistLabel;  //背腰标题
    LineLabel* _hipLabel;  //臀部标题
    LineLabel* _footLabel;  //腿足标题
}
@end

@implementation ManualHumanView


-(instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self setUp];
        [self adjustPositin];
    }
    return self;
}

#pragma mark - 初始化
-(void)setUp
{
    _parts = @[@"全身",@"臀肩",@"背腰",@"臀部",@"腿足"];
    _humanImage = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"body"]];
//    _humanImage.backgroundColor = [UIColor redColor];
    [self addSubview:_humanImage];
    
    _partLabel = [[UILabel alloc]init];
    _partLabel.font = [UIFont systemFontOfSize:15];
    _partLabel.text = @"请选择需要的按摩部位";
    _partLabel.textColor = ORANGE;
    _partLabel.textAlignment = NSTextAlignmentCenter;
//    _partLabel.backgroundColor = [UIColor lightGrayColor];
    [self addSubview:_partLabel];
    
    //
    _bodyBtn = [self pointButtonByTag:2100];
    _shoulderBtn = [self pointButtonByTag:2101];
    _waistBtn = [self pointButtonByTag:2102];
    _hipBtn = [self pointButtonByTag:2103];
    _footBtn = [self pointButtonByTag:2104];
    
    //
    _bodyLabel = [self lineLabelByTag:2110 Name:_parts[0]];
    _bodyLabel.labelType = LineRightLabel;
    _shoulderLabel = [self lineLabelByTag:2111 Name:_parts[1]];
    _waistLabel = [self lineLabelByTag:2112 Name:_parts[2]];
    _hipLabel = [self lineLabelByTag:2113 Name:_parts[3]];
    _hipLabel.labelType = LineRightLabel;
    _footLabel = [self lineLabelByTag:2114 Name:_parts[4]];
    
    //
    _isSelected = NO;
}

#pragma mark - 调整UI位置
-(void)adjustPositin
{
    CGFloat h = CGRectGetHeight(self.frame);
    CGFloat w = CGRectGetWidth(self.frame);
    CGFloat buttonWidth = 0.07*h;
    CGFloat imageHeight = 0.9*h;
    CGFloat imageWidth = imageHeight*152/285;
    CGFloat imageX = (w-imageWidth)/2;
    
    _humanImage.frame = CGRectMake(imageX, 0, imageWidth, imageHeight);
    
    _partLabel.frame = CGRectMake(0.15*w, imageHeight, 0.7*w, 0.1*h);
    
    //
    _bodyBtn.frame = CGRectMake((w-buttonWidth)/2, 0.028*h, buttonWidth, buttonWidth);
    _shoulderBtn.frame = CGRectMake(imageX+0.26*imageWidth, 0.155*h, buttonWidth, buttonWidth);
    _waistBtn.frame = CGRectMake(imageX+0.339*imageWidth, 0.337*h, buttonWidth, buttonWidth);
    _hipBtn.frame = CGRectMake(imageX+0.539*imageWidth, 0.452*h, buttonWidth, buttonWidth);
    _footBtn.frame = CGRectMake(imageX+0.355*imageWidth, 0.609*h, buttonWidth, buttonWidth);
    
    //
    _bodyLabel.frame = CGRectMake((1.01*w+buttonWidth)/2, 0.028*h, 0.15*w, buttonWidth);
    _shoulderLabel.frame = CGRectMake(imageX+0.26*imageWidth-0.16*w, 0.155*h, 0.15*w, buttonWidth);
    _waistLabel.frame = CGRectMake(imageX+0.339*imageWidth-0.26*w, 0.337*h, 0.25*w, buttonWidth);
    _hipLabel.frame = CGRectMake(imageX+0.539*imageWidth+buttonWidth+0.01*w, 0.452*h, 0.25*w, buttonWidth);
    _footLabel.frame = CGRectMake(imageX+0.355*imageWidth-0.19*w, 0.609*h, 0.18*w, buttonWidth);
}


#pragma mark - 快速生成一个按钮
-(UIButton*)pointButtonByTag:(NSInteger)tag
{
    UIButton* btn = [[UIButton alloc]init];
    btn.tag = tag;
    [btn setImage:[UIImage imageNamed:@"piont_2"] forState:UIControlStateNormal];
    [btn setImage:[UIImage imageNamed:@"piont_3"] forState:UIControlStateSelected];
    [btn addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:btn];
    return btn;
}

#pragma mark - 快速生成一个LineLabel
-(LineLabel*)lineLabelByTag:(NSInteger)tag Name:(NSString*)name
{
    LineLabel* lineLabel = [[LineLabel alloc]init];
    lineLabel.tag = tag;
    lineLabel.title = name;
    [self addSubview:lineLabel];
    return lineLabel;
}

#pragma mark - 按钮方法
-(void)buttonClicked:(UIButton*)btn
{
    _isSelected = YES;
    for (int i = 0; i<_parts.count; i++) {
        UIButton* b = (UIButton*)[self viewWithTag:2100+i];
        LineLabel* l = (LineLabel*)[self viewWithTag:2110+i];
        if (b.tag == btn.tag) {
            [b setSelected:YES];
            l.isSelected = YES;
        }
        else
        {
            [b setSelected:NO];
            l.isSelected = NO;
        }
    }
    _partLabel.text = [NSString stringWithFormat:@"按摩部位：%@",_parts[btn.tag-2100]];
    _partLabel.textColor = BLUE;
    NSMutableAttributedString* string = [[NSMutableAttributedString alloc]initWithAttributedString:_partLabel.attributedText];
    
    NSDictionary* dic = [[NSDictionary alloc]initWithObjectsAndKeys:ORANGE,NSForegroundColorAttributeName, nil];
    NSRange r = [string.string rangeOfString:@"："];
    r.location ++;
    r.length = string.string.length - r.location;
    [string setAttributes:dic range:r];
    _partLabel.attributedText = string;

	switch (btn.tag) {
  		case 2100:
			[[RTBleConnector shareManager] sendControlMode:H10_KEY_AIRBAG_AUTO];
			break;
		case 2101:
			[[RTBleConnector shareManager] sendControlMode:H10_KEY_AIRBAG_ARM];
			break;
		case 2102:
			[[RTBleConnector shareManager] sendControlMode:H10_KEY_AIRBAG_WAIST];
			break;
		case 2103:
			[[RTBleConnector shareManager] sendControlMode:H10_KEY_AIRBAG_BUTTOCKS];
			break;
		case 2104:
			[[RTBleConnector shareManager] sendControlMode:H10_KEY_AIRBAG_LEG];
			break;
	}
    if ([self.delegate respondsToSelector:@selector(maualHumanViewClicked:)]) {
        [self.delegate maualHumanViewClicked:self];
    }
}

- (void)checkButtonByAirBagProgram:(RTMassageChairAirBagProgram)airBagProgram {
	UIButton *btn;
	
	switch (airBagProgram) {
  		case RTMassageChairAirBagProgramFullBody:
			btn = _bodyBtn;
			break;
		case RTMassageChairAirBagProgramArmAndShoulder:
			btn = _shoulderBtn;
			break;
		case RTMassageChairAirBagProgramBackAndWaist:
			btn = _waistBtn;
			break;
		case RTMassageChairAirBagProgramButtock:
			btn = _hipBtn;
			break;
		case RTMassageChairAirBagProgramLegAndFeet:
			btn = _footBtn;
			break;
		case RTMassageChairAirBagProgramNone:
			break;
	}
	
    for (int i = 0; i<_parts.count; i++) {
        UIButton* b = (UIButton*)[self viewWithTag:2100+i];
        LineLabel* l = (LineLabel*)[self viewWithTag:2110+i];
        if (btn && b.tag == btn.tag) {
            [b setSelected:YES];
            l.isSelected = YES;
        }
        else
        {
            [b setSelected:NO];
            l.isSelected = NO;
        }
    }
    
	if (btn) {
        _isSelected = YES;
		_partLabel.text = [NSString stringWithFormat:@"按摩部位：%@",_parts[btn.tag-2100]];
		_partLabel.textColor = BLUE;
		NSMutableAttributedString* string = [[NSMutableAttributedString alloc]initWithAttributedString:_partLabel.attributedText];
		
		NSDictionary* dic = [[NSDictionary alloc]initWithObjectsAndKeys:ORANGE,NSForegroundColorAttributeName, nil];
		NSRange r = [string.string rangeOfString:@"："];
		r.location ++;
		r.length = string.string.length - r.location;
		[string setAttributes:dic range:r];
		_partLabel.attributedText = string;
	}
    else
    {
        _isSelected = NO;
        _partLabel.text = @"请选择需要的按摩部位";
        _partLabel.textColor = ORANGE;
    }
}

@end
