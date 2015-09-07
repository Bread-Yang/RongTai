//
//  RTMassageChairStatus.h
//  BLETool
//
//  Created by yoghourt on 5/26/15.
//  Copyright (c) 2015 Jaben. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, RTMassageChairDeviceStatus) {
	
	/** 
	 *	待机状态, 第七位中 : workingStatusFlag == 0
	 */
	RtMassageChairStatusStandby,
	
	/** 
	 *	按摩椅复位, 第七位中 : workingStatusFlag == 1
	 */
	RtMassageChairStatusResetting,
	
	/** 
	 *	按摩椅复位,按摩椅点亮主屏，等待用户操作, 第七位 : workingStatusFlag == 2
	 */
	RtMassageChairStatusWaiting,
	
	/** 
	 *	正常运行模式：此时手控器需要显示时间，按摩手法，或按摩程序等信息, 第七位 : workingStatusFlag == 3
	 */
	RtMassageChairStatusMassaging,
	
	/** 
	 *	数据存储
	 */
	RtMassageChairStatusDataStore,
	
	/** 
	 *	严重的故障模式
	 */
	RtMassageChairStatusError
	
};

typedef NS_ENUM(NSInteger, RTMassageChairProgramType) {
	
	/**
	 *	自动按摩程序, 地址13位 : massageProgramFlag < 7
	 */
	RtMassageChairProgramAuto,
	
	/**
	 *	手动按摩程序, 地址13位 : massageProgramFlag == 7
	 */
	RtMassageChairProgramManual,
	
	/**
	 *	网络按摩程序, 地址13位 : massageProgramFlag > 7
	 */
	RtMassageChairProgramNetwork,
	
	// 以下是自动程序
	
	/**
	 *	自动按摩程序 : 运动恢复, 地址13位 : massageProgramFlag == 1
	 */
	RtMassageChairProgramSportRecover,
	
	/**
	 *	自动按摩程序 : 舒展活络, 地址13位 : massageProgramFlag == 2
	 */
	RtMassageChairProgramExtension,
	
	/**
	 *	自动按摩程序 : 休憩促眠, 地址13位 : massageProgramFlag == 3
	 */
	RtMassageChairProgramRestAndSleep,
	
	/**
	 *	自动按摩程序 : 工作减压, 地址13位 : massageProgramFlag == 4
	 */
	RtMassageChairProgramWorkingRelieve,
	
	/**
	 *	自动按摩程序 : 肩颈重点, 地址13位 : massageProgramFlag == 5
	 */
	RtMassageChairProgramShoulderAndNeck,
	
	/**
	 *	自动按摩程序 : 腰椎舒缓, 地址13位 : massageProgramFlag == 6
	 */
	RtMassageChairProgramWaistAndSpine,
	
	// 以下是网络程序
	
	/**
	 *	网络按摩程序 : 网络程序1
	 */
	RTMassageChairProgramNetwork1,
	
	/**
	 *	网络按摩程序 : 网络程序2
	 */
	RTMassageChairProgramNetwork2,
	
	/**
	 *	网络按摩程序 : 网络程序3
	 */
	RTMassageChairProgramNetwork3,
	
	/**
	 *	网络按摩程序 : 网络程序4
	 */
	RTMassageChairProgramNetwork4,
	
	/**
	 *	3D按摩
	 */
	RTMassageChairAutoProgram3D,
	
};

typedef NS_ENUM(NSInteger, RTMassageChairMassageTechnique) {
	
	/**
	 *	按摩手法 : 停止(stop), 地址1位 : massageTechniqueFlag == 0
	 */
	RTMassageChairMassageTechniqueStop,
	
	/**
	 *	按摩手法 : 揉捏(knead), 地址1位 : massageTechniqueFlag == 1
	 */
	RTMassageChairMassageTechniqueKnead,
	
	/**
	 *	按摩手法 : 敲击(knock), 地址1位 : massageTechniqueFlag == 2
	 */
	RTMassageChairMassageTechniqueKnock,
	
	/**
	 *	按摩手法 : 揉敲同步(sync), 地址1位 : massageTechniqueFlag == 3
	 */
	RTMassageChairMassageTechniqueSync,
	
	/**
	 *	按摩手法 : 叩击(tapping), 地址1位 : massageTechniqueFlag == 4
	 */
	RTMassageChairMassageTechniqueTapping,
	
	/**
	 *	按摩手法 : 指压(shiatsu), 地址1位 : massageTechniqueFlag == 5
	 */
	RTMassageChairMassageTechniqueShiatsu,
	
	/**
	 *	按摩手法 : 韵律按摩(rhythm), 地址1位 : massageTechniqueFlag == 6
	 */
	RTMassageChairMassageTechniqueRhythm,
	
	/**
	 *	按摩手法 : 搓背(back rub), 地址1位 : massageTechniqueFlag == 7
	 */
	RTMassageChairMassageTechniqueBackRub,
	
};

typedef NS_ENUM(NSInteger, RTMassageChairAirBagProgram) {
	
	/**
	 *	气囊程序 : 无
	 */
	RTMassageChairAirBagProgramNone,
	
	/**
	 *	气囊程序 : 全身, 地址12位 : FullBodyAirBagProgramFlag == 1
	 */
	RTMassageChairAirBagProgramFullBody,
	
	/**
	 *	气囊程序 : 臂肩, 地址12位 : armAndShoulderAirBagProgramFlag == 1
	 */
	RTMassageChairAirBagProgramArmAndShoulder,
	
	/**
	 *	气囊程序 : 背腰, 地址12位 : backAndWaistAirBagProgramFlag == 1
	 */
	RTMassageChairAirBagProgramBackAndWaist,
	
	/**
	 *	气囊程序 : 臀部, 地址12位 : buttockAirBagProgramFlag == 1
	 */
	RTMassageChairAirBagProgramButtock,
	
	/**
	 *	气囊程序 : 腿足, 地址12位 : legAndFootAirBagProgramFlag == 1
	 */
	RTMassageChairAirBagProgramLegAndFeet,
	
};


@interface RTMassageChairStatus : NSObject

#pragma mark - 按摩界面状态显示用到的字段

/**
 *	按摩椅运行状态
 */
@property (nonatomic, assign) RTMassageChairDeviceStatus deviceStatus;

/**
 *	按摩椅按摩程序类型(手动按摩, 自动按摩, 网络按摩)
 */
@property (nonatomic, assign) RTMassageChairProgramType programType;

/**
 *	自动程序类型(运动恢复, 舒展活络, 休憩促眠, 工作减压, 肩颈重点, 腰椎舒缓)
 */
@property (nonatomic, assign) RTMassageChairProgramType autoProgramType;

/**
 * 	网络程序类型(云养程序1, 云养程序2, 云养程序3, 云养程序4)
 */
@property (nonatomic, assign) RTMassageChairProgramType networkProgramType;

/**
 *	按摩椅按摩手法
 */
@property (nonatomic, assign) RTMassageChairMassageTechnique massageTechnique;

/**
 *	按摩椅气囊程序
 */
@property (nonatomic, assign) RTMassageChairAirBagProgram airBagProgram;

/**
 *	按摩椅剩余运行时间, 地址 5 : remainingTimeLow7Bit + remainingTimeHigh5Bit * 128
 */
@property (nonatomic, assign) NSInteger remainingTime;

/**
 *	按摩椅是否正在加热, 地址 2 : heatingSwitchFlag == 1(正在加热)
 */
@property (nonatomic, assign) BOOL isHeating;

/**
 *	脚部滚轮是否打开, 地址 2 : rollerSwitchFlag == 1(打开)
 */
@property (nonatomic, assign) BOOL isRollerOn;

/**
 *	程序预设时间, 地址 12 : preprogrammedTimeFlag
 */
@property (nonatomic, assign) NSInteger preprogrammedTime;


#pragma mark - 地址 1 按摩椅程序运行状态和按摩手法

/**
 3D标示
 0：机器无3D功能
 1:机器具备3D功能
 */
@property (nonatomic, assign) NSInteger _3dFlag;

/**
 小腿伸缩标示
 0：机器具备小腿伸缩功能
 1:机器无小腿伸缩，此时APP程序中的腿部伸缩按钮变灰
 */
@property (nonatomic, assign) NSInteger calfStretchFlag;

/**
 新程序名称标识
 0:旧程序名称
 1:新程序名称
 */
@property (nonatomic, assign) NSInteger nameFlag;

/**
 按摩手法
 00：停止
 01：揉捏
 02：敲击
 03：揉敲同步
 04：叩击
 05：指压
 06：韵律按摩
 07：搓背
 */
@property (nonatomic, assign) NSInteger massageTechniqueFlag;

/**
 按摩椅运行状态
 0：按摩椅处于待机,主电源关闭，省电模式
 1：按摩椅处于非待机状态，此时手控器相应的图标点亮
 */
@property (nonatomic, assign) NSInteger runningStatusFlag;

#pragma mark - 地址 2 按摩机芯速度和揉捏头宽度位置指示 机芯速度是指当前设定的目标速度，揉捏头宽度指按摩头当前位置

/**
 揉捏头宽度位置
 00：未知（上电后，揉捏电机还未加电，并且此时揉捏头不处于宽、中、窄三个点）
 01：揉捏头最窄
 02：揉捏头中间
 03：揉捏头最宽
 */
@property (nonatomic, assign) NSInteger kneadWidthFlag;

/**
 按摩机芯速度
 00（二进制000）：停止，
 01（二进制001）速度最小，
 02（二进制010）速度较小，
 03（二进制011）速度中小，
 04（二进制100）速度中大，
 05（二进制101）速度较大，
 06（二级制110）速度最大，
 07（二进制111）：保留
 */
@property (nonatomic, assign) NSInteger movementSpeedFlag;

/**
 滚轮
 0：滚轮关，当滚轮关闭时速度必然为零
 1：滚轮开
 手动模式滚轮开，速度可进行三档调节，在自动模式滚轮速度受自动程序控制
 */
@property (nonatomic, assign) NSInteger rollerSwitchFlag;

/**
 加热
 0：关
 1：开
 */
@property (nonatomic, assign) NSInteger heatingSwitchFlag;

#pragma mark - 地址 3 气压强度和振动（或扭腰）强度

/**
 气压强度
 5档强度：00：停止，01最弱，05最强，06和07：保留
 3档强度：00：停止，01最弱，03最强，04-07：保留
 */
@property (nonatomic, assign) NSInteger airPressureFlag;

/**
 负离子开关 : bit 6
 0：负离子关
 1：负离子开
 */
@property (nonatomic, assign) NSInteger anionSwitchFlag;

#pragma mark - 地址 4 运行时间高5位，单位秒

/**
 按摩椅剩余运行秒数高5位
 数值范围0-31
 */
@property (nonatomic, assign) NSInteger remainingTimeHigh5Bit;

/**
 机芯按摩部位
 00：不显示
 01：全局
 02：局部
 03：定点
 */
@property (nonatomic, assign) NSInteger movementMassagePositionFlag;

#pragma mark - 地址 5 运行时间低7位，单位秒，在故障模式为错误代码指示

/**
 按摩椅剩余运行秒数低7位，在故障模式为错误代码指示
 数值范围0-127
 */
@property (nonatomic, assign) NSInteger remainingTimeLow7Bit;

#pragma  mark - 地址 6 气囊或气阀运行状态指示, 滚轮状态指示

/**
 足部气囊动作指示
 */
@property (nonatomic, assign) NSInteger footAirBagFlag;

/**
 小腿气囊动作指示
 */
@property (nonatomic, assign) NSInteger calfAirBagFlag;

/**
 大腿气囊动作指示
 */
@property (nonatomic, assign) NSInteger thighAirBagFlag;

/**
 坐垫气囊动作指示
 */
@property (nonatomic, assign) NSInteger cushionAirBagFlag;

/**
 手臂气囊动作指示
 */
@property (nonatomic, assign) NSInteger armAirBagFlag;

/**
 滚轮速度
 00：滚轮自动
 01：速度最慢
 02：速度中
 03：速度最快
 */
@property (nonatomic, assign) NSInteger rollerSpeedFlag;

#pragma mark - 地址7 气囊按摩部位和按摩椅工作状态

/**
 按摩椅工作状态
 0：待机状态
 1：收藏状态：按摩椅复位
 2：等待命令：按摩椅点亮主屏，等待用户操作
 3：正常运行模式：此时手控器需要显示时间，按摩手法，或按摩程序等信息
 4：数据存储 此项功能待定
 5：严重的故障模式，例如主板24V电源过低，按摩椅不具备工作条件，此时手控器只需要显示错误代码就可以
 6 - 15 保留
 */
@property (nonatomic, assign) NSInteger workingStatusFlag;

/**
 肩部气囊动作指示
 0：相关部位无气囊动作
 1：相关部位有至少一个气囊动作
 */
@property (nonatomic, assign) NSInteger shoulderAirBagFlag;

/**
 背腰气囊动作指示
 0：相关部位无气囊动作
 1：相关部位有至少一个气囊动作
 */
@property (nonatomic, assign) NSInteger waistAirBagFlag;

/**
 颈部气囊动作指示
 0：相关部位无气囊动作
 1：相关部位有至少一个气囊动作
 */
@property (nonatomic, assign) NSInteger neckAirBagFlag;

#pragma mark - 地址 8 背部揉捏头位置指示

/**
 机芯位置
 数值范围0-31 ，0为机芯在最低点，31为机芯最高点
 */
@property (nonatomic, assign) NSInteger movementPositionFlag;

#pragma mark - 地址 9 体型检测数据

/**
 体型检测位置
 0000：体型检测中间位置
 0111：体型检测最高位置
 1111：体型检测最低位置
 中间位置依比例计算
 */
@property (nonatomic, assign) NSInteger figureCheckPositionFlag;

/**
 体型检测结果指示
 01：体型检测成功
 00：体型检测失败
 */
@property (nonatomic, assign) NSInteger figureCheckResultFlag;

/**
 肩位调节指示
 1：可调节
 0：不可调节
 */
@property (nonatomic, assign) NSInteger shoulderAjustFlag;

/**
 体型检测指示
 1：执行体型检测程序
 0：按摩程序
 */
@property (nonatomic, assign) NSInteger figureCheckFlag;

#pragma mark - 地址10 靠背和小腿电动缸

/**
 靠背电动缸运行指示
 00：停止
 01：靠背上升
 02：靠背下降
 */
@property (nonatomic, assign) NSInteger backrestActuatorMotionFlag;

/**
 小腿电动缸运行指示
 00：停止
 01：小腿上升
 02：小腿下降
 */
@property (nonatomic, assign) NSInteger calfActuatorMotionFlag;

/**
 零重力或前滑电动缸运行指示
 00：停止
 01：前滑电动缸向前或零重力电动缸向下
 02：前滑电动缸向后或零重力电动缸向上
 */
@property (nonatomic, assign) NSInteger forwardSlipOrZeroGravityActuatorMotionFlag;

/**
 零重力指示
 1：到达默认最佳位置
 0：不在默认最佳位置
 */
@property (nonatomic, assign) NSInteger zeroGravityFlag;

#pragma mark - 地址11 音乐指示

/**
 运行模式
 0家庭
 1商用
 */
@property (nonatomic, assign) NSInteger runningModeFlag;

/**
 音量
 0-7
 */
@property (nonatomic, assign) NSInteger volumeFlag;

/**
 音乐开关
 0 关
 1 开
 */
@property (nonatomic, assign) NSInteger musicSwitchFlag;

/**
 蜂鸣器模式
 蜂鸣器模式：0:不发声，1:短间隔发声，2:长间隔发声，3: 发单声
 */
@property (nonatomic, assign) NSInteger buzzerModeFlag;

#pragma mark - 地址12 时间和气囊

/**
 程序预设时间
 00：无
 01：10分钟
 02：20分钟
 03：30分钟
 */
@property (nonatomic, assign) NSInteger preprogrammedTimeFlag;

/**
 腿脚气囊程序
 当选择全身气囊程序时，后面的部位气囊程序无效恒为0，当选择部位气囊程序时依据按摩椅主控制器的命令可以单选也可以多选。
 */
@property (nonatomic, assign) NSInteger legAndFootAirBagProgramFlag;

/**
 背腰气囊程序
 当选择全身气囊程序时，后面的部位气囊程序无效恒为0，当选择部位气囊程序时依据按摩椅主控制器的命令可以单选也可以多选。
 */
@property (nonatomic, assign) NSInteger backAndWaistAirBagProgramFlag;

/**
 臂肩气囊程序
 当选择全身气囊程序时，后面的部位气囊程序无效恒为0，当选择部位气囊程序时依据按摩椅主控制器的命令可以单选也可以多选。
 */
@property (nonatomic, assign) NSInteger armAndShoulderAirBagProgramFlag;

/**
 坐垫气囊程序
 当选择全身气囊程序时，后面的部位气囊程序无效恒为0，当选择部位气囊程序时依据按摩椅主控制器的命令可以单选也可以多选。
 */
@property (nonatomic, assign) NSInteger buttockAirBagProgramFlag;

/**
 全身气囊程序
 当选择全身气囊程序时，后面的部位气囊程序无效恒为0，当选择部位气囊程序时依据按摩椅主控制器的命令可以单选也可以多选。
 */
@property (nonatomic, assign) NSInteger FullBodyAirBagProgramFlag;

#pragma mark - 地址13 滚轮方向和自动按摩程序

/**
 bit 0, bit 1 : 滚轮方向
 00：停止
 01：顺时针
 02：逆时针
 03：正反转
 */
@property (nonatomic, assign) NSInteger rollerDirectionFlag;

/**
 bit 2, bit 3, bit 4, bit 5 : 按摩程序
 00：无
 01：疲劳恢复
 02：舒适按摩
 03：轻松按摩
 04：酸痛改善
 05：颈肩自动（上半身）
 06：背腰自动（下半身）
 07：手动
 08：网络程序 1 
 09：网络程序 2
 0A：网络程序3
 0B：网络程序4
 0C：3D按摩
 */
@property (nonatomic, assign) NSInteger massageProgramFlag;

#pragma mark - 地址14 3D机芯状态（非3D机型无此字节）

/**
 3D力度
 00：3D力度0
 01：3D力度1
 02：3D力度2
 03：3D力度3
 04：3D力度4
 05：3D力度5
 06：保留
 07：保留
 */
@property (nonatomic, assign) NSInteger _3dStrengthFlag;

/**
 3D手法
 00：停
 01：3D1
 02：3D2
 03：3D3
 04：3D4
 05：3D5
 06：3D6
 07：3D7
 */
@property (nonatomic, assign) NSInteger _3dSkillFlag;

#pragma mark - 输出按摩椅状态
-(void)printStatus;
@end
