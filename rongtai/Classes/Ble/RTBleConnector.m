//
//  RTBleConnector.m
//  BLETool
//
//  Created by Jaben on 15/5/6.
//  Copyright (c) 2015年 Jaben. All rights reserved.
//

#import "RTBleConnector.h"
#import "RTCommand.h"
#import "ReadFile.h"
#import "MainViewController.h"
#import "RongTaiConstant.h"
#import "AFNetworking.h"
#import "CustomIOSAlertView.h"
//#import "MassageProgram.h"
#import "CoreData+MagicalRecord.h"

static Byte const BYTE_iOS_Mark = 0x84;
static Byte const BYTE_Head = 0xf0;
static Byte const BYTE_Tail = 0xf1;
static Byte const BYTE_CodeMode = 0xA5;

//===== wl:Xmodem
//static Byte const BYTE_Download = 0x01;
//static Byte const BYTE_Delete = 0x02;

//static Byte const BYTE_ExitCode = 0x82;
//=====


//FFF1  == read write
#define kCharacterRW(periphralName) [NSString stringWithFormat:@"RW_%@",periphralName]

// 0734594A-A8E7-4B1A-A6B1-CD5243059A57 ==  notify
#define kCharacterN(periphralName) [NSString stringWithFormat:@"N_%@",periphralName]

// 8B00ACE7-EB0B-49B0-BBE9-9AEE0A26E1A3 == write with no response
#define kCharacterW(periphralName) [NSString stringWithFormat:@"W_%@",periphralName]

// E06D5EFB-4F4A-45C0-9EB1-371AE5A14AD4 == Read notify
#define kCharacterRN(periphralName) [NSString stringWithFormat:@"RN_%@",periphralName]



@implementation RTNetworkProgramStatus

//- (instancetype)init {
//	
//	self = [super init];
//	
//	if (self) {
//		
//		self.networkProgramStatusArray = @[@0, @0, @0, @0];
//		
//	}
//	return self;
//}

- (NSInteger)getEmptySlotIndex {
    for (int i = 0; i < [self.networkProgramStatusArray count]; i++) {
        NSInteger value = [((NSNumber *)[self.networkProgramStatusArray objectAtIndex:i]) intValue];
        if (value == 0) {
            return i + 1;
        }
    }
    return -1;
}

- (NSInteger)getMassageIdBySlotIndex:(NSInteger)index {
    if (index < 0 || index > [self.networkProgramStatusArray count] - 1) {
        return 0;
    }
    for (int i = 0; i < [self.networkProgramStatusArray count]; i++) {
        if (i == index) {
            return [((NSNumber *)[self.networkProgramStatusArray objectAtIndex:i]) intValue];
        }
    }
    return 0;
}

- (NSInteger)getSlotIndexByMassageId:(NSInteger)massageId {
    for (int i = 0; i < [self.networkProgramStatusArray count]; i++) {
        if ([(NSNumber *)[self.networkProgramStatusArray objectAtIndex:i] intValue] == massageId) {
            return i + 1;
        }
    }
    return -1;
}

- (BOOL)isAlreadyIntall:(NSInteger)massageId {
    for (int i = 0; i < [self.networkProgramStatusArray count]; i++) {
        if ([(NSNumber *)[self.networkProgramStatusArray objectAtIndex:i] intValue] == massageId) {
            return true;
        }
    }
    return false;
}

- (MassageProgram *)getNetworkProgramNameBySlotIndex:(NSInteger)slotIndex {
    NSInteger massageId = [self getMassageIdBySlotIndex:slotIndex];
    MassageProgram *massageProgram = nil;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"commandId = %@", [NSNumber numberWithInteger:massageId]];
    NSArray* arr = [MassageProgram MR_findAllWithPredicate:predicate];
    if (arr.count>0) {
        massageProgram = arr[0];
    }
    else
    {
        NSLog(@"找不到云养程序💢 massageId:%ld, slotIndex:%ld",massageId,slotIndex);
    }
    
    return massageProgram;
}

@end



@interface RTBleConnector ()<JRBluetoothManagerDelegate>

@property (nonatomic, assign) int installCount;

@property (nonatomic, assign) int installAllCount;

@property (nonatomic, assign) BOOL isStartInstall;

@property (nonatomic, retain) NSMutableArray *installEachDataMutableArray;

@property (nonatomic, retain) ReadFile *readFile;

@property (nonatomic, strong) NSMutableDictionary *characteristicDicionary;

@property (readonly) NSTimeInterval reconnectInterval;

@property (nonatomic, retain) NSTimer *turnOnTimer;

@property (nonatomic, retain) CustomIOSAlertView *reconnectDialog, *chairInstallExceptionDialog;

@property (nonatomic, retain) NSString *oldMassageChairRunningStatusString, *oldMassageChairNetworkStatusString;

@property (nonatomic, assign) NSInteger updateNetworkStatusCount;


//蓝牙断开时是否弹框
@property (nonatomic, assign) BOOL isSendMessage;

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
        
        _isSendMessage = NO;

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
			self.currentConnectedPeripheral = nil;
			self.isStartInstall = false;
            if (_isSendMessage) {
                [self showConnectDialog];
            }
			break;
		case CBCentralManagerStatePoweredOn:
			message = @"蓝牙已经成功开启，稍后……";
			isBleTurnOn = YES;
            _isSendMessage = YES;
			break;
        case CBCentralManagerStateUnknown:
            message = @"蓝牙发生未知错误，请重新打开……";
			self.currentConnectedPeripheral = nil;
//			_rtNetworkProgramStatus = [[RTNetworkProgramStatus alloc] init];
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
	
	[self.chairInstallExceptionDialog close];
	
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
	self.isStartInstall = false;

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
			NSData *runningStatusData = [data subdataWithRange:NSMakeRange(1, 14)];   // 运行状态在1到14位
			
			NSString *newRunningStatusString = NSDataToHex(runningStatusData);
			
			if (![newRunningStatusString isEqualToString:_oldMassageChairRunningStatusString]) {
//				NSLog(@"newRunningStatusString : %@", newRunningStatusString);
//				NSLog(@"_oldMassageChairStatus : %@", _oldMassageChairRunningStatusString);
				
				_oldMassageChairRunningStatusString = newRunningStatusString;
				
				[self parseData:data];
//                [self.rtMassageChairStatus printStatus];
				if (self.delegate && [self.delegate respondsToSelector:@selector(didUpdateMassageChairStatus:)]) {
					[self.delegate didUpdateMassageChairStatus:self.rtMassageChairStatus];
				}
			}
			
		} else if (data.length == 11 || data.length == 12) {	// 等于11位或者12位 : 返回按摩椅网络程序状态
//
//			NSData *networkStatusData = [data subdataWithRange:NSMakeRange(2, 8)];
//			
//			NSLog(@"[rawData subdataWithRange:NSMakeRange(2, 8)] : %@", networkStatusData);
			
			Byte *response = (Byte *)[data bytes];
			
			if (response[1] == 0xa5) {
				[self sendControlByBytes:[self exitEditMode]];  // 退出编辑模式
				
				if (self.delegate && [self.delegate respondsToSelector:@selector(didEndInstallProgramMassage)]) {
					[self.delegate didEndInstallProgramMassage];
				}
			}
			
			NSString *newNetworkStatusString = NSDataToHex(data);
			
			if (![newNetworkStatusString isEqualToString:_oldMassageChairNetworkStatusString]) {
				NSLog(@"newNetworkStatusString : %@", newNetworkStatusString);
				NSLog(@"_oldMassageChairStatus : %@", _oldMassageChairNetworkStatusString);
				
				_oldMassageChairNetworkStatusString = newNetworkStatusString;
				
				[self parseNetworkStatus:data];
				
				if (self.delegate && [self.delegate respondsToSelector:@selector(didUpdateNetworkMassageStatus:)]) {
					
					[self.delegate didUpdateNetworkMassageStatus:self.rtNetworkProgramStatus];
				}
			}
		}
//		else {  // 不等于11位或者17位 : 编辑模式
		
		else if (data.length == 1) { // 改成一位, 如果有错,讲上面的那一行注释回来
		
//			if (data.length == 12) {
//				
//				if (![newStatusString isEqualToString:_oldMassageChairNetworkStatusString]) {
//					
//					_oldMassageChairNetworkStatusString = newStatusString;
//					
//					[self parseNetworkStatus:data];
//					
//					if (self.delegate && [self.delegate respondsToSelector:@selector(didUpdateNetworkMassageStatus:)]) {
//						
//						[self.delegate didUpdateNetworkMassageStatus:self.rtNetworkProgramStatus];
//					}
//				}
//			}
            NSLog(@"进入安装状态，此时返回数据长度为:%ld",data.length);
			[self parseInstallingStatus:data];
			
			if (self.delegate && [self.delegate respondsToSelector:@selector(didUpdateStatusInProgramMode:)]) {
				[self.delegate didUpdateStatusInProgramMode:data];
			}
		}
    }
}

- (void)didWriteValueForCharacteristic:(CBCharacteristic *)characteristic inPeripheral:(CBPeripheral *)peripheral {
    
}

static inline char itoh(int i) {
	if (i > 9) return 'A' + (i - 10);
	return '0' + i;
}

NSString * NSDataToHex(NSData *data) {
	NSUInteger i, len;
	unsigned char *buf, *bytes;
	
	len = data.length;
	bytes = (unsigned char*)data.bytes;
	buf = malloc(len*2);
	
	for (i=0; i<len; i++) {
		buf[i*2] = itoh((bytes[i] >> 4) & 0xF);
		buf[i*2+1] = itoh(bytes[i] & 0xF);
	}
	
	return [[NSString alloc] initWithBytesNoCopy:buf
										  length:len*2
										encoding:NSASCIIStringEncoding
									freeWhenDone:YES];
}

#pragma mark - Send Command

- (void)sendControlMode:(NSInteger)mode {
    //	NSInteger commnad[] = {NORMAL_CTRL,ENGGER_CTRL,H10_KEY_CHAIR_AUTO_0};
	
	if (self.currentConnectedPeripheral == nil || !isBleTurnOn || !self.isConnectedDevice) {
		
		[self showConnectDialog];

		return;
	}
	
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
	if (self.currentConnectedPeripheral == nil || !isBleTurnOn || !self.isConnectedDevice) {
		[self showConnectDialog];
	}
	
	if (self.isConnectedDevice) {
		
		if (self.rtMassageChairStatus.deviceStatus == RtMassageChairStatusResetting) { // 复位状态下不发送指令
			return;
		}
		
//		NSLog(@"发送的data : %@", data);
		
		[self sendDataToPeripheral:data];
	}
}

- (void)delaySendCommand:(NSTimer *)timer {
	NSInteger mode = [[[timer userInfo] objectForKey:@"mode"] integerValue];
	NSData *bodyData = [self dataWithFuc:mode];
	NSData *sendData = [self fillDataHeadAndTail:bodyData];
	[self sendDataToPeripheral:sendData];
}

#pragma mark - install network program

- (void)installProgramMassageByBinName:(NSString *)binName {
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
	NSString *binDir = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"bin"];
	NSString *binPath = [binDir stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.bin", binName]];
	
	NSFileManager *fileManager = [NSFileManager defaultManager];
	
	// 文件夹不存在则创建
	[fileManager createDirectoryAtPath:binDir withIntermediateDirectories:YES attributes:nil error:nil];
	
	// 在本地查看是否存在
	if ([fileManager fileExistsAtPath:binPath]) {
		
		[self sendControlByBytes:[self getInstallProgramMassageCommand:binName]];
		
	} else {
		NSString *url = [RongTaiFileDomain stringByAppendingString:binName];
		
		NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:5];
		
		AFHTTPRequestOperation *afOperation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
		afOperation.outputStream = [NSOutputStream outputStreamToFileAtPath:binPath append:NO];  // 保存文件
		
		__weak RTBleConnector *weakSelf = self;
		
		[afOperation setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
			
			weakSelf.progress = (double)totalBytesRead / totalBytesExpectedToRead;
			weakSelf.bytesProgress = [NSString stringWithFormat:@"%@/%@", [weakSelf formatByteCount:totalBytesRead], [weakSelf formatByteCount:totalBytesExpectedToRead]];
			
			NSLog(@"下载了多少 : %zd", weakSelf.progress);
		}];
		
		[afOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
			
			if (self.delegate && [self.delegate respondsToSelector:@selector(didSuccessDownloadProgramMassage)]) {
				[self.delegate didSuccessDownloadProgramMassage];
			}
			
			weakSelf.bytesTotal = [weakSelf formatByteCount:operation.response.expectedContentLength];
			weakSelf.isCompleted = YES;
			
			// 下载完后安装
			[self sendControlByBytes:[[RTBleConnector shareManager] getInstallProgramMassageCommand:binName]];
			
		} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
			
			if ([[NSFileManager defaultManager] fileExistsAtPath:binPath]) {
				NSLog(@"网络下载bin文件失败,删除文件,目录是 : %@", binPath);
				[[NSFileManager defaultManager] removeItemAtPath:binPath error:nil];
			}
			
			if (self.delegate && [self.delegate respondsToSelector:@selector(didFailDownloadProgramMassage)]) {
				[self.delegate didFailDownloadProgramMassage];
			}
			
			weakSelf.error = error.localizedDescription;
			weakSelf.isCompleted = YES;
			
		}];
		
		if (self.delegate && [self.delegate respondsToSelector:@selector(didStartDownloadProgramMassage)]) {
			[self.delegate didStartDownloadProgramMassage];
		}
		
		[afOperation start];
	}
}

- (NSString*)formatByteCount:(long long)size {
	return [NSByteCountFormatter stringFromByteCount:size countStyle:NSByteCountFormatterCountStyleFile];
}

#pragma mark - get network program operation command

- (NSData *)getInstallProgramMassageCommand:(NSString *)binName {
	
	if (!self.readFile) {
		self.readFile = [[ReadFile alloc] init];
		_installEachDataMutableArray = [[NSMutableArray alloc]init];
	}
	
	[self.readFile read:binName];
	
	NSInteger installIndex = [self.rtNetworkProgramStatus getEmptySlotIndex];
	
	Byte byte[] = {0xf0, 0xa5, 0x10, 1, installIndex, installIndex, 0x4a, 0xf1};
	NSInteger sumData = byte[1] + byte[2] + byte[3] + byte[4] + byte[5];
	NSInteger contraryData =  ~sumData;
	NSInteger checkSum = contraryData & 0x7f;
	byte[6] = checkSum;
	NSData *bodayData = [NSData dataWithBytes:&byte length:8];
	
	return bodayData;
}

- (NSData *)deleteProgramMassage:(NSInteger)massageId {
	NSInteger deleteIndex = [self.rtNetworkProgramStatus getSlotIndexByMassageId:massageId];
	if (deleteIndex != -1) {
		Byte byte[] = {0xf0, 0xa5, 0x10, 2, deleteIndex, deleteIndex, 0x4a, 0xf1};
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

#pragma mark - 开始发送程序

- (void)startInstallMassage {
	
	self.installCount = 1;
	self.isStartInstall = YES;
	self.installAllCount = (self.readFile.resultData.length / 128) + 1;
	
	Byte *fileData = (Byte *)[self.readFile.resultData bytes];
	for (int i = 0; i < self.installAllCount; i++) {
		Byte data[128];
		for (int j = 0; j < 128; j++) {
			if((i * 128 + j) > self.readFile.resultData.length - 1) {
				data[j] = 0x1a;
			} else {
				data[j] = fileData[i * 128 + j];
			}
		}
		NSData *tempdata = [[NSData alloc] initWithBytes:data length:128];
		[self.installEachDataMutableArray addObject:tempdata];
		
	}
	[self installCommandSend];
}

#pragma mark - 一个数据帧总长度为1+1+1+128+2=133字节，由于XOMDEM协议是通过蓝牙4.0发送给主板，故APP软件在发送数据时需将133字节分三次发送，第一次先发送50字节数据延时10-20ms后，开始第二次发送50字节数据后延时10-20ms 后，开始第三次发送33字节的数据同时再延时20ms后等待主板发送回应码 ACK/NAK/CAN后进行下一个数据包（133字节）的发送。

- (void)installCommandSend {
	Byte *testByte = (Byte *)[[self.installEachDataMutableArray objectAtIndex:self.installCount - 1] bytes];
	
	if (testByte) {
		[self sendControlByBytes:[[self makeInstallCommand:testByte] subdataWithRange:NSMakeRange(0, 50)]];
		[NSThread sleepForTimeInterval:0.01f];
		
		[self sendControlByBytes:[[self makeInstallCommand:testByte] subdataWithRange:NSMakeRange(50, 50)]];
		[NSThread sleepForTimeInterval:0.01f];
		
		[self sendControlByBytes:[[self makeInstallCommand:testByte] subdataWithRange:NSMakeRange(100, 33)]];
	} else {
		[self sendControlByBytes:[self exitEditMode]];  // 退出编辑模式
	}
}

- (NSData *) makeInstallCommand:(Byte *) data {
	Byte command[133];
	command[0] = 1;
	command[1] = self.installCount;
	command[2] = 255 - self.installCount;
#warning 这里曾经奔溃过，只是手动按摩，最后一次NSLog输出是“进入安装状态，此时返回数据长度为16”
	for (int i = 0; i < 128; i++) {
		command[3+i] = data[i];
	}
	command[131] = (CRC_calc(&data[0], &data[127]) & 0xff00) >> 8; 	// CRC校验高位
	command[132] = CRC_calc(&data[0], &data[127]) & 0xff;			// CRC校验低位
	return  [[NSData alloc] initWithBytes:command length:133];
}

#pragma mark - 发送下一条指令
- (void)installNext {
	self.installCount++;
	NSLog(@"总数 : %zd , 当前数量 : %zd", self.installCount, self.installCount);
	if(self.installCount <= self.installAllCount) {
		[self installCommandSend];
	} else {
		NSLog(@"传输结束,发送04");
		Byte byte[] = {0x04};  // EOT 0X04 传输结束标志，所有数据包数据传输完成后，APP只发一个字节的EOT信息给主板，主板收到EOT后，发送ACK信息给APP 表示本次传输完毕
		[self sendControlByBytes:[NSData dataWithBytes:byte length:1]];
		self.isStartInstall = false;
		[self.installEachDataMutableArray removeAllObjects];
		
		[self.readFile.resultData setLength:0];
		
		if (self.delegate && [self.delegate respondsToSelector:@selector(didEndInstallProgramMassage)]) {
			[self.delegate didEndInstallProgramMassage];
		}
	}
}

#pragma mark - 128字节数据的CRC校验算法

unsigned short CRC_calc(unsigned char *start, unsigned char *end) {
	unsigned short crc = 0x0;
	unsigned char  *data;
	
	for (data = start; data <= end; data++) {
		crc  = (crc >> 8) | (crc << 8);
		crc ^= *data;
		crc ^= (crc & 0xff) >> 4;
		crc ^= crc << 12;
		crc ^= (crc & 0xff) << 5;
	}
	return crc;
}

#pragma mark - 解析返回的状态

- (void)parseInstallingStatus:(NSData *)data {
	Byte *response = (Byte *)[data bytes];
	switch (response[0]) {
			
		case 0x43:		// NCG     0x43     主板上传给APP的请求发送数据包标志位
			if(!_isStartInstall && self.readFile.resultData.length > 0) {
				[self startInstallMassage];
				
				if (self.delegate && [self.delegate respondsToSelector:@selector(didStartInstallProgramMassage)]) {
					[self.delegate didStartInstallProgramMassage];
				}
			} else {   // 之后如果还是返回0x43,则弹出错误提示框
				[self showChairInstallExceptionDialog];
				
				if (self.delegate && [self.delegate respondsToSelector:@selector(didEndInstallProgramMassage)]) {
					[self.delegate didEndInstallProgramMassage];
				}
			}
			break;
			
		case 0x06:		// ACK     0X06     数据被正确接收标志
			if(_isStartInstall) {
				[self installNext];
			}
			
			break;
			
		case 0x15:		// NAK     0X15     数据包接收出错，请求重发当前数据包标志
			if(_isStartInstall) {
				[self installCommandSend];
			}
			
			break;
			
	}

}

- (void)parseNetworkStatus:(NSData *)data  {
	NSData *networkStatusData = [data subdataWithRange:NSMakeRange(2, 8)];
	
//	NSLog(@"[rawData subdataWithRange:NSMakeRange(2, 8)] : %@", networkStatusData);
	
	Byte *networkStatusByte = (Byte *)[networkStatusData bytes];
	
	NSInteger massageId_1 = networkStatusByte[0] * 16 + networkStatusByte[1];
	NSInteger massageId_2 = networkStatusByte[2] * 16 + networkStatusByte[3];
	NSInteger massageId_3 = networkStatusByte[4] * 16 + networkStatusByte[5];
	NSInteger massageId_4 = networkStatusByte[6] * 16 + networkStatusByte[7];
	
	[NSNumber numberWithInteger:massageId_1];
	
	self.rtNetworkProgramStatus.networkProgramStatusArray = @[[NSNumber numberWithInteger:massageId_1], [NSNumber numberWithInteger:massageId_2], [NSNumber numberWithInteger:massageId_3], [NSNumber numberWithInteger:massageId_4]];
	
//	NSLog(@"按摩椅云养程序数组是 : %@", self.rtNetworkProgramStatus.networkProgramStatusArray);
}

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
	 08：网络程序 1  //20150721增加
	 09：网络程序 2
	 0A：网络程序3
	 0B：网络程序4
	 0C：3D按摩
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
				_rtMassageChairStatus.autoProgramType = RtMassageChairProgramExtension;
				break;
			case 3:
				_rtMassageChairStatus.autoProgramType = RtMassageChairProgramRestAndSleep;
				break;
			case 4:
				_rtMassageChairStatus.autoProgramType = RtMassageChairProgramWorkingRelieve;
				break;
			case 5:
				_rtMassageChairStatus.autoProgramType = RtMassageChairProgramShoulderAndNeck;
				break;
			case 6:
				_rtMassageChairStatus.autoProgramType = RtMassageChairProgramWaistAndSpine;
				break;
		}
		
	} else if (_rtMassageChairStatus.massageProgramFlag == 7) {
		_rtMassageChairStatus.programType = RtMassageChairProgramManual;
	} else {
		_rtMassageChairStatus.programType = RtMassageChairProgramNetwork;
		
		switch (_rtMassageChairStatus.massageProgramFlag) {
			case 8:
				_rtMassageChairStatus.networkProgramType = RTMassageChairProgramNetwork1;
				break;
			case 9:
				_rtMassageChairStatus.networkProgramType = RTMassageChairProgramNetwork2;
				break;
			case 10:
				_rtMassageChairStatus.networkProgramType = RTMassageChairProgramNetwork3;
				break;
			case 11:
				_rtMassageChairStatus.networkProgramType = RTMassageChairProgramNetwork4;
				break;
		}
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
	
//	NSInteger i = addr;
	
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
     数值范围0-31 ，0为机芯在最低点，31为机芯最高点 (目前按摩椅实际数值范围是0 - 12)
     */
    _rtMassageChairStatus.movementPositionFlag = addr & 31;
	
//	NSLog(@"机芯位置是 : %zd", _rtMassageChairStatus.movementPositionFlag);
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
     按摩椅运行状态
     0：按摩椅处于待机,主电源关闭，省电模式
     1：按摩椅处于非待机状态，此时手控器相应的图标点亮
     */
    _rtMassageChairStatus.runningStatusFlag = (addr >> 6) & 1;
    
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

#pragma mark  根据要下载或者删除的网络程序id来启动主板
-(void)startMainboardOI:(NSInteger)nAppId Way:(Byte)way {
    if (self.isConnectedDevice) {
        
        if (self.rtMassageChairStatus.deviceStatus == RtMassageChairStatusResetting) { // 复位状态下不发送指令
            return;
        }
        
        if (self.rtMassageChairStatus.deviceStatus == RtMassageChairStatusStandby) {
            // 先发开机指令,过一秒再发模式指令
            
            // 先开机
            NSData *bodyData = [self dataWithFuc:H10_KEY_POWER_SWITCH];
            NSData *sendData = [self fillDataHeadAndTail:bodyData];
            [self sendDataToPeripheral:sendData];
            
            //延迟1.0秒后启动主板读写程序
            NSData* data = [self dataWithState:BYTE_CodeMode ID:nAppId Way:way];
            [self performSelector:@selector(sendDataToPeripheral:) withObject:data afterDelay:1.0f];
            
        } else {
            //启动主板读写程序
            NSData* data = [self dataWithState:BYTE_CodeMode ID:nAppId Way:way];
            [self sendDataToPeripheral:data];
        }
    }
    
}


#pragma mark 根据nAppId和way生成data

- (NSData*)dataWithState:(Byte)state ID:(NSInteger)nAppId Way:(Byte)way {
    Byte code = 0x10;
    NSInteger idHigh7Bit;
    NSInteger idLow7Bit;
    
    if (nAppId > 127) {
        idHigh7Bit = nAppId - 127;
        idLow7Bit = 127;
    }
    else
    {
        idHigh7Bit = 0;
        idLow7Bit = nAppId;
    }
    NSInteger sumNum = (NSInteger)BYTE_Head+(NSInteger)state+(NSInteger)code+(NSInteger)way+idHigh7Bit+idLow7Bit;
    NSInteger contraryNum = ~sumNum;
    NSInteger checkNum = contraryNum & 0x7f;
    Byte command[] = {BYTE_Head,state,code,way,idHigh7Bit,idLow7Bit,checkNum,BYTE_Tail};
    NSData* data = [NSData dataWithBytes:&command length:8];
    return data;
}

#pragma mark - connect dialog

- (void)showConnectDialog {
	
	if (!self.reconnectDialog) {
		self.reconnectDialog = [[CustomIOSAlertView alloc] init];
		self.reconnectDialog.isReconnectDialog = YES;
		
		self.reconnectDialog.reconnectTipsString = NSLocalizedString(@"未连接设备", nil);
		[self.reconnectDialog setButtonTitles:[NSMutableArray arrayWithObjects:NSLocalizedString(@"重新连接", nil), nil]];
	}
	
	if (self.delegate && [self.delegate isKindOfClass:[UIViewController class]]) {
		__weak UIViewController *weakSelf = (UIViewController *)self.delegate;
		[self.reconnectDialog setOnButtonTouchUpInside:^(CustomIOSAlertView *alertView, int buttonIndex) {
			UIStoryboard *secondStoryBoard = [UIStoryboard storyboardWithName:@"Second" bundle:[NSBundle mainBundle]];
			UIViewController *viewController = [secondStoryBoard instantiateViewControllerWithIdentifier:@"ScanVC"];
			[weakSelf.navigationController pushViewController:viewController animated:YES];
			[alertView close];
		}];
		
		[self.reconnectDialog show];
	}
}

#pragma mark - chair install program exception dialog

- (void)showChairInstallExceptionDialog {
	
	if (!self.chairInstallExceptionDialog) {
		self.chairInstallExceptionDialog = [[CustomIOSAlertView alloc] init];
		self.chairInstallExceptionDialog.isReconnectDialog = YES;
		
		self.chairInstallExceptionDialog.reconnectTipsString = NSLocalizedString(@"重启按摩椅", nil);
		[self.chairInstallExceptionDialog setButtonTitles:[NSMutableArray arrayWithObjects:NSLocalizedString(@"确认", nil), nil]];
	}
	
	if (self.delegate && [self.delegate isKindOfClass:[UIViewController class]]) {
		[self.reconnectDialog close];
		
		[self.chairInstallExceptionDialog show];
	}
}

- (UIViewController *)getCurrentViewController {
	UIViewController *result = nil;
	
	UIWindow * window = [[UIApplication sharedApplication] keyWindow];
	if (window.windowLevel != UIWindowLevelNormal)
	{
		NSArray *windows = [[UIApplication sharedApplication] windows];
		for(UIWindow * tmpWin in windows)
		{
			if (tmpWin.windowLevel == UIWindowLevelNormal)
			{
				window = tmpWin;
				break;
			}
		}
	}
	
	UIView *frontView = [[window subviews] objectAtIndex:0];
	id nextResponder = [frontView nextResponder];
	
	if ([nextResponder isKindOfClass:[UIViewController class]])
		result = nextResponder;
	else
		result = window.rootViewController;
	
	return result;
}
@end





