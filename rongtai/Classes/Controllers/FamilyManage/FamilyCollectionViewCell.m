//
//  FamilyCollectionViewCell.m
//  rongtai
//
//  Created by William-zhang on 15/6/12.
//  Copyright (c) 2015年 William-zhang. All rights reserved.
//

#import "FamilyCollectionViewCell.h"
#import "UIImageView+AFNetworking.h"
#import "NSString+RT.h"

#import "RongTaiConstant.h"

@interface FamilyCollectionViewCell () {
	
}
@end

@implementation FamilyCollectionViewCell


-(instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setUp];
    }
    return self;
}

#pragma mark - 初始化

- (void)setUp {
    CGFloat w = self.frame.size.width;
    CGFloat h = self.frame.size.height;
    self.layer.borderColor = [UIColor colorWithRed:116/255.0 green:154/255.0 blue:180/255.0 alpha:0.3].CGColor;
    self.layer.borderWidth = 1;
    self.layer.cornerRadius = 3;
//    self.layer.shadowColor = [UIColor blackColor].CGColor;
//    self.layer.shadowOpacity = 1;
//    self.layer.shadowRadius = 4;
//    self.layer.shadowOffset = CGSizeMake(4, 4);
//    self.clipsToBounds = YES;
    
//    UILabel* add = [[UILabel alloc]initWithFrame:CGRectMake(0.1*w, 0.4*h, 0.8*w, 0.2*h)];
//    add.textAlignment = NSTextAlignmentCenter;
//    add.adjustsFontSizeToFitWidth = YES;
//    add.text = @"+ 添加成员";
//    add.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
//    [self.contentView addSubview:add];
    
    UIView* bg = [[UIView alloc]initWithFrame:self.bounds];
    bg.backgroundColor = [UIColor clearColor];
    bg.layer.borderColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.7].CGColor;
    bg.layer.borderWidth = 2;
    bg.layer.cornerRadius = 3;
    [self addSubview:bg];
    
    CGRect f = self.frame;
    f.size.width *= 0.8;
    f.size.height = f.size.width;
    f.origin.x = 0.1*self.frame.size.width;
    f.origin.y = 0.1*self.frame.size.height;
    _userIconView = [[UIImageView alloc]initWithFrame:f];
    _userIconView.backgroundColor = [UIColor greenColor];
    _userIconView.clipsToBounds = YES;
    _userIconView.layer.cornerRadius = f.size.width/2;
    _userIconView.layer.borderColor = [UIColor whiteColor].CGColor;
    _userIconView.layer.borderWidth = 2;
    _userIconView.layer.shadowColor = [UIColor blackColor].CGColor;
    _userIconView.layer.shadowOpacity = 2;
    [self.contentView addSubview:_userIconView];
    
    _userNameLabel = [[UILabel alloc]initWithFrame:CGRectMake(0.25*w, 0.75*h, 0.5*w, 0.2*h)];
    _userNameLabel.textAlignment = NSTextAlignmentCenter;
    _userNameLabel.adjustsFontSizeToFitWidth = YES;
    _userNameLabel.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
    _userNameLabel.textColor = [UIColor blackColor];
    [self.contentView addSubview:_userNameLabel];
    
}

#pragma mark - set方法


-(void)setMember:(Member *)member {
    _member = member;
    if (_member.imageURL.length<1) {
        //空的用默认头像
        _userIconView.image = [UIImage imageNamed:@"userIcon.jpg"];
    }
    else
    {
        //先使用本地图片，若本地读不到图片则使用网络请求
        
        
        //网络请求
        if (![NSString isBlankString:member.imageURL]) {
            NSURL *url = [NSURL URLWithString:member.imageURL];
            NSURLRequest *request = [NSURLRequest requestWithURL:url];
            UIImage *placeholderImage = [UIImage imageNamed:@"placeholder"];
            
            __weak FamilyCollectionViewCell *weakCell = self;
            
            [_userIconView setImageWithURLRequest:request
                                 placeholderImage:placeholderImage
                                          success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                              weakCell.userIconView.image = image;
                                              [weakCell setNeedsLayout];
                                              
                                          } failure:nil];
        }
        
    }
	_userNameLabel.text = member.name;
	

}

@end
