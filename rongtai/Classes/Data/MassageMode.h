//
//  MassageMode.h
//  rongtai
//
//  Created by William-zhang on 15/6/12.
//  Copyright (c) 2015年 William-zhang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MassageModeENUM.h"

@interface MassageMode : NSObject

/**
 *  名称
 */
@property(nonatomic, strong)NSString* name;

/**
 *  使用时机
 */
@property(nonatomic)MassageUsetiming massageUsetiming;

/**
 *  使用目的
 */
@property(nonatomic)MassagePurpose massagePurpose;

/**
 *  重点部位
 */
@property(nonatomic)ImportantPart importantPart;

/**
 *  按摩手法
 */
@property(nonatomic)MassageWay massageWay;

/**
 *  技法偏好
 */
@property(nonatomic)SkillPreference skillsPreference;


/**
 *  根据使用时机枚举类返回对应的字符串
 */
+(NSString*)MassageUsetimingString:(MassageUsetiming)massageUsetiming;

/**
 *  根据使用目的枚举类返回对应的字符串
 */
+(NSString*)MassagePurposeString:(MassagePurpose)massagePurpose;

/**
 *  根据重点部位枚举类返回对应的字符串
 */
+(NSString*)ImportantPartString:(ImportantPart)importantPart;

/**
 *  根据按摩手法枚举类返回对应的字符串
 */
+(NSString*)MassageWayString:(MassageWay)massageWay;

/**
 *  根据技法偏好枚举类返回对应的字符串
 */
+(NSString*)SkillPreferenceString:(SkillPreference)skillPreference;

@end
