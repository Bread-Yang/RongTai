//
//  RTBleConnector.m
//  BLETool
//
//  Created by Jaben on 15/5/6.
//  Copyright (c) 2015年 Jaben. All rights reserved.
//

#import "RTBleConnector.h"
#import "RTCommand.h"
#import "CustomIOSAlertView.h"

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

@property (readonly) NSTimeInterval reconnectInterval;

@property (nonatomic, retain) NSTimer *turnOnTimer;

@end

@implementation RTBleConnector


+ (instancetype)shareManager {
	NSLog(@"%@", @"shareManager()");
    static RTBleConnector *shareManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareManager =[[RTBleConnector alloc] init];
    });
    return shareManager;
}

+ (BOOL)isBleTurnOn {
	return isBleTurnOn;
}

- (instancetype)init {
	NSLog(@"%@", @"init()");
	
    self = [super init];
	
    if (self) {
        
        [JRBluetoothManager shareManager].delegate = self;
        
        _rtMassageChairStatus = [[RTMassageChairStatus alloc] init];
		
		_rtNetworkProgramStatus = [[RTNetworkProgramStatus alloc] init];
        
        _characteristicDicionary = [[NSMutableDictionary alloc] init];
		
		_reconnectInterval = 10;

    }
    return self;
}

- (void)handleReconnect {
	NSLog(@"handleReconnect()");
	[[JRBluetoothManager shareManager] connectPeripheral:self.currentConnectedPeripheral];
}

#pragma mark - JRBluetoothManagerDelegate

- (void)didUpdateState:(CBCentralManagerState)state {
	NSLog(@"%@", @"didUpdateState()");
	
	NSString *message;
	
	switch (state) {
		case CBCentralManagerStateResetting:
			message = @"初始化中，请稍后……";
			break;
		case CBCentralManagerStateUnsupported:
			message = @"设备不支持状态，过会请重试……";
			break;
		case CBCentralManagerStateUnauthorized:
			message = @"设备未授权状态，过会请重试……";
			break;
		case CBCentralManagerStatePoweredOff:
			message = @"尚未打开蓝牙，请在设置中打开……";
			isBleTurnOn = NO;
			break;
		case CBCentralManagerStatePoweredOn:
			message = @"蓝牙已经成功开启，稍后……";
			isBleTurnOn = YES;
			break;
	}

	NSLog(@"%@", message);
	
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
	self.isConnectedDevice = YES;
	
	self.currentConnectedPeripheral = periphral;
	
    if (self.delegate && [self.delegate respondsToSelector:@selector(didConnectRTBlePeripheral:)]) {
        [self.delegate didConnectRTBlePeripheral:periphral];
    }
	
	if (_reconnectTimer && [_reconnectTimer isValid]) {
		[_reconnectTimer invalidate];
	}
}

- (void)didFailToConnectPeriphral:(CBPeripheral *)periphral {
    if (self.delegate && [self.delegate respondsToSelector:@selector(didFailToConnectRTBlePeripheral:)]) {
        [self.delegate didFailToConnectRTBlePeripheral:periphral];
    }
}

- (void)didDisconnectPeriphral:(CBPeripheral *)periphral {
	NSLog(@"didDisconnectPeriphral()");
	
	self.isConnectedDevice = NO;
	
    if (self.delegate && [self.delegate respondsToSelector:@selector(didDisconnectRTBlePeripheral:)]) {
        [self.delegate didDisconnectRTBlePeripheral:periphral];
    }
	
	if (self.currentConnectedPeripheral) {
		//	_reconnectTimer = [NSTimer timerWithTimeInterval:_reconnectInterval target:self selector:@selector(handleReconnect) userInfo:nil repeats:YES];
		
		if (_reconnectTimer && [_reconnectTimer isValid]) {
			[_reconnectTimer invalidate];
		}
		_reconnectTimer = [NSTimer scheduledTimerWithTimeInterval:_reconnectInterval target:self selector:@selector(handleReconnect) userInfo:nil repeats:YES];
		[_reconnectTimer fire];
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
	
	NSLog(@"data.length : %zd", data.length);
	NSLog(@"data : %@", data);
	
    if ([[characteristic.UUID UUIDString] isEqualToString:RT_N_ChracteristicUUID]) {
		
		if (data.length == 17) {	// 等于17位 : 按摩模式下返回的状态
			[self parseData:data];
			
			if (self.delegate && [self.delegate respondsToSelector:@selector(didUpdateMassageChairStatus:)]) {
				[self.delegate didUpdateMassageChairStatus:self.rtMassageChairStatus];
			}
			
		} else if (data.length == 11) {	// 等于11位 : 返回按摩椅网络程序状态
			
			NSData *networkStatusData = [data subdataWithRange:NSMakeRange(2, 8)];
			
			NSLog(@"[rawData subdataWithRange:NSMakeRange(2, 8)] : %@", networkStatusData);
			
			Byte *networkStatusByte = (Byte *)[networkStatusData bytes];
			
			NSInteger massageId_1 = networkStatusByte[0] * 16 + networkStatusByte[1];
			NSInteger massageId_2 = networkStatusByte[2] * 16 + networkStatusByte[3];
			NSInteger massageId_3 = networkStatusByte[4] * 16 + networkStatusByte[5];
			NSInteger massageId_4 = networkStatusByte[6] * 16 + networkStatusByte[7];
			
			self.rtNetworkProgramStatus.networkProgramStatusArray = @{massageId_1, massageId_2, massageId_3, massageId_4};
			
			if (self.delegate && [self.delegate respondsToSelector:@selector(didUpdateNetworkMassageStatus:)]) {
				
				[self.delegate didUpdateNetworkMassageStatus:self.rtNetworkProgramStatus];
			}
			
		} else {  // 不等于11位或者17位 : 编辑模式
			
			if (self.delegate && [self.delegate respondsToSelector:@selector(didUpdateStatusInProgramMode:)]) {
				[self.delegate didUpdateStatusInProgramMode:data];
			}
			
		}
    }
}

- (void)didWriteValueForCharacteristic:(CBCharacteristic *)characteristic inPeripheral:(CBPeripheral *)peripheral {
    
}

#pragma mark - Send Command

- (void)sendControlMode:(NSInteger)mode {
    //	NSInteger commnad[] = {NORMAL_CTRL,ENGGER_CTRL,H10_KEY_CHAIR_AUTO_0};
	
	if (self.isConnectedDevice) {
		
		if (self.rtMassageChairStatus.deviceStatus == RtMassageChairStatusResetting) { // 复位状态下不发送指令
			return;
		}
		
		if (self.rtMassageChairStatus.deviceStatus == RtMassageChairStatusStandby) { // 先发开机指令,过一秒再发模式指令
			if  (_turnOnTimer && [_turnOnTimer isValid]) {
				[_turnOnTimer invalidate];
			}
			// 先开机
			NSData *bodyData = [self dataWithFuc:H10_KEY_POWER_SWITCH];
			NSData *sendData = [self fillDataHeadAndTail:bodyData];
			[self sendDataToPeripheral:sendData];
			
			_turnOnTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(delaySendCommand:) userInfo:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:mode], @"mode", nil] repeats:NO];
		} else {
			NSData *bodyData = [self dataWithFuc:mode];
			NSData *sendData = [self fillDataHeadAndTail:bodyData];
			[self sendDataToPeripheral:sendData];
		}
	}
//	else {
//		[self didDisconnectPeriphral:self.currentConnectedPeripheral];
//	}
}

- (void)sendControlByBytes:(NSData *)data {
	if (self.isConnectedDevice) {
		
		if (self.rtMassageChairStatus.deviceStatus == RtMassageChairStatusResetting) { // 复位状态下不发送指令
			return;
		}
		
		NSLog(@"发送的data : %@", data);
		
		[self sendDataToPeripheral:data];
	}
}

- (void)delaySendCommand:(NSTimer *)timer {
	NSInteger mode = [[[timer userInfo] objectForKey:@"mode"] integerValue];
	NSData *bodyData = [self dataWithFuc:mode];
	NSData *sendData = [self fillDataHeadAndTail:bodyData];
	[self sendDataToPeripheral:sendData];
}

#pragma mark - get program mode command

- (NSData *)controlInstallMassage:(NSInteger)massageId {
	if (0 < massageId && massageId < 5) {
		Byte byte[] = {0xf0, 0xa5, 0x10, 1, massageId, massageId, 0x4a, 0xf1};
		//    byte[4] =(massageId&0xff00)>>8;
		//    byte[5] =massageId&0xff;
		NSInteger sumData = byte[1] + byte[2] + byte[3] + byte[4] + byte[5];
		NSInteger contraryData =  ~sumData;
		NSInteger checkSum = contraryData & 0x7f;
		byte[6] = checkSum;
		NSData *bodayData = [NSData dataWithBytes:&byte length:8];
		return bodayData;
	} else {
		return nil;
	}
}

- (NSData *)deleteMassage:(NSInteger)massageId{
	if (0 < massageId && massageId < 5) {
		Byte byte[] = {0xf0, 0xa5, 0x10, 2, massageId, massageId, 0x4a, 0xf1};
		NSInteger sumData = byte[1] + byte[2] + byte[3] + byte[4] + byte[5];
		NSInteger contraryData =  ~sumData;
		NSInteger checkSum = contraryData & 0x7f;
		byte[6] = checkSum;
		NSData *bodayData = [NSData dataWithBytes:&byte length:8];
		return bodayData;
	} else {
		return nil;
	}
}

- (NSData *)exitEditMode {
	Byte byte[] = {0xf0, 0xa5, 0x11, 0, 0, 0, 0x4a, 0xf1};
	NSInteger sumData = byte[1] + byte[2] + byte[3] + byte[4] + byte[5];
	NSInteger contraryData =  ~sumData;
	NSInteger checkSum = contraryData & 0x7f;
	byte[6] = checkSum;
	NSData *bodayData = [NSData dataWithBytes:&byte length:8];
	return bodayData;
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

- (void)cancelCurrentConnectedRTPeripheral {
	NSLog(@"cancelCurrentConnectedRTPeripheral:");
	if (self.currentConnectedPeripheral) {
		CBPeripheral *temp = self.currentConnectedPeripheral;
		
		self.currentConnectedPeripheral = nil;
		
		[[JRBluetoothManager shareManager] cancelConnectPeriphral:temp];
	}
}


#pragma mark - Misc

#pragma mark - Read

- (void)parseData:(NSData *)rawData {
    /*
     rawData = head(0),body(1-14),checkSum(15),tail(16)
     total:17bytes
     */
    
    Byte *bodyData = (Byte *)[[rawData subdataWithRange:NSMakeRange(1, 14)] bytes]; // 14 bytes
    
//    NSLog(@"rawData : %@", rawData);
//	
//	NSLog(@"rawData[6] : %hhu", bodyData[6]);
	
    [self parseByteOfAddress1:bodyData[0]];
    [self parseByteOfAddress2:bodyData[1]];
	[self parseByteOfAddress3:bodyData[2]];
	[self parseByteOfAddress4:bodyData[3]];
	[self parseByteOfAddress5:bodyData[4]];
	[self parseByteOfAddress6:bodyData[5]];
	[self parseByteOfAddress7:bodyData[6]];
	[self parseByteOfAddress8:bodyData[7]];
	[self parseByteOfAddress9:bodyData[8]];
	[self parseByteOfAddress10:bodyData[9]];
	[self parseByteOfAddress11:bodyData[10]];
	[self parseByteOfAddress12:bodyData[11]];
	[self parseByteOfAddress13:bodyData[12]];
	[self parseByteOfAddress14:bodyData[13]];
    
//    NSDictionary *package;
//	
//    [[NSNotificationCenter defaultCenter] postNotificationName:@"name" object:package];
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
    _rtMassageChairStatus._3dStrengthFlag = addr & 7;
    
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
    _rtMassageChairStatus._3dSkillFlag = (addr >> 3) & 7;
    
    
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
    _rtMassageChairStatus.rollerDirectionFlag = addr & 1;
    
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
    _rtMassageChairStatus.massageProgramFlag = (addr >> 2) & 15;
	
	_rtMassageChairStatus.autoProgramType = RTMassageChairAirBagProgramNone;
	
	if (_rtMassageChairStatus.massageProgramFlag < 7) {
		_rtMassageChairStatus.programType = RtMassageChairProgramAuto;
		
		switch (_rtMassageChairStatus.massageProgramFlag) {
			case 1:
				_rtMassageChairStatus.autoProgramType = RtMassageChairProgramSportRecover;
    			break;
			case 2:
				_rtMassageChairStatus.autoProgramType = RtMassageChairProgramStretch;
				break;
			case 3:
				_rtMassageChairStatus.autoProgramType = RtMassageChairProgramRestAndPromoteSleep;
				break;
			case 4:
				_rtMassageChairStatus.autoProgramType = RtMassageChairProgramWorkDecompression;
				break;
			case 5:
				_rtMassageChairStatus.autoProgramType = RtMassageChairProgramShoulderAndNeck;
				break;
			case 6:
				_rtMassageChairStatus.autoProgramType = RtMassageChairProgramLumbarRelieve;
				break;
		}
		
	} else if (_rtMassageChairStatus.massageProgramFlag == 7) {
		_rtMassageChairStatus.programType = RtMassageChairProgramManual;
	} else {
		_rtMassageChairStatus.programType = RtMassageChairProgramNetwork;
	}
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
    _rtMassageChairStatus.preprogrammedTimeFlag = addr & 3;
	
	_rtMassageChairStatus.preprogrammedTime = _rtMassageChairStatus.preprogrammedTimeFlag * 10;
    
    /**
     bit 2 : 腿脚气囊程序
     当选择全身气囊程序时，后面的部位气囊程序无效恒为0，当选择部位气囊程序时依据按摩椅主控制器的命令可以单选也可以多选。
     */
    _rtMassageChairStatus.legAndFootAirBagProgramFlag = (addr >> 2) & 1;
    
    /**
     bit 3 : 背腰气囊程序
     当选择全身气囊程序时，后面的部位气囊程序无效恒为0，当选择部位气囊程序时依据按摩椅主控制器的命令可以单选也可以多选。
     */
    _rtMassageChairStatus.backAndWaistAirBagProgramFlag = (addr >> 3) & 1;
    
    /**
     bit 4 : 臂肩气囊程序
     当选择全身气囊程序时，后面的部位气囊程序无效恒为0，当选择部位气囊程序时依据按摩椅主控制器的命令可以单选也可以多选。
     */
    _rtMassageChairStatus.armAndShoulderAirBagProgramFlag = (addr >> 4) & 1;
    
    /**
     bit 5 : 坐垫气囊程序
     当选择全身气囊程序时，后面的部位气囊程序无效恒为0，当选择部位气囊程序时依据按摩椅主控制器的命令可以单选也可以多选。
     */
    _rtMassageChairStatus.buttockAirBagProgramFlag = (addr >> 5) & 1;
    
    /**
     bit 6 : 全身气囊程序
     当选择全身气囊程序时，后面的部位气囊程序无效恒为0，当选择部位气囊程序时依据按摩椅主控制器的命令可以单选也可以多选。
     */
    _rtMassageChairStatus.FullBodyAirBagProgramFlag = (addr >> 6) & 1;
	
	if (_rtMassageChairStatus.FullBodyAirBagProgramFlag == 1) {
		
		_rtMassageChairStatus.airBagProgram = RTMassageChairAirBagProgramFullBody;
		
	} else if (_rtMassageChairStatus.armAndShoulderAirBagProgramFlag == 1) {
		
		_rtMassageChairStatus.airBagProgram = RTMassageChairAirBagProgramArmAndShoulder;
		
	} else if (_rtMassageChairStatus.backAndWaistAirBagProgramFlag == 1) {
		
		_rtMassageChairStatus.airBagProgram = RTMassageChairAirBagProgramBackAndWaist;
		
	} else if (_rtMassageChairStatus.buttockAirBagProgramFlag == 1) {
		
		_rtMassageChairStatus.airBagProgram = RTMassageChairAirBagProgramButtock;
		
	} else if (_rtMassageChairStatus.legAndFootAirBagProgramFlag == 1) {
		
		_rtMassageChairStatus.airBagProgram = RTMassageChairAirBagProgramLegAndFeet;
		
	} else {
		
		_rtMassageChairStatus.airBagProgram = RTMassageChairAirBagProgramNone;
		
	}
}

// 地址11 音乐指示

- (void)parseByteOfAddress11:(Byte)addr {
    /**
     bit 0 : 运行模式
     0家庭
     1商用
     */
    _rtMassageChairStatus.runningModeFlag = addr & 1;
    
    /**
     bit 1, bit 2, bit 3 : 音量
     0-7
     */
    _rtMassageChairStatus.volumeFlag = (addr >> 1) & 7;
    
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
    _rtMassageChairStatus.buzzerModeFlag = (addr > 5) & 3;
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
	
	NSInteger i = addr;
	
//	NSLog(@"byte[9] : %zd", i);
	
    /**
     bit 0, bit 1, bit 2, bit 3 : 体型检测位置
     0000：体型检测中间位置
     0111：体型检测最高位置
     1111：体型检测最低位置
     中间位置依比例计算
     */
    _rtMassageChairStatus.figureCheckPositionFlag = addr & 15;
    
    /**
     bit 4 : 体型检测结果指示
     01：体型检测成功
     00：体型检测失败
     */
    _rtMassageChairStatus.figureCheckResultFlag = (addr >> 4) & 1;
    
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
    _rtMassageChairStatus.movementPositionFlag = addr & 31;
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
    _rtMassageChairStatus.workingStatusFlag = addr & 15;
    
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
	
	switch (_rtMassageChairStatus.workingStatusFlag) {
  		case 0:
			_rtMassageChairStatus.deviceStatus = RtMassageChairStatusStandby;
			break;
		case 1:
			_rtMassageChairStatus.deviceStatus = RtMassageChairStatusResetting;
			break;
		case 2:
			_rtMassageChairStatus.deviceStatus = RtMassageChairStatusWaiting;
			break;
		case 3:
			if (_rtMassageChairStatus.deviceStatus == RtMassageChairStatusStandby || _rtMassageChairStatus.deviceStatus == RtMassageChairStatusWaiting) {  // 开始计时
				
			}
			_rtMassageChairStatus.deviceStatus = RtMassageChairStatusMassaging;
			break;
	}
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
    _rtMassageChairStatus.rollerSpeedFlag = (addr >> 5) & 3;
}

// 地址 5运行时间低7位，单位秒，在故障模式为错误代码指示

- (void)parseByteOfAddress5:(Byte)addr {
    /**
     按摩椅剩余运行秒数低7位，在故障模式为错误代码指示
     : bit 0, bit 1, bit 2, bit 3, bit 4, bit 5, bit 6
     数值范围0-127
     */
    _rtMassageChairStatus.remainingTimeLow7Bit = (addr & 127);
	
	_rtMassageChairStatus.remainingTime = _rtMassageChairStatus.remainingTimeHigh5Bit * 128 + _rtMassageChairStatus.remainingTimeLow7Bit;
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
    _rtMassageChairStatus.movementMassagePositionFlag = (addr >> 5) & 3;
}

// 地址 3 气压强度和振动（或扭腰）强度

- (void)parseByteOfAddress3:(Byte)addr {
    /**
     气压强度 : bit 0,bit 1, bit 2
     5档强度：00：停止，01最弱，05最强，06和07：保留
     3档强度：00：停止，01最弱，03最强，04-07：保留
     */
    _rtMassageChairStatus.airPressureFlag = (addr & 7);
    
    /**
     负离子开关 : bit 6
     0：负离子关
     1：负离子开
     */
    _rtMassageChairStatus.anionSwitchFlag = (addr >> 6) & 1;
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
    _rtMassageChairStatus.kneadWidthFlag = (addr & 3);
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
    _rtMassageChairStatus.movementSpeedFlag = (addr >> 2) & 7;
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
	
	_rtMassageChairStatus.isRollerOn = (_rtMassageChairStatus.rollerSwitchFlag == 1);
	
	_rtMassageChairStatus.isHeating = (_rtMassageChairStatus.heatingSwitchFlag == 1);
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
    _rtMassageChairStatus.massageTechniqueFlag = (addr >> 3) & 7;
    
    /**
     按摩椅运行状态
     0：按摩椅处于待机,主电源关闭，省电模式
     1：按摩椅处于非待机状态，此时手控器相应的图标点亮
     */
    _rtMassageChairStatus.runningStatusFlag = (addr >> 6) & 1;
	
	switch (_rtMassageChairStatus.massageTechniqueFlag) {
  		case 0:
			_rtMassageChairStatus.massageTechnique = RTMassageChairMassageTechniqueStop;
			break;
			
		case 1:
			_rtMassageChairStatus.massageTechnique = RTMassageChairMassageTechniqueKnead;
			break;
			
		case 2:
			_rtMassageChairStatus.massageTechnique = RTMassageChairMassageTechniqueKnock;
			break;
			
		case 3:
			_rtMassageChairStatus.massageTechnique = RTMassageChairMassageTechniqueSync;
			break;
			
		case 4:
			_rtMassageChairStatus.massageTechnique = RTMassageChairMassageTechniqueTapping;
			break;
			
		case 5:
			_rtMassageChairStatus.massageTechnique = RTMassageChairMassageTechniqueShiatsu;
			break;
			
		case 6:
			_rtMassageChairStatus.massageTechnique = RTMassageChairMassageTechniqueRhythm;
			break;
			
		case 7:
			_rtMassageChairStatus.massageTechnique = RTMassageChairMassageTechniqueBackRub;
			break;
	}
}
@end
