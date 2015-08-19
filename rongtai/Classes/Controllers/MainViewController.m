//
//  MainViewController.m
//  rongtai
//
//  Created by William-zhang on 15/6/8.
//  Copyright (c) 2015年 William-zhang. All rights reserved.
//

#import "MainViewController.h"
#import "SlideNavigationController.h"
#import "MassageRequest.h"
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

//
#import "MemberRequest.h"

@interface MainViewController ()<SlideNavigationControllerDelegate,UITableViewDataSource, UITableViewDelegate, MassageRequestDelegate,UITabBarDelegate, MenuViewControllerDelegate, UIGestureRecognizerDelegate>
{
    UITableView* _table;
    NSMutableArray* _massageArr;
    MassageRequest* _massageRequest;
	NSArray *_modeNameArray;
    WLWeatherView* _weatherView;
    UITabBar* _menuBar;
	CustomIOSAlertView *reconnectDialog;
	UIButton *anionButton, *manualMassageButton, *customProgramButton, *downloadButton;
    NSUInteger _vcCount;

}
@end

@implementation MainViewController

#pragma mark - Life Cycle

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
    SlideNavigationController* slideNav = (SlideNavigationController *)self.navigationController;
    slideNav.enableSwipeGesture = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];

	self.isListenBluetoothStatus = YES;

    self.navigationController.interactivePopGestureRecognizer.delegate = self;
    _vcCount = self.navigationController.viewControllers.count;
     NSLog(@"VC:%ld",_vcCount);
	
    self.title = NSLocalizedString(@"荣泰", nil);
    self.navigationController.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName];
//    self.navigationController.delegate = self;
    //
    SlideNavigationController* slideNav = (SlideNavigationController *)self.navigationController;
    MenuViewController* menu = (MenuViewController*)slideNav.leftMenu;
    menu.delegate = self;
    
    //天气预报
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSNumber* loadWeather = [defaults valueForKey:@"weather"];
    if ([loadWeather boolValue]) {
        _weatherView = [[WLWeatherView alloc]initWithFrame:CGRectMake(0, 0, 90, 44)];
        UIBarButtonItem* right = [[UIBarButtonItem alloc]initWithCustomView:_weatherView];
        self.navigationItem.rightBarButtonItem  = right;
    }
    
    //菜单按钮
    UIBarButtonItem* left = [[UIBarButtonItem alloc]initWithTitle:nil style:UIBarButtonItemStylePlain target:self action:@selector(slideMenuAppear:)];
    UIButton* image = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 34, 34)];
    [image setImage:[UIImage imageNamed:@"userIcon.jpg"] forState:UIControlStateNormal];
    [image addTarget:self action:@selector(slideMenuAppear:) forControlEvents:UIControlEventTouchUpInside];
    image.layer.cornerRadius = 17;
    left.customView = image;
    image.clipsToBounds = YES;
    slideNav.leftBarButtonItem = left;
    
    //侧滑菜单
    slideNav.view.layer.shadowColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.35].CGColor;
    slideNav.view.layer.shadowOffset = CGSizeMake(-0.5, 0);
    slideNav.view.layer.shadowOpacity  = 5;
    slideNav.view.layer.shadowRadius = 10;
    
    //
    _table = [[UITableView alloc]initWithFrame:CGRectMake(0, 64, SCREENWIDTH, SCREENHEIGHT-49-64) style:UITableViewStylePlain];
    _table.dataSource = self;
    _table.delegate = self;
    _table.backgroundColor = [UIColor clearColor];
    _table.separatorStyle = UITableViewCellSeparatorStyleNone;
    _table.showsHorizontalScrollIndicator = NO;
    _table.showsVerticalScrollIndicator = NO;
    [self.view addSubview:_table];
    
    //
    _massageRequest = [[MassageRequest alloc]init];
    _massageRequest.delegate = self;
    NSString* uid = [[NSUserDefaults standardUserDefaults] objectForKey:@"uid"];
//    [_massageRequest requestMassageListByUid:uid Index:0 Size:100];
    _massageArr = [NSMutableArray new];
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
	
    for (int i = 0; i < [_modeNameArray count]; i++) {
        MassageProgram *m = [MassageProgram new];
        m.name = _modeNameArray[i];
        m.mDescription = @"以颈部、肩部、背部按摩为主，腰部、尾椎骨按摩为辅";
        m.imageUrl = [NSString stringWithFormat:@"mode_%d",i + 1];
        [_massageArr addObject:m];
    }
    
    //
    _menuBar = [[UITabBar alloc]initWithFrame:CGRectMake(0, SCREENHEIGHT-49, SCREENWIDTH, 49)];
    _menuBar.barTintColor = [UIColor colorWithRed:48/255.0 green:65/255.0 blue:77/255.0 alpha:1.0];
    _menuBar.tintColor = [UIColor whiteColor];
    UITabBarItem* item1 = [[UITabBarItem alloc]initWithTitle:@"负离子" image:[UIImage imageNamed:@"icon_set"] tag:0];
    UITabBarItem* item2 = [[UITabBarItem alloc]initWithTitle:@"手动" image:[UIImage imageNamed:@"icon_hand"] tag:1];
    UITabBarItem* item3 = [[UITabBarItem alloc]initWithTitle:@"自定义" image:[UIImage imageNamed:@"icon_user"] tag:2];
    UITabBarItem* item4 = [[UITabBarItem alloc]initWithTitle:@"下载" image:[UIImage imageNamed:@"icon_download"] tag:3];
    _menuBar.items = @[item1,item2,item3,item4];
    _menuBar.selectedItem = item1;
    _menuBar.delegate = self;
    [self.view addSubview:_menuBar];
	
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
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    SlideNavigationController* slideNav = (SlideNavigationController*)self.navigationController;
    slideNav.enableSwipeGesture = NO;
	[_table reloadData];
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
    }
    cell.backgroundColor = [UIColor clearColor];
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
    cell.accessoryView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"arrow"]];
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = [self tableView:_table cellForRowAtIndexPath:indexPath];
	
	if (indexPath.row >= 6) {
		if ([[RTBleConnector shareManager].rtNetworkProgramStatus getIntByIndex:indexPath.row - 6] == 0) {
			cell.hidden = YES;
			
			if ([cell.contentView subviews]){
				for (UIView *subview in [cell.contentView subviews]) {
					[subview removeFromSuperview];
				}
			}
			return 0;
		}
	}
	
	cell.hidden = NO;
	return 80;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//	if ([RTBleConnector shareManager].currentConnectedPeripheral == nil) {
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
			
		// 云养程序一
		case 5:
			[[RTBleConnector shareManager] sendControlMode:H10_KEY_CHAIR_AUTO_NETCLOUD_1];
			break;
		// 云养程序二
		case 6:
			[[RTBleConnector shareManager] sendControlMode:H10_KEY_CHAIR_AUTO_NETCLOUD_2];
			break;
		// 云养程序三
		case 7:
			[[RTBleConnector shareManager] sendControlMode:H10_KEY_CHAIR_AUTO_NETCLOUD_3];
			break;
		// 云养程序四
		case 8:
			[[RTBleConnector shareManager] sendControlMode:H10_KEY_CHAIR_AUTO_NETCLOUD_4];
			break;
	}
}

#pragma mark - massageRequest代理
-(void)massageRequestMassageListFinish:(BOOL)success Result:(NSDictionary *)dic {
    if (success) {
        NSArray* arr = [dic objectForKey:@"result"];
        NSLog(@"用户下载列表:%@",arr);
        if (arr.count>0) {
            for (int i = 0; i<arr.count; i++) {
                MassageProgram* massage = [[MassageProgram alloc]initWithJSON:arr[i]];
                [_massageArr addObject:massage];
            }
            [_table reloadData];
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

#pragma mark - RTBleConnectorDelegate

- (void)didUpdateMassageChairStatus:(RTMassageChairStatus *)rtMassageChairStatus {
	
	NSLog(@"体型检测标记 : %zd", 	rtMassageChairStatus.figureCheckFlag);
	
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

- (void)didUpdateNetworkMassageStatus:(RTNetworkProgramStatus *)rtNetwrokProgramStatus {
	NSLog(@"didUpdateNetworkMassageStatus");
	[_table reloadData];
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
