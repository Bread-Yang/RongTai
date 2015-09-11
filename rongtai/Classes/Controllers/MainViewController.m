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
#import "DataRequest.h"
#import "ProgramCount.h"
#import "MassageRecord.h"
#import "MBProgressHUD.h"


@interface MainViewController ()<SlideNavigationControllerDelegate,UITableViewDataSource, UITableViewDelegate, MenuViewControllerDelegate, UIGestureRecognizerDelegate>
{
    UITableView* _table;
    NSMutableArray *_massageArr;
	NSMutableDictionary *_networkMassageDic;
    MassageProgramRequest* _networkMassageProgramRequest;
	NSArray *_modeNameArray;
	NSArray *_modeDescriptionArray;
    WLWeatherView* _weatherView;
	CustomIOSAlertView *reconnectDialog;
    NSUInteger _vcCount;
    UIBarButtonItem* _leftBtn;
    NSString* _userImageUrl; //导航栏左边按钮，即用户头像的链接
    UIImageView* imView;
    
    //由于该类覆盖了父类的RTBleConnector代理方法，所以需要自己实现统计次数
    RTBleConnector *_bleConnector;
    ProgramCount* _programCount;
    NSString* _programName;
    NSUInteger _massageFlag;
    
    //底部菜单
    UIView* _menuView;  //菜单栏
    UIButton *_anionButton; //负离子按钮
    UIButton *_manualMassageButton; //手动按摩 按钮
    UIButton *_customProgramButton; //自定义 按钮
    UIButton *_downloadButton;  //下载按钮
}
@end

@implementation MainViewController

#pragma mark - Life Cycle

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
    SlideNavigationController* slideNav = (SlideNavigationController *)self.navigationController;
    slideNav.enableSwipeGesture = YES;
	
	[_table reloadData];
    
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSString* mid = [defaults objectForKey:@"currentMemberId"];
    NSArray* arr = [Member MR_findAllWithPredicate:[NSPredicate predicateWithFormat:@"(uid = %@) AND (memberId == %@)",self.uid, mid]];
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
    
    _bleConnector = [RTBleConnector shareManager];
    //页面出现就记录当前按摩椅按摩状态
    if (_bleConnector.rtMassageChairStatus.deviceStatus == RtMassageChairStatusMassaging) {
        if (_bleConnector.rtMassageChairStatus.massageProgramFlag != 7) {
            _massageFlag = _bleConnector.rtMassageChairStatus.massageProgramFlag;
            NSLog(@"按摩记录：%ld",_massageFlag);
        }
        else
        {
            NSLog(@"手动按摩中");
            [_manualMassageButton setSelected:YES];
        }
    }
    else
    {
        _massageFlag = 0;
        NSLog(@"按摩记录，没有按摩");
    }
	
	if (self.isFromLoginViewController) {
		self.isFromLoginViewController = false;
		// 获取网络按摩程序列表, 并保存在本地,如果获取失败,使用本地的
		[self requestNetworkMassageProgram];
	}
}

- (void)viewDidLoad {
    [super viewDidLoad];
	self.isListenBluetoothStatus = YES;
    self.navigationController.interactivePopGestureRecognizer.delegate = self;
    _vcCount = self.navigationController.viewControllers.count;
	
    self.title = NSLocalizedString(@"荣泰", nil);
    self.navigationController.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName];
    //
    SlideNavigationController* slideNav = (SlideNavigationController *)self.navigationController;
    MenuViewController* menu = (MenuViewController*)slideNav.leftMenu;
    menu.delegate = self;
    
    //
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    
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
    
    CGFloat sWidth = SCREENWIDTH;
    CGFloat sHeight = SCREENHEIGHT;

    _table = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, sWidth, sHeight-49-64) style:UITableViewStylePlain];
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
    
    //底部菜单
    _menuView = [[UIView alloc]initWithFrame:CGRectMake(0, SCREENHEIGHT-49-64, SCREENWIDTH, 49)];
    _menuView.backgroundColor = [UIColor colorWithRed:48/255.0 green:65/255.0 blue:77/255.0 alpha:1.0];
    [self.view addSubview:_menuView];
    
    //负离子按钮
    CGFloat btnWidth = sWidth/4;
    NSLog(@"按钮长度:%f",btnWidth);
    _anionButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, btnWidth, 49)];
    [_anionButton setTitle:NSLocalizedString(@"负离子", nil) forState:UIControlStateNormal];
    [_anionButton setTitleColor:[UIColor colorWithRed:64/255.0 green:178/255.0 blue:223/255.0 alpha:1] forState:UIControlStateSelected];
    _anionButton.titleLabel.font = [UIFont systemFontOfSize:11];
    _anionButton.contentEdgeInsets = UIEdgeInsetsMake(-15, 0, 0, 0);
    _anionButton.imageEdgeInsets = UIEdgeInsetsMake(0, btnWidth*0.35, 0, 0);
    _anionButton.titleEdgeInsets = UIEdgeInsetsMake(40, -btnWidth*0.25, 0, 0);
    [_anionButton setImage:[UIImage imageNamed:@"icon_set"] forState:UIControlStateNormal];
    [_anionButton setImage:[UIImage imageNamed:@"icon_set2"] forState:UIControlStateSelected];
    [_anionButton addTarget:self action:@selector(anionButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [_menuView addSubview:_anionButton];
    
    //手动 按钮
    _manualMassageButton = [[UIButton alloc]initWithFrame:CGRectMake(btnWidth, 0, btnWidth, 49)];
    [_manualMassageButton setTitle:NSLocalizedString(@"手动", nil) forState:UIControlStateNormal];
    [_manualMassageButton setTitleColor:[UIColor colorWithRed:64/255.0 green:178/255.0 blue:223/255.0 alpha:1] forState:UIControlStateSelected];
    _manualMassageButton.titleLabel.font = [UIFont systemFontOfSize:11];
    _manualMassageButton.contentEdgeInsets = UIEdgeInsetsMake(-15, 0, 0, 0);
    _manualMassageButton.imageEdgeInsets = UIEdgeInsetsMake(0, btnWidth*0.3, 0, 0);;
    _manualMassageButton.titleEdgeInsets = UIEdgeInsetsMake(40, -btnWidth*0.2, 0, 0);
    [_manualMassageButton setImage:[UIImage imageNamed:@"icon_hand"] forState:UIControlStateNormal];
    [_manualMassageButton setImage:[UIImage imageNamed:@"icon_hand2"] forState:UIControlStateSelected];
    [_manualMassageButton addTarget:self action:@selector(manualButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [_menuView addSubview:_manualMassageButton];
    
    //自定义按钮
    _customProgramButton = [[UIButton alloc]initWithFrame:CGRectMake(btnWidth*2, 0, btnWidth, 49)];
    [_customProgramButton setTitle:NSLocalizedString(@"自定义", nil) forState:UIControlStateNormal];
    [_customProgramButton setTitleColor:[UIColor colorWithRed:64/255.0 green:178/255.0 blue:223/255.0 alpha:1] forState:UIControlStateHighlighted];
    _customProgramButton.titleLabel.font = [UIFont systemFontOfSize:11];
    _customProgramButton.contentEdgeInsets = UIEdgeInsetsMake(-15, 0, 0, 0);
    _customProgramButton.imageEdgeInsets = UIEdgeInsetsMake(0, btnWidth*0.35, 0, 0);
    _customProgramButton.titleEdgeInsets = UIEdgeInsetsMake(40, -btnWidth*0.25, 0, 0);
    [_customProgramButton setImage:[UIImage imageNamed:@"icon_user"] forState:UIControlStateNormal];
    [_customProgramButton setImage:[UIImage imageNamed:@"icon_user2"] forState:UIControlStateHighlighted];
    [_customProgramButton addTarget:self action:@selector(customButtonCilcked) forControlEvents:UIControlEventTouchUpInside];
    [_menuView addSubview:_customProgramButton];

    //下载按钮
    _downloadButton = [[UIButton alloc]initWithFrame:CGRectMake(btnWidth*3, 0, btnWidth, 49)];
    [_downloadButton setTitle:NSLocalizedString(@"下载", nil) forState:UIControlStateNormal];
    [_downloadButton setTitleColor:[UIColor colorWithRed:64/255.0 green:178/255.0 blue:223/255.0 alpha:1] forState:UIControlStateHighlighted];
    _downloadButton.titleLabel.font = [UIFont systemFontOfSize:11];
    _downloadButton.contentEdgeInsets = UIEdgeInsetsMake(-15, 0, 0, 0);
    _downloadButton.imageEdgeInsets = UIEdgeInsetsMake(0, btnWidth*0.3, 0, 0);;
    _downloadButton.titleEdgeInsets = UIEdgeInsetsMake(40, -btnWidth*0.2, 0, 0);
    [_downloadButton setImage:[UIImage imageNamed:@"icon_download"] forState:UIControlStateNormal];
    [_downloadButton setImage:[UIImage imageNamed:@"icon_download2"] forState:UIControlStateHighlighted];
    [_downloadButton addTarget:self action:@selector(downloadButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [_menuView addSubview:_downloadButton];
    
    //

    imView = [UIImageView new];
    _massageFlag = 0;
    [self synchroMassageRecord];

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
				[_networkMassageDic setObject:massage forKey:[NSString stringWithFormat:@"%zd", [massage.commandId integerValue]]];
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

#pragma mark - 同步按摩记录
-(void)synchroMassageRecord
{
    DataRequest* r = [DataRequest new];
    MassageRecord* r1 = [MassageRecord MR_createEntity];
    r1.name = @"运动恢复";
    r1.useTime = @100;
    r1.date = @"2015-09-07";
    r1.programId = @1;
//    r1.uid = _uid;
//    [r addMassageRecord:@[[r1 toDictionary]] Success:^{
//        
//    } fail:^(NSDictionary *dic) {
//        
//    }];
    
    [r getMassageRecordFrom:[NSDate dateWithTimeIntervalSince1970:0] To:[NSDate dateWithTimeIntervalSinceNow:0] Success:^(NSArray * arr) {

    } fail:^(NSDictionary * dic) {
        
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
        NSArray* plans = [TimingPlan MR_findAllWithPredicate:[NSPredicate predicateWithFormat:@"(state < 4) AND (state > 0) AND uid == %@",self.uid]];
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
	
	NSIndexPath *alreadySelectIndexPath = [_table indexPathForSelectedRow];
	
	if (!alreadySelectIndexPath) {
		[_table deselectRowAtIndexPath:alreadySelectIndexPath animated:YES];
	}
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
        [_weatherView updateWeather2];
    }
    else
    {
        _weatherView.hidden = YES;
        [_weatherView cancelUpdate];
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
//    cell.selectionStyle = UITableViewCellSelectionStyleNone;
	UIView *bgColorView = [[UIView alloc] init];
	bgColorView.backgroundColor = [UIColor colorWithRed:176.0 / 255.0 green:215.0 / 255.0 blue:233.0 / 255.0 alpha:1];
	[cell setSelectedBackgroundView:bgColorView];
	
    cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"arrow"]];
	
	if (indexPath.row >= 6) {
		NSInteger commandId = [[RTBleConnector shareManager].rtNetworkProgramStatus getMassageIdBySlotIndex:indexPath.row - 6];
		if (![RTBleConnector shareManager].currentConnectedPeripheral || ![RTBleConnector isBleTurnOn] || commandId == 0) {
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
		if (![RTBleConnector isBleTurnOn] || [[RTBleConnector shareManager].rtNetworkProgramStatus getMassageIdBySlotIndex:indexPath.row - 6] == 0) {
			return 0;
		}
	}
	return 80;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
//	NSIndexPath *alreadySelectIndexPath = [_table indexPathForSelectedRow];
//	
//	if (!alreadySelectIndexPath && alreadySelectIndexPath.row != indexPath.row) {
//		[tableView deselectRowAtIndexPath:indexPath animated:YES];
//	}
	
//	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	
//	if ([RTBleConnector shareManager].currentConnectedPeripheral == nil) {
//        NSLog(@"连接设备为空");
//		[reconnectDialog show];
//		return;
//	}
	
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
	
	RTMassageChairStatus *rtMassageChairStatus = [RTBleConnector shareManager].rtMassageChairStatus;
	
	if ([RTBleConnector shareManager].currentConnectedPeripheral != nil && rtMassageChairStatus != nil) {
		if (rtMassageChairStatus && rtMassageChairStatus.deviceStatus == RtMassageChairStatusMassaging) {
			
			[self jumpToCorrespondingControllerByMassageStatus];
			
		} else {
			
			// 延迟1.5秒再进入按摩界面
			
			double delayInSeconds = 1.5;
			
			dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
			
			dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
				[self jumpToCorrespondingControllerByMassageStatus];
			});
		}
	}
}

#pragma mark - 根据当前自动按摩的状态,跳进对应的界面(自动按摩界面, 体型检测界面)

- (void)jumpToCorrespondingControllerByMassageStatus {
	
	RTMassageChairStatus *rtMassageChairStatus = [RTBleConnector shareManager].rtMassageChairStatus;
	
	if (rtMassageChairStatus && rtMassageChairStatus.deviceStatus == RtMassageChairStatusMassaging) {
		
		if (rtMassageChairStatus.programType == RtMassageChairProgramAuto || rtMassageChairStatus.programType == RtMassageChairProgramNetwork) {
			
			if (rtMassageChairStatus.figureCheckFlag == 1) {  // 执行体型检测程序
				
				[self jumpToScanViewConroller];
				
			} else { // 自动按摩
				
				[self jumpToAutoMassageViewConroller];
				
			}
		}
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

#pragma mark - 清空主界面所有高亮状态
- (void)clearHightlightView {
	[_table deselectRowAtIndexPath:[_table indexPathForSelectedRow] animated:YES];
	[_table reloadData];
    [_anionButton setSelected:NO];
    [_manualMassageButton setSelected:NO];
}

#pragma mark - RTBleConnectorDelegate

- (void)didUpdateRTBleState:(CBCentralManagerState)state {
	
	NSString *message;
	
	switch (state) {
		case CBCentralManagerStateResetting:
			message = @"初始化中，请稍后……";
			break;
			
		case CBCentralManagerStateUnsupported:
			message = @"设备不支持状态，过会请重试……";
			break;
			
		case CBCentralManagerStateUnauthorized:
			message = @"设备未授权状态，过会请重试……";
			break;
			
		case CBCentralManagerStatePoweredOff:
			message = @"尚未打开蓝牙，请在设置中打开……";
			[self clearHightlightView];
			break;
			
		case CBCentralManagerStatePoweredOn:
			message = @"蓝牙已经成功开启，稍后……";
			break;
			
		case CBCentralManagerStateUnknown:
			message = @"蓝牙发生未知错误，请重新打开……";
			[self clearHightlightView];
			break;
	}
}

- (void)didUpdateNetworkMassageStatus:(RTNetworkProgramStatus *)rtNetwrokProgramStatus {
	//	NSLog(@"didUpdateNetworkMassageStatus");
	[self requestNetworkMassageProgram];
}

- (void)didUpdateMassageChairStatus:(RTMassageChairStatus *)rtMassageChairStatus {
	
//	NSLog(@"didUpdateMassageChairStatus");
	
	if (rtMassageChairStatus.anionSwitchFlag == 0) {   // 负离子关
        [_anionButton setSelected:NO];
	} else {
        [_anionButton setSelected:YES];
	}
	
	if (rtMassageChairStatus.deviceStatus == RtMassageChairStatusResetting) {
		[self.resettingDialog show];
	} else {
		[self.resettingDialog close];
	}
	
	if (rtMassageChairStatus.deviceStatus == RtMassageChairStatusMassaging)
    {  //按摩中
        
		// 高亮item
        int highlightIndex = -1;
		
		if (rtMassageChairStatus.programType == RtMassageChairProgramAuto || rtMassageChairStatus.programType == RtMassageChairProgramNetwork)
        {
            //自动时设置手动按钮不为高亮
            [_manualMassageButton setSelected:NO];
			
            if (rtMassageChairStatus.programType == RtMassageChairProgramAuto) {
                switch (rtMassageChairStatus.autoProgramType) {
                        
                    case RtMassageChairProgramSportRecover:
                        highlightIndex = 0;
                        break;
                        
                    case RtMassageChairProgramExtension:
                        highlightIndex = 1;
                        break;
                        
                    case RtMassageChairProgramRestAndSleep:
                        highlightIndex = 2;
                        break;
                        
                    case RtMassageChairProgramWorkingRelieve:
                        highlightIndex = 3;
                        break;
                        
                    case RtMassageChairProgramShoulderAndNeck:
                        highlightIndex = 4;
                        break;
                        
                    case RtMassageChairProgramWaistAndSpine:
                        highlightIndex = 5;
                        break;
               }
            }else if (rtMassageChairStatus.programType == RtMassageChairProgramNetwork)
            {
                 switch (rtMassageChairStatus.networkProgramType) {
                    case RTMassageChairProgramNetwork1:
                        highlightIndex = 6;
                        break;
                        
                    case RTMassageChairProgramNetwork2:
                        highlightIndex = 7;
                        break;
                        
                    case RTMassageChairProgramNetwork3:
                        highlightIndex = 8;
                        break;
                
                    case RTMassageChairProgramNetwork4:
                        highlightIndex = 9;
                        break;
                }
            }
            if (highlightIndex>=0) {
                [_table selectRowAtIndexPath:[NSIndexPath indexPathForRow:highlightIndex inSection:0]
                                    animated:YES
                              scrollPosition:UITableViewScrollPositionNone];
            }
            else
            {
                [_table deselectRowAtIndexPath:[_table indexPathForSelectedRow] animated:YES];
            }
            
		}
        else if (rtMassageChairStatus.programType == RtMassageChairProgramManual)
        {
            //手动按摩的话，底部菜单栏的手动要高亮
            [_manualMassageButton setSelected:YES];
            [_table deselectRowAtIndexPath:[_table indexPathForSelectedRow] animated:YES];
        }
        else
        {
            [_manualMassageButton setSelected:NO];
            [_table deselectRowAtIndexPath:[_table indexPathForSelectedRow] animated:YES];
        }
	}
    else
    {
        // 没有在按摩
		[_table deselectRowAtIndexPath:[_table indexPathForSelectedRow] animated:YES];
        [_manualMassageButton setSelected:NO];
        
	}
    
    //统计数据
    if (rtMassageChairStatus.deviceStatus == RtMassageChairStatusMassaging)
    {
        //按摩中
        if (rtMassageChairStatus.programType == RtMassageChairProgramManual) {
            //手动按摩中
            if (_massageFlag != rtMassageChairStatus.massageProgramFlag) {
                NSLog(@"切换到手动按摩");
                //从自动按摩切换过来的话，需要进行按摩时间和次数统计
                [self countMassageTime];
                _massageFlag = rtMassageChairStatus.massageProgramFlag;
            }
        }
        else if (rtMassageChairStatus.programType == RtMassageChairProgramNetwork || rtMassageChairStatus.programType == RtMassageChairProgramAuto)
        {
            //自动按摩
            if (_massageFlag != rtMassageChairStatus.massageProgramFlag) {
                if (_massageFlag == 7 || _massageFlag == 0) {
                    //每次切换到自动按摩程序的时候，就设置开始按摩时间
                    _massageFlag = rtMassageChairStatus.massageProgramFlag;
                    _bleConnector.startTime = [NSDate date];
                    NSLog(@"切换到自动按摩");
                    NSLog(@"设置开始时间");
                }
                else
                {
                    NSLog(@"更换自动按摩种类:%ld",_massageFlag);
                    //切换自动按摩程序种类，需要进行按摩时间和次数统计
                    [self countMassageTime];
                    //再次设置开始时间
                    _bleConnector.startTime = [NSDate date];
                    _massageFlag = rtMassageChairStatus.massageProgramFlag;
                }
            }
        }
    }
    else if (rtMassageChairStatus.deviceStatus == RtMassageChairStatusResetting)
    {
        //复位中
        if (_massageFlag != 0) {
            if (_massageFlag>0&&_massageFlag<11&&_massageFlag!=7) {
                NSLog(@"复位前是自动按摩");
                //复位前是自动按摩需要统计
                [self countMassageTime];
                _massageFlag = 0;
                _bleConnector.startTime = nil;
                NSLog(@"设置开始时间为空");
            }
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

#pragma mark - 计算按摩时间
-(void)countMassageTime
{
    //计算按摩时间
    NSDate* end = [NSDate date];
    NSDate* start = _bleConnector.startTime;
    NSLog(@"开始时间:%@",start);
    if (start) {
        NSLog(@"进入统计");
        NSTimeInterval time = [end timeIntervalSinceDate:start];
        //        NSLog(@"此次按摩了%f秒",time);
        if (time>30) {
            //时间大于30秒才开始统计
            NSUInteger min;
            if (time<=60) {
                min = 1;
            }
            else
            {
                min = (int)round(time/60);
            }
            NSLog(@"此次按摩了%ld分钟",min);
            //将开始按摩的日期转成字符串
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"YYYY-MM-dd"];
            NSString* date = [dateFormatter stringFromDate:start];
            NSInteger programId = -1;
            if (_massageFlag<7&&_massageFlag>0) {
                //属于自动按摩的统计
                NSLog(@"自动按摩统计");
                _programName = [_bleConnector.rtMassageChairStatus autoMassageNameByIndex:_massageFlag];
                programId = _massageFlag;
            }
            else if (_massageFlag<11&&_massageFlag>7)
            {
                //属于网络按摩的统计
                NSLog(@"网络按摩统计");
                MassageProgram* p = [_bleConnector.rtNetworkProgramStatus getNetworkProgramNameBySlotIndex:_massageFlag-8];
                programId = [p.commandId integerValue];
                _programName = p.name;
            }
            else
            {
                _programName = nil;
                programId = 0;
                NSLog(@"统计到的按摩程序名称为空");
            }
            
            if (programId>0) {
                NSLog(@"统计一次");
                NSArray* result = [ProgramCount MR_findAllWithPredicate:[NSPredicate predicateWithFormat:@"(programId == %ld) AND (uid == %@)",programId,self.uid]];
                
                //按摩次数统计
                if (result.count >0) {
                    _programCount = result[0];
                    NSUInteger count = [_programCount.unUpdateCount integerValue];
                    count++;
                    _programCount.unUpdateCount = [NSNumber numberWithUnsignedInteger:count];
                    _programCount.programId = [NSNumber numberWithInteger:programId];
                }
                else
                {
                    _programCount = [ProgramCount MR_createEntity];
                    _programCount.name = _programName;
                    _programCount.uid = self.uid;
                    _programCount.unUpdateCount = [NSNumber numberWithInt:1];
                    _programCount.programId = [NSNumber numberWithInteger:programId];
                }
                
                //开始统计次数的网络数据同步
                [ProgramCount synchroUseCountDataFormServer:YES Success:nil Fail:nil];
                
                //按摩记录
                MassageRecord* massageRecord;
                NSArray* records = [MassageRecord MR_findAllWithPredicate:[NSPredicate predicateWithFormat:@"(programId == %ld) AND (date == %@) AND (uid == %@)",programId,date,self.uid]];
                if (records.count > 1) {
                    NSLog(@"查找数组:%@",records);
                    massageRecord = records[0];
                }
                if (massageRecord) {
                    NSUInteger oldTime = [massageRecord.useTime integerValue];
                    oldTime += min;
                    massageRecord.useTime = [NSNumber numberWithUnsignedInteger:oldTime];
                }
                else
                {
                    //创建一条按摩记录
                    massageRecord = [MassageRecord MR_createEntity];
                    massageRecord.useTime = [NSNumber numberWithUnsignedInteger:min];
                    massageRecord.name = _programName;
                    massageRecord.date = date;
                    massageRecord.uid = self.uid;
                    massageRecord.programId = [NSNumber numberWithInteger:programId];
                }
            }
        }
        
        //统计完成要把开始时间置空，表示此次按摩已结束
        _bleConnector.startTime = nil;
        NSLog(@"设置开始时间为空");
    }
    else
    {
        NSLog(@"不统计");
    }
}

#pragma mark - 负离子方法
-(void)anionButtonClicked
{
    //发送负离子开关
    [_bleConnector sendControlMode:H10_KEY_OZON_SWITCH];
    [_anionButton setSelected:!_anionButton.isSelected];
}

#pragma mark - 手动方法
-(void)manualButtonClicked
{
    if (_bleConnector.currentConnectedPeripheral == nil || ![RTBleConnector isBleTurnOn]) {
        [_bleConnector showConnectDialog];
        return;
    }
    
    //连接按摩椅之后才可以跳到手动按摩
    UIStoryboard* s = [UIStoryboard storyboardWithName:@"Login" bundle:nil];
    ManualViewController* mVC = (ManualViewController*)[s instantiateViewControllerWithIdentifier:@"ManualVC"];
    [self.navigationController pushViewController:mVC animated:YES];
}

#pragma mark - 自定义方法
-(void)customButtonCilcked
{
    //跳到自定义页面
    UIStoryboard* s = [UIStoryboard storyboardWithName:@"Login" bundle:nil];
    CustomProcedureViewController* cVC= (CustomProcedureViewController*)[s instantiateViewControllerWithIdentifier:@"CustomProcedure"];
    [self.navigationController pushViewController:cVC animated:YES];
}

#pragma mark - 下载方法
-(void)downloadButtonClicked
{
    //跳到下载页面
    UIStoryboard* s = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    ProgramDownloadViewController* pVC = (ProgramDownloadViewController*)[s instantiateViewControllerWithIdentifier:@"ProgramDownloadVC"];
    [self.navigationController pushViewController:pVC animated:YES];
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
