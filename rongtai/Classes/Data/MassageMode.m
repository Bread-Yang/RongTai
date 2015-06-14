//
//  MassageMode.m
//  rongtai
//
//  Created by William-zhang on 15/6/12.
//  Copyright (c) 2015年 William-zhang. All rights reserved.
//

#import "MassageMode.h"

@implementation MassageMode


#pragma mark - 根据枚举返回对应字符串
//使用时机
+(NSString*)MassageUsetimingString:(MassageUsetiming)massageUsetiming
{
    NSString* s;
    switch (massageUsetiming) {
        case MUAfterWork:
            s = NSLocalizedString(@"工作后", nil);
            break;
        case MUAfterTraveling:
            s = NSLocalizedString(@"出差后", nil);
            break;
        case MUAfterSport:
            s = NSLocalizedString(@"运动后", nil);
            break;
        case MUAfterShopping:
            s = NSLocalizedString(@"逛街后", nil);
            break;
        default:
            break;
    }
    return s;
}

//使用目的
+(NSString*)MassagePurposeString:(MassagePurpose)massagePurpose
{
    NSString* s;
    switch (massagePurpose) {
        case MPRelieveFatigue:
            s = NSLocalizedString(@"缓解疲劳", nil);
            break;
        case MPMuscularRelaxation:
            s = NSLocalizedString(@"肌肉放松", nil);
            break;
        case MPSleepImprovement:
            s = NSLocalizedString(@"改善睡眠", nil);
            break;
        case MPDailyHealthCare:
            s = NSLocalizedString(@"日常保健", nil);
            break;
        default:
            break;
    }
    return s;
}

//重点部位
+(NSString*)ImportantPartString:(ImportantPart)importantPart
{
    NSString* s;
    switch (importantPart) {
        case IPShoulders:
            s = NSLocalizedString(@"肩部", nil);
            break;
        case IPBack:
            s = NSLocalizedString(@"背部", nil);
            break;
        case IPWaist:
            s = NSLocalizedString(@"腰部", nil);
            break;
        case IPHip:
            s = NSLocalizedString(@"臀部", nil);
            break;
        default:
            break;
    }
    return s;
}

//按摩手法
+(NSString*)MassageWayString:(MassageWay)massageWay
{
    NSString* s;
    switch (massageWay) {
        case MWThailand:
            s = NSLocalizedString(@"泰式", nil);
            break;
        case MWJapanese:
            s = NSLocalizedString(@"日式", nil);
            break;
        case MWChinese:
            s = NSLocalizedString(@"中式", nil);
            break;
        default:
            break;
    }
    return s;
}

//技法偏好
+(NSString*)SkillPreferenceString:(SkillPreference)skillPreference
{
    NSString* s;
    switch (skillPreference) {
        case SPMalaxation:
            s = NSLocalizedString(@"揉捏", nil);
            break;
        case SPManipulation:
            s = NSLocalizedString(@"推拿", nil);
            break;
        case SPStrike:
            s = NSLocalizedString(@"敲打", nil);
            break;
        case SPMix:
            s = NSLocalizedString(@"组合", nil);
            break;
        default:
            break;
    }
    return s;
}


@end
