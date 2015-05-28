//
//  MusicPickerViewcontrollerViewController.h
//  rongtai
//
//  Created by yoghourt on 5/28/15.
//  Copyright (c) 2015 William-zhang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MusicPickerViewcontrollerViewController : UIViewController<UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *musicTableView;


@end
