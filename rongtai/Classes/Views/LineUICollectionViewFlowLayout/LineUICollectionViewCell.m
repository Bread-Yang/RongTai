//
//  AddTimingMassageViewController.h
//  rongtai
//
//  Created by yoghourt on 6/10/15.
//  Copyright (c) 2015 William-zhang. All rights reserved.
//

#import "LineUICollectionViewCell.h"

@implementation LineUICollectionViewCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.label = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, frame.size.width, frame.size.height)];
		self.label.layer.cornerRadius = frame.size.width / 2;
		self.label.clipsToBounds = YES;
        self.label.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
        self.label.textAlignment = NSTextAlignmentCenter;
        self.label.font = [UIFont boldSystemFontOfSize:15.0];
		self.label.numberOfLines = 2;
		self.label.textAlignment = NSTextAlignmentCenter;
//        self.label.backgroundColor = [UIColor underPageBackgroundColor];
		self.label.layer.borderColor = [UIColor blackColor].CGColor;
		self.label.layer.borderWidth = 1.0;
        self.label.textColor = [UIColor blackColor];
        [self.contentView addSubview:self.label];;
    }
    return self;
}

@end
