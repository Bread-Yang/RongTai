//
//  TimingMassageTableViewController.m
//  rongtai
//
//  Created by yoghourt on 6/11/15.
//  Copyright (c) 2015 William-zhang. All rights reserved.
//

#import "TimingMassageTableViewController.h"
#import "AddOrEditTimingMassageViewController.h"
#import "TimingPlanTableViewCell.h"
#import "TimingPlan.h"
#import <MagicalRecord.h>
#import "UIBarButtonItem+goBack.h"
#import "MBProgressHUD.h"
#import "AFHTTPRequestOperationManager.h"
#import "RongTaiConstant.h"
#import "TimingPlanRequest.h"
#import "MBProgressHUD.h"
#import "AppDelegate.h"

@interface TimingMassageTableViewController () <TimingPlanDelegate,UITableViewDataSource,UITableViewDelegate>{
    MBProgressHUD *_loading;
	TimingPlanRequest *_timingPlanRequest;
    NSString* _uid;
    UITableView* _tableView;
}

@property (nonatomic, strong) NSMutableArray *timingMassageArray;

@end

@implementation TimingMassageTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"定时计划", nil);
    
    _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHT-64) style:UITableViewStylePlain];
    _tableView.backgroundColor = [UIColor clearColor];
	
    //导航栏右边的添加按钮
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_set-07"] style:UIBarButtonItemStylePlain target:self action:@selector(addTimingMassage)];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.dataSource = self;
    _tableView.delegate = self;
    [self.view addSubview:_tableView];
    
    //导航栏返回按钮设置
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem goBackItemByTarget:self Action:@selector(goBack)];
	
	//MBProgressHUD
    _loading = [[MBProgressHUD alloc]initWithView:self.view];
    _loading.labelText = NSLocalizedString(@"读取中...", nil);
    [self.view addSubview:_loading];
	
	_timingPlanRequest = [TimingPlanRequest new];
	_timingPlanRequest.overTime = 30;
	_timingPlanRequest.delegate = self;
    
    //
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    _uid = [defaults objectForKey:@"uid"];
}
                    
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
	AFNetworkReachabilityManager *reachability = [AFNetworkReachabilityManager sharedManager];
	if (reachability.reachable) {
		[_loading show:YES];
        
        //同步数据
        NSLog(@"开始同步数据");
        [TimingPlan synchroTimingPlanLocalData:YES ByCount:0 Uid:_uid Success:^{
            [self loadLocalData];
            [_loading hide:YES];
            NSLog(@"定时计划:%@",[UIApplication sharedApplication].scheduledLocalNotifications);
        } Fail:^{
            [self loadLocalData];
            [_loading hide:YES];
            NSLog(@"定时计划:%@",[UIApplication sharedApplication].scheduledLocalNotifications);
        }];
    }
    else
    {
        NSLog(@"定时计划网络请求 没网");
        //没有网络读取本地数据库
        [self loadLocalData];
        NSLog(@"定时计划:%@",[UIApplication sharedApplication].scheduledLocalNotifications);
    }
}

#pragma mark - 读取本地数据
-(void)loadLocalData
{
    //查询去状态不是 未同步的删除 的所有数据
    NSLog(@"定时计划 读取本地数据");
//    NSArray* plans = [TimingPlan MR_findAllWithPredicate:[NSPredicate predicateWithFormat:@"(state < 3) AND uid == %@",_uid]];
    NSArray* plans = [TimingPlan MR_findAllSortedBy:@"planId" ascending:YES withPredicate:[NSPredicate predicateWithFormat:@"(state < 3) AND uid == %@",_uid]];
    self.timingMassageArray = [NSMutableArray arrayWithArray:plans];
    [_tableView reloadData];
}

#pragma mark - 返回
-(void)goBack
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - TableView data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.timingMassageArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	static NSString *reuseId = @"TIMING_MASSAGE_CELL";
	
    TimingPlanTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseId];
	
	if (!cell) {
		cell = [[TimingPlanTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseId];
	}
	
    cell.timingPlan = self.timingMassageArray[indexPath.row];
	
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 80;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	UIStoryboard *mainStoryBoard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
	AddOrEditTimingMassageViewController *viewController = (AddOrEditTimingMassageViewController *)[mainStoryBoard instantiateViewControllerWithIdentifier:@"AddTimingMassage"];
	
	viewController.timingPlan = self.timingMassageArray[indexPath.row];
	
	[self.navigationController pushViewController:viewController animated:YES];
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
	
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        TimingPlan *timingPlan = self.timingMassageArray[indexPath.row];
        
		[_loading show:YES];
        //取消本地通知
        [timingPlan cancelLocalNotification];
        
        NSUInteger planId = [timingPlan.planId integerValue];
        if (planId == 0) {
            //如果id等于0，即是未添加到服务器的数据，直接删除本地记录就行了
            [self.timingMassageArray removeObjectAtIndex:indexPath.row];
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
            
            [timingPlan MR_deleteEntity];
            [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
            
            [_loading hide:YES];
        }
        else
        {
            [_timingPlanRequest deleteTimingPlanId:[timingPlan.planId integerValue] success:^{
                //网络删除成功
                [self.timingMassageArray removeObjectAtIndex:indexPath.row];
                [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
                
                [timingPlan MR_deleteEntity];
                [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
                
                [_loading hide:YES];
            } fail:^(NSDictionary *dic) {
                //网络删除失败
                
                //把数据状态变成3，表示 未同步的 删除 数据
                timingPlan.state = [NSNumber numberWithInteger:3];
                [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
                
                [self.timingMassageArray removeObjectAtIndex:indexPath.row];
                [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
                
                [_loading hide:YES];
            }];
        }
		
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}

#pragma mark - Action
- (void)addTimingMassage {
	
	UIStoryboard *mainStoryBoard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
	AddOrEditTimingMassageViewController *viewController = (AddOrEditTimingMassageViewController *)[mainStoryBoard instantiateViewControllerWithIdentifier:@"AddTimingMassage"];
	
	__weak __typeof(self) weakSelf = self;
	
	[viewController setReturnTimingMassageBlock:^(TimingMassageModel *entity) {
		[weakSelf.timingMassageArray addObject:entity];
		[_tableView reloadData];
	}];
	[self.navigationController pushViewController:viewController animated:YES];
}

#pragma mark - TimingPlanDelegate代理

- (void)timingPlanRequestTimeOut:(TimingPlanRequest *)request {
    [_loading hide:YES];
    [self showProgressHUDByString:@"请求超时"];
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


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
