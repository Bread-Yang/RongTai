//
//  BaoSegmentedControl.m
//  rongtai
//
//  Created by yoghourt on 7/15/15.
//  Copyright (c) 2015 William-zhang. All rights reserved.
//

#import "BaoSegmentedControl.h"

@implementation BaoSegmentedControl

- (id)initWithItems:(NSArray *)items {
	self = [super initWithItems:items];
	
	if (self) {
		// Initialization code
		
		// Set divider images
//		[self setDividerImage:[UIImage imageNamed:@"mySegCtrl-divider-none-selected.png"]
//		  forLeftSegmentState:UIControlStateNormal
//			rightSegmentState:UIControlStateNormal
//				   barMetrics:UIBarMetricsDefault];
		[self setDividerImage:[UIImage imageNamed:@"user_edit_select"]
		  forLeftSegmentState:UIControlStateSelected
			rightSegmentState:UIControlStateNormal
				   barMetrics:UIBarMetricsDefault];
		[self setDividerImage:[UIImage imageNamed:@"user_edit_select_2"]
		  forLeftSegmentState:UIControlStateNormal
			rightSegmentState:UIControlStateSelected
				   barMetrics:UIBarMetricsDefault];
		
		// Set background images
		UIImage *normalBackgroundImage = [UIImage imageNamed:@"program_select3_2_2"];
		[self setBackgroundImage:normalBackgroundImage
						forState:UIControlStateNormal
					  barMetrics:UIBarMetricsDefault];
		UIImage *selectedBackgroundImage = [UIImage imageNamed:@"program_select3_2"];
		[self setBackgroundImage:selectedBackgroundImage
						forState:UIControlStateSelected
					  barMetrics:UIBarMetricsDefault];
	}
	return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
