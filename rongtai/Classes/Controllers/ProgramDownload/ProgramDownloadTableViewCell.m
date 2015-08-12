//
//  ProgramDownloadTableViewCell.m
//  rongtai
//
//  Created by yoghourt on 8/11/15.
//  Copyright (c) 2015 William-zhang. All rights reserved.
//

#import "ProgramDownloadTableViewCell.h"
#import "RTBleConnector.h"

@implementation ProgramDownloadTableViewCell

- (void)awakeFromNib {
	
	[self.downloadOrDeleteButton.currentImage setAccessibilityIdentifier:@"download"];
	
	[self.downloadOrDeleteButton addTarget:self action:@selector(downloadOrDeleteProgram:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark - Download or delete program

- (void)downloadOrDeleteProgram:(UIButton *)button {
	
	if ([[button.currentImage accessibilityIdentifier] isEqualToString:@"download"]) {
		[button setImage:[UIImage imageNamed:@"program_icon_delete"] forState:UIControlStateNormal];
		[button.currentImage setAccessibilityIdentifier:@"delete"];
		
		[[RTBleConnector shareManager] sendControlByBytes:[[RTBleConnector shareManager] controlInstallMassage:self.row]];
	} else {
		[button setImage:[UIImage imageNamed:@"program_icon_download"] forState:UIControlStateNormal];
		
		[button.currentImage setAccessibilityIdentifier:@"download"];
		
		[[RTBleConnector shareManager] sendControlByBytes:[[RTBleConnector shareManager] deleteMassage:self.row]];
	}
}

@end
