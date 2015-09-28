//
//  ManualTableViewCell.m
//  rongtai
//
//  Created by William-zhang on 15/7/20.
//  Copyright (c) 2015年 William-zhang. All rights reserved.
//

#import "ManualTableViewCell.h"

@implementation ManualTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)leftButtonTouchDown:(id)sender {
	if ([self.delegate respondsToSelector:@selector(manualTableViewCell:Clicked:UIControlEvents:)]) {
		[self.delegate manualTableViewCell:self Clicked:0 UIControlEvents:UIControlEventTouchDown];
	}
}

- (IBAction)leftButtonTouchUpInside:(id)sender {
	if ([self.delegate respondsToSelector:@selector(manualTableViewCell:Clicked:UIControlEvents:)]) {
		[self.delegate manualTableViewCell:self Clicked:0 UIControlEvents:UIControlEventTouchUpInside];
	}
}

- (IBAction)leftButtonTouchUpOutside:(id)sender {
	if ([self.delegate respondsToSelector:@selector(manualTableViewCell:Clicked:UIControlEvents:)]) {
		[self.delegate manualTableViewCell:self Clicked:0 UIControlEvents:UIControlEventTouchUpOutside];
	}
}

- (IBAction)rightButtonTouchDown:(id)sender {
	if ([self.delegate respondsToSelector:@selector(manualTableViewCell:Clicked:UIControlEvents:)]) {
		[self.delegate manualTableViewCell:self Clicked:1 UIControlEvents:UIControlEventTouchDown];
	}
}

- (IBAction)rightButtonTouchUpInside:(id)sender {
	if ([self.delegate respondsToSelector:@selector(manualTableViewCell:Clicked:UIControlEvents:)]) {
		[self.delegate manualTableViewCell:self Clicked:1 UIControlEvents:UIControlEventTouchUpInside];
	}
}

- (IBAction)rightButtonTouchUpOutside:(id)sender {
	if ([self.delegate respondsToSelector:@selector(manualTableViewCell:Clicked:UIControlEvents:)]) {
		[self.delegate manualTableViewCell:self Clicked:1 UIControlEvents:UIControlEventTouchUpOutside];
	}
}

@end
