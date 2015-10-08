//
//  BuyRTProductTableViewController.m
//  rongtai
//
//  Created by yoghourt on 6/11/15.
//  Copyright (c) 2015 William-zhang. All rights reserved.
//

#import "BuyRTProductTableViewController.h"
#import "UIBarButtonItem+goBack.h"
#import "RongTaiConstant.h"

@interface BuyRTProductTableViewController ()<UITableViewDelegate,UITableViewDataSource>
{
    __weak IBOutlet UITableView *_tableView;
}
@end

@implementation BuyRTProductTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedString(@"我要购买", nil);
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    [self.view addSubview:_tableView];
	 self.navigationItem.leftBarButtonItem = [UIBarButtonItem goBackItemByTarget:self Action:@selector(back)];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

#pragma mark - 返回按钮方法
-(void)back
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    // Return the number of rows in the section.
    return 4;
}

//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
//	UILabel *label = [[UILabel alloc] init];
//	label.text = @"(具体产品信息由客户提供资料)";
//	label.backgroundColor = [UIColor whiteColor];
//	label.textAlignment = NSTextAlignmentCenter;
//	return label;
//}

//-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
//	return 50;
//}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BuyUITableViewCell"
									  forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
	
	UIImageView *productImageView = (UIImageView *)[cell viewWithTag:1];
//	UILabel *productModelLabel = (UILabel *)[cell viewWithTag:2];
	UILabel *productAliasLabel = (UILabel *)[cell viewWithTag:3];
	UILabel *productDescriptionLabel = (UILabel *)[cell viewWithTag:4];
	
	NSLog(@"当前行 : %d", indexPath.row);
	
	switch (indexPath.row) {
  		case 0:
			productImageView.image = [UIImage imageNamed:@"buy_device_1"];
			productAliasLabel.text = NSLocalizedString(@"未来太空舱按摩椅", nil);
			productDescriptionLabel.text = NSLocalizedString(@"未来太空舱按摩椅产品描述", nil);

			break;
		case 1:
			productImageView.image = [UIImage imageNamed:@"buy_device_2"];
			productAliasLabel.text = NSLocalizedString(@"金钻椅", nil);
			productDescriptionLabel.text = NSLocalizedString(@"金钻椅产品描述", nil);
			
			break;
		case 2:
			productImageView.image = [UIImage imageNamed:@"buy_device_3"];
			productAliasLabel.text = NSLocalizedString(@"太空舱按摩椅(香槟色)", nil);
			productDescriptionLabel.text = NSLocalizedString(@"未来太空舱按摩椅产品描述", nil);
			
			break;
		case 3:
			productImageView.image = [UIImage imageNamed:@"buy_device_4"];
			productAliasLabel.text = NSLocalizedString(@"金钻椅", nil);
			NSLog(NSLocalizedString(@"金钻椅产品描述", nil));

			break;
	}
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 126;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
