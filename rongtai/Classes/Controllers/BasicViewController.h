//
//  BasicViewController.h
//  rongtai
//
//  Created by William-zhang on 15/7/10.
//  Copyright (c) 2015年 William-zhang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RTBleConnector.h"
#import "CustomIOSAlertView.h"

@interface BasicViewController : UIViewController <RTBleConnectorDelegate>

@property (nonatomic, assign) BOOL isListenBluetoothStatus;

@property (nonatomic, retain) CustomIOSAlertView *resettingDialog;

- (void)backToMainViewController;

- (void)jumpToAutoMassageViewConroller;

- (void)jumpToScanViewConroller;

- (void)jumpToManualMassageViewConroller;

- (void)jumpToFinishMassageViewConroller;

@end
