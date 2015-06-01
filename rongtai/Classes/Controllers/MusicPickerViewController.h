//
//  MusicPickerViewcontrollerViewController.h
//  rongtai
//
//  Created by yoghourt on 5/28/15.
//  Copyright (c) 2015 William-zhang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MusicPickerViewController : UIViewController<UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *musicTableView;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *backButton;

- (IBAction)backButtonAction:(id)sender;
@end
