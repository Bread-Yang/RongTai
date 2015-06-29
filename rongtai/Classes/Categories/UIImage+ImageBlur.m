//
//  UIImage+ImageBlur.m
//  rongtai
//
//  Created by William-zhang on 15/6/29.
//  Copyright (c) 2015年 William-zhang. All rights reserved.
//

#import "UIImage+ImageBlur.h"

@implementation UIImage (ImageBlur)

#pragma mark - 根据参数返回一张模糊照片
-(UIImage*)blurImage:(CGFloat)blur
{
    CIContext* context = [CIContext contextWithOptions:nil];
    CIImage* old = [CIImage imageWithCGImage:self.CGImage];
    CIFilter* filter = [CIFilter filterWithName:@"CIGaussianBlur"];
    [filter setValue:old forKey:kCIInputImageKey];
    [filter setValue:[NSNumber numberWithFloat:blur] forKey:@"inputRadius"];
    CIImage* output = [filter valueForKey:kCIOutputImageKey];
    CGRect r = [output extent];
    r.origin.x += 4*blur;
    r.origin.y += 4*blur;
    r.size.width  -= 8*blur;
    r.size.height -= 8*blur;
    NSLog(@"rect:%@",NSStringFromCGRect(r));

    CGImageRef ref  = [context createCGImage:output fromRect:r];
    UIImage* new = [UIImage imageWithCGImage:ref];
    CGImageRelease(ref);
    return new;
}

@end
