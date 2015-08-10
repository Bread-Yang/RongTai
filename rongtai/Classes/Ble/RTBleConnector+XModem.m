//
//  RTBleConnector+XModem.m
//  rongtai
//
//  Created by William-zhang on 15/8/10.
//  Copyright (c) 2015年 William-zhang. All rights reserved.
//

#import "RTBleConnector+XModem.h"
#import "RTCommand.h"

static Byte const BYTE_Download = 0X01;
static Byte const BYTE_Delete = 0X02;

@interface RTBleConnector ()
{
    
}
@end

@implementation RTBleConnector (XModem)


#pragma mark - 根据要下载或者删除的网络程序id来启动主板
-(void)startMainboardOI:(NSInteger)nAppId Way:(Byte)way
{
    if (self.isConnectedDevice) {
        
        if (self.rtMassageChairStatus.deviceStatus == RtMassageChairResetting) { // 复位状态下不发送指令
            return;
        }
        
        if (self.rtMassageChairStatus.deviceStatus == RtMassageChairStandby) {
            // 先发开机指令,过一秒再发模式指令
     
            // 先开机
            [self sendControlMode:H10_KEY_POWER_SWITCH];
            
            //延迟启动主板读写程序
        } else {
            //启动主板读写程序
            
        }
    }

}



-(void)wlSendDataToPeripheral:(NSData*)data
{
//    CBCharacteristic *writeCharacteritic = self.characteristicDicionary[[NSString stringWithFormat:@"W_%@",RTLocalName]];
//    [[JRBluetoothManager shareManager] writeData:data toPeriperalWithName:RTLocalName characteritic:writeCharacteritic type:CBCharacteristicWriteWithoutResponse];
}


#pragma mark - PUBLIC
#pragma mark  开始下载
-(void)startDownload:(NSInteger)nAppId
{
    [self startMainboardOI:nAppId Way:BYTE_Download];
}

#pragma mark  开始删除
-(void)startDelete:(NSInteger)nAppId
{
    [self startMainboardOI:nAppId Way:BYTE_Delete];
}

@end
