//
//  UIImageView.m
//  rongtai
//
//  Created by yoghourt on 9/2/15.
//  Copyright (c) 2015 William-zhang. All rights reserved.
//

#import "UIImageView+RT.h"
#import "UIImage+ImageBlur.h"
#import "RongTaiConstant.h"
#import "UIImageView+AFNetworking.h"

@implementation UIImageView (ImageBlur)

+ (void)loadImageByURL:(NSString *)imageURL imageView:(UIImageView *)imageView {
	// 图片
	UIImage *img = [UIImage imageInLocalByName:[NSString stringWithFormat:@"%@.jpg", imageURL]];
	if (img) {			// 本地图片
		imageView.image = img;
	} else {			// 网络图片
		NSURL *url = [NSURL URLWithString:[RongTaiFileDomain stringByAppendingString:imageURL]];
		
		NSURLRequest *request = [NSURLRequest requestWithURL:url];
		UIImage *placeHolderImage = [UIImage imageNamed:@"placeholder"];
		
		__weak UIImageView *weakImage = imageView;
		
		[imageView setImageWithURLRequest:request placeholderImage:placeHolderImage success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
			
			weakImage.image = image;
			
		} failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
			NSLog(@"请求失败");
		}];
	}
}

@end
