//
//  ProgramDownloadTableViewController.m
//  rongtai
//
//  Created by yoghourt on 6/14/15.
//  Copyright (c) 2015 William-zhang. All rights reserved.
//

#import "ProgramDownloadViewController.h"
#import "UIBarButtonItem+goBack.h"
#import "RTBleConnector.h"
#import "ReadFile.h"
#import "ProgramDownloadTableViewCell.h"

@interface ProgramDownloadViewController ()<UITableViewDelegate, UITableViewDataSource, RTBleConnectorDelegate>

@property (nonatomic, retain) ReadFile *readFile;

@property (nonatomic, assign) int installCount;

@property (nonatomic, assign) int installAllCount;

@property (nonatomic, assign) BOOL isStartInstall;

@property (nonatomic, retain) NSMutableArray *installEachDataMutableArray;

@end

@implementation ProgramDownloadViewController

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.isListenBluetoothStatus = YES;
	
	self.readFile = [[ReadFile alloc] init];
	self.installEachDataMutableArray = [[NSMutableArray alloc]init];
	
	[self.readFile read];
	
	UIBarButtonItem *item = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"icon_back"] style:UIBarButtonItemStylePlain target:self action:@selector(goBack)];
	self.navigationItem.leftBarButtonItem = item;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 返回

- (void)goBack {
	[[RTBleConnector shareManager] sendControlByBytes:[[RTBleConnector shareManager] exitEditMode]];  // 退出编辑模式
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - RTBleConnectorDelegate

- (void)didUpdateStatusInProgramMode:(NSData *)rawData {
	
	Byte *response = (Byte *)[rawData bytes];
	
	switch (response[0]) {
		case 0x43:		// NCG     0x43     主板上传给APP的请求发送数据包标志位
			if(!self.isStartInstall) {
				[self startInstallMassage];
			}
			break;
		case 0x06:		// ACK     0X06     数据被正确接收标志
			[self installNext];
			break;
		case 0x15:		// NAK     0X15     数据包接收出错，请求重发当前数据包标志
			[self installCommandSend];
			break;
	}
}

- (void)didUpdateMassageChairStatus:(RTMassageChairStatus *)rtMassageChairStatus {

}

#pragma mark - 开始发送安装程序

- (void)startInstallMassage {
	self.installCount = 1;
	self.isStartInstall = YES;
	NSLog(@"readfile.resultData.length : %zd", self.readFile.resultData.length);
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
	[[RTBleConnector shareManager] sendControlByBytes:[[self makeInstallCommand:testByte] subdataWithRange:NSMakeRange(0, 50)]];
	[NSThread sleepForTimeInterval:0.01f];
	[[RTBleConnector shareManager] sendControlByBytes:[[self makeInstallCommand:testByte] subdataWithRange:NSMakeRange(50, 50)]];
	[NSThread sleepForTimeInterval:0.01f];
	[[RTBleConnector shareManager] sendControlByBytes:[[self makeInstallCommand:testByte] subdataWithRange:NSMakeRange(100, 33)]];
}

- (NSData *) makeInstallCommand:(Byte *) data {
	Byte command[133];
	command[0] = 1;
	command[1] = self.installCount;
	command[2] = 255 - self.installCount;
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
	if(self.installCount <= self.installAllCount) {
		[self installCommandSend];
	} else {
		Byte byte[] = {4};  // EOT 0X04 传输结束标志，所有数据包数据传输完成后，APP只发一个字节的EOT信息给主板，主板收到EOT后，发送ACK信息给APP 表示本次传输完毕
		[[RTBleConnector shareManager] sendControlByBytes:[NSData dataWithBytes:byte length:1]];
		self.isStartInstall = false;
		[self.installEachDataMutableArray removeAllObjects];
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

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 7;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
    ProgramDownloadTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ProgramDownloadTableViewCell" forIndexPath:indexPath];
	
	cell.row = indexPath.row;
	
	switch (indexPath.row) {
  		case 0:
			cell.programImageView.image = [UIImage imageNamed:@"mode_1"];
			cell.programNameLabel.text = NSLocalizedString(@"韩式按摩", nil);
			break;
		case 1:
			cell.programImageView.image = [UIImage imageNamed:@"mode_2"];
			cell.programNameLabel.text = NSLocalizedString(@"舒展活络", nil);
			break;
		case 2:
			cell.programImageView.image = [UIImage imageNamed:@"mode_3"];
			cell.programNameLabel.text = NSLocalizedString(@"工作减压", nil);
			break;
		case 3:
			cell.programImageView.image = [UIImage imageNamed:@"mode_4"];
			cell.programNameLabel.text = NSLocalizedString(@"运动恢复", nil);
			break;
		case 4:
			cell.programImageView.image = [UIImage imageNamed:@"mode_5"];
			cell.programNameLabel.text = NSLocalizedString(@"消除疲劳", nil);
			break;
		case 5:
			cell.programImageView.image = [UIImage imageNamed:@"mode_6"];
			cell.programNameLabel.text = NSLocalizedString(@"女性纤体按摩", nil);
			break;
		case 6:
			cell.programImageView.image = [UIImage imageNamed:@"mode_7"];
			cell.programNameLabel.text = NSLocalizedString(@"老年按摩", nil);
			break;
		case 7:
			cell.programImageView.image = [UIImage imageNamed:@"mode_8"];
			break;
	}
    
    return cell;
}

@end
