//
//  MainViewController.m
//  rongtai
//
//  Created by William-zhang on 15/6/8.
//  Copyright (c) 2015年 William-zhang. All rights reserved.
//

#import "MainViewController.h"
#import "SlideNavigationController.h"
#import "MassageProgramRequest.h"
#import "WLWeatherView.h"
#import "MenuViewController.h"
#import "CustomProcedureViewController.h"
#import "ProgramDownloadViewController.h"
#import "ManualViewController.h"
#import "BasicTableViewCell.h"
#import "RongTaiConstant.h"
#import "ScanViewController.h"
#import "RTCommand.h"
#import "RTBleConnector.h"
#import "AutoMassageViewController.h"
#import "CustomIOSAlertView.h"
#import "ProgramCount.h"
#import "CoreData+MagicalRecord.h"
#import "UIImage+ImageBlur.h"
#import "UIImageView+AFNetworking.h"
#import "MemberRequest.h"
#import "TimingPlan.h"
#import "TimingPlanRequest.h"
#import "UIImageView+RT.h"

#import "ProgramCount.h"
#import "MBProgressHUD.h"


@interface MainViewController ()<SlideNavigationControllerDelegate,UITableViewDataSource, UITableViewDelegate, UITabBarDelegate, MenuViewControllerDelegate, UIGestureRecognizerDelegate>
{
    UITableView* _table;
    NSMutableArray *_massageArr;
	NSMutableDictionary *_networkMassageDic;
    MassageProgramRequest* _networkMassageProgramRequest;
	NSArray *_modeNameArray;
	NSArray *_modeDescriptionArray;
    WLWeatherView* _weatherView;
    UITabBar* _menuBar;
	CustomIOSAlertView *reconnectDialog;
	UIButton *anionButton, *manualMassageButton, *customProgramButton, *downloadButton;
    NSUInteger _vcCount;
    UIBarButtonItem* _leftBtn;
    NSString* _userImageUrl; //导航栏左边按钮，即用户头像的链接
    UIImageView* imView;
    NSString* _uid;
}
@end

@implementation MainViewController

#pragma mark - Life Cycle

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
    SlideNavigationController* slideNav = (SlideNavigationController *)self.navigationController;
    slideNav.enableSwipeGesture = YES;
    if (_menuBar) {
        _menuBar.selectedItem = nil;
    }
	
	[_table reloadData];
    
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSString* mid = [defaults objectForKey:@"currentMemberId"];
    NSArray* arr = [Member MR_findAllWithPredicate:[NSPredicate predicateWithFormat:@"(uid = %@) AND (memberId == %@)",_uid, mid]];
    if (arr.count > 0) {
        Member* m = arr[0];
        [self changeUser:m.imageURL];
        NSLog(@"有用户:%@",m.name);
    }
    else
    {
        NSLog(@"找不到用户");
        [self changeUser:nil];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];

	self.isListenBluetoothStatus = YES;
    self.navigationController.interactivePopGestureRecognizer.delegate = self;
    _vcCount = self.navigationController.viewControllers.count;
//     NSLog(@"VC:%ld",_vcCount);
	
    self.title = NSLocalizedString(@"荣泰", nil);
    self.navigationController.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName];
    //
    SlideNavigationController* slideNav = (SlideNavigationController *)self.navigationController;
    MenuViewController* menu = (MenuViewController*)slideNav.leftMenu;
    menu.delegate = self;
    
    //
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    _uid = [defaults objectForKey:@"uid"];
    
    //天气预报
    NSNumber* loadWeather = [defaults valueForKey:@"weather"];
    if ([loadWeather boolValue]) {
        _weatherView = [[WLWeatherView alloc]initWithFrame:CGRectMake(0, 0, 90, 44)];
        UIBarButtonItem* right = [[UIBarButtonItem alloc]initWithCustomView:_weatherView];
        self.navigationItem.rightBarButtonItem  = right;
    }
    
    //菜单按钮
    _leftBtn = [[UIBarButtonItem alloc]initWithTitle:nil style:UIBarButtonItemStylePlain target:self action:@selector(slideMenuAppear:)];
    UIButton* image = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 34, 34)];
    [image setImage:[UIImage imageNamed:@"userIcon"] forState:UIControlStateNormal];
    [image addTarget:self action:@selector(slideMenuAppear:) forControlEvents:UIControlEventTouchUpInside];
    image.layer.cornerRadius = 17;
    _leftBtn.customView = image;
    image.clipsToBounds = YES;
    slideNav.leftBarButtonItem = _leftBtn;
    
    //侧滑菜单
    slideNav.view.layer.shadowColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.35].CGColor;
    slideNav.view.layer.shadowOffset = CGSizeMake(-0.5, 0);
    slideNav.view.layer.shadowOpacity  = 5;
    slideNav.view.layer.shadowRadius = 10;
    

    _table = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHT-49-64) style:UITableViewStylePlain];
    _table.dataSource = self;
    _table.delegate = self;
    _table.backgroundColor = [UIColor clearColor];
    _table.separatorStyle = UITableViewCellSeparatorStyleNone;
    _table.showsHorizontalScrollIndicator = NO;
    _table.showsVerticalScrollIndicator = NO;
    [self.view addSubview:_table];
	
	_modeNameArray = @[NSLocalizedString(@"运动恢复", nil),
					   NSLocalizedString(@"舒展活络", nil),
					   NSLocalizedString(@"休憩促眠", nil),
					   NSLocalizedString(@"工作减压", nil),
					   NSLocalizedString(@"肩颈重点", nil),
					   NSLocalizedString(@"腰椎舒缓", nil),
					   NSLocalizedString(@"云养程序一", nil),
					   NSLocalizedString(@"云养程序二", nil),
					   NSLocalizedString(@"云养程序三", nil),
					   NSLocalizedString(@"云养程序四", nil),];
	
	_modeDescriptionArray = @[NSLocalizedString(@"运动恢复简介", nil),
							  NSLocalizedString(@"舒展活络简介", nil),
							  NSLocalizedString(@"休憩促眠简介", nil),
							  NSLocalizedString(@"工作减压简介", nil),
							  NSLocalizedString(@"肩颈重点简介", nil),
							  NSLocalizedString(@"腰椎舒缓简介", nil),
							  NSLocalizedString(@"腰椎舒缓简介", nil),
							  NSLocalizedString(@"腰椎舒缓简介", nil),
							  NSLocalizedString(@"腰椎舒缓简介", nil),
							  NSLocalizedString(@"腰椎舒缓简介", nil),];
	
	_massageArr = [NSMutableArray new];
	for (int i = 0; i < [_modeNameArray count]; i++) {
		MassageProgram *m = [MassageProgram MR_createEntity];
		m.name = _modeNameArray[i];
		m.mDescription = _modeDescriptionArray[i];
		m.imageUrl = [NSString stringWithFormat:@"mode_%d",i + 1];
		m.isLocalDummyData = @YES;
		[_massageArr addObject:m];
	}
	
    // 获取网络按摩程序列表, 并保存在本地,如果获取失败,使用本地的
	[self requestNetworkMassageProgram];

    _menuBar = [[UITabBar alloc]initWithFrame:CGRectMake(0, SCREENHEIGHT-64-49, SCREENWIDTH, 49)];
    _menuBar.barTintColor = [UIColor colorWithRed:48/255.0 green:65/255.0 blue:77/255.0 alpha:1.0];
    _menuBar.translucent = NO;
    [_menuBar setBackgroundColor:[UIColor colorWithRed:48/255.0 green:65/255.0 blue:77/255.0 alpha:1.0]];
    _menuBar.tintColor = [UIColor whiteColor];
    UITabBarItem* item1 = [[UITabBarItem alloc]initWithTitle:NSLocalizedString(@"负离子", nil) image:[UIImage imageNamed:@"icon_set"] tag:0];
    UITabBarItem* item2 = [[UITabBarItem alloc]initWithTitle:NSLocalizedString(@"手动", nil) image:[UIImage imageNamed:@"icon_hand"] tag:1];
    UITabBarItem* item3 = [[UITabBarItem alloc]initWithTitle:NSLocalizedString(@"自定义", nil) image:[UIImage imageNamed:@"icon_user"] tag:2];
    UITabBarItem* item4 = [[UITabBarItem alloc]initWithTitle:NSLocalizedString(@"下载", nil) image:[UIImage imageNamed:@"icon_download"] tag:3];
    _menuBar.items = @[item1,item2,item3,item4];
    _menuBar.selectedItem = item1;
    _menuBar.delegate = self;
    [self.view addSubview:_menuBar];
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
	
	reconnectDialog = [[CustomIOSAlertView alloc] init];
	reconnectDialog.isReconnectDialog = YES;
	
	reconnectDialog.reconnectTipsString = NSLocalizedString(@"未连接设备", nil);
	[reconnectDialog setButtonTitles:[NSMutableArray arrayWithObjects:NSLocalizedString(@"重新连接", nil), nil]];
	
	__weak UIViewController *weakSelf = self;
	[reconnectDialog setOnButtonTouchUpInside:^(CustomIOSAlertView *alertView, int buttonIndex) {
		UIStoryboard *secondStoryBoard = [UIStoryboard storyboardWithName:@"Second" bundle:[NSBundle mainBundle]];
		UIViewController *viewController = [secondStoryBoard instantiateViewControllerWithIdentifier:@"ScanVC"];
		[weakSelf.navigationController pushViewController:viewController animated:YES];
		
		[alertView close];
	}];
    
    
    AFNetworkReachabilityManager *reachability = [AFNetworkReachabilityManager sharedManager];
    if (reachability.reachable) {
        //同步 定时计划 数据
        //app启动时要开始进行 定时计划的数据同步
        [self synchroTimingPlanLocalData:YES];
		
		//对 使用次数 数据进行同步
		[self synchroUseTimeData];
    }
    
    imView = [UIImageView new];
}

#pragma mark - 请求网络按摩程序

- (void)requestNetworkMassageProgram {
	// 获取网络按摩程序列表, 并保存在本地,如果获取失败,使用本地的
	_networkMassageDic = [NSMutableDictionary new];
	_networkMassageProgramRequest = [[MassageProgramRequest alloc]init];
	
	[_networkMassageProgramRequest requestNetworkMassageProgramListByIndex:0 Size:100 success:^(NSArray *networkMassageProgramArray) {
		
		if (networkMassageProgramArray.count > 0) {
			for (int i = 0; i < networkMassageProgramArray.count; i++) {
				MassageProgram *massage = [networkMassageProgramArray objectAtIndex:i];
				[_networkMassageDic setObject:massage forKey:[NSString stringWithFormat:@"%zd", massage.commandId]];
			}
			[_table reloadData];
		}
		
	} failure:^(NSArray *localMassageProgramArray) {
		
		if (localMassageProgramArray.count > 0) {
			for (int i = 0; i < localMassageProgramArray.count; i++) {
				MassageProgram *massage = [localMassageProgramArray objectAtIndex:i];
				[_networkMassageDic setObject:massage forKey:[NSString stringWithFormat:@"%zd", massage.commandId]];
			}
			[_table reloadData];
		}
	}];
}

#pragma mark - 同步使用次数数据
-(void)synchroUseTimeData
{
    NSArray* counts = [ProgramCount MR_findAllWithPredicate:[NSPredicate predicateWithFormat:@"unUpdateCount > 0"]];
    BOOL b = counts.count>0;
    [ProgramCount synchroUseCountDataFormServer:b Success:nil Fail:nil];
}

#pragma mark - 同步本地定时计划数据
-(void)synchroTimingPlanLocalData:(BOOL)isContinue
{
    if (isContinue) {
        NSArray* plans = [TimingPlan MR_findAllWithPredicate:[NSPredicate predicateWithFormat:@"(state < 4) AND (state > 0) AND uid == %@",_uid]];
        if (plans.count>0) {
            TimingPlan* plan = plans[0];
            NSInteger state = [plan.state integerValue];
            TimingPlanRequest* request = [TimingPlanRequest new];
            __weak MainViewController* weakSelf = self;
            if (state == 1)
            {
                //新增数据
                [request addTimingPlan:plan success:^(NSUInteger timingPlanId) {
                    NSLog(@"定时计划 同步新增成功");
                    plan.planId = [NSNumber numberWithUnsignedInteger:timingPlanId];
                    plan.state = [NSNumber numberWithInteger:0];
                    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
                    
                    [weakSelf synchroTimingPlanLocalData:YES];
                } fail:^(NSDictionary *dic) {
                    [weakSelf synchroTimingPlanLocalData:NO];
                }];
            }
            else if (state == 2)
            {
                //编辑数据
                [request updateTimingPlan:plan success:^(NSDictionary *dic) {
                    NSLog(@"定时计划 同步编辑成功");
                    plan.state = [NSNumber numberWithInteger:0];
                    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
                    
                    [weakSelf synchroTimingPlanLocalData:YES];
                } fail:^(NSDictionary *dic) {
                    [weakSelf synchroTimingPlanLocalData:NO];
                }];
            }
            else if (state == 3)
            {
                //删除数据
                NSUInteger planId = [plan.planId integerValue];
                [request deleteTimingPlanId:planId success:^{
                    NSLog(@"定时计划 同步删除成功");
                    [plan MR_deleteEntity];
                    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
                    
                    [weakSelf synchroTimingPlanLocalData:YES];
                } fail:^(NSDictionary *dic) {
                    [weakSelf synchroTimingPlanLocalData:NO];
                }];
            }
        }
        else
        {
            //没有需要的同步数据才去请求列表
            [self getTimingPlanList];
        }
    }
}

#pragma mark - 请求定时计划列表
-(void)getTimingPlanList
{
    //网络请求定时计划列表
    TimingPlanRequest* request = [TimingPlanRequest new];
    [request getTimingPlanListSuccess:^(NSArray *timingPlanList) {
        NSLog(@"定时计划网络请求成功");
        [TimingPlan updateLocalNotificationByNetworkData:timingPlanList];
        
    } fail:^(NSDictionary *dic) {
        NSLog(@"定时计划网络请求失败");
        
    }];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    SlideNavigationController* slideNav = (SlideNavigationController*)self.navigationController;
    slideNav.enableSwipeGesture = NO;
//	[_table reloadData];
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

#pragma mark - UIGestureRecognizer代理
-(BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if (self.navigationController.viewControllers.count == _vcCount) {
        return NO;
    }
    else
    {
        return YES;
    }
}

#pragma mark - menuController代理
-(void)switchChange:(BOOL)isOn {
    if (!_weatherView) {
        _weatherView = [[WLWeatherView alloc]initWithFrame:CGRectMake(0, 0, 90, 44)];
        UIBarButtonItem* right = [[UIBarButtonItem alloc]initWithCustomView:_weatherView];
        self.navigationItem.rightBarButtonItem  = right;
    }
    
    if (isOn) {
        _weatherView.hidden = NO;
        [_weatherView updateWeather];
    }
    else
    {
        _weatherView.hidden = YES;
        [_weatherView cancelUpdate];
    }
}

#pragma mark - tabBar代理

-(void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item {
//    NSLog(@"tabBar:%ld",item.tag);
//	if ([RTBleConnector shareManager].currentConnectedPeripheral == nil) {
//		[reconnectDialog show];
//		return;
//	}
	if (item.tag == 0) {
		[[RTBleConnector shareManager] sendControlMode:H10_KEY_OZON_SWITCH];
	} else if (item.tag == 1) {
        //手动按摩
        UIStoryboard* s = [UIStoryboard storyboardWithName:@"Login" bundle:nil];
        ManualViewController* mVC = (ManualViewController*)[s instantiateViewControllerWithIdentifier:@"ManualVC"];
        [self.navigationController pushViewController:mVC animated:YES];
    } else if (item.tag == 2) {
        //自定义
        UIStoryboard* s = [UIStoryboard storyboardWithName:@"Login" bundle:nil];
        CustomProcedureViewController* cVC= (CustomProcedureViewController*)[s instantiateViewControllerWithIdentifier:@"CustomProcedure"];
        [self.navigationController pushViewController:cVC animated:YES];
    } else if (item.tag == 3) {
        //下载
        UIStoryboard* s = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        ProgramDownloadViewController* pVC = (ProgramDownloadViewController*)[s instantiateViewControllerWithIdentifier:@"ProgramDownloadVC"];
        [self.navigationController pushViewController:pVC animated:YES];
    }
}

#pragma mark - tableView代理

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_modeNameArray count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    BasicTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[BasicTableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];
        cell.imageViewScale = 0.55;
        CGRect f = CGRectMake(0, 0, SCREENWIDTH, 78);
        UIImageView* bg = [[UIImageView alloc]initWithFrame:f];
        bg.image = [UIImage imageNamed:@"list_bg"];
        bg.contentMode = UIViewContentModeScaleToFill;
        bg.alpha = 0.5;
        [cell addSubview:bg];
        [cell sendSubviewToBack:bg];
        cell.backgroundColor = [UIColor clearColor];
    }
    
    MassageProgram *massage = _massageArr[indexPath.row];
    if (massage) {
        cell.textLabel.text = massage.name;
        cell.textLabel.textColor = BLACK;
        cell.textLabel.font = [UIFont systemFontOfSize:18];
        cell.detailTextLabel.text = massage.mDescription;
        cell.detailTextLabel.numberOfLines = 0;
        cell.detailTextLabel.textColor = BLACK;
        cell.detailTextLabel.font = [UIFont systemFontOfSize:10];
        cell.imageView.image = [UIImage imageNamed:massage.imageUrl];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"arrow"]];
	
	if (indexPath.row >= 6) {
		NSInteger commandId = [[RTBleConnector shareManager].rtNetworkProgramStatus getMassageIdBySlotIndex:indexPath.row - 6];
		if (commandId == 0) {
			cell.hidden = YES;
		} else {
			MassageProgram *networkMassage = [_networkMassageDic objectForKey:[NSString stringWithFormat:@"%zd", commandId]];
			if (networkMassage) {
				cell.textLabel.text = networkMassage.name;
				cell.detailTextLabel.text = networkMassage.mDescription;
				
				[UIImageView loadImageByURL:networkMassage.imageUrl imageView:cell.imageView];
				
			}
		}
	}
	
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = [self tableView:_table cellForRowAtIndexPath:indexPath];
	
	if (indexPath.row >= 6) {
		if ([[RTBleConnector shareManager].rtNetworkProgramStatus getMassageIdBySlotIndex:indexPath.row - 6] == 0) {
			return 0;
		}
	}
	return 80;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
//    if (![RTBleConnector isBleTurnOn]) {
//        UIAlertView* alert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"蓝牙未打开" delegate:self cancelButtonTitle:@"知道了" otherButtonTitles: nil];
//        [alert show];
//    }
    
	if ([RTBleConnector shareManager].currentConnectedPeripheral == nil) {
        NSLog(@"连接设备为空");
		[reconnectDialog show];
		return;
	}
    
	switch (indexPath.row) {
			
		// 运动恢复
		case 0:
			[[RTBleConnector shareManager] sendControlMode:H10_KEY_CHAIR_AUTO_0];
			break;
			
		// 舒展活络
		case 1:
			[[RTBleConnector shareManager] sendControlMode:H10_KEY_CHAIR_AUTO_1];
			break;
			
		// 休憩促眠
		case 2:
			[[RTBleConnector shareManager] sendControlMode:H10_KEY_CHAIR_AUTO_2];
			break;
			
		// 工作减压
		case 3:
			[[RTBleConnector shareManager] sendControlMode:H10_KEY_CHAIR_AUTO_3];
			break;
			
		// 肩颈重点
		case 4:
			[[RTBleConnector shareManager] sendControlMode:H10_KEY_CHAIR_AUTO_4];
			break;
			
		// 腰椎舒缓
		case 5:
			[[RTBleConnector shareManager] sendControlMode:H10_KEY_CHAIR_AUTO_5];
			break;
			
		// 云养程序一
		case 6:
			[[RTBleConnector shareManager] sendControlMode:H10_KEY_CHAIR_AUTO_NETCLOUD_1];
			break;
		// 云养程序二
		case 7:
			[[RTBleConnector shareManager] sendControlMode:H10_KEY_CHAIR_AUTO_NETCLOUD_2];
			break;
		// 云养程序三
		case 8:
			[[RTBleConnector shareManager] sendControlMode:H10_KEY_CHAIR_AUTO_NETCLOUD_3];
			break;
		// 云养程序四
		case 9:
			[[RTBleConnector shareManager] sendControlMode:H10_KEY_CHAIR_AUTO_NETCLOUD_4];
			break;
	}
}

#pragma mark - 侧滑菜单代理
-(BOOL)slideNavigationControllerShouldDisplayLeftMenu {
    return YES;
}

#pragma mark - 侧滑菜单出现
- (IBAction)slideMenuAppear:(id)sender {
    [[SlideNavigationController sharedInstance] toggleLeftMenu];
}

#pragma mark - RTBleConnectorDelegate

- (void)didUpdateMassageChairStatus:(RTMassageChairStatus *)rtMassageChairStatus {
	
	NSLog(@"didUpdateMassageChairStatus");
	
	if (rtMassageChairStatus.anionSwitchFlag == 0) {   // 负离子关
		_menuBar.selectedItem = nil;
	} else {
		 _menuBar.selectedItem = (UITabBarItem*)_menuBar.items[0];
	}
	
	if (rtMassageChairStatus.deviceStatus == RtMassageChairStatusResetting) {
		[self.resettingDialog show];
	} else {
		[self.resettingDialog close];
	}
	
	if (rtMassageChairStatus.deviceStatus == RtMassageChairStatusMassaging) {
		
			if (rtMassageChairStatus.programType == RtMassageChairProgramAuto) {
                
                //自动按摩时，开始统计时间
                NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
                NSDate* startTime = [NSDate date];
                [defaults setObject:startTime forKey:@"MassageStartTime"];
                
				if (rtMassageChairStatus.figureCheckFlag == 1) {  // 执行体型检测程序
					
					[self jumpToScanViewConroller];
					
				} else { // 自动按摩
					
					[self jumpToAutoMassageViewConroller];
					
				}
			} else if (rtMassageChairStatus.programType == RtMassageChairProgramManual) {  // 手动按摩
				
				[self jumpToManualMassageViewConroller];
				
			}
	}
}


#pragma mark - 切换用户代理
-(void)changeUser:(NSString *)imageUrl
{
    UIButton* btn = (UIButton*)_leftBtn.customView;
    if ([imageUrl isEqualToString:@"default"]||imageUrl.length < 1) {
        NSLog(@"头像链接为默认");
        //空的用默认头像
        [btn setImage:[UIImage imageNamed:@"userIcon"] forState:UIControlStateNormal];
    }
    else
    {
        NSLog(@"读取头像");
        //先使用本地图片，若本地读不到图片则使用网络请求
        UIImage* img = [UIImage imageInLocalByName:[NSString stringWithFormat:@"%@.jpg",imageUrl]];
        //网络请求
        if (!img) {
            NSLog(@"网络读取头像");
            NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://recipe.xtremeprog.com/file/g/%@",imageUrl]];
            NSURLRequest *request = [NSURLRequest requestWithURL:url];
            UIImage *placeholderImage = [UIImage imageNamed:@"placeholder"];
//            UIImageView* imView = [UIImageView new];
            [imView setImageWithURLRequest:request
                                 placeholderImage:placeholderImage
                                          success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                              NSLog(@"网络读取成功");
                                              UIButton* btn = (UIButton*)_leftBtn.customView;
                                              [image saveImageByName:[NSString stringWithFormat:@"%@.jpg",imageUrl]];
                                              [btn setImage:image forState:UIControlStateNormal];
                                              
                                          } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error)
             {
                 NSLog(@"网络头像读取失败");
                 //头像读取失败
                 [btn setImage:[UIImage imageNamed:@"userIcon"] forState:UIControlStateNormal];
                 [self showProgressHUDByString:@"头像下载失败，请检测网络"];
             }];
        }
        else
        {
            [btn setImage:img forState:UIControlStateNormal];
        }
    }
}

#pragma mark - 快速提示
-(void)showProgressHUDByString:(NSString*)message
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.labelText = message;
    hud.margin = 10.f;
    hud.removeFromSuperViewOnHide = YES;
    [hud hide:YES afterDelay:0.7];
}

- (void)didUpdateNetworkMassageStatus:(RTNetworkProgramStatus *)rtNetwrokProgramStatus {
//	NSLog(@"didUpdateNetworkMassageStatus");
	[self requestNetworkMassageProgram];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
