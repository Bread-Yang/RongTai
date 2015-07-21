//
//  LineLabel.h
//  rongtai
//
//  Created by William-zhang on 15/7/21.
//  Copyright (c) 2015年 William-zhang. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, LineLabelType) {
    LineLeftLabel = 0,
    LineRightLabel,
};


@interface LineLabel : UIView

@property(nonatomic, readonly)UILabel* titleLabel;

@property(nonatomic, readonly)UIView* line;

@property(nonatomic, strong)UIColor* selectedColor;

@property(nonatomic, strong)UIColor* unselectedColor;

@property(nonatomic, strong)NSString* title;

@property(nonatomic, assign)LineLabelType labelType;

@property(nonatomic)BOOL isSelected;

@property(nonatomic, strong)UIFont* font;

@end
