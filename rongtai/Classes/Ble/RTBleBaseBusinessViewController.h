//
//  RTBleBaseBusinessViewController.h
//  rongtai
//
//  Created by yoghourt on 6/29/15.
//  Copyright (c) 2015 William-zhang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RTBleConnector.h"

@interface RTBleBaseBusinessViewController : UIViewController

@property (nonatomic, strong) id<RTBleConnectorDelegate> delegate;

@end
