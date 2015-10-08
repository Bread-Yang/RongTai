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
#import "WLButtonItem.h"


@interface MainViewController ()<SlideNavigationControllerDelegate,UITableViewDataSource, UITableViewDelegate, MenuViewControllerDelegate, UIGestureRecognizerDelegate>
{
    UITableView* _table;
	NSMutableDictionary *_networkMassageDic;
    MassageProgramRequest* _networkMassageProgramRequest;
	NSArray *_localProgramArray;
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

//    UIButton *_anionButton;
    WLButtonItem* _anionButtonItem; //负离子按钮
//    UIButton *_manualMassageButton;
    WLButtonItem* _manualMassageButtonItem;  //手动按摩 按钮
//    UIButton *_customProgramButton;
    WLButtonItem* _customProgramButtonItem; //自定义 按钮
//    UIButton *_downloadButton;
    WLButtonItem* _downloadButtonItem;  //下载按钮
    
    NSUInteger _timingPlanCount; //记录未同步的定时计划
    
    BOOL _isClicked;   //是否点击了按摩模式
}
@end

@implementation MainViewController

#pragma mark - Life Cycle

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    _isClicked = NO;
    self.navigationController.navigationBarHidden = NO;
    [_customProgramButtonItem setSelected:NO];
    [_downloadButtonItem setSelected:NO];
    SlideNavigationController* slideNav = (SlideNavigationController *)self.navigationController;
    slideNav.enableSwipeGesture = YES;
    
    _bleConnector = [RTBleConnector shareManager];
    //页面出现就记录当前按摩椅按摩状态
//    NSLog(@"连接设备:%@",_bleConnector.currentConnectedPeripheral);
//    NSLog(@"蓝牙是否打开:%d",[RTBleConnector isBleTurnOn]);
    if (_bleConnector.currentConnectedPeripheral == nil || ![RTBleConnector isBleTurnOn]) {
        [_anionButtonItem setSelected:NO];
        [_manualMassageButtonItem setSelected:NO];
    }
    else
    {
        if (_bleConnector.rtMassageChairStatus.deviceStatus == RtMassageChairStatusMassaging) {
            if (_bleConnector.rtMassageChairStatus.massageProgramFlag != 7) {
                _massageFlag = _bleConnector.rtMassageChairStatus.massageProgramFlag;
                NSLog(@"按摩记录：%ld",(unsigned long)_massageFlag);
            }
            else
            {
                NSLog(@"手动按摩中");
                [_manualMassageButtonItem setSelected:YES];
            }
        }
        else
        {
            _massageFlag = 0;
            NSLog(@"按摩记录，没有按摩");
        }
    }

	if (self.isFromLoginViewController) {
		self.isFromLoginViewController = false;
		// 获取网络按摩程序列表, 并保存在本地,如果获取失败,使用本地的
		[self requestNetworkMassageProgram];
        [self updateUserIcon];
	}
    else
    {
        //同步家庭管理成员
        [self synchroFamily];
    }
	
	[self refreshTableView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
//    NSLog(@"😳");
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
    
    //
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
	
    //读取按摩椅固定的按摩程序
	NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"LocalProgramList" ofType:@"plist"];
	_localProgramArray = [[NSArray alloc] initWithContentsOfFile:plistPath];
    
    //
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
    
    //同步 定时计划 数据
    //app启动时要开始进行 定时计划的数据同步
    [TimingPlan synchroTimingPlanLocalData:YES ByCount:0 Uid:self.uid Success:nil Fail:nil];
    
    //对 使用次数 数据进行同步
    [self synchroUseTimeData];
    
    //对 使用时间 数据进行同步
    [DataRequest synchroMassageRecordSuccess:nil fail:nil];
    
    //底部菜单
    _menuView = [[UIView alloc]initWithFrame:CGRectMake(0, SCREENHEIGHT-49-64, SCREENWIDTH, 49)];
    _menuView.backgroundColor = [UIColor colorWithRed:48/255.0 green:65/255.0 blue:77/255.0 alpha:1.0];
    [self.view addSubview:_menuView];
    
    //负离子按钮
    CGFloat btnWidth = sWidth/4;
    _anionButtonItem = [[WLButtonItem alloc]initWithFrame:CGRectMake(0, 0, btnWidth, 49)];
    _anionButtonItem.title = NSLocalizedString(@"负离子", nil);
    [_anionButtonItem setTitleSelectedColor:[UIColor colorWithRed:64/255.0 green:178/255.0 blue:223/255.0 alpha:1]];
    [_anionButtonItem setImage:[UIImage imageNamed:@"icon_set"]];
    [_anionButtonItem setSelectedImage:[UIImage imageNamed:@"icon_set2"]];
    UITapGestureRecognizer* anionTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(anionButtonClicked)];
    [_anionButtonItem addGestureRecognizer:anionTap];
    [_menuView addSubview:_anionButtonItem];
    
    //手动 按钮
    _manualMassageButtonItem = [[WLButtonItem alloc]initWithFrame:CGRectMake(btnWidth, 0, btnWidth, 49)];
    _manualMassageButtonItem.title = NSLocalizedString(@"手动按摩", nil);
    [_manualMassageButtonItem setTitleSelectedColor:[UIColor colorWithRed:64/255.0 green:178/255.0 blue:223/255.0 alpha:1]];
    [_manualMassageButtonItem setImage:[UIImage imageNamed:@"icon_hand"]];
    [_manualMassageButtonItem setSelectedImage:[UIImage imageNamed:@"icon_hand2"]];
    UITapGestureRecognizer* manualTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(manualButtonClicked)];
    [_manualMassageButtonItem addGestureRecognizer:manualTap];
    [_menuView addSubview:_manualMassageButtonItem];
    
    //自定义按钮
    _customProgramButtonItem = [[WLButtonItem alloc]initWithFrame:CGRectMake(btnWidth*2, 0, btnWidth, 49)];
    _customProgramButtonItem.title = NSLocalizedString(@"DIY按摩", nil);
    [_customProgramButtonItem setTitleSelectedColor:[UIColor colorWithRed:64/255.0 green:178/255.0 blue:223/255.0 alpha:1]];
    [_customProgramButtonItem setImage:[UIImage imageNamed:@"icon_user"]];
    [_customProgramButtonItem setSelectedImage:[UIImage imageNamed:@"icon_user2"]];
    UITapGestureRecognizer* customTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(customButtonCilcked)];
    [_customProgramButtonItem addGestureRecognizer:customTap];
    [_menuView addSubview:_customProgramButtonItem];

    //下载按钮
    _downloadButtonItem = [[WLButtonItem alloc]initWithFrame:CGRectMake(btnWidth*3, 0, btnWidth, 49)];
    _downloadButtonItem.title = NSLocalizedString(@"程序下载", nil);
    [_downloadButtonItem setTitleSelectedColor:[UIColor colorWithRed:64/255.0 green:178/255.0 blue:223/255.0 alpha:1]];
    [_downloadButtonItem setImage:[UIImage imageNamed:@"icon_download"]];
    [_downloadButtonItem setSelectedImage:[UIImage imageNamed:@"icon_download2"]];
    UITapGestureRecognizer* downloadTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(downloadButtonClicked)];
    [_downloadButtonItem addGestureRecognizer:downloadTap];
    [_menuView addSubview:_downloadButtonItem];
    
    //
    imView = [UIImageView new];
    _massageFlag = 0;
    
    //检测云养程序本地记录
    NSArray* arr = [MassageProgram MR_findAll];
    if (arr.count<1) {
        //如果本地记录为空，则启动程序需要请求
        [self requestNetworkMassageProgram];
    }
	
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
				[_networkMassageDic setObject:massage forKey:[NSString stringWithFormat:@"%zd", [massage.commandId integerValue]]];
			}
			[_table reloadData];
		}
	}];
}

- (void)refreshTableView {
	
	@synchronized(self) {
		_networkMassageDic = [NSMutableDictionary new];
		_networkMassageProgramRequest = [[MassageProgramRequest alloc]init];
		
		NSArray *localMassageProgramArray = [_networkMassageProgramRequest getAlreadySaveNetworkMassageProgramList];
		for (int i = 0; i < localMassageProgramArray.count; i++) {
			MassageProgram *massage = [localMassageProgramArray objectAtIndex:i];
			[_networkMassageDic setObject:massage forKey:[NSString stringWithFormat:@"%zd", [massage.commandId integerValue]]];
		}
		[_table reloadData];
	}
}

#pragma mark - 同步使用次数数据
-(void)synchroUseTimeData
{
    NSArray* counts = [ProgramCount MR_findAllWithPredicate:[NSPredicate predicateWithFormat:@"unUpdateCount > 0"]];
    BOOL b = counts.count>0;
    [ProgramCount synchroUseCountDataFormServer:b Success:nil Fail:nil];
}


#pragma mark - 更新用户头像
-(void)updateUserIcon
{
    //设置用户头像
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSString* mid = [defaults objectForKey:@"currentMemberId"];
    NSArray* arr;
    if (mid.length<1) {
//        NSLog(@"默认第一个成员");
        arr = [Member MR_findByAttribute:@"uid" withValue:self.uid andOrderBy:@"memberId" ascending:YES];
        if (arr.count>0) {
            Member* r = arr[0];
            NSString* mid = [NSString stringWithFormat:@"%d",[r.memberId intValue]];
            [defaults setObject:mid forKey:@"currentMemberId"];
        }
    }
    else
    {
//        NSLog(@"有默认成员:%@",mid);
        arr = [Member MR_findAllWithPredicate:[NSPredicate predicateWithFormat:@"(uid == %@) AND (memberId == %d)",self.uid, [mid intValue]]];
//        NSLog(@"%@",arr);
    }

    if (arr.count > 0) {
        Member* m = arr[0];
        [self changeUser:m.imageURL];
//        NSLog(@"有用户:%@",m.name);
    }
    else
    {
        NSLog(@"找不到用户");
        NSArray* ms = [Member MR_findByAttribute:@"uid" withValue:self.uid andOrderBy:@"memberId" ascending:YES];;
//        NSMutableArray* arr = [NSMutableArray new];
//        for (int i = 0; i < ms.count; i++) {
//            Member* m = ms[i];
//            NSMutableDictionary* dic = [[NSMutableDictionary alloc]initWithDictionary:[m memberToDictionary]];
//            [dic setObject:m.uid forKey:@"uid"];
//            [arr addObject:dic];
//        }
        
//        NSLog(@"成员数据:%@",arr);
        if (ms.count>0) {
            Member* m = ms[0];
            [self changeUser:m.imageURL];
        }
        else
        {
            [self changeUser:nil];
        }
    }
}

#pragma mark - 同步家庭成员
-(void)synchroFamily
{
    //读取家庭成员
    //网络请求
//    NSLog(@"请求成员");
    MemberRequest* mr = [MemberRequest new];
    [mr requestMemberListByIndex:0 Size:2000 success:^(NSArray *members) {
        //            NSLog(@"成员:%@",members);
        [Member updateLocalDataByNetworkData:members];
        [self updateUserIcon];
    } failure:^(id responseObject) {
        NSLog(@"本地记录读取成员");
        [self updateUserIcon];
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
    return [_localProgramArray count] + 4;  // 除了本地程序,还有4个云养程序
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
	
	UIView *bgColorView = [[UIView alloc] init];
	bgColorView.backgroundColor = [UIColor colorWithRed:176.0 / 255.0 green:215.0 / 255.0 blue:233.0 / 255.0 alpha:1];
	[cell setSelectedBackgroundView:bgColorView];
	
	cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"arrow"]];
	
	if (indexPath.row < [_localProgramArray count]) {		//	自带程序显示
		NSDictionary *programDic = _localProgramArray[indexPath.row];
		if (programDic) {
			cell.textLabel.text = programDic[@"programName"];
//			cell.textLabel.textColor = BLACK;
//			cell.textLabel.font = [UIFont systemFontOfSize:18];
			cell.detailTextLabel.text = programDic[@"programDescription"];
//			cell.detailTextLabel.numberOfLines = 0;
//			cell.detailTextLabel.textColor = BLACK;
//			cell.detailTextLabel.font = [UIFont systemFontOfSize:10];
			cell.imageView.image = [UIImage imageNamed:programDic[@"programImageUrl"]];
		}
		
	} else {			// 云养程序显示
		NSInteger commandId = [[RTBleConnector shareManager].rtNetworkProgramStatus getMassageIdBySlotIndex:indexPath.row - [_localProgramArray count]];
		if (![RTBleConnector shareManager].currentConnectedPeripheral || ![RTBleConnector isBleTurnOn] || ![RTBleConnector shareManager].isConnectedDevice ||commandId == 0) {
			cell.hidden = YES;
		} else {
			MassageProgram *networkMassage = [_networkMassageDic objectForKey:[NSString stringWithFormat:@"%zd", commandId]];
			cell.detailTextLabel.text = @"";
			if (networkMassage != nil) {
				cell.textLabel.text = networkMassage.name;
				cell.detailTextLabel.text = networkMassage.mDescription;
				[UIImageView loadImageByURL:networkMassage.imageUrl imageView:cell.imageView];
			} else {
				cell.imageView.image = [UIImage imageNamed:@"mode_10"];
				switch (indexPath.row - [_localProgramArray count]) {
					case 0:
						cell.textLabel.text = NSLocalizedString(@"云养程序一", nil);
						break;
					
					case 1:
						cell.textLabel.text = NSLocalizedString(@"云养程序二", nil);
						break;
																
					case 2:
						cell.textLabel.text = NSLocalizedString(@"云养程序三", nil);
						break;
						
					case 3:
						cell.textLabel.text = NSLocalizedString(@"云养程序四", nil);
						break;
					
				}
			}
		}
	}
    cell.textLabel.textColor = BLACK;
    cell.textLabel.font = [UIFont systemFontOfSize:18];
    cell.detailTextLabel.textColor = BLACK;
    cell.detailTextLabel.font = [UIFont systemFontOfSize:10];
	cell.detailTextLabel.numberOfLines = 0;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
//	UITableViewCell *cell = [self tableView:_table cellForRowAtIndexPath:indexPath];
	
	if (indexPath.row >= [_localProgramArray count]) {
		if (![RTBleConnector isBleTurnOn] || [[RTBleConnector shareManager].rtNetworkProgramStatus getMassageIdBySlotIndex:indexPath.row - [_localProgramArray count]] == 0) {
			return 0;
		}
	}
	return 80;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
//	NSIndexPath *alreadySelectIndexPath = [_table indexPathForSelectedRow];
//	
//	if (!alreadySelectIndexPath && alreadySelectIndexPath.row != indexPath.row) {
//		[tableView deselectRowAtIndexPath:indexPath animated:YES];
//	}
	
//	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	
    _isClicked = YES;
	
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
	
	if ([RTBleConnector shareManager].currentConnectedPeripheral != nil && rtMassageChairStatus != nil && [RTBleConnector shareManager].isConnectedDevice) {
		
//		if (rtMassageChairStatus.figureCheckFlag == 1) {  // 执行体型检测程序
//			
//			[self jumpToScanViewConroller];
//			
//		} else { // 自动按摩
//			
//			[self jumpToAutoMassageViewConroller];
//			
//		}
		
//		if (rtMassageChairStatus && rtMassageChairStatus.deviceStatus == RtMassageChairStatusMassaging) {
//			
//			[self jumpToCorrespondingControllerByMassageStatus];
//			
//		} else {
//			
			// 延迟1.5秒再进入按摩界面
			
//			double delayInSeconds = 1.5;
//			
//			dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
//			
//			dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        NSLog(@"跳转到自动按摩");
				[self jumpToAutoMassageViewConroller];
//			});
//		}
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
    [_anionButtonItem setSelected:NO];
    [_manualMassageButtonItem setSelected:NO];
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
//	[self requestNetworkMassageProgram];
	[self refreshTableView];
}

- (void)didUpdateMassageChairStatus:(RTMassageChairStatus *)rtMassageChairStatus {
	
//	NSLog(@"didUpdateMassageChairStatus");
//    NSLog(@"state:%ld",rtMassageChairStatus.deviceStatus);
    
    //错误状态代码
//    if (rtMassageChairStatus.deviceStatus == RtMassageChairStatusError) {
//        UIAlertView* alert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"请重启按摩椅" delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles:nil];
//        [alert show];
//    }
    
    
	if (rtMassageChairStatus.anionSwitchFlag == 0) {   // 负离子关
        [_anionButtonItem setSelected:NO];
	} else {
        [_anionButtonItem setSelected:YES];
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
            [_manualMassageButtonItem setSelected:NO];
            
            if (_isClicked) {
                [self jumpToAutoMassageViewConroller];
                _isClicked = NO;
            }
			
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
                    default:
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
                    default:
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
            [_manualMassageButtonItem setSelected:YES];
            [_table deselectRowAtIndexPath:[_table indexPathForSelectedRow] animated:YES];
        }
        else
        {
            [_manualMassageButtonItem setSelected:NO];
            [_table deselectRowAtIndexPath:[_table indexPathForSelectedRow] animated:YES];
        }
	}
    else
    {
        // 没有在按摩
		[_table deselectRowAtIndexPath:[_table indexPathForSelectedRow] animated:YES];
        [_manualMassageButtonItem setSelected:NO];
        
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
                    NSLog(@"更换自动按摩种类:%d",_massageFlag);
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

-(void)didDisconnectRTBlePeripheral:(CBPeripheral *)peripheral
{
    NSLog(@"main 断开设备");
    [super didDisconnectRTBlePeripheral:peripheral];
    [self clearHightlightView];
}

#pragma mark - 切换用户
-(void)changeUser:(NSString *)imageUrl
{
    UIButton* btn = (UIButton*)_leftBtn.customView;
    if ([imageUrl isEqualToString:@"default"]||imageUrl.length < 1) {
//        NSLog(@"头像链接为默认");
        //空的用默认头像
        [btn setImage:[UIImage imageNamed:@"userIcon"] forState:UIControlStateNormal];
    }
    else
    {
//        NSLog(@"读取头像");
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
            NSLog(@"此次按摩了%d分钟",min);
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
                 NSLog(@"网络按摩统计:%d",_massageFlag);
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
}

#pragma mark - 手动方法
-(void)manualButtonClicked
{
    if (_bleConnector.currentConnectedPeripheral == nil || ![RTBleConnector isBleTurnOn]|| !_bleConnector.isConnectedDevice) {
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
    [_customProgramButtonItem setSelected:YES];
    //跳到自定义页面
    UIStoryboard* s = [UIStoryboard storyboardWithName:@"Login" bundle:nil];
    CustomProcedureViewController* cVC= (CustomProcedureViewController*)[s instantiateViewControllerWithIdentifier:@"CustomProcedure"];
    [self.navigationController pushViewController:cVC animated:YES];
}

#pragma mark - 下载方法
-(void)downloadButtonClicked
{
    [_downloadButtonItem setSelected:YES];
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

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return (toInterfaceOrientation == UIInterfaceOrientationPortrait);
}

- (BOOL)shouldAutorotate
{
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations

{
    return UIInterfaceOrientationMaskPortrait;
}

-(UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
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
