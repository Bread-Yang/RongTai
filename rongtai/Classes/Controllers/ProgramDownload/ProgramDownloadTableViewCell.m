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
	
	// 图片
	UIImage *img = [UIImage imageInLocalByName:[NSString stringWithFormat:@"%@.jpg", massageProgram.imageUrl]];
	if (img) {			// 本地图片
		self.programImageView.image = img;
	} else {			// 网络图片
		NSURL *url = [NSURL URLWithString:[RongTaiFileDomain stringByAppendingString:massageProgram.imageUrl]];
		
		NSURLRequest *request = [NSURLRequest requestWithURL:url];
		UIImage *placeHolderImage = [UIImage imageNamed:@"placeholder"];
		
		__weak ProgramDownloadTableViewCell *weakCell = self;
		
		[self.programImageView setImageWithURLRequest:request placeholderImage:placeHolderImage success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
			
			weakCell.programImageView.image = image;
			[weakCell setNeedsLayout];
			[image saveImageByName:[NSString stringWithFormat:@"%@.jpg", weakCell.massageProgram.imageUrl]];
			
		} failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
			NSLog(@"请求失败");
		}];
	}
	
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

		[self downloadProgram:_massageProgram.binUrl];
		
	} else {
		[[RTBleConnector shareManager] sendControlByBytes:[[RTBleConnector shareManager] deleteProgramMassage:self.massageProgram.massageId]];
	}
}

- (void)downloadProgram:(NSString *)binName {
	
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
	NSString *binDir = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"bin"];
	NSString *binPath = [binDir stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.bin", binName]];
	
	// 文件夹不存在则创建
	[[NSFileManager defaultManager] createDirectoryAtPath:binDir withIntermediateDirectories:YES attributes:nil error:nil];
	
	// 在本地查看是否存在
	if ([[NSFileManager defaultManager] fileExistsAtPath:binPath]) {
		
		[[RTBleConnector shareManager] sendControlByBytes:[[RTBleConnector shareManager] InstallProgramMassage:self.massageProgram.binUrl]];
		
	} else {
		NSString *url = [RongTaiFileDomain stringByAppendingString:binName];
		
		NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:5];
		
		AFHTTPRequestOperation *afOperation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
		afOperation.outputStream = [NSOutputStream outputStreamToFileAtPath:binPath append:NO];  // 保存文件
		
		__weak ProgramDownloadTableViewCell *weakSelf = self;
		
		[afOperation setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
			
			weakSelf.progress = (double)totalBytesRead / totalBytesExpectedToRead;
			weakSelf.bytesProgress = [NSString stringWithFormat:@"%@/%@", [weakSelf formatByteCount:totalBytesRead], [weakSelf formatByteCount:totalBytesExpectedToRead]];
			
			NSLog(@"下载了多少 : %zd", weakSelf.progress);
		}];
		
		[afOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
			
			weakSelf.bytesTotal = [weakSelf formatByteCount:operation.response.expectedContentLength];
			weakSelf.isCompleted = YES;
			
			// 下载完后安装
			[[RTBleConnector shareManager] sendControlByBytes:[[RTBleConnector shareManager] InstallProgramMassage:self.massageProgram.binUrl]];
			
		} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
			
			weakSelf.error = error.localizedDescription;
			weakSelf.isCompleted = YES;
			
		}];
		
		[afOperation start];
	}
}

- (NSString*)formatByteCount:(long long)size {
	return [NSByteCountFormatter stringFromByteCount:size countStyle:NSByteCountFormatterCountStyleFile];
}

@end
