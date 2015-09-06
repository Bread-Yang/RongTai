//
//  UIImageView.h
//  rongtai
//
//  Created by yoghourt on 9/2/15.
//  Copyright (c) 2015 William-zhang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImageView (ImageBlur)

/**
 *	先在本地看有没有缓存,没有再从网上拉
 */
+ (void)loadImageByURL:(NSString *)imageURL imageView:(UIImageView *)imageView;

@end
