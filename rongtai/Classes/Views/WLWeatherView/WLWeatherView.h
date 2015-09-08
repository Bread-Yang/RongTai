//
//  WLWeatherView.h
//  WLWeatherView
//
//  Created by William-zhang on 15/6/24.
//  Copyright (c) 2015年 William-zhang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface WLWeatherView : UIView

@property(nonatomic, strong)CLLocationManager* lManager;

/**
 *  更新天气
 */
-(void)updateWeather;

/**
 *  更新天气 2.0
 */
-(void)updateWeather2;


/**
 *  停止更新天气
 */
-(void)cancelUpdate;

@end
