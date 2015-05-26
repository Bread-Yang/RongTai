//
//  RTBleConnector.m
//  BLETool
//
//  Created by Jaben on 15/5/6.
//  Copyright (c) 2015年 Jaben. All rights reserved.
//

#import "RTBleConnector.h"
#import "RTCommand.h"

static Byte const BYTE_iOS_Mark = 0x84;
static Byte const BYTE_Head = 0xf0;
static Byte const BYTE_Tail = 0xf1;

//FFF1  == read write
#define kCharacterRW(periphralName) [NSString stringWithFormat:@"RW_%@",periphralName]

// 0734594A-A8E7-4B1A-A6B1-CD5243059A57 ==  notify
#define kCharacterN(periphralName) [NSString stringWithFormat:@"N_%@",periphralName]

// 8B00ACE7-EB0B-49B0-BBE9-9AEE0A26E1A3 == write with no response
#define kCharacterW(periphralName) [NSString stringWithFormat:@"W_%@",periphralName]

// E06D5EFB-4F4A-45C0-9EB1-371AE5A14AD4 == Read notify
#define kCharacterRN(periphralName) [NSString stringWithFormat:@"RN_%@",periphralName]

@interface RTBleConnector ()<JRBluetoothManagerDelegate>

@property (nonatomic, strong) NSMutableDictionary *characteristicDicionary;

@end

@implementation RTBleConnector


+ (instancetype)shareManager {
    static RTBleConnector *shareManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareManager =[[RTBleConnector alloc] init];
    });
    return shareManager;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        
        [JRBluetoothManager shareManager].delegate = self;
        
        _rtMassageChairStatus = [[RTMassageChairStatus alloc] init];
        
        _characteristicDicionary = [[NSMutableDictionary alloc] init];
        
    }
    return self;
}

#pragma mark - JRBluetoothManagerDelegate

- (void)didUpdateState:(CBCentralManagerState)state {
    if (self.delegate && [self.delegate respondsToSelector:@selector(didUpdateRTBleState:)]) {
        [self.delegate didUpdateRTBleState:state];
    }
}

- (void)didFoundPeripheral:(CBPeripheral *)peripheral advertisement:(NSDictionary *)advertisement rssi:(NSNumber *)rssi {
    if (self.delegate && [self.delegate respondsToSelector:@selector(didFoundRTBlePeriperalInfo:)]) {
        NSDictionary *peripheralInfo = @{
                                         RTBle_Periperal:peripheral,
                                         RTBle_BroadcastData:advertisement,
                                         RTBle_RSSI:rssi,
                                         };
        [self.delegate didFoundRTBlePeriperalInfo:peripheralInfo];
    }
}

- (void)didConnectPeriphral:(CBPeripheral *)periphral {
    if (self.delegate && [self.delegate respondsToSelector:@selector(didConnectRTBlePeripheral:)]) {
        [self.delegate didConnectRTBlePeripheral:periphral];
    }
}

- (void)didFailToConnectPeriphral:(CBPeripheral *)periphral {
    if (self.delegate && [self.delegate respondsToSelector:@selector(didFailToConnectRTBlePeripheral:)]) {
        [self.delegate didFailToConnectRTBlePeripheral:periphral];
    }
}

- (void)didDisconnectPeriphral:(CBPeripheral *)periphral {
    if (self.delegate && [self.delegate respondsToSelector:@selector(didDisconnectRTBlePeripheral:)]) {
        [self.delegate didDisconnectRTBlePeripheral:periphral];
    }
}

- (void)didDiscoverCharacteristicOfService:(CBService *)service fromPeriperal:(CBPeripheral *)periphral {
    
    NSLog(@"servie: %@", [service.UUID UUIDString]);
    if ([[service.UUID UUIDString] isEqualToString:RTServiceUUID]) {
        for(CBCharacteristic *characteristic in service.characteristics) {
            NSString *characteristicID = [characteristic.UUID UUIDString];
            NSLog(@"============ characteristic UUID %@ ============",characteristicID);
            if ([characteristicID isEqualToString:RT_N_ChracteristicUUID]) {
                
                [periphral setNotifyValue:YES forCharacteristic:characteristic];
                [self.characteristicDicionary setObject:characteristic forKey:kCharacterN(periphral.name)];
                
            }else if([characteristicID isEqualToString:RT_RN_ChracteristicUUID]) {
                
                [periphral setNotifyValue:YES forCharacteristic:characteristic];
                [self.characteristicDicionary setObject:characteristic forKey:kCharacterRN(periphral.name)];
                
            }else if([characteristicID isEqualToString:RT_RW_ChracteristicUUID]) {
                
                [self.characteristicDicionary setObject:characteristic forKey:kCharacterRW(periphral.name)];
                
            }else if([characteristicID isEqualToString:RT_W_ChracteristicUUID]) {
                
                [self.characteristicDicionary setObject:characteristic forKey:kCharacterW(periphral.name)];
            }
        }
    }
    
}

- (void)didUpdateValue:(NSData *)data fromPeripheral:(CBPeripheral *)peripheral characteritic:(CBCharacteristic *)characteristic {
    
    if ([[characteristic.UUID UUIDString] isEqualToString:RT_N_ChracteristicUUID]) {
        if (data.length < 17) {
            return;
        }
        
        [self parseData:data];
        
    }
}

- (void)didWriteValueForCharacteristic:(CBCharacteristic *)characteristic inPeripheral:(CBPeripheral *)peripheral {
    
}

#pragma mark - Command

- (void)controlMode:(NSInteger)mode {
    //	NSInteger commnad[] = {NORMAL_CTRL,ENGGER_CTRL,H10_KEY_CHAIR_AUTO_0};
    
    NSData *bodyData = [self dataWithFuc:mode];
    NSData *sendData = [self fillDataHeadAndTail:bodyData];
    [self sendDataToPeripheral:sendData];
}

#pragma mark - Write

- (NSData *)dataWithFuc:(NSInteger)fuctionCommand {
    
    // fucByte = 1 byte ---> 功能键
    /*
     7位校验和（Checksum）将地址1和地址2的数据相加后取反码，再与0x7F相与变为7位数据
     */
    NSInteger sumData = fuctionCommand + (NSInteger)BYTE_iOS_Mark;
    NSInteger contraryData =  ~sumData;
    NSInteger checkSum = contraryData & 0x7f;
    
    Byte commandBody[] = {BYTE_iOS_Mark, fuctionCommand, checkSum};
    
    NSData *bodayData = [NSData dataWithBytes:&commandBody length:3];
    
    /*
     bodayData = 3byte ---> 控制设备标识 功能键 校验
     */
    return bodayData;
}

- (NSData *)fillDataHeadAndTail:(NSData *)data {
    
    /*
     5 bytes:
     1: 协议头，2:控制设备标识 3:功能键 4:校验 5:尾部
     */
    NSMutableData *sendData = [NSMutableData dataWithBytes:&BYTE_Head length:1];
    [sendData appendData:data];
    [sendData appendBytes:&BYTE_Tail length:1];
    return sendData;
}

- (void)sendDataToPeripheral:(NSData *)data {
    
    CBCharacteristic *writeCharacteritic = self.characteristicDicionary[kCharacterW(RTLocalName)];
    
    [[JRBluetoothManager shareManager] writeData:data toPeriperalWithName:RTLocalName characteritic:writeCharacteritic type:CBCharacteristicWriteWithoutResponse];
    
}

#pragma mark - Public
#pragma mark - BLE


- (void)startScanRTPeripheral:(NSArray *)serviceUUIDs {
    [[JRBluetoothManager shareManager] startScanPeripherals:serviceUUIDs];
}

- (void)stopScanRTPeripheral {
    [[JRBluetoothManager shareManager] stopScanPeripherals];
}

- (void)connectRTPeripheral:(CBPeripheral *)peripheral {
    [[JRBluetoothManager shareManager] connectPeripheral:peripheral];
}

- (void)cancelConnectRTPeripheral:(CBPeripheral *)peripheral {
    [[JRBluetoothManager shareManager] cancelConnectPeriphral:peripheral];
}


#pragma mark - Misc

#pragma mark - Read

- (void)parseData:(NSData *)rawData {
    /*
     rawData = head(0),body(1-14),checkSum(15),tail(16)
     total:17bytes
     */
    
    Byte *bodyData = (Byte *)[[rawData subdataWithRange:NSMakeRange(1, 14)] bytes]; // 14 bytes
    
    NSLog(@"rawData : %@", rawData);
    
    [self parseByteOfAddress1:bodyData[0]];
    [self parseByteOfAddress2:bodyData[1]];
    
    NSLog(@"重载description : %@", [_rtMassageChairStatus description]);
    
    NSDictionary *package;
    
    
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"name" object:package];
}

// 地址14 3D机芯状态（非3D机型无此字节）

- (void)parseByteOfAddress14:(Byte)addr {
    /**
     bit 0, bit 1, bit 2 : 3D力度
     00：3D力度0
     01：3D力度1
     02：3D力度2
     03：3D力度3
     04：3D力度4
     05：3D力度5
     06：保留
     07：保留
     */
    _rtMassageChairStatus._3dStrength = addr & 7;
    
    /**
     bit 3, bit 4, bit 5 : 3D手法
     00：停
     01：3D1
     02：3D2
     03：3D3
     04：3D4
     05：3D5
     06：3D6
     07：3D7
     */
    _rtMassageChairStatus._3dSkill = (addr >> 3) & 7;
    
    
}

// 地址13 滚轮方向和自动按摩程序

- (void)parseByteOfAddress13:(Byte)addr {
    /**
     bit 0, bit 1 : 滚轮方向
     00：停止
     01：顺时针
     02：逆时针
     03：正反转
     */
    _rtMassageChairStatus.rollerDirection = addr & 1;
    
    /**
     bit 2, bit 3, bit 4, bit 5 : 自动按摩程序
     00：无
     01：疲劳恢复
     02：舒适按摩
     03：轻松按摩
     04：酸痛改善
     05：颈肩自动（上半身）
     06：背腰自动（下半身）
     07：手动
     08：睡眠1
     09：睡眠2
     0A：全身气压
     0B：3D 按摩
     */
    _rtMassageChairStatus.autoMassageProgram = (addr >> 2) & 15;
}

// 地址12 时间和气囊

- (void)parseByteOfAddress12:(Byte)addr {
    /**
     bit 0, bit 1 : 程序预设时间
     00：无
     01：10分钟
     02：20分钟
     03：30分钟
     */
    _rtMassageChairStatus.preprogrammedTime = addr & 3;
    
    /**
     bit 2 : 腿脚气囊程序
     当选择全身气囊程序时，后面的部位气囊程序无效恒为0，当选择部位气囊程序时依据按摩椅主控制器的命令可以单选也可以多选。
     */
    _rtMassageChairStatus.feetAirBagProgram = (addr >> 2) & 1;
    
    /**
     bit 3 : 背腰气囊程序
     当选择全身气囊程序时，后面的部位气囊程序无效恒为0，当选择部位气囊程序时依据按摩椅主控制器的命令可以单选也可以多选。
     */
    _rtMassageChairStatus.waistAirBagProgram = (addr >> 3) & 1;
    
    /**
     bit 4 : 臂肩气囊程序
     当选择全身气囊程序时，后面的部位气囊程序无效恒为0，当选择部位气囊程序时依据按摩椅主控制器的命令可以单选也可以多选。
     */
    _rtMassageChairStatus.shoulderAirBagProgram = (addr >> 4) & 1;
    
    /**
     bit 5 : 坐垫气囊程序
     当选择全身气囊程序时，后面的部位气囊程序无效恒为0，当选择部位气囊程序时依据按摩椅主控制器的命令可以单选也可以多选。
     */
    _rtMassageChairStatus.cushionAirBagProgram = (addr >> 5) & 1;
    
    /**
     bit 6 : 全身气囊程序
     当选择全身气囊程序时，后面的部位气囊程序无效恒为0，当选择部位气囊程序时依据按摩椅主控制器的命令可以单选也可以多选。
     */
    _rtMassageChairStatus.bodyAirBagProgram = (addr >> 6) & 1;
}

// 地址11 音乐指示

- (void)parseByteOfAddress11:(Byte)addr {
    /**
     bit 0 : 运行模式
     0家庭
     1商用
     */
    _rtMassageChairStatus.runningMode = addr & 1;
    
    /**
     bit 1, bit 2, bit 3 : 音量
     0-7
     */
    _rtMassageChairStatus.volume = (addr >> 1) & 7;
    
    /**
     bit 4 : 音乐开关
     0 关
     1 开
     */
    _rtMassageChairStatus.musicSwitchFlag = (addr > 4) & 1;
    
    /**
     bit 5, bit 6 : 蜂鸣器模式
     蜂鸣器模式：0:不发声，1:短间隔发声，2:长间隔发声，3: 发单声
     */
    _rtMassageChairStatus.buzzerMode = (addr > 5) & 3;
}

// 地址10 靠背和小腿电动缸

- (void)parseByteOfAddress10:(Byte)addr {
    /**
     bit 0, bit 1 : 靠背电动缸运行指示
     00：停止
     01：靠背上升
     02：靠背下降
     */
    _rtMassageChairStatus.backrestActuatorMotionFlag = addr & 7;
    
    /**
     bit 2, bit 3 : 小腿电动缸运行指示
     00：停止
     01：小腿上升
     02：小腿下降
     */
    _rtMassageChairStatus.calfActuatorMotionFlag = (addr >> 2) & 3;
    
    /**
     bit 4, bit 5 : 零重力或前滑电动缸运行指示
     00：停止
     01：前滑电动缸向前或零重力电动缸向下
     02：前滑电动缸向后或零重力电动缸向上
     */
    _rtMassageChairStatus.forwardSlipOrZeroGravityActuatorMotionFlag = (addr >> 4) & 3;
    
    /**
     bit 6 : 零重力指示
     1：到达默认最佳位置
     0：不在默认最佳位置
     */
    _rtMassageChairStatus.zeroGravityFlag = (addr >> 5) & 1;
}

// 地址9 体型检测数据

- (void)parseByteOfAddress9:(Byte)addr {
    /**
     bit 0, bit 1, bit 2, bit 3 : 体型检测位置
     0000：体型检测中间位置
     0111：体型检测最高位置
     1111：体型检测最低位置
     中间位置依比例计算
     */
    _rtMassageChairStatus.figureCheckPosition = addr & 15;
    
    /**
     bit 4 : 体型检测结果指示
     01：体型检测成功
     00：体型检测失败
     */
    _rtMassageChairStatus.figureCheckResult = (addr >> 4) & 1;
    
    /**
     bit 5 : 肩位调节指示
     1：可调节
     0：不可调节
     */
    _rtMassageChairStatus.shoulderAjustFlag = (addr >> 5) & 1;
    
    /**
     bit 6 : 体型检测指示
     1：执行体型检测程序
     0：按摩程序
     */
    _rtMassageChairStatus.figureCheckFlag = (addr >> 6) & 1;
}

// 地址8 背部揉捏头位置指示

- (void)parseByteOfAddress8:(Byte)addr {
    /**
     bit 0, bit 1, bit 2, bit 3, bit 4 : 机芯位置
     数值范围0-31 ，0为机芯在最低点，31为机芯最高点
     */
    _rtMassageChairStatus.movementPosition = addr & 31;
}

// 地址7 气囊按摩部位和按摩椅工作状态

- (void)parseByteOfAddress7:(Byte)addr {
    /**
     bit 0, bit 1, bit 2, bit 3 : 按摩椅工作状态
     0：待机状态
     1：收藏状态：按摩椅复位
     2：等待命令：按摩椅点亮主屏，等待用户操作
     3：正常运行模式：此时手控器需要显示时间，按摩手法，或按摩程序等信息
     4：数据存储 此项功能待定
     5：严重的故障模式，例如主板24V电源过低，按摩椅不具备工作条件，此时手控器只需要显示错误代码就可以
     6-15 保留
     */
    _rtMassageChairStatus.workingStatus = addr & 15;
    
    /**
     bit 4 : 肩部气囊动作指示
     0：相关部位无气囊动作
     1：相关部位有至少一个气囊动作
     */
    _rtMassageChairStatus.shoulderAirBagFlag = (addr >> 4) & 1;
    
    /**
     bit 5 : 背腰气囊动作指示
     0：相关部位无气囊动作
     1：相关部位有至少一个气囊动作
     */
    _rtMassageChairStatus.waistAirBagFlag = (addr >> 5) & 1;
    
    /**
     bit 6 : 颈部气囊动作指示
     0：相关部位无气囊动作
     1：相关部位有至少一个气囊动作
     */
    _rtMassageChairStatus.neckAirBagFlag = (addr >> 6) & 1;
}

// 地址 6气囊或气阀运行状态指示, 滚轮状态指示

- (void)parseByteOfAddress6:(Byte)addr {
    /**
     bit 0 : 足部气囊动作指示
     */
    _rtMassageChairStatus.footAirBagFlag = addr & 1;
    
    /**
     bit 1 : 小腿气囊动作指示
     */
    _rtMassageChairStatus.calfAirBagFlag = (addr >> 1) & 1;
    
    /**
     bit 2 : 大腿气囊动作指示
     */
    _rtMassageChairStatus.calfAirBagFlag = (addr >> 2) & 1;
    
    /**
     bit 3 : 坐垫气囊动作指示
     */
    _rtMassageChairStatus.calfAirBagFlag = (addr >> 3) & 1;
    
    /**
     bit 4 : 手臂气囊动作指示
     */
    _rtMassageChairStatus.armAirBagFlag = (addr >> 4) & 1;
    
    /**
     bit 5, bit 6 : 滚轮速度
     00：滚轮自动
     01：速度最慢
     02：速度中
     03：速度最快
     */
    _rtMassageChairStatus.rollerSpeed = (addr >> 5) & 3;
}

// 地址 5运行时间低7位，单位秒，在故障模式为错误代码指示

- (void)parseByteOfAddress5:(Byte)addr {
    /**
     按摩椅剩余运行秒数低7位，在故障模式为错误代码指示
     : bit 0, bit 1, bit 2, bit 3, bit 4, bit 5, bit 6
     数值范围0-127
     */
    _rtMassageChairStatus.remainingTimeLow7Bit = (addr & 127);
}

// 地址 4 运行时间高5位，单位秒

- (void)parseByteOfAddress4:(Byte)addr {
    /**
     按摩椅剩余运行秒数高5位 : bit 0, bit 1, bit 2, bit 3, bit 4
     数值范围0-31
     */
    _rtMassageChairStatus.remainingTimeHigh5Bit = (addr & 31);
    
    /**
     机芯按摩部位 : bit 5, bit 6
     00：不显示
     01：全局
     02：局部
     03：定点
     */
    _rtMassageChairStatus.movementMassagePosition = (addr >> 5) & 3;
}

// 地址 3 气压强度和振动（或扭腰）强度

- (void)parseByteOfAddress3:(Byte)addr {
    /**
     气压强度 : bit 0,bit 1, bit 2
     5档强度：00：停止，01最弱，05最强，06和07：保留
     3档强度：00：停止，01最弱，03最强，04-07：保留
     */
    _rtMassageChairStatus.airPressure = (addr & 7);
    
    /**
     3D力度指示 : bit 3, bit 4, bit 5
     */
    _rtMassageChairStatus._3dStrengthFlag = (addr >> 3) & 7;
    
    /**
     负离子开关 : bit 6
     0：负离子关
     1：负离子开
     */
    _rtMassageChairStatus.anionSwitchFlag = (addr >> 6) & 7;
}

//地址 2 按摩机芯速度和揉捏头宽度位置指示 机芯速度是指当前设定的目标速度，揉捏头宽度指按摩头当前位置

- (void)parseByteOfAddress2:(Byte)addr {
    /**
     揉捏头宽度位置
     00：未知（上电后，揉捏电机还未加电，并且此时揉捏头不处于宽、中、窄三个点）
     01：揉捏头最窄
     02：揉捏头中间
     03：揉捏头最宽
     */
    _rtMassageChairStatus.kneadWidth = (addr & 3);
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
    _rtMassageChairStatus.movementSpeed = (addr >> 2) & 7;
    /**
     滚轮
     0：滚轮关，当滚轮关闭时速度必然为零
     1：滚轮开
     手动模式滚轮开，速度可进行三档调节，在自动模式滚轮速度受自动程序控制
     */
    _rtMassageChairStatus.rollerSwitchFlag = (addr >> 5) & 1;
    /**
     加热
     0：关
     1：开
     */
    _rtMassageChairStatus.heatingSwitchFlag = (addr >> 6) & 1;
}

// 地址 1 按摩椅程序运行状态和按摩手法

- (void)parseByteOfAddress1:(Byte)addr {
    /**
     3D标示
     0：机器无3D功能
     1:机器具备3D功能
     */
    _rtMassageChairStatus._3dFlag = addr & 1;
    
    /**
     小腿伸缩标示
     0：机器具备小腿伸缩功能
     1:机器无小腿伸缩，此时APP程序中的腿部伸缩按钮变灰
     */
    _rtMassageChairStatus.calfStretchFlag = (addr >> 1) & 1;
    
    /**
     新程序名称标示
     0：旧程序名称
     1:新程序名称
     */
    _rtMassageChairStatus.nameFlag = (addr >> 2) & 1;
    
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
    _rtMassageChairStatus.massageTechnique = (addr >> 3) & 7;
    
    /**
     按摩椅运行状态
     0：按摩椅处于待机,主电源关闭，省电模式
     1：按摩椅处于非待机状态，此时手控器相应的图标点亮
     */
    _rtMassageChairStatus.runningStatus = (addr >> 6) & 1;
}
@end
