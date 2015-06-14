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

@end
