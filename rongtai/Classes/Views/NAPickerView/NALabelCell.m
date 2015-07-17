//
//  NALabelCell.m
//  NAPickerView
//
//  Created by iNghia on 8/5/13.
//  Copyright (c) 2013 nghialv. All rights reserved.
//

#import "NALabelCell.h"

@implementation NALabelCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier cellWidth:(CGFloat)cellWidth
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.textView = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, cellWidth, 40)];
		self.textView.backgroundColor = [UIColor clearColor];
        [self addSubview:self.textView];
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

+ (CGFloat)cellHeight
{
    return 40.f;
}

@end
