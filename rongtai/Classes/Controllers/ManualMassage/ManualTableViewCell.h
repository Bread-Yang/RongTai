//
//  ManualTableViewCell.h
//  rongtai
//
//  Created by William-zhang on 15/7/20.
//  Copyright (c) 2015年 William-zhang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ManualTableViewCell : UITableViewCell


@property (weak, nonatomic) IBOutlet UILabel *titleLabel;


@property (weak, nonatomic) IBOutlet UIButton *leftButton;

@property (weak, nonatomic) IBOutlet UIButton *rightButton;

@end
