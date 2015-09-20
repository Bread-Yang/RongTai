//
//  DoughnutViewController.h
//  rongtai
//
//  Created by William-zhang on 15/6/11.
//  Copyright (c) 2015年 William-zhang. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DataCenterViewController;

@interface DoughnutViewController : UIViewController

@property(nonatomic, strong)NSArray* progarmCounts;

-(void)requestData:(DataCenterViewController*)vc;

@end
