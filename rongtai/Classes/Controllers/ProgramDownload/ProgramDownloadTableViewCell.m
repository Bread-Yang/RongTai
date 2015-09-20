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
#import "AppDelegate.h"
#import "MBProgressHUD.h"


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

- (void)setIsLocalProgram:(BOOL)isLocalProgram {
	_isLocalProgram = isLocalProgram;
	if (isLocalProgram) {
//		[self.downloadOrDeleteButton removeTarget:self action:@selector(downloadOrDeleteProgram:) forControlEvents:UIControlEventTouchDragInside];
		[self.downloadOrDeleteButton removeTarget:nil
						   action:NULL
				 forControlEvents:UIControlEventAllEvents];
	} else {
		[self.downloadOrDeleteButton addTarget:self action:@selector(downloadOrDeleteProgram:) forControlEvents:UIControlEventTouchUpInside];
	}
}

- (void)setIsAlreadyDownload:(BOOL)isAlreadyDownload {
	_isAlreadyDownload = isAlreadyDownload;
	if (self.isLocalProgram) {
		[self.downloadOrDeleteButton setImage:[UIImage imageNamed:@"arrow"] forState:UIControlStateNormal];
	} else {
		if (isAlreadyDownload) {
			[self.downloadOrDeleteButton setImage:[UIImage imageNamed:@"program_icon_delete"] forState:UIControlStateNormal];
			[self.downloadOrDeleteButton.currentImage setAccessibilityIdentifier:@"delete"];
		} else {
			[self.downloadOrDeleteButton setImage:[UIImage imageNamed:@"program_icon_download"] forState:UIControlStateNormal];
			[self.downloadOrDeleteButton.currentImage setAccessibilityIdentifier:@"download"];
		}
	}
}


#pragma mark - Download or delete program

- (void)downloadOrDeleteProgram:(UIButton *)button {
	
	if ([RTBleConnector shareManager].currentConnectedPeripheral == nil) {
		
		[[RTBleConnector shareManager] showConnectDialog];
		
	} else {
		
		if ([RTBleConnector shareManager].rtMassageChairStatus.deviceStatus != RtMassageChairStatusStandby) {
			[self showCannotInstallDialog];
			return;
		}
		
		if ([[button.currentImage accessibilityIdentifier] isEqualToString:@"download"]) {
			
			// 网络4个位都已经安装了程序, 提醒用户删除其中一个才可以安装
			if ([[RTBleConnector shareManager].rtNetworkProgramStatus getEmptySlotIndex] == -1) {
				
                [self showProgressHUDByString: @"安装的云养程序已达4个，请先删除其他的云养程序再进行下载"];

//				CustomIOSAlertView *tipsDialog = [[CustomIOSAlertView alloc] init];
//				tipsDialog.isReconnectDialog = YES;
//				tipsDialog.reconnectTipsString = @"安装的云养程序已达4个，请先删除其他的云养程序再进行下载";
//				[tipsDialog setButtonTitles:[NSMutableArray arrayWithObjects:NSLocalizedString(@"确定", nil), nil]];
//				
//				[tipsDialog show];
			} else {
				[[RTBleConnector shareManager] installProgramMassageByBinName:_massageProgram.binUrl];
			}
			
		} else {
			[[RTBleConnector shareManager] sendControlByBytes:[[RTBleConnector shareManager] deleteProgramMassage:[self.massageProgram.commandId integerValue]]];
			
			[NSThread sleepForTimeInterval:0.3f];
			
			[[RTBleConnector shareManager] sendControlByBytes:[[RTBleConnector shareManager] exitEditMode]];  // 退出编辑模式
		}
		
	}
}

#pragma mark - 显示按摩椅正在运行,不能安装对话框

- (void)showCannotInstallDialog {
	
	CustomIOSAlertView *dialog = [[CustomIOSAlertView alloc] init];
	dialog.isReconnectDialog = YES;
	
	dialog.reconnectTipsString = NSLocalizedString(@"非待机状态,不能操作", nil);
	[dialog setButtonTitles:[NSMutableArray arrayWithObjects:NSLocalizedString(@"确定", nil), nil]];
	
	[dialog show];
	
}

#pragma mark - 快速提示
-(void)showProgressHUDByString:(NSString*)message
{
    AppDelegate* delegate = [[UIApplication sharedApplication] delegate];
    UIWindow* win = delegate.window;
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:win animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.labelText = message;
    hud.margin = 10.f;
    hud.removeFromSuperViewOnHide = YES;
    [hud hide:YES afterDelay:0.7];
}

@end
