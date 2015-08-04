//
//  BasicViewController.h
//  rongtai
//
//  Created by William-zhang on 15/7/10.
//  Copyright (c) 2015年 William-zhang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RTBleConnector.h"

@interface BasicViewController : UIViewController <RTBleConnectorDelegate>

@property(nonatomic, assign) BOOL isListenBluetoothStatus;

- (void)backToMainViewController;

@end
