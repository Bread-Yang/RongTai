//
//  ProgramDownloadTableViewController.m
//  rongtai
//
//  Created by yoghourt on 6/14/15.
//  Copyright (c) 2015 William-zhang. All rights reserved.
//

#import "ProgramDownloadTableViewController.h"
#import "UIBarButtonItem+goBack.h"

@interface ProgramDownloadTableViewController ()

@end

@implementation ProgramDownloadTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.tableView.backgroundView = [[UIImageView alloc] initWithImage:
									 [UIImage imageNamed:@"bg"]];
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem goBackItemByTarget:self Action:@selector(goBack)];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 返回
-(void)goBack
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return 7;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ProgramDownloadUItableViewCell" forIndexPath:indexPath];
	
	UIImageView *programImageView = (UIImageView *)[cell viewWithTag:1];
	UILabel *programNameLabel = (UILabel *)[cell viewWithTag:2];
	UILabel *programDescriptionLabel = (UILabel *)[cell viewWithTag:3];
	UIImageView *downloadOrDeleteImageView = (UILabel *)[cell viewWithTag:4];
	
	switch (indexPath.row) {
  		case 0:
			programImageView.image = [UIImage imageNamed:@"mode_1"];
			programNameLabel.text = NSLocalizedString(@"韩式按摩", nil);
			break;
		case 1:
			programImageView.image = [UIImage imageNamed:@"mode_2"];
			programNameLabel.text = NSLocalizedString(@"舒展活络", nil);
			break;
		case 2:
			programImageView.image = [UIImage imageNamed:@"mode_3"];
			programNameLabel.text = NSLocalizedString(@"工作减压", nil);
			break;
		case 3:
			programImageView.image = [UIImage imageNamed:@"mode_4"];
			programNameLabel.text = NSLocalizedString(@"运动恢复", nil);
			break;
		case 4:
			programImageView.image = [UIImage imageNamed:@"mode_5"];
			programNameLabel.text = NSLocalizedString(@"消除疲劳", nil);
			break;
		case 5:
			programImageView.image = [UIImage imageNamed:@"mode_6"];
			programNameLabel.text = NSLocalizedString(@"女性纤体按摩", nil);
			break;
		case 6:
			programImageView.image = [UIImage imageNamed:@"mode_7"];
			programNameLabel.text = NSLocalizedString(@"老年按摩", nil);
			break;
		case 7:
			programImageView.image = [UIImage imageNamed:@"mode_8"];
			break;
	}
	
    
    return cell;
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
