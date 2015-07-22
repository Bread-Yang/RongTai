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

- (IBAction)leftButtonClicked:(id)sender {
    if ([self.delegate respondsToSelector:@selector(manualTableViewCell:Clicked:)]) {
        [self.delegate manualTableViewCell:self Clicked:0];
    }
}


- (IBAction)rightButtonClicked:(id)sender {
    if ([self.delegate respondsToSelector:@selector(manualTableViewCell:Clicked:)]) {
        [self.delegate manualTableViewCell:self Clicked:1];
    }
}

@end
