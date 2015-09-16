//
//  UseTimeViewController.h
//  rongtai
//
//  Created by William-zhang on 15/6/10.
//  Copyright (c) 2015年 William-zhang. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DataCenterViewController;

@interface UseTimeViewController : UIViewController

-(void)setTodayRecord:(NSArray *)todayRecord AndTodayUseTime:(NSInteger)useTime;


-(void)setWeekData:(NSArray*)weekRecords ByDataCenterVC:(DataCenterViewController*)dataCenterVC;
@end
