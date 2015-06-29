//
//  ViewController.h
//  BLETool
//
//  Created by Jaben on 14-12-23.
//  Copyright (c) 2014年 Jaben. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RTBleListViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *bleTurnOnTipsLabel;

@property (weak, nonatomic) IBOutlet UIImageView *bleImageView;

@property (weak, nonatomic) IBOutlet UITableView *periphralTableView;

@end

