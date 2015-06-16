//
//  CircleButton.m
//  rongtai
//
//  Created by yoghourt on 6/16/15.
//  Copyright (c) 2015 William-zhang. All rights reserved.
//

#import "CircleButton.h"

@implementation CircleButton {
	NSMutableDictionary *colours;
}

- (id)initWithCoder:(NSCoder *)decoder {
	self = [super initWithCoder:decoder];
	if (self) {
		[self initCircleButton];
	}
	return self;
}

- (id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	if (self) {
		[self initCircleButton];
	}
	return self;
}

- (void)initCircleButton {
	self.layer.cornerRadius = self.frame.size.height / 2;
	self.backgroundColor = [UIColor whiteColor];
	
	if(!colours) {
		colours = [NSMutableDictionary new];  // The dictionary is used to store the colour, the key is a text version of the ENUM
		colours[[NSString stringWithFormat:@"%lu", UIControlStateNormal]] = (UIColor*) self.backgroundColor;  // Store the original background colour
	}
}

-(void)setBackgroundColor:(UIColor *)backgroundColor forState:(UIControlState)state {
	// If it is normal then set the standard background here
	if(state & UIControlStateNormal) {
		[super setBackgroundColor:backgroundColor];
	}
	
	// Store the background colour for that state
	colours[[NSString stringWithFormat:@"%lu", state]] = backgroundColor;
}

-(void)setHighlighted:(BOOL)highlighted {
	// Do original Highlight
	[super setHighlighted:highlighted];
	
	// Highlight with new colour OR replace with orignial
	if (highlighted && colours[[NSString stringWithFormat:@"%lu", UIControlStateHighlighted]])
	{
		self.backgroundColor = colours[[NSString stringWithFormat:@"%lu", UIControlStateHighlighted]];
	}
	else
	{
		self.backgroundColor = colours[[NSString stringWithFormat:@"%lu", UIControlStateNormal]];
	}
}

-(void)setSelected:(BOOL)selected {
	// Do original Selected
	[super setSelected:selected];
	
	// Select with new colour OR replace with orignial
	if (selected && colours[[NSString stringWithFormat:@"%lu", UIControlStateSelected]])
	{
		self.backgroundColor = colours[[NSString stringWithFormat:@"%lu", UIControlStateSelected]];
	}
	else
	{
		self.backgroundColor = colours[[NSString stringWithFormat:@"%lu", UIControlStateNormal]];
	}
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
