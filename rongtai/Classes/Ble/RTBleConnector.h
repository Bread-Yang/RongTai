//
//  RTBleConnector.h
//  BLETool
//
//  Created by Jaben on 15/5/6.
//  Copyright (c) 2015年 Jaben. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JRBluetoothManager.h"
#import "RongTai.h"
#import "RTMassageChairStatus.h"
#import "MassageProgram.h"

static NSString *const RTBle_Periperal     = @"RTPeriperal";
static NSString *const RTBle_BroadcastData = @"RTBroadcastData";
static NSString *const RTBle_RSSI          = @"RTRSSI";

static BOOL isBleTurnOn;

#define RTLocalName @"RT8600S"
#define RTBroadServiceUUID @"1802"

#define RTServiceUUID @"FFF0"
#define RT_N_ChracteristicUUID @"0734594A-A8E7-4B1A-A6B1-CD5243059A57"
#define RT_RW_ChracteristicUUID @"FFF1"
#define RT_W_ChracteristicUUID @"8B00ACE7-EB0B-49B0-BBE9-9AEE0A26E1A3"
#define RT_RN_ChracteristicUUID @"E06D5EFB-4F4A-45C0-9EB1-371AE5A14AD4"

#pragma mark - RTBleConnectorDelegate

@class RTNetworkProgramStatus;

@protocol RTBleConnectorDelegate <NSObject>

@required
- (void)didUpdateRTBleState:(CBCentralManagerState)state;

@optional

- (void)didFoundRTBlePeriperalInfo:(NSDictionary *)periperalInfo;

- (void)didConnectRTBlePeripheral:(CBPeripheral *)peripheral;

- (void)didFailToConnectRTBlePeripheral:(CBPeripheral *)peripheral;

- (void)didDisconnectRTBlePeripheral:(CBPeripheral *)peripheral;

/**
 *	处于"按摩模式"下(返回的NSData.length == 17),按摩椅返回的状态(用于更新App按摩界面)
 */
- (void)didUpdateMassageChairStatus:(RTMassageChairStatus *)rtMassageChairStatus;

/**
 *	处于"按摩模式"下(返回的NSData.length == 11),返回按摩椅网络程序的状态(更新按摩程序列表)
 */
- (void)didUpdateNetworkMassageStatus:(RTNetworkProgramStatus *)rtNetwrokProgramStatus;

/**
 *	处于"编程模式"下,按摩椅返回的状态(用于App"程序下载"功能)
 */
- (void)didUpdateStatusInProgramMode:(NSData *)rawData;

/**
 *	开始下载网络程序
 */
- (void)didStartDownloadProgramMassage;

/**
 *	网络程序下载中
 */
- (void)didDownloadingProgramMassage;

/**
 *	网络程序下载完成
 */
- (void)didSuccessDownloadProgramMassage;

/**
 *	网络程序下载失败
 */
- (void)didFailDownloadProgramMassage;

/**
 *	开始安装网络程序
 */
- (void)didStartInstallProgramMassage;

/**
 *	结束安装网络程序
 */
- (void)didEndInstallProgramMassage;

@end

#pragma mark - RTBleConnector

/*======================================================
 RTBleConnector
 /======================================================*/

@interface RTBleConnector : NSObject

@property (nonatomic, strong) id<RTBleConnectorDelegate> delegate;

@property (nonatomic, assign) BOOL isConnectedDevice;

@property (nonatomic, strong) NSTimer *reconnectTimer;

@property (nonatomic, strong) RTMassageChairStatus *rtMassageChairStatus;

@property (nonatomic, strong) RTNetworkProgramStatus *rtNetworkProgramStatus;

@property (nonatomic, retain) CBPeripheral *currentConnectedPeripheral;

/**
 *  是否重新连接当前断开设备
 */
@property (nonatomic) BOOL isReconnect;

/**
 *  开始按摩时间，只用于自动按摩的时间统计
 */
@property (nonatomic, strong) NSDate* startTime;

/**
 *  最后一次按摩信息
 */
@property (nonatomic, strong) NSDictionary* massageRecord;


//蓝牙断开时是否弹框
@property (nonatomic, assign) BOOL isSendMessage;


#pragma mark - download network program field

@property (nonatomic, assign) CGFloat progress;
@property (nonatomic, assign) BOOL isCompleted;
@property (nonatomic, strong) NSString *bytesProgress;
@property (nonatomic, strong) NSString *bytesTotal;
@property (nonatomic, strong) NSString *error;

+ (instancetype)shareManager;

+ (BOOL)isBleTurnOn;

- (void)startScanRTPeripheral:(NSArray *)serviceUUIDs;

- (void)stopScanRTPeripheral;

- (void)connectRTPeripheral:(CBPeripheral *)peripheral;

- (void)cancelConnectRTPeripheral:(CBPeripheral *)peripheral;

- (void)cancelCurrentConnectedRTPeripheral;

/*======================================================
 业务命令
 /======================================================*/

#pragma mark - Control Command

- (void)sendControlMode:(NSInteger)mode;

- (void)sendControlByBytes:(NSData *)data;

- (void)installProgramMassageByBinName:(NSString *)binName;

- (NSData *)deleteProgramMassage:(NSInteger)massageId;

- (NSData *)exitEditMode;

#pragma mark - reconnect dialog 

- (void)showConnectDialog;

@end


#pragma mark - RTNetworkProgramStatus Class
@interface RTNetworkProgramStatus : NSObject

@property (nonatomic, retain) NSArray *networkProgramStatusArray;

/**
 *	用于安装网络程序,四个位,如果是0,就返回该index,如果四个位都满了,就默认返回-1
 */
- (NSInteger)getEmptySlotIndex;

- (NSInteger)getMassageIdBySlotIndex:(NSInteger)index;

/**
 *	用于删除网络程序
 */
- (NSInteger)getSlotIndexByMassageId:(NSInteger)massageId;

/**
 *	网络程序是否已经安装过
 */
- (BOOL)isAlreadyIntall:(NSInteger)massageId;

/**
 *	根据参数是云养程序1, 云养程序2, 云养程序3, 云养程序4,返回该程序的实体
 */
- (MassageProgram *)getNetworkProgramNameBySlotIndex:(NSInteger)slotIndex;

@end

