//
//  UIImage+ImageBlur.h
//  rongtai
//
//  Created by William-zhang on 15/6/29.
//  Copyright (c) 2015年 William-zhang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (ImageBlur)

/**
 *  根据参数返回一张模糊照片
 */
-(UIImage*)blurImage:(CGFloat)blur;

@end
