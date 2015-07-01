//
//  TimingPlanTableViewCell.m
//  rongtai
//
//  Created by William-zhang on 15/7/1.
//  Copyright (c) 2015年 William-zhang. All rights reserved.
//

#import "TimingPlanTableViewCell.h"
#import "TimingPlan.h"
#import <MagicalRecord.h>

@interface TimingPlanTableViewCell ()
{
    UISwitch* _switch;
    UILabel* _title;
    UILabel* _time;
    UIView* _line;
}
@end

@implementation TimingPlanTableViewCell

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

-(void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    [self setUIFrame];
}

-(void)setTimingPlan:(TimingPlan *)timingPlan
{
    _timingPlan = timingPlan;
    _title.text = _timingPlan.massageName;
    _time.text = [_timingPlan planTime];
    [_switch setOn:[_timingPlan.isOn boolValue] animated:YES];
    
}

#pragma mark - 初始化UI
-(void)setUp
{
    _switch = [[UISwitch alloc]init];
    [_switch addTarget:self action:@selector(switchChange:) forControlEvents:UIControlEventValueChanged];
    _title = [[UILabel alloc]init];
    _title.adjustsFontSizeToFitWidth = YES;
    _time.textColor = [UIColor lightGrayColor];
    _time = [[UILabel alloc]init];
    _time.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
    _time.font = [UIFont fontWithName:@"HelveticaNeue" size:30];
    _line = [[UIView alloc]init];
    _line.backgroundColor = [UIColor lightGrayColor];
    [self addSubview:_switch];
    [self addSubview:_title];
    [self addSubview:_time];
    [self addSubview:_line];
}

#pragma mark - 定位UI
-(void)setUIFrame
{
    CGFloat width = self.frame.size.width;
    CGFloat height = self.frame.size.height;
    _title.frame = CGRectMake(10, 5, 0.5*width, 0.2*height);
    _time.frame = CGRectMake(10, 5+0.2*height, 0.6*width, 0.7*height);
    _line.frame = CGRectMake(0, height-1, width, 1);
    _switch.frame = CGRectMake(width*0.8, (height-27)/2, 79, 27);
}

#pragma mark - switch开关方法
-(void)switchChange:(UISwitch*)aSwitch
{
    if (aSwitch.isOn) {
        [self setOn];
    }
    else
    {
        [self setOff];
    }
    _timingPlan.isOn = [NSNumber numberWithBool:aSwitch.isOn];
    [[NSManagedObjectContext MR_contextForCurrentThread] MR_saveToPersistentStoreAndWait];
}

#pragma mark - 设置开状态的UI
-(void)setOn
{
    _time.textColor = [UIColor blueColor];
    _title.alpha = 1;
}

#pragma mark - 设置关状态的UI
-(void)setOff
{
    _time.textColor = [UIColor lightGrayColor];
    _title.alpha = 0.6;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
