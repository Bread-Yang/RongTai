//
//  ProgramDownloadTableViewCell.m
//  rongtai
//
//  Created by yoghourt on 8/11/15.
//  Copyright (c) 2015 William-zhang. All rights reserved.
//

#import "ProgramDownloadTableViewCell.h"
#import "RTBleConnector.h"
#import "UIImageView+AFNetworking.h"
#import "UIImage+ImageBlur.h"
#import "RongTaiConstant.h"
#import "AFNetworking.h"
#import "CustomIOSAlertView.h"
#import "UIImageView+RT.h"


@implementation ProgramDownloadTableViewCell 

- (void)awakeFromNib {
	
	[self.downloadOrDeleteButton.currentImage setAccessibilityIdentifier:@"download"];
	
	[self.downloadOrDeleteButton addTarget:self action:@selector(downloadOrDeleteProgram:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark - setter and getter

- (void)setMassageProgram:(MassageProgram *)massageProgram {
	_massageProgram = massageProgram;
	
	[UIImageView loadImageByURL:massageProgram.imageUrl imageView:self.programImageView];
	
	// 网络程序名
	self.programNameLabel.text = massageProgram.name;
	
	// 网络程序描述
	self.programDescriptionLabel.text = massageProgram.mDescription;
	
}

- (void)setIsAlreadyDownload:(BOOL)isAlreadyDownload {
	_isAlreadyDownload = isAlreadyDownload;
	if (isAlreadyDownload) {
		[self.downloadOrDeleteButton setImage:[UIImage imageNamed:@"program_icon_delete"] forState:UIControlStateNormal];
		[self.downloadOrDeleteButton.currentImage setAccessibilityIdentifier:@"delete"];
	} else {
		[self.downloadOrDeleteButton setImage:[UIImage imageNamed:@"program_icon_download"] forState:UIControlStateNormal];
		[self.downloadOrDeleteButton.currentImage setAccessibilityIdentifier:@"download"];
	}
}


#pragma mark - Download or delete program

- (void)downloadOrDeleteProgram:(UIButton *)button {
	
	if ([[button.currentImage accessibilityIdentifier] isEqualToString:@"download"]) {
		
		if ([RTBleConnector shareManager].currentConnectedPeripheral == nil) {
			[[RTBleConnector shareManager] showConnectDialog];
		} else {
			// 网络4个位都已经安装了程序, 提醒用户删除其中一个才可以安装
			if ([[RTBleConnector shareManager].rtNetworkProgramStatus getEmptySlotIndex] == -1) {
				
				CustomIOSAlertView *tipsDialog = [[CustomIOSAlertView alloc] init];
				tipsDialog.isReconnectDialog = YES;
				tipsDialog.reconnectTipsString = NSLocalizedString(@"网络程序安装位已满", nil);
				[tipsDialog setButtonTitles:[NSMutableArray arrayWithObjects:NSLocalizedString(@"确定", nil), nil]];
				
				[tipsDialog show];
			} else {
				[[RTBleConnector shareManager] installProgramMassageByBinName:_massageProgram.binUrl];
			}
		}
	} else {
		[[RTBleConnector shareManager] sendControlByBytes:[[RTBleConnector shareManager] deleteProgramMassage:self.massageProgram.commandId]];
		
		[NSThread sleepForTimeInterval:0.3f];
		
		[[RTBleConnector shareManager] sendControlByBytes:[[RTBleConnector shareManager] exitEditMode]];  // 退出编辑模式
	}
}

@end
