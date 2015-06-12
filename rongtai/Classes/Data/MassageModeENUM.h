//
//  MassageModeENUM.h
//  rongtai
//
//  Created by William-zhang on 15/6/12.
//  Copyright (c) 2015年 William-zhang. All rights reserved.
//

#ifndef rongtai_MassageModeENUM_h
#define rongtai_MassageModeENUM_h

/**
 *  使用说明：只要根据枚举名称打出前两个字母，就可以根据自动提示查看所有该枚举的值
 */


/**
 *  使用时机枚举
 */
typedef NS_ENUM(NSUInteger, MassageUsetiming)
{
    MUAfterWork = 0,  //工作后
    MUAfterBusinessTrip,  //出差后
    MUAfterSport,       //运动后
    MUAfterShopping,   //逛街后
};

/**
 *  使用目的枚举
 */
typedef NS_ENUM(NSUInteger, MassagePurpose)
{
    MPRelieveFatigue = 0,  //缓解疲劳
    MPMuscularRelaxation,  //肌肉放松
    MPSleepImprovement,    //改善睡眠
    MPDailyHealthCare,     //日常保健
};

/**
 *  重点部位枚举
 */
typedef NS_ENUM(NSUInteger, ImportantPart)
{
    IPShoulders = 0,  //肩部
    IPBack,  //背部
    IPWaist,  //腰部
    IPHip,  //臀部
};

/**
 *  按摩手法枚举
 */
typedef NS_ENUM(NSUInteger, MassageWay)
{
    MWThailand = 0,  //泰式
    MWJapanese,      //日式
    MWChinese,       //中式
};

/**
 *  技法偏好枚举
 */
typedef NS_ENUM(NSUInteger, SkillsPreference)
{
    SPMalaxation = 0, //揉捏
    SPManipulation,  //推拿
    SPStrike, //敲打
    SPMix, //组合
};

#endif
