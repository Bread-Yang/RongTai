//
//  ProgramDownloadTableViewCell.h
//  rongtai
//
//  Created by yoghourt on 8/11/15.
//  Copyright (c) 2015 William-zhang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProgramDownloadTableViewCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UIImageView *programImageView;
@property (nonatomic, weak) IBOutlet UILabel *programNameLabel;
@property (nonatomic, weak) IBOutlet UILabel *programDescriptionLabel;
@property (nonatomic, weak) IBOutlet UIButton *downloadOrDeleteButton;

@property (nonatomic, assign) NSInteger row;

@end
