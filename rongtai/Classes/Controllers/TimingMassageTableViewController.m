//
//  TimingMassageTableViewController.m
//  rongtai
//
//  Created by yoghourt on 6/11/15.
//  Copyright (c) 2015 William-zhang. All rights reserved.
//

#import "TimingMassageTableViewController.h"
#import "AddTimingMassageViewController.h"
#import "TimingPlanTableViewCell.h"
#import "TimingPlan.h"
#import <MagicalRecord.h>
#import "UIBarButtonItem+goBack.h"

@interface TimingMassageTableViewController ()

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
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"添加" style:UIBarButtonItemStylePlain target:self action:@selector(addTimingMassage)];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    //导航栏返回按钮设置
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem goBackItemByTarget:self Action:@selector(goBack)];
}
                    
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	
    //清空本地通知
    NSInteger number =[[UIApplication sharedApplication] scheduledLocalNotifications].count;
	
    NSLog(@"本地通知数量:%ld",number);
    NSLog(@"本地通知:%@",[[UIApplication sharedApplication] scheduledLocalNotifications]);
	
    [UIApplication sharedApplication].applicationIconBadgeNumber -= number;
    
//    [[UIApplication sharedApplication] cancelAllLocalNotifications];
//    NSLog(@"清空后本地通知数量:%ld",[[UIApplication sharedApplication]scheduledLocalNotifications].count);
    
    self.timingMassageArray = [[NSMutableArray alloc] init];
    NSArray *arr = [TimingPlan MR_findAll];
	
    NSLog(@"定时计划数量:%lud",arr.count);
	
    for (int i = 0; i < arr.count; i++) {
        TimingPlan *item = arr[i];
        [self.timingMassageArray addObject:item];
    }
    [self.tableView reloadData];
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
        [timingPlan cancelLocalNotification];
        [timingPlan MR_deleteEntity];
        [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
        
		[self.timingMassageArray removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
		
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
	AddTimingMassageViewController *viewController = (AddTimingMassageViewController *)[mainStoryBoard instantiateViewControllerWithIdentifier:@"AddTimingMassage"];
	
	__weak __typeof(self) weakSelf = self;
	
	[viewController setReturnTimingMassageBlock:^(TimingMassageModel *entity) {
		[weakSelf.timingMassageArray addObject:entity];
		[weakSelf.tableView reloadData];
	}];

	[self.navigationController pushViewController:viewController animated:YES];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
