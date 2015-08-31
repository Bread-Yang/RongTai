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
#import "TimingPlanRequest.h"

#define TIME_COLOR [UIColor colorWithRed:3 / 255.0 green:124 / 255.0 blue:230 / 255.0 alpha:1.0]

@interface TimingPlanTableViewCell () {
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

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setUp];
    }
    return self;
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    [self setUIFrame];
}

- (void)setTimingPlan:(TimingPlan *)timingPlan {
    _timingPlan = timingPlan;
    _title.text = _timingPlan.massageName;
    _time.text = _timingPlan.ptime;
    BOOL isOn = [_timingPlan.isOn boolValue];
    [_switch setOn:isOn animated:YES];
    if (isOn) {
        [self setOn];
    } else {
        [self setOff];
    }
}

#pragma mark - 初始化UI
- (void)setUp {
    _switch = [[UISwitch alloc]init];
    [_switch addTarget:self action:@selector(switchChange:) forControlEvents:UIControlEventValueChanged];
    _title = [[UILabel alloc] init];
    _title.adjustsFontSizeToFitWidth = YES;
    _time = [[UILabel alloc] init];
	_time.textColor = TIME_COLOR;
    _time.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
	_time.font = [UIFont systemFontOfSize:35];
//    _time.font = [UIFont fontWithName:@"HelveticaNeue" size:40];
    _line = [[UIView alloc] init];
    _line.backgroundColor = [UIColor grayColor];
    [self addSubview:_switch];
    [self addSubview:_title];
    [self addSubview:_time];
    [self addSubview:_line];
	self.backgroundColor = [UIColor clearColor];
}

#pragma mark - 定位UI

-(void)setUIFrame {
    CGFloat width = self.frame.size.width;
    CGFloat height = self.frame.size.height;
    _title.frame = CGRectMake(10, 5, 0.5 * width, 0.2 * height);
    _time.frame = CGRectMake(10, 5 + 0.2 * height, 0.6 * width, 0.7 * height);
    _line.frame = CGRectMake(0, height - 1, width, 1);
    _switch.frame = CGRectMake(width * 0.8, (height - 27) / 2, 79, 27);
}

#pragma mark - switch开关方法
-(void)switchChange:(UISwitch*)aSwitch {
	TimingPlanRequest *request = [TimingPlanRequest new];
	
    if (aSwitch.isOn) {
        [self setOn];
        [_timingPlan turnOnLocalNotification];
    } else {
        [self setOff];
        [_timingPlan cancelLocalNotification];
    }
    
    _timingPlan.isOn = [NSNumber numberWithBool:aSwitch.isOn];
    
    NSUInteger planId = [_timingPlan.planId integerValue];
    if (planId == 0)
    {
        //id=0，即是未上传到服务器的数据，要使用 新增 方法
        [request addTimingPlan:_timingPlan success:^(NSUInteger timingPlanId) {
            _timingPlan.planId = [NSNumber numberWithUnsignedInteger:timingPlanId];
            _timingPlan.state = [NSNumber numberWithInteger:0];
            [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
        } fail:^(NSDictionary *dic) {
            _timingPlan.state = [NSNumber numberWithInteger:1];
            [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
        }];
    }
    else
    {
        //id不为0，则使用 编辑 方法
        [request updateTimingPlan:_timingPlan success:^(NSDictionary *dic) {
            _timingPlan.state = [NSNumber numberWithInteger:0];
            [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
        } fail:^(NSDictionary *dic) {
            _timingPlan.state = [NSNumber numberWithInteger:2];
            [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
        }];
    }
}

#pragma mark - 设置开状态的UI
-(void)setOn {
    _time.textColor = TIME_COLOR;
    _title.alpha = 1;
}

#pragma mark - 设置关状态的UI
-(void)setOff {
    _time.textColor = [UIColor lightGrayColor];
    _title.alpha = 0.6;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
