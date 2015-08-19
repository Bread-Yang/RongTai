//
//  BasicTableViewCell.m
//  rongtai
//
//  Created by William-zhang on 15/7/14.
//  Copyright (c) 2015年 William-zhang. All rights reserved.
//

#import "BasicTableViewCell.h"

@implementation BasicTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)layoutSubviews
{
    [super layoutSubviews];
//    NSLog(@"titleF:%@",NSStringFromCGRect(self.textLabel.frame));
	if (!self.hidden) {
		CGFloat h = CGRectGetHeight(self.frame);
		//    CGFloat w = CGRectGetWidth(self.frame);
		CGRect f = self.imageView.frame;
		f.size.height = self.imageViewScale*h;
		f.size.width = self.imageViewScale*h;
		f.origin.y = (1-self.imageViewScale)*h/2;
		self.imageView.frame = f;
		
		//
		f = self.textLabel.frame;
		f.origin.x = self.imageView.frame.origin.x+self.imageView.frame.size.width+10;
		self.textLabel.frame = f;
		
		//    self.detailTextLabel.backgroundColor = [UIColor blueColor];
		f = self.detailTextLabel.frame;
		f.size.width *= 0.85;
		f.size.height = h*0.3;
		self.detailTextLabel.frame = f;
	}
}

@end
