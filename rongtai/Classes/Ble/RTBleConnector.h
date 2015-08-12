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
#import "RTNetworkProgramStatus.h"

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

- (NSData *)controlInstallMassage:(NSInteger)massageId;

- (NSData *)deleteMassage:(NSInteger)massageId;

- (NSData *)exitEditMode;

#pragma mark - WL:Xmodem
-(void)startDownload:(NSInteger)nAppId;

-(void)endCodeMode;

@end
