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

@interface TimingMassageTableViewController () <TimingPlanDelegate>{
	MBProgressHUD *_loadingHUD;
	TimingPlanRequest *_timingPlanRequest;
}

@property (nonatomic, retain) NSMutableArray *timingMassageArray;

@end

@implementation TimingMassageTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	
    //添加背景
	UIImageView *backgroundImageView = [[UIImageView alloc]initWithFrame:self.view.frame];
	backgroundImageView.image = [UIImage imageNamed:@"bg"];
	self.tableView.backgroundView = backgroundImageView;

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
	
    //导航栏右边的添加按钮
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_set-07"] style:UIBarButtonItemStylePlain target:self action:@selector(addTimingMassage)];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    //导航栏返回按钮设置
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem goBackItemByTarget:self Action:@selector(goBack)];
	
	//MBProgressHUD
	AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
	_loadingHUD = [[MBProgressHUD alloc] initWithWindow:appDelegate.window];
	[appDelegate.window addSubview:_loadingHUD];
	
	_timingPlanRequest = [TimingPlanRequest new];
	_timingPlanRequest.overTime = 30;
	_timingPlanRequest.delegate = self;
}
                    
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	
    //清空本地通知
//    NSInteger number =[[UIApplication sharedApplication] scheduledLocalNotifications].count;
	
//    NSLog(@"本地通知数量:%ld",number);
//    NSLog(@"本地通知:%@",[[UIApplication sharedApplication] scheduledLocalNotifications]);
    
	AFNetworkReachabilityManager *reachability = [AFNetworkReachabilityManager sharedManager];
	if (reachability.reachable) {
		_loadingHUD.labelText = NSLocalizedString( @"读取中...", nil);
		[_loadingHUD show:YES];
        
        if ([self synchroLocalData]) {  //同步本地数据成功后才请求定时计划列表
            NSLog(@"定时计划同步时成功");
            //网络请求定时计划列表
            [_timingPlanRequest getTimingPlanListSuccess:^(NSArray *timingPlanList) {
                NSLog(@"定时计划网络请求成功");
                self.timingMassageArray = [[NSMutableArray alloc] init];
                for (NSDictionary *dic in timingPlanList) {
                    TimingPlan *item = [TimingPlan updateTimingPlanDB:dic];
                    [self.timingMassageArray addObject:item];
                }
                [self.tableView reloadData];
                [_loadingHUD hide:YES];
                
            } fail:^(NSDictionary *dic) {
                NSLog(@"定时计划网络请求失败");
                //失败时读取本地数据库
                
                //查询去状态不是 未同步的删除 的所有数据
                [self loadLocalData];
                [_loadingHUD hide:YES];
            }];
            
        } else {
           //同步失败的话，读取本地数据
            NSLog(@"定时计划同步时失败");
            [self loadLocalData];
            [_loadingHUD hide:YES];
        }
    }
    else
    {
        NSLog(@"定时计划网络请求 没网");
        //没有网络读取本地数据库
        [self loadLocalData];
    }
}

#pragma mark - 读取本地数据
-(void)loadLocalData
{
    //查询去状态不是 未同步的删除 的所有数据
    NSLog(@"定时计划 读取本地数据");
    NSArray* plans = [TimingPlan MR_findAllWithPredicate:[NSPredicate predicateWithFormat:@"state < 3"]];
    self.timingMassageArray = [NSMutableArray arrayWithArray:plans];
    [self.tableView reloadData];
}

#pragma mark - 同步本地数据
-(BOOL)synchroLocalData
{
    BOOL result = YES;
    NSArray* plans = [TimingPlan MR_findAllWithPredicate:[NSPredicate predicateWithFormat:@"state > 0"]];
    if (plans.count>0) {
        NSLog(@"未同步数据有%ld条🔁",plans.count);
        __block BOOL success = YES;
        for (int i = 0; i<plans.count; i++) {

            if (!success) {
                result = NO;
                //只要其中有一个数据同步失败，即停止同步
                break;
            }
            
            TimingPlan* plan = plans[i];
            NSInteger state = [plan.state integerValue];
            if (state == 1)
            {
                //新增数据
                [_timingPlanRequest addTimingPlan:plan success:^(NSUInteger timingPlanId) {
                    NSLog(@"定时计划 同步新增成功");
                    plan.planId = [NSNumber numberWithUnsignedInteger:timingPlanId];
                    plan.state = [NSNumber numberWithInteger:0];
                    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
                } fail:^(NSDictionary *dic) {
                    success = NO;
                }];
            }
            else if (state == 2)
            {
                //编辑数据
                [_timingPlanRequest updateTimingPlan:plan success:^(NSDictionary *dic) {
                    NSLog(@"定时计划 同步编辑成功");
                    plan.state = [NSNumber numberWithInteger:0];
                    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
                } fail:^(NSDictionary *dic) {
                    success = NO;
                }];
            }
            else if (state == 3)
            {
                //删除数据
                NSUInteger planId = [plan.planId integerValue];
                [_timingPlanRequest deleteTimingPlanId:planId success:^{
                    NSLog(@"定时计划 同步删除成功");
                    [plan MR_deleteEntity];
                    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
                } fail:^(NSDictionary *dic) {
                    success = NO;
                }];
            }
        }
    }
    return result;
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
//        [timingPlan cancelLocalNotification];
//        [timingPlan MR_deleteEntity];
//        [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
		
		[_loadingHUD show:YES];
        
        NSUInteger planId = [timingPlan.planId integerValue];
        if (planId == 0) {
            //如果id等于0，即是未添加到服务器的数据，直接删除本地记录就行了
            [self.timingMassageArray removeObjectAtIndex:indexPath.row];
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
            
            [timingPlan MR_deleteEntity];
            [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
            
            [_loadingHUD hide:YES];
        }
        else
        {
            [_timingPlanRequest deleteTimingPlanId:[timingPlan.planId integerValue] success:^{
                //网络删除成功
                [self.timingMassageArray removeObjectAtIndex:indexPath.row];
                [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
                
                [timingPlan MR_deleteEntity];
                [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
                
                [_loadingHUD hide:YES];
            } fail:^(NSDictionary *dic) {
                //网络删除失败
                
                //把数据状态变成3，表示 未同步的 删除 数据
                timingPlan.state = [NSNumber numberWithInteger:3];
                [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
                
                [self.timingMassageArray removeObjectAtIndex:indexPath.row];
                [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
                
                [_loadingHUD hide:YES];
            }];
        }
		
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 70;
}

#pragma mark - Action

- (void)addTimingMassage {
	
	UIStoryboard *mainStoryBoard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
	AddOrEditTimingMassageViewController *viewController = (AddOrEditTimingMassageViewController *)[mainStoryBoard instantiateViewControllerWithIdentifier:@"AddTimingMassage"];
	
	__weak __typeof(self) weakSelf = self;
	
	[viewController setReturnTimingMassageBlock:^(TimingMassageModel *entity) {
		[weakSelf.timingMassageArray addObject:entity];
		[weakSelf.tableView reloadData];
	}];

	[self.navigationController pushViewController:viewController animated:YES];
}

#pragma mark - TimingPlanDelegate代理

- (void)timingPlanRequestTimeOut:(TimingPlanRequest *)request {
	
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
