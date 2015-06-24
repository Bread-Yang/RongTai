//
//  WLWeatherView.m
//  WLWeatherView
//
//  Created by William-zhang on 15/6/24.
//  Copyright (c) 2015年 William-zhang. All rights reserved.
//

#import "WLWeatherView.h"
#import "MBProgressHUD.h"


@interface WLWeatherView ()<NSURLConnectionDataDelegate, NSXMLParserDelegate, CLLocationManagerDelegate>
{
    UIImageView* _icon;  //天气图像
    UILabel* _temperature;  //温度
    UILabel* _o;          //符号o
    UILabel* _aqi;        //空气污染情况
    NSString* _city;
    MBProgressHUD* _hud;
}
@end

@implementation WLWeatherView

-(instancetype)init
{
    if (self = [super init]) {
        [self setUp];
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        [self setUp];
    }
    return self;
}

-(instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self setUp];
        [self setSubviewFrame];
    }
    return self;
}

-(void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    [self setSubviewFrame];
}

#pragma mark - 初始化
-(void)setUp
{
    _icon = [[UIImageView alloc]init];
    _icon.contentMode = UIViewContentModeScaleAspectFit;
    _temperature = [self newLabel];
    _o = [self newLabel];
//    _o.backgroundColor = [UIColor cyanColor];
    _o.text = @"o";
    _o.font = [UIFont systemFontOfSize:10];
    _aqi = [self newLabel];
    [self addSubview:_icon];
    [self addSubview:_temperature];
    [self addSubview:_o];
    [self addSubview:_aqi];
    
    //
    _icon.image = [UIImage imageNamed:@"mini-sun"];
    _temperature.text = @"29";
    _aqi.text = @"广州  轻度污染";
    
    _city = @"广州";
    [self locationCity];
    
    //
    _hud = [[MBProgressHUD alloc]initWithWindow:[UIApplication sharedApplication].keyWindow];
    [[UIApplication sharedApplication].keyWindow addSubview:_hud];
    _hud.mode = MBProgressHUDModeText;
}

#pragma mark - 元素大小设置
-(void)setSubviewFrame
{
    CGFloat w = self.frame.size.width;
    CGFloat h = self.frame.size.height;
    CGFloat hscale = 0.7;
   
    _icon.frame = CGRectMake(w*(1-0.6), 0, w*0.25, h*hscale);
    _temperature.frame = CGRectMake(w*(1-0.35), 0, w*0.25, h*hscale);
    _o.frame = CGRectMake(w*(1-0.13), h*0.14, w*0.1, w*0.1);
    _aqi.frame = CGRectMake(w*0.2, h*(hscale-0.1), w*0.8, h*(1-hscale));
}

#pragma mark - 更新天气
-(void)updateWeather
{
    NSString* str = [NSString stringWithFormat:@"http://wthrcdn.etouch.cn/weather_mini?city=%@",_city];
    str = [str stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSURL* url = [NSURL URLWithString:str];
    NSURLRequest* request = [[NSURLRequest alloc]initWithURL:url];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (connectionError) {
            NSLog(@"请求出错:%@",connectionError);
        }
        else
        {
            NSLog(@"data:%@",[[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding]);
            NSError* error;
            NSDictionary* dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
            if (error) {
                NSLog(@"解析出错:%@",error);
            }
            else
            {
                NSDictionary* data = [dic objectForKey:@"data"];
                if (data) {
                    //更新温度
                    _temperature.text = [data objectForKey:@"wendu"];
                    
                    //更新天气图标
                    NSArray* arr = [data objectForKey:@"forecast"];
                    NSDictionary* today = arr[0];
                    [self updateWeatherIconByName:[today objectForKey:@"type"]];
                    
                    //更新城市空气情况
                    CGFloat aqi = [[data objectForKey:@"aqi"] floatValue];
                    NSString* city;
                    if (aqi == 0) {
                        //有些城市并没有提供aqi指数，此时读到的数值为0,此时数据改为显示风向
                        city = [NSString stringWithFormat:@"%@  %@",_city,[today objectForKey:@"fengxiang"]];
                    }
                    else
                    {
                        city = [NSString stringWithFormat:@"%@  %@",_city,[self aqiNameByFloat:aqi]];
                    }
                    _aqi.text = city;

                }
                else
                {
                    NSLog(@"当前城市未提供天气服务");
                    [self setDefaultCity:@"当前城市未提供天气服务"];
                }
             }
        }

    }];
}

#pragma mark - 城市定位
-(void)locationCity
{
    
    if ([CLLocationManager locationServicesEnabled]) {
        NSLog(@"开始定位");
        self.lManager = [[CLLocationManager alloc]init];
        self.lManager.delegate = self;
        self.lManager.desiredAccuracy = kCLLocationAccuracyBest;
        self.lManager.distanceFilter = kCLDistanceFilterNone;
        [self.lManager requestAlwaysAuthorization];
        [self.lManager requestWhenInUseAuthorization];
        [self.lManager startUpdatingLocation];
    }
    else
    {
        NSLog(@"定位服务不被允许");
    }
}

#pragma mark - 定位代理
-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    NSLog(@"定位结束");
    CLLocation *currLocation = [locations lastObject];
    NSLog(@"经度=%f 纬度=%f 高度=%f", currLocation.coordinate.latitude, currLocation.coordinate.longitude, currLocation.altitude);
    
    // 获取当前所在的城市名
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    
    //根据经纬度反向地理编译出地址信息
    [geocoder reverseGeocodeLocation:currLocation completionHandler:^(NSArray *array, NSError *error)
    {
        if (array.count > 0)
        {
            CLPlacemark *placemark = [array objectAtIndex:0];
            NSLog(@"%@",placemark.name);
            //获取城市
            NSString *city = placemark.locality;
            if (!city) {
                //四大直辖市的城市信息无法通过locality获得，只能通过获取省份的方法来获得（如果city为空，则可知为直辖市）
                city = placemark.administrativeArea;
            }
            NSLog(@"City:%@",city);
            if ([self subString:@"市" InString:city]) {
                city = [city substringWithRange:NSMakeRange(0, city.length-1)];
            }
            _city = city;
//            _city = @"香港";
            [self updateWeather];
        }
        else if (error == nil && [array count] == 0)
        {
            NSLog(@"查询不到结果");
            [self setDefaultCity: @"查询不到当前城市"];
        }
        else if (error != nil)
        {
            NSLog(@"查询错误:%@", error);
            [self setDefaultCity:@"查询出错"];
        }
    }];
    
    [manager stopUpdatingLocation];
}

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    if ([error code] == kCLErrorDenied)
    {
        NSLog(@"访问被拒绝");
    }
    if ([error code] == kCLErrorLocationUnknown) {
        NSLog(@"无法获取位置信息");
    }
}

#pragma mark - 错误时调用默认城市
-(void)setDefaultCity:(NSString*)error
{
    _hud.labelText = [NSString stringWithFormat:@"%@，自动切换城市",error];
    [_hud show:YES];
    [_hud hide:YES afterDelay:0.7];
    _city = @"广州";
    [self updateWeather];
}

#pragma mark - 根据数字返回污染指数
-(NSString*)aqiNameByFloat:(CGFloat)aqi
{
    if (aqi<=50) {
        return @"空气优";
    }
    else if (aqi<=100)
    {
        return @"空气良";
    }
    else if (aqi<=150)
    {
        return @"轻微污染";
    }
    else if (aqi<=200)
    {
        return @"轻度污染";
    }
    else if (aqi<=250)
    {
        return @"中度污染";
    }
    else if(aqi<=300)
    {
        return @"中度重污染";
    }
    else
    {
        return @"重污染";
    }
}

#pragma mark - 根据天气情况改变图标
-(void)updateWeatherIconByName:(NSString*)name
{
    if ([self subString:@"雹" InString:name]) {
        _icon.image = [UIImage imageNamed:@"mini-hail"];
        return;
    }
    if ([self subString:@"雨" InString:name]) {
        if ([self subString:@"雪" InString:name]) {
            _icon.image = [UIImage imageNamed:@"mini-snowrain"];
            return;
        }
        if ([self subString:@"雷" InString:name]) {
            if ([self subString:@"晴" InString:name]) {
                _icon.image = [UIImage imageNamed:@"mini-sunlightningrain"];
                return;
            }
            _icon.image = [UIImage imageNamed:@"mini-lightningrain"];
            return;
        }
        if ([self subString:@"晴" InString:name]) {
            _icon.image = [UIImage imageNamed:@"mini-sunrain"];
            return;
        }
        _icon.image = [UIImage imageNamed:@"mini-rain"];
        return;
    }
    if ([self subString:@"雪" InString:name]) {
        _icon.image = [UIImage imageNamed:@"mini-snow"];
        return;
    }
    if ([self subString:@"雷" InString:name]) {
        _icon.image = [UIImage imageNamed:@"mini-lightning"];
        return;
    }
    if ([self subString:@"雾" InString:name]) {
        if ([self subString:@"晴" InString:name]) {
            _icon.image = [UIImage imageNamed:@"mini-sunhaze"];
            return;
        }
        _icon.image = [UIImage imageNamed:@"mini-fog"];
        return;
    }
    if ([self subString:@"多云" InString:name]) {
        if ([self subString:@"晴" InString:name]) {
            _icon.image = [UIImage imageNamed:@"mini-suncloud"];
            return;
        }
        _icon.image = [UIImage imageNamed:@"mini-clouds"];
        return;
    }
    _icon.image = [UIImage imageNamed:@"mini-sun"];
    
    
}

-(BOOL)subString:(NSString*)subString InString:(NSString*)string
{
    NSRange r = [string rangeOfString:subString];
    if (r.length>0) {
        return YES;
    }
    return NO;
}

#pragma mark - 生成一个UILabel
-(UILabel*)newLabel
{
    UILabel* l = [[UILabel alloc]init];
    l.textAlignment = NSTextAlignmentCenter;
    l.adjustsFontSizeToFitWidth = YES;
    l.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
    return l;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
